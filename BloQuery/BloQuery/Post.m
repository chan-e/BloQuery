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
    return [self initWithUid:@"" andUsername:@"" andText:@""];
}

- (instancetype)initWithUid:(NSString *)uid
                andUsername:(NSString *)username
                    andText:(NSString *)text {
    self = [super init];
    
    if (self) {
        self.uid = uid;
        self.username = username;
        self.text = text;
    }
    
    return self;
}

@end
