//
//  CommentTableViewCell.h
//  BloQuery
//
//  Created by Eddy Chan on 9/16/16.
//  Copyright © 2016 Eddy Chan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIImageView *upvoteImageView;

@property (weak, nonatomic) IBOutlet UILabel *commentTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *voteCountLabel;

@end
