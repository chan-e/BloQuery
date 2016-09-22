//
//  RecentPostsTableViewController.m
//  BloQuery
//
//  Created by Eddy Chan on 9/11/16.
//  Copyright © 2016 Eddy Chan. All rights reserved.
//

#import "RecentPostsTableViewController.h"

@interface RecentPostsTableViewController ()

@end

@implementation RecentPostsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (FIRDatabaseQuery *)getQuery {
    FIRDatabaseQuery *recentPostsQuery = [[self.databaseRef child:@"posts"] queryLimitedToLast:25];
    
    return recentPostsQuery;
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
