//
//  ProfileViewController.m
//  BloQuery
//
//  Created by Eddy Chan on 9/29/16.
//  Copyright © 2016 Eddy Chan. All rights reserved.
//

#import "ProfileViewController.h"
#import "EditProfileViewController.h"

@import Firebase;
#import "UIImageView+AFNetworking.h"

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (strong, nonatomic) FIRDatabaseReference *ref;
@property (strong, nonatomic) FIRDatabaseReference *usersRef;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.ref = [[FIRDatabase database] reference];
    self.usersRef = [[self.ref child:@"users"] child:self.userID];
    
    // Only the account owner can edit his/her profile
    NSString *currentUserID = [FIRAuth auth].currentUser.uid;
    if ([currentUserID isEqualToString:self.userID]) {
        self.editButton.enabled = YES;
        self.editButton.title = @"Edit";
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self.usersRef observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot *snapshot) {
        NSDictionary *user = snapshot.value;
        
        self.usernameLabel.text = user[@"username"];
        self.descriptionLabel.text = user[@"description"];
        
        NSString *profileImageURL = user[@"profileImageURL"];
        
        if (profileImageURL.length) {
            // Download the profile image
            NSURL *url = [NSURL URLWithString:profileImageURL];
            [self.userImageView setImageWithURL:url];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"ShowEditProfile"]) {
        EditProfileViewController *editProfileVC = segue.destinationViewController;
        
        editProfileVC.userID = self.userID;
    }
    
}

@end
