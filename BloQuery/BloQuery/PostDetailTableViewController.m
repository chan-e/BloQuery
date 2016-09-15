//
//  PostDetailTableViewController.m
//  BloQuery
//
//  Created by Eddy Chan on 9/13/16.
//  Copyright © 2016 Eddy Chan. All rights reserved.
//

#import "PostDetailTableViewController.h"
#import "Post.h"
#import "PostDetailTableViewCell.h"
@import SDCAlertView;
@import Firebase;

@interface PostDetailTableViewController ()

@property (strong, nonatomic) Post *post;
@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRDatabaseReference *postsRef;
@property (strong, nonatomic) FIRDatabaseReference *commentsRef;
@property (assign, nonatomic) FIRDatabaseHandle databaseHandle;

@end

@implementation PostDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.post = [[Post alloc] init];
    
    self.ref = [[FIRDatabase database] reference];
    self.postsRef = [[self.ref child:@"posts"] child:self.postKey];
    self.commentsRef = [[self.ref child:@"comments"] child:self.postKey];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 88;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.databaseHandle = [self.postsRef observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        NSDictionary *postDict = snapshot.value;
        
        [self.post setValuesForKeysWithDictionary:postDict];
        
        [self.tableView reloadData];
        
        self.navigationItem.title = [NSString stringWithFormat:@"%@ asks...", self.post.username];
    }];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    
    [self.postsRef removeObserverWithHandle:self.databaseHandle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"postDetailTableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    PostDetailTableViewCell *postCell = (PostDetailTableViewCell *)cell;
    
    //postCell.userImageView.image = [UIImage imageNamed:@""];
    postCell.postTextLabel.text = self.post.text;
    
    return cell;
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
        NSString *userID = [FIRAuth auth].currentUser.uid;
        
        [[[self.ref child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
            NSString *username = snapshot.value[@"username"];
            NSDictionary *comment = @{@"uid": userID,
                                      @"username": username,
                                      @"text": textView.text};
            
            [[self.commentsRef childByAutoId] setValue:comment];
        } withCancelBlock:^(NSError *error) {
            NSLog(@"%@", error.localizedDescription);
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
