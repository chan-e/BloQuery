//
//  PostDetailTableViewController.m
//  BloQuery
//
//  Created by Eddy Chan on 9/13/16.
//  Copyright © 2016 Eddy Chan. All rights reserved.
//

#import "PostDetailTableViewController.h"
#import "ProfileViewController.h"
#import "Post.h"
#import "PostDetailTableViewCell.h"
#import "CommentTableViewCell.h"

@import Firebase;
@import SDCAlertView;
#import "UIImageView+AFNetworking.h"

@interface PostDetailTableViewController ()

@property (strong, nonatomic) Post *post;
@property (strong, nonatomic) NSMutableArray<FIRDataSnapshot *> *comments;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRDatabaseReference *postsRef;
@property (strong, nonatomic) FIRDatabaseReference *commentsRef;
@property (strong, nonatomic) FIRDatabaseQuery *queryOrderedByVoteCount;

@end

@implementation PostDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.post = [[Post alloc] init];
    self.comments = [[NSMutableArray alloc] init];
    
    self.ref = [[FIRDatabase database] reference];
    self.postsRef = [[self.ref child:@"posts"] child:self.postKey];
    self.commentsRef = [[self.ref child:@"comments"] child:self.postKey];
    
    self.queryOrderedByVoteCount = [self.commentsRef queryOrderedByChild:@"voteCount"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 176;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self.postsRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        NSDictionary *postDict = snapshot.value;
        
        [self.post setValuesForKeysWithDictionary:postDict];
        
        [self.tableView reloadData];
        
        self.navigationItem.title = [NSString stringWithFormat:@"%@ asks...", self.post.username];
    }];
    
    // Listen for changes in comments
    [self.queryOrderedByVoteCount observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        [self.comments removeAllObjects];
        
        // Firebase returns the query ordered by vote count in ascending order
        for (FIRDataSnapshot *child in snapshot.children) {
            [self.comments insertObject:child atIndex:0];
        }
        
        [self.tableView reloadData];
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    
    [self.queryOrderedByVoteCount removeAllObservers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        // The post or question section
        return 1;
    } else {
        // The comment or answer section
        return [self.comments count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
    
    if (indexPath.section == 0) {
        // The post or question section
        PostDetailTableViewCell *postCell = (PostDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"postDetailTableViewCell" forIndexPath:indexPath];
        
        // Configure the post cell...
        postCell.postTextLabel.text = self.post.text;
        
        // Make the image view tappable
        postCell.userImageView.tag = -1;
        
        postCell.userImageView.userInteractionEnabled = YES;
        
        [postCell.userImageView addGestureRecognizer:tapGestureRecognizer];
        
        // The Post object might not be set yet
        // because of the asynchronous read from the database
        if (self.post.uid.length) {
            FIRDatabaseReference *usersRef = [[self.ref child:@"users"] child:self.post.uid];
            
            [usersRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
                NSString *profileImageURL = snapshot.value[@"profileImageURL"];
                
                if (profileImageURL.length) {
                    // Download the profile image
                    NSURL *url = [NSURL URLWithString:profileImageURL];
                    [postCell.userImageView setImageWithURL:url];
                }
            }];
        }
        
        return postCell;
    } else {
        // The comment or answer section
        CommentTableViewCell *commentCell = (CommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"commentTableViewCell" forIndexPath:indexPath];
        
        FIRDataSnapshot *snapshot = self.comments[indexPath.row];
        
        NSDictionary *comment = snapshot.value;
        
        // Configure the comment cell...
        commentCell.usernameLabel.text = comment[@"username"];
        commentCell.commentTextLabel.text = comment[@"text"];
        commentCell.voteCountLabel.text = [[comment[@"voteCount"] stringValue] stringByAppendingString:@" votes"];
        
        NSString *uid = [FIRAuth auth].currentUser.uid;
        
        NSString *imageName = [comment[@"votes"] objectForKey:uid] ? @"777-thumbs-up-toolbar-selected" : @"777-thumbs-up-toolbar";
        [commentCell.upvoteButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        
        commentCell.commentRef = snapshot.ref;
        
        // Make the image view tappable
        commentCell.userImageView.tag = indexPath.row;
        
        commentCell.userImageView.userInteractionEnabled = YES;
        
        [commentCell.userImageView addGestureRecognizer:tapGestureRecognizer];
        
        
        FIRDatabaseReference *usersRef = [[self.ref child:@"users"] child:comment[@"uid"]];
        
        [usersRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
            NSString *profileImageURL = snapshot.value[@"profileImageURL"];
            
            if (profileImageURL.length) {
                // Download the profile image
                NSURL *url = [NSURL URLWithString:profileImageURL];
                [commentCell.userImageView setImageWithURL:url];
            }
        }];
        
        return commentCell;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Gesture Recognizers

- (void)imageViewTapped:(UITapGestureRecognizer *)tapGestureRecognizer {
    NSInteger row = tapGestureRecognizer.view.tag;
    
    NSIndexPath *indexPath = nil;
    
    if (row == -1) {
        // The only image view in the post or question section was tapped
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    } else {
        // One of the image views in the comment or answer section was tapped
        indexPath = [NSIndexPath indexPathForRow:row inSection:1];
    }
    
    [self performSegueWithIdentifier:@"ShowProfileDetail" sender:indexPath];
}

#pragma mark - IBActions

- (IBAction)addComment:(id)sender {
    UITextView *textView = [[UITextView alloc] init];
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    
    SDCAlertController *alertController = [[SDCAlertController alloc] initWithTitle:@"Comment"
                                                                            message:nil
                                                                     preferredStyle:SDCAlertControllerStyleAlert];
    
    SDCAlertAction *cancelAction = [[SDCAlertAction alloc] initWithTitle:@"Cancel"
                                                                   style:SDCAlertActionStylePreferred
                                                                 handler:nil];
    
    SDCAlertAction *postAction =
    [[SDCAlertAction alloc] initWithTitle:@"Post" style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
        // This ID belongs to the post commenter
        NSString *userID = [FIRAuth auth].currentUser.uid;
        
        [[[self.ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
            NSString *username = snapshot.value[@"username"];
            NSDictionary *comment = @{@"uid": userID,
                                      @"username": username,
                                      @"text": textView.text,
                                      @"voteCount": @0};
            
            [[self.commentsRef childByAutoId] setValue:comment];
        } withCancelBlock:^(NSError *error) {
            NSLog(@"%@", error.localizedDescription);
        }];
        
        // After posting a comment to a post, increment its comment count
        // at /posts/$postKey and at /user-posts/$uid/$postKey
        
        [self incrementCommentCountForRef:self.postsRef];
        
        [self.postsRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
            // This ID belongs to the post owner
            NSString *uid = snapshot.value[@"uid"];
            
            FIRDatabaseReference *userPostsRef = [[[self.ref child:@"user-posts"] child:uid] child:self.postKey];
            
            [self incrementCommentCountForRef:userPostsRef];
        }];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:postAction];
    
    UIView *contentView = alertController.contentView;
    
    [contentView addSubview:textView];
    
    [textView.centerXAnchor constraintEqualToAnchor:contentView.centerXAnchor].active = YES;
    [textView.topAnchor constraintEqualToAnchor:contentView.topAnchor].active = YES;
    [textView.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor].active = YES;
    
    NSLayoutConstraint *textViewWidth = [NSLayoutConstraint constraintWithItem:textView
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:contentView
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:1
                                                                      constant:0];
    
    NSLayoutConstraint *textViewHeight = [NSLayoutConstraint constraintWithItem:textView
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:0
                                                                       constant:100];
    
    [contentView addConstraint:textViewWidth];
    [contentView addConstraint:textViewHeight];
    
    [alertController presentAnimated:YES completion:nil];
}

#pragma mark -

- (void)incrementCommentCountForRef:(FIRDatabaseReference *)ref {
    [ref runTransactionBlock:^FIRTransactionResult *(FIRMutableData *currentData) {
        NSMutableDictionary *post = currentData.value;
        
        if (!post || [post isEqual:[NSNull null]]) {
            return [FIRTransactionResult successWithValue:currentData];
        }
        
        int commentCount = [post[@"commentCount"] intValue];
        
        commentCount++;
        
        post[@"commentCount"] = [NSNumber numberWithInt:commentCount];
        
        [currentData setValue:post];
        
        return [FIRTransactionResult successWithValue:currentData];
    } andCompletionBlock:^(NSError *error, BOOL committed, FIRDataSnapshot *snapshot) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"ShowProfileDetail"]) {
        ProfileViewController *profileVC = segue.destinationViewController;
        
        NSIndexPath *path = sender;
        
        NSString *userID = @"";
        
        if (path.section == 0) {
            // The post or question section
            userID = self.post.uid;
        } else {
            // The comment or answer section
            FIRDataSnapshot *snapshot = self.comments[path.row];
            
            NSDictionary *comment = snapshot.value;
            
            userID = comment[@"uid"];
        }
        
        profileVC.userID = userID;
    }
}

@end
