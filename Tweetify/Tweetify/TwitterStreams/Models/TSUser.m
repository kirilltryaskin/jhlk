//
//  TSUser.m
//  TwitterStreams
//
//  Created by Stuart Hall on 6/03/12.
//  Copyright (c) 2012 Stuart Hall. All rights reserved.
//

#import "TSUser.h"

@implementation TSUser

- (NSString*)screenName {
    return [self.dictionary objectForKey:@"screen_name"];
}

- (NSString*)name {
    return [self.dictionary objectForKey:@"name"];
}

- (NSString*)ava{
    return [self.dictionary objectForKey:@"profile_image_url"];
}

- (NSString*)uid{
    return [self.dictionary objectForKey:@"id"];
}


@end
