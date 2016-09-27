//
//  CommentTableViewCell.m
//  BloQuery
//
//  Created by Eddy Chan on 9/16/16.
//  Copyright © 2016 Eddy Chan. All rights reserved.
//

#import "CommentTableViewCell.h"

@implementation CommentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - IBActions

- (IBAction)upvoteComment:(id)sender {
    [self.commentRef runTransactionBlock:^FIRTransactionResult *(FIRMutableData *currentData) {
        NSMutableDictionary *comment = currentData.value;
        if (!comment || [comment isEqual:[NSNull null]]) {
            return [FIRTransactionResult successWithValue:currentData];
        }
        
        NSMutableDictionary *votes = [comment objectForKey:@"votes"];
        if (!votes) {
            votes = [[NSMutableDictionary alloc] initWithCapacity:1];
        }
        
        NSString *uid = [FIRAuth auth].currentUser.uid;
        
        int voteCount = [comment[@"voteCount"] intValue];
        
        if ([votes objectForKey:uid]) {
            // "Downvote" the comment and remove self from votes
            voteCount--;
            [votes removeObjectForKey:uid];
        } else {
            // Upvote the comment and add self to votes
            voteCount++;
            votes[uid] = @YES;
        }
        
        comment[@"votes"] = votes;
        comment[@"voteCount"] = [NSNumber numberWithInt:voteCount];
        
        [currentData setValue:comment];
        
        return [FIRTransactionResult successWithValue:currentData];
    } andCompletionBlock:^(NSError *error, BOOL committed, FIRDataSnapshot *snapshot) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

@end
