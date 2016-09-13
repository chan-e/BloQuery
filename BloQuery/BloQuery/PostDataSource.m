//
//  PostDataSource.m
//  BloQuery
//
//  Created by Eddy Chan on 9/10/16.
//  Copyright © 2016 Eddy Chan. All rights reserved.
//

#import "PostDataSource.h"

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

@end
