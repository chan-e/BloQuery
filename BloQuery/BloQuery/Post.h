//
//  Post.h
//  BloQuery
//
//  Created by Eddy Chan on 9/11/16.
//  Copyright © 2016 Eddy Chan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Post : NSObject

@property(strong, nonatomic) NSString *uid;
@property(strong, nonatomic) NSString *username;
@property(strong, nonatomic) NSString *text;
@property(strong, nonatomic) NSNumber *commentCount;
@property(strong, nonatomic) NSNumber *createdDate;

- (instancetype)initWithUid:(NSString *)uid
                andUsername:(NSString *)username
                    andText:(NSString *)text
            andCommentCount:(NSNumber *)commentCount
             andCreatedDate:(NSNumber *)createdDate;

@end
