//
//  PostTableViewController.m
//  BloQuery
//
//  Created by Eddy Chan on 8/27/16.
//  Copyright © 2016 Eddy Chan. All rights reserved.
//

#import "PostTableViewController.h"
#import "PostDetailTableViewController.h"
#import "ProfileViewController.h"
#import "PostDataSource.h"
#import "Post.h"
#import "PostTableViewCell.h"

@import SDCAlertView;
@import FirebaseDatabaseUI;
#import "UIImageView+AFNetworking.h"

@interface PostTableViewController () <UITableViewDelegate>

@property (strong, nonatomic) FirebaseTableViewDataSource *dataSource;

@end

@implementation PostTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.databaseRef = [[FIRDatabase database] reference];
    
    self.dataSource = [[PostDataSource alloc] initWithQuery:[self getQuery]
                                                 modelClass:[Post class]
                                   prototypeReuseIdentifier:@"postTableViewCell"
                                                       view:self.tableView];
    
    [self.dataSource populateCellWithBlock:^(PostTableViewCell *cell, Post *post) {
        cell.usernameLabel.text = post.username;
        cell.postTextLabel.text = post.text;
        cell.commentCountLabel.text = [post.commentCount.stringValue stringByAppendingString:@" comments"];
        
        // Make the image view tappable
        cell.userImageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
        [cell.userImageView addGestureRecognizer:tapGestureRecognizer];
        
        
        FIRDatabaseReference *usersRef = [[self.databaseRef child:@"users"] child:post.uid];
        
        [usersRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
            NSString *profileImageURL = snapshot.value[@"profileImageURL"];
            
            if (profileImageURL.length) {
                // Download the profile image
                NSURL *url = [NSURL URLWithString:profileImageURL];
                [cell.userImageView setImageWithURL:url];
            }
        }];
     }];
    
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 132;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (FIRDatabaseQuery *)getQuery {
    return self.databaseRef;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ShowPostDetail" sender:indexPath];
}

#pragma mark - Gesture Recognizers

- (void)imageViewTapped:(UITapGestureRecognizer *)tapGestureRecognizer {
    NSInteger row = tapGestureRecognizer.view.tag;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    
    [self performSegueWithIdentifier:@"ShowProfileDetail" sender:indexPath];
}

#pragma mark - IBActions

- (IBAction)addPost:(id)sender {
    UITextView *textView = [[UITextView alloc] init];
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    
    SDCAlertController *alertController = [[SDCAlertController alloc] initWithTitle:@"Query"
                                                                            message:nil
                                                                     preferredStyle:SDCAlertControllerStyleAlert];
    
    SDCAlertAction *cancelAction = [[SDCAlertAction alloc] initWithTitle:@"Cancel"
                                                                   style:SDCAlertActionStylePreferred
                                                                 handler:nil];
    
    SDCAlertAction *postAction =
    [[SDCAlertAction alloc] initWithTitle:@"Post" style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
        NSString *userID = [FIRAuth auth].currentUser.uid;
        
        [[[self.databaseRef child:@"users"] child:userID] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
            NSString *username = snapshot.value[@"username"];
            
            [self writeNewPost:userID username:username text:textView.text];
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

- (void)writeNewPost:(NSString *)userID username:(NSString *)username text:(NSString *)text {
    NSString *key = [[self.databaseRef child:@"posts"] childByAutoId].key;
    
    // By creating a negative created date
    // and Firebase returning sorted posts in ascending order,
    // the most recently created one will be at the top of the table view.
    NSTimeInterval timeInterval = [NSDate date].timeIntervalSince1970;
    NSNumber *createdDate = [NSNumber numberWithDouble:-timeInterval];
    
    NSDictionary *post = @{@"uid": userID,
                           @"username": username,
                           @"text": text,
                           @"commentCount": @0,
                           @"createdDate": createdDate};
    
    NSDictionary *childUpdates = @{[@"/posts/" stringByAppendingString:key]: post,
                                   [NSString stringWithFormat:@"/user-posts/%@/%@/", userID, key]: post};
    
    // Create new post at /posts/$postid
    // and at /user-posts/$userid/$postid simultaneously
    [self.databaseRef updateChildValues:childUpdates];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"ShowPostDetail"]) {
        PostDetailTableViewController *postDetailTableVC = segue.destinationViewController;
        NSIndexPath *path = sender;
        
        FIRDataSnapshot *snapshot = [self.dataSource objectAtIndex:path.row];
        postDetailTableVC.postKey = snapshot.key;
    }
    else if ([segue.identifier isEqualToString:@"ShowProfileDetail"]) {
        ProfileViewController *profileVC = segue.destinationViewController;
        NSIndexPath *path = sender;
        
        FIRDataSnapshot *snapshot = [self.dataSource objectAtIndex:path.row];
        
        NSDictionary *post = snapshot.value;
        NSString *userID = post[@"uid"];
        
        profileVC.userID = userID;
    }
}

@end
