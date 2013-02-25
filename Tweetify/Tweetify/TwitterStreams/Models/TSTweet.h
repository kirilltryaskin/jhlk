//
//  TSTweet.h
//  TwitterStreams
//
//  Created by Stuart Hall on 6/03/12.
//  Copyright (c) 2012 Stuart Hall. All rights reserved.
//

#import "TSModel.h"
#import "TSUser.h"
#import "TSUrl.h"
#import "TSHashtag.h"

@interface TSTweet : TSModel

- (NSString*)text;
- (NSString*)created_at;
- (NSString*)tweetID;

- (TSUser*)user;
- (NSArray*)userMentions;
- (NSArray*)urls;
- (NSArray*)hashtags;

@property (nonatomic, retain) NSString* deleteTwID;

@end
