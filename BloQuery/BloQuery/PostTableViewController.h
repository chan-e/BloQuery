//
//  PostTableViewController.h
//  BloQuery
//
//  Created by Eddy Chan on 8/27/16.
//  Copyright © 2016 Eddy Chan. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;

@interface PostTableViewController : UIViewController

@property (strong, nonatomic) FIRDatabaseReference *databaseRef;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
