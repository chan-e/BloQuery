//
//  Post.m
//  BloQuery
//
//  Created by Eddy Chan on 9/11/16.
//  Copyright © 2016 Eddy Chan. All rights reserved.
//

#import "Post.h"

@implementation Post

- (instancetype)init {
    return [self initWithUid:@"" andUsername:@"" andText:@"" andCommentCount:@0 andCreatedDate:@0];
}

- (instancetype)initWithUid:(NSString *)uid
                andUsername:(NSString *)username
                    andText:(NSString *)text
            andCommentCount:(NSNumber *)commentCount
             andCreatedDate:(NSNumber *)createdDate {
    
    self = [super init];
    
    if (self) {
        self.uid = uid;
        self.username = username;
        self.text = text;
        self.commentCount = commentCount;
        self.createdDate = createdDate;
    }
    
    return self;
}

@end
