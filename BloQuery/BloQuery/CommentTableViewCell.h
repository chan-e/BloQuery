//
//  CommentTableViewCell.h
//  BloQuery
//
//  Created by Eddy Chan on 9/16/16.
//  Copyright © 2016 Eddy Chan. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Firebase;

@interface CommentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (weak, nonatomic) IBOutlet UIButton *upvoteButton;

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *voteCountLabel;

@property (strong, nonatomic) FIRDatabaseReference *commentRef;

@end
