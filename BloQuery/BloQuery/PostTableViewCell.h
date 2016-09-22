//
//  PostTableViewCell.h
//  BloQuery
//
//  Created by Eddy Chan on 9/11/16.
//  Copyright © 2016 Eddy Chan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *postTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;

@end
