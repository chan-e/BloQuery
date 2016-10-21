//
//  PostDataSource.m
//  BloQuery
//
//  Created by Eddy Chan on 9/10/16.
//  Copyright © 2016 Eddy Chan. All rights reserved.
//

#import "PostDataSource.h"
#import "PostTableViewCell.h"

@implementation PostDataSource

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostTableViewCell *cell = (PostTableViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    cell.userImageView.tag = indexPath.row;
    
    return cell;
}

@end
