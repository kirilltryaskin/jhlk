//
//  ProfileViewController.h
//  Tweetify
//
//  Created by smr on 24.02.13.
//  Copyright (c) 2013 smr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "ISRefreshControl.h"

#import "IFTweetLabel.h"

@interface ProfileViewController : UIViewController<UIActionSheetDelegate>{

    NSMutableArray *mrUserTweets;
    UITableViewCell *jobCell;
    
    NSString*currentUserName;
    
    NSMutableArray *mrUserFriends;
}

@property (retain, nonatomic) IBOutlet UIWebView *mrAccountBG;
@property (retain, nonatomic) IBOutlet UIWebView *mrAccountAva;
@property (retain, nonatomic) IBOutlet UILabel *mrAccountName;
@property (retain, nonatomic) IBOutlet UILabel *mrAccountFollow;
@property (retain, nonatomic) IBOutlet UILabel *mrAccountFollowers;
@property (retain, nonatomic) IBOutlet UILabel *mrAccountTweets;
@property (retain, nonatomic) IBOutlet UITableView *mrUserTweetsTable;
- (IBAction)mrGoToProfile:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *mrHeaderSectionButton;

@property (nonatomic, assign) IBOutlet UITableViewCell *jobCell;
@property (nonatomic, retain) NSMutableArray *mrUserTweets;
@property (nonatomic, retain) NSString*currentUserName;
@property (nonatomic, retain) NSMutableArray *mrUserFriends;

@property (nonatomic, retain) ISRefreshControl *refreshControl3;
- (IBAction)mrCloseAction:(id)sender;
- (IBAction)mrFollowAction:(id)sender;
@property (nonatomic, retain) ACAccount* account;
- (void)mrGetUserData:(NSString*)accountName;
-(void)mrGetTwDataUserTweets:(NSString*)accountName;
- (IBAction)mrRemoveTweetAction:(id)sender;
-(NSString *)mrGetTimeStrFromDate:(NSString*)date;
- (void)gotoProfile:(NSString *)profileName;
@property (retain, nonatomic) IBOutlet UIButton *mrFollowBtn;

@property (retain, nonatomic) IBOutlet UIView *mrCellActionView;

@property (retain, nonatomic) IBOutlet UILabel *mrCellName;
@property (retain, nonatomic) IBOutlet UILabel *mrCellUserName;
@property (retain, nonatomic) IBOutlet UILabel *mrCellText;
@property (retain, nonatomic) IBOutlet UILabel *mrCellTime;
@property (retain, nonatomic) IBOutlet UIButton *mrRemoveTweetBtn;
@property (retain, nonatomic) IBOutlet UIImageView *mrCellAva;

@end
