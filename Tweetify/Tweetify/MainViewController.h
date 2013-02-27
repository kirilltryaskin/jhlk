//
//  MainViewController.h
//  Tweetify
//
//  Created by smr on 20.02.13.
//  Copyright (c) 2013 smr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import "TSUserStream.h"
#import "TSFilterStream.h"

#import "TSModelParser.h"

#import "NSArray+Enumerable.h"
#import "ISRefreshControl.h"
#import "FDTakeController.h"

#import "IFTweetLabel.h"

@interface MainViewController : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate, TSStreamDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FDTakeDelegate>{

    NSMutableArray *mrTimelineItems;
    NSMutableArray *mrMentionsItems;
    NSMutableArray *mrUserTweets;
    
    NSMutableArray *mrUserFriends;
    
    
    UITableViewCell *jobCell;
    
    UIImage *uploadedImage;
    
    int mrLinkLen;
}

@property int mrLinkLen;

-(NSArray *)mrGetReplarray:(NSString *)text:(NSString *)twUserName;
-(void)loadUserInformation;
@property (retain, nonatomic) IBOutlet UIButton *mrSendTweetBtn;
@property (retain, nonatomic) IBOutlet UILabel *mrCellRetweetLabel;

@property (retain, nonatomic) IBOutlet UIButton *mrDeleteTweetBtn;
@property (retain, nonatomic) IBOutlet UIButton *mrReloader1;
- (IBAction)mrReloader1action:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *mrReloader2;
- (IBAction)mrReloader2action:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *mrReloader3;
- (IBAction)mrReloader3action:(id)sender;
- (IBAction)mrCloseNewTweetPage:(id)sender;
- (IBAction)mrDeleteNewTweetAction:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *mrTweetCounter;
@property (retain, nonatomic) IBOutlet UIImageView *mrCellAva;
- (IBAction)mrReplyAction:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *mrReplyTweetBtn;

@property (retain, nonatomic) FDTakeController *takeController;

@property (retain, nonatomic) IBOutlet UILabel *mrHeaderSectionButton;

@property (retain, nonatomic) IBOutlet UILabel *mrAccountName;
@property (retain, nonatomic) IBOutlet UILabel *mrAccountFollow;
@property (retain, nonatomic) IBOutlet UILabel *mrAccountFollowers;
@property (retain, nonatomic) IBOutlet UILabel *mrAccountTweets;

@property (nonatomic, assign) IBOutlet UITableViewCell *jobCell;

@property (nonatomic, retain) NSMutableArray *mrTimelineItems;
@property (nonatomic, retain) NSMutableArray *mrMentionsItems;
@property (nonatomic, retain) NSMutableArray *mrUserTweets;
@property (nonatomic, retain) NSMutableArray *mrUserFriends;


@property int mrCurrentPageIndex;

@property (retain, nonatomic) IBOutlet UILabel *mrCellTime;
@property (retain, nonatomic) IBOutlet UILabel *mrCellUserName;
@property (retain, nonatomic) IBOutlet UILabel *mrCellText;
@property (retain, nonatomic) IBOutlet UILabel *mrCellName;
@property (retain, nonatomic) IBOutlet UIScrollView *scroll;


@property (retain, nonatomic) IBOutlet UIView *mrView1;
@property (retain, nonatomic) IBOutlet UIView *mrView2;
@property (retain, nonatomic) IBOutlet UIView *mrView3;
@property (retain, nonatomic) IBOutlet UITableView *mrTimeLineTable;
@property (retain, nonatomic) IBOutlet UITableView *mrMentionsTable;
@property (retain, nonatomic) IBOutlet UITableView *mrUserTweetsTable;

@property (retain, nonatomic) IBOutlet UIButton *mrTweetBtn;

@property (retain, nonatomic) IBOutlet UIView *mrCellActionView;
@property (retain, nonatomic) UIImage *uploadedImage;


@property (nonatomic, retain) NSArray* accounts;
@property (nonatomic, retain) ACAccountStore* accountStore;
@property (nonatomic, retain) ACAccount* account;
@property (nonatomic, retain) TSStream* stream;

-(void)mrGetAccessToTwitterAccounts;
-(void)mrGetTwDataTimeLine:(ACAccount*)account;
-(void)mrGetTwDataMentions:(ACAccount*)account;
-(void)mrGetTwDataUserTweets:(ACAccount*)account;
-(void)mrGetUserData:(ACAccount*)account;
-(void)mrGetUserDataStreem:(ACAccount*)account;
-(void)mrGetAccessToTwitterAccountsAggain;

@property (retain, nonatomic) IBOutlet UIWebView *mrAccountBG;
- (IBAction)mrViewTweetView:(id)sender;
-(NSString *)mrGetTimeStrFromDate:(NSString*)date;
-(BOOL)textFieldShouldReturn:(UITextField *)textField;

-(void)refresh1;
-(void)refresh2;
-(void)refresh3;

@property (nonatomic, retain) ISRefreshControl *refreshControl1;
@property (nonatomic, retain) ISRefreshControl *refreshControl2;
@property (nonatomic, retain) ISRefreshControl *refreshControl3;

@property (retain, nonatomic) IBOutlet UIView *mrTweetSendView;
@property (retain, nonatomic) IBOutlet UITextView *mrAddTwittText;
@property (retain, nonatomic) IBOutlet UIButton *mrRemoveTweetBtn;
@property (retain, nonatomic) IBOutlet UIWebView *mrAccountAva;
@property (retain, nonatomic) IBOutlet UIButton *mrPictureSelector;

- (IBAction)mrSendTweetAction:(id)sender;
- (IBAction)mrSelectPictureAction:(id)sender;

- (void)mrSendNewAction;
- (void)mrHideTweetView;
- (IBAction)mrRemoveTweetAction:(id)sender;
- (void)mrGetUserFriends:(ACAccount*)account;


- (IBAction)mrGoToSettings:(id)sender;
- (void)gotoUserPage:(UIGestureRecognizer *)gestureRecognizer;
- (IBAction)mrGoToProfile:(id)sender;

-(UIImage *)mrResizePicture:(UIImage *)inputImage;

-(void)mrTweetCounterAction;
-(void)textfieldChangeText;
-(void)mrTwitLen:(ACAccount*)account;


@end
