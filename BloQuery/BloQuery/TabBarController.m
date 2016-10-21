//
//  TabBarController.m
//  BloQuery
//
//  Created by Eddy Chan on 10/3/16.
//  Copyright © 2016 Eddy Chan. All rights reserved.
//

#import "TabBarController.h"
#import "ProfileViewController.h"

@import Firebase;

@interface TabBarController () <UITabBarControllerDelegate>

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    NSUInteger selectedIndex = tabBarController.selectedIndex;
    
    if (selectedIndex == 1) {
        // Selected the Profile tab
        UINavigationController *navigationVC = (UINavigationController *)viewController;
        
        ProfileViewController *profileVC = (ProfileViewController *)navigationVC.topViewController;
        
        NSString *userID = [FIRAuth auth].currentUser.uid;
        
        profileVC.userID = userID;
    }
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
