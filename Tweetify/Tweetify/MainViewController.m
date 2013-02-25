//
//  MainViewController.m
//  Tweetify
//
//  Created by smr on 20.02.13.
//  Copyright (c) 2013 smr. All rights reserved.
//

#import "MainViewController.h"
#import "ProfileViewController.h"


@interface MainViewController ()

@end

@implementation MainViewController

@synthesize mrTimelineItems, mrMentionsItems, mrUserTweets;
@synthesize jobCell;
@synthesize mrCurrentPageIndex;
@synthesize scroll;
@synthesize accounts=_accounts;
@synthesize accountStore=_accountStore;
@synthesize account=_account;
@synthesize stream=_stream;
@synthesize refreshControl1,refreshControl2,refreshControl3;
@synthesize mrTweetSendView;
@synthesize mrAccountTweets;
@synthesize uploadedImage;
@synthesize mrUserFriends;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTweetNotification:) name:IFTweetLabelURLNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textfieldChangeText) name:UITextViewTextDidChangeNotification object:self.mrAddTwittText];
    }
    return self;
}


-(void)textfieldChangeText
{
    [self mrTweetCounterAction];
}

- (void)gotoProfile:(NSString *)profileName
{
    ProfileViewController *profile = [[[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil] autorelease];
    profile.account = self.account;
    profile.currentUserName = profileName;
    profile.mrUserFriends = self.mrUserFriends;
    [self.navigationController pushViewController:profile animated:YES];
}

- (void)handleTweetNotification:(NSNotification *)notification
{
    //NSLog(@"%@",[NSString stringWithFormat:@"%@",notification.object]);
    
    NSString * firstLetter = [[NSString stringWithFormat:@"%@",notification.object] substringToIndex:1];

    if([firstLetter isEqualToString:@"@"])
    {
        [self gotoProfile:[[NSString stringWithFormat:@"%@",notification.object] substringFromIndex:1]];
    }
    else
    {
        UIActionSheet* sheet = [[[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"%@",notification.object]
                                                            delegate:self
                                                   cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:nil] autorelease];
        
        [sheet addButtonWithTitle:@"Open Link in Safari"];
        
        sheet.tag = 8;
        [sheet showInView:self.view];
    }
}

-(void)refresh1{
    self.mrReloader1.hidden = YES;
    [self.mrTimeLineTable reloadData];
    [self.refreshControl1 endRefreshing];
}

-(void)refresh2{
    self.mrReloader2.hidden = YES;
   [self.mrMentionsTable reloadData];
    [self.refreshControl2 endRefreshing];
}

-(void)refresh3{
    self.mrReloader3.hidden = YES;
    [self.mrUserTweetsTable reloadData];
    [self.refreshControl3 endRefreshing];
}

#pragma mark - View funcs

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mrReloader1.hidden = YES;
    self.mrReloader2.hidden = YES;
    self.mrReloader3.hidden = YES;
    
    self.mrPictureSelector.tag = 99;
    self.uploadedImage = nil;
    
    self.takeController = [[[FDTakeController alloc] init]autorelease];
    self.takeController.delegate = self;

    [self mrGetAccessToTwitterAccounts];
    
    self.refreshControl1 = [[[ISRefreshControl alloc] init]autorelease];
    [self.mrTimeLineTable addSubview:self.refreshControl1];
    [self.refreshControl1 addTarget:self
                       action:@selector(refresh1)
             forControlEvents:UIControlEventValueChanged];
    
    
    self.refreshControl2 = [[[ISRefreshControl alloc] init]autorelease];
    [self.mrMentionsTable addSubview:self.refreshControl2];
    [self.refreshControl2 addTarget:self
                        action:@selector(refresh2)
              forControlEvents:UIControlEventValueChanged];
    
    
    self.refreshControl3 = [[[ISRefreshControl alloc] init]autorelease];
    [self.mrUserTweetsTable addSubview:self.refreshControl3];
    [self.refreshControl3 addTarget:self
                        action:@selector(refresh3)
              forControlEvents:UIControlEventValueChanged];
    
    /* this is temp array */
    NSArray *pages = [NSArray arrayWithObjects:self.mrView1, self.mrView2, self.mrView3, nil];
    
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    /* scroll functionality init */
    scroll.contentSize = CGSizeMake(pages.count * 320.0f, scroll.frame.size.height);
    [scroll setScrollEnabled:YES];
    [scroll setDelegate:self];
    
    
    for (int i = 0; i < pages.count; i++)
    {
        CGRect frame;
        frame.origin.x = self.scroll.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.scroll.frame.size;
        
        [[pages objectAtIndex:i] setFrame:frame];
        
        [self.scroll addSubview:[pages objectAtIndex:i]];
        
    }
}

- (void)viewDidAppear:(BOOL)animated{

    if(self.account != nil)
        [self mrGetTwDataTimeLine:self.account];
}

/* scroll action */
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    CGFloat pageWidth = self.scroll.frame.size.width;
    int page = floor((self.scroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if(page == 2)
        self.mrTweetBtn.hidden = YES;
    else
        self.mrTweetBtn.hidden = NO;
}



#pragma mark - Table functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.mrTimeLineTable)
    {
        return self.mrTimelineItems.count;
    }
    else if(tableView == self.mrMentionsTable)
    {
        return self.mrMentionsItems.count;
    }
    else if(tableView == self.mrUserTweetsTable)
    {
        return self.mrUserTweets.count;
    }
    else
        return 0;
}

-(void)gotoUserPage:(UIGestureRecognizer *)gestureRecognizer{
    
    UIView *tappedView = [gestureRecognizer.view hitTest:[gestureRecognizer locationInView:gestureRecognizer.view] withEvent:nil];
    UILabel *theLabel = (UILabel *)tappedView;
    
    NSString * firstLetter = [[NSString stringWithFormat:@"%@",theLabel.text] substringToIndex:1];
    
    if([firstLetter isEqualToString:@"@"])
        [self gotoProfile:[[NSString stringWithFormat:@"%@",theLabel.text] substringFromIndex:1]];
    else
        [self gotoProfile:[NSString stringWithFormat:@"%@",theLabel.text]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int rowIndex = indexPath.row;
    [[NSBundle mainBundle] loadNibNamed:@"customCell" owner:self options:nil];
    
    UITableViewCell *cell = jobCell;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.jobCell = nil;
    
    self.mrRemoveTweetBtn.tag = rowIndex;
    self.mrReplyTweetBtn.tag = rowIndex;
    self.mrHeaderSectionButton.tag = rowIndex;
    
    //[self.mrCellAva loadHTMLString:nil baseURL:nil];
    
    NSLog(@"table cell init");
    if(tableView == self.mrTimeLineTable)
    {
        cell.tag = 1;
        self.mrCellName.text = [[self.mrTimelineItems objectAtIndex:rowIndex]objectForKey:@"name"];
        self.mrCellUserName.text = [NSString stringWithFormat:@"%@%@",@"@",[[self.mrTimelineItems objectAtIndex:rowIndex]objectForKey:@"username"]];
        self.mrCellText.text = [[self.mrTimelineItems objectAtIndex:rowIndex]objectForKey:@"text"];
        
        /*NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[[self.mrTimelineItems objectAtIndex:rowIndex]objectForKey:@"ava"]]];
        [self.mrCellAva loadRequest:urlRequest];*/
        
        self.mrCellAva.image = [[self.mrTimelineItems objectAtIndex:rowIndex]objectForKey:@"ava"];
        
        
        self.mrCellTime.text = [self mrGetTimeStrFromDate:[[self.mrTimelineItems objectAtIndex:rowIndex]objectForKey:@"created"]];
        self.mrCellActionView.tag = 1;
        
        
        if([[[self.mrTimelineItems objectAtIndex:rowIndex]objectForKey:@"username"] isEqualToString:self.account.username])
            self.mrRemoveTweetBtn.hidden = NO;
        else
            self.mrRemoveTweetBtn.hidden = YES;
        
    }
    else if(tableView == self.mrMentionsTable)
    {
        cell.tag = 2;
        self.mrCellName.text = [[self.mrMentionsItems objectAtIndex:rowIndex]objectForKey:@"name"];
        self.mrCellUserName.text = [NSString stringWithFormat:@"%@%@",@"@",[[self.mrMentionsItems objectAtIndex:rowIndex]objectForKey:@"username"]];
        self.mrCellText.text = [[self.mrMentionsItems objectAtIndex:rowIndex]objectForKey:@"text"];
        
        self.mrCellAva.image = [[self.mrMentionsItems objectAtIndex:rowIndex]objectForKey:@"ava"];
        
        /*NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[[self.mrMentionsItems objectAtIndex:rowIndex]objectForKey:@"ava"]]];
        [self.mrCellAva loadRequest:urlRequest];*/
        
        self.mrCellTime.text = [self mrGetTimeStrFromDate:[[self.mrMentionsItems objectAtIndex:rowIndex]objectForKey:@"created"]];
        self.mrCellActionView.tag = 2;
        
        if([[[self.mrMentionsItems objectAtIndex:rowIndex]objectForKey:@"username"] isEqualToString:self.account.username])
            self.mrRemoveTweetBtn.hidden = NO;
        else
            self.mrRemoveTweetBtn.hidden = YES;
    }
    else if(tableView == self.mrUserTweetsTable)
    {
        cell.tag = 3;
        self.mrCellName.text = [[self.mrUserTweets objectAtIndex:rowIndex]objectForKey:@"name"];
        self.mrCellUserName.text = [NSString stringWithFormat:@"%@%@",@"@",[[self.mrUserTweets objectAtIndex:rowIndex]objectForKey:@"username"]];
        self.mrCellText.text = [[self.mrUserTweets objectAtIndex:rowIndex]objectForKey:@"text"];
        
        self.mrCellAva.image = [[self.mrUserTweets objectAtIndex:rowIndex]objectForKey:@"ava"];
        
        /*NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[[self.mrUserTweets objectAtIndex:rowIndex]objectForKey:@"ava"]]];
        [self.mrCellAva loadRequest:urlRequest];*/
        
        self.mrCellTime.text = [self mrGetTimeStrFromDate:[[self.mrUserTweets objectAtIndex:rowIndex]objectForKey:@"created"]];
        self.mrCellActionView.tag = 3;
        
        if([[[self.mrUserTweets objectAtIndex:rowIndex]objectForKey:@"username"] isEqualToString:self.account.username])
            self.mrRemoveTweetBtn.hidden = NO;
        else
            self.mrRemoveTweetBtn.hidden = YES;
    }
    else
    {
        self.mrCellText.text = @"";
        self.mrCellUserName.text = @"";
        self.mrCellText.text = @"";
        self.mrCellAva.image = nil;
        //[self.mrCellAva loadHTMLString:nil baseURL:nil];
    }
    
    IFTweetLabel *newLabel = [[[IFTweetLabel alloc] initWithFrame:self.mrCellText.frame] autorelease];
    newLabel.font = self.mrCellText.font;
    newLabel.text = self.mrCellText.text;
    [newLabel setNumberOfLines:0];
    [newLabel setBackgroundColor:[UIColor clearColor]];
    [newLabel setLinksEnabled:YES];
    
    [cell addSubview:newLabel];
    [self.mrCellText removeFromSuperview];
    
    
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoUserPage:)];
    [self.mrCellUserName setUserInteractionEnabled:YES];
    [self.mrCellUserName addGestureRecognizer:gesture];
    [gesture release];
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 140.00;
}



-(NSString *)mrGetTimeStrFromDate:(NSString*)date{

    NSString *returnSTR;
    
    NSDate *nowDate = [NSDate date];
    time_t unixNowTime = (time_t) [nowDate timeIntervalSince1970];
    int intNowTime = unixNowTime;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"EEE MMM d HH:mm:ss Z yyyy"];
    NSDate *dateFromString = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@",date]];
    [dateFormatter release];
    
    time_t unixTime = (time_t) [dateFromString timeIntervalSince1970];
    int intTime = unixTime;

    int mrTimeDelta = intNowTime - intTime;
    
    if(mrTimeDelta > (24 * 60 * 60))
    {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"d MMM"];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

        returnSTR = [formatter stringFromDate:dateFromString];
        
        [formatter release];
    }
    else
    {
        if(mrTimeDelta > (60 * 60))
        {
            int hours = (int)mrTimeDelta/(60 * 60);
            returnSTR = [NSString stringWithFormat:@"%dh",hours];
        }
        else if(mrTimeDelta > 60)
        {
            int minutes = (int)mrTimeDelta / 60;
            returnSTR = [NSString stringWithFormat:@"%dm",minutes];
        }
        else
        {
            int seconds = mrTimeDelta;
            returnSTR = [NSString stringWithFormat:@"%ds",seconds];
        }
    
    }

    return returnSTR;
}

-(void)mrGetAccessToTwitterAccounts
{
    // Get access to their accounts
    self.accountStore = [[[ACAccountStore alloc] init] autorelease];
    ACAccountType *accountTypeTwitter = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [self.accountStore requestAccessToAccountsWithType:accountTypeTwitter
        withCompletionHandler:^(BOOL granted, NSError *error)
        {
            if (granted && !error)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.accounts = [self.accountStore accountsWithAccountType:accountTypeTwitter];
                                         
                    if (self.accounts.count == 0)
                    {
                        [[[[UIAlertView alloc] initWithTitle:nil
                                message:@"Please add a Twitter account in the Settings app"
                                delegate:nil
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil] autorelease] show];
                    }
                    else
                    {
                        // Let them select the account they want to use
                        UIActionSheet* sheet = [[[UIActionSheet alloc] initWithTitle:@"Select your Twitter account:"
                                delegate:self
                                cancelButtonTitle:nil
                                destructiveButtonTitle:nil
                                otherButtonTitles:nil] autorelease];
                                             
                        for (ACAccount* account in self.accounts)
                        {
                          [sheet addButtonWithTitle:account.accountDescription];
                        }
                                             
                        sheet.tag = 5;
                                             
                        [sheet showInView:self.view];
                    }
                });
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSString* message = [NSString stringWithFormat:@"Error getting access to accounts : %@", [error localizedDescription]];
                [[[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
            });
        }
    }];
}



#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    switch (actionSheet.tag)
    {
        case 5:
        {
            if (buttonIndex < self.accounts.count)
            {
                [self.stream stop];
                
                [self.stream release];
                
                self.account = [self.accounts objectAtIndex:buttonIndex];
                
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate splashScreenAddActivity];
                
                [self mrGetTwDataTimeLine:self.account];
                [self mrGetTwDataMentions:self.account];
                [self mrGetTwDataUserTweets:self.account];
                
                [self mrGetUserData:self.account];
                [self mrGetUserFriends:self.account];
                
                //NSLog(@"--- account --- %@",self.account);
                
                self.stream = [[[TSUserStream alloc] initWithAccount:self.account
                                                         andDelegate:self
                                                       andAllReplies:NO
                                                    andAllFollowings:YES] autorelease];
                if (self.stream)
                    [self.stream start];
            }
        }
        break;
            
        case 6:
        {
            if(buttonIndex == 2)
            {
                BOOL isCameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
                
                if (isCameraAvailable == NO) {
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                    message:@"Camera not available"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                    return;
                }
                
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                [imagePicker setDelegate:self];
                [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
                [imagePicker setCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
                [self presentModalViewController:imagePicker animated:YES];
                [imagePicker release];

            }
            else if(buttonIndex == 1)
            {
                [self.takeController takePhotoOrChooseFromLibrary];
            }
        }
            break;
            
        case 8:
        {
            if(buttonIndex == 1)
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:actionSheet.title]];
            }
        }
            break;


            
    }
}


#pragma mark - REST API

-(void)mrGetUserFriends:(ACAccount*)account{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/friends/ids.json?screen_name=%@",self.account.username]];
    TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:nil requestMethod:TWRequestMethodGET];
    [request setAccount:account];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
     {
         if (responseData)
         {
             NSError *error;
             
             NSDictionary *mrUserInfo = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
             NSMutableArray *friendsMutable = [[[NSMutableArray alloc] init]autorelease];
             friendsMutable = [mrUserInfo objectForKey:@"ids"];
             self.mrUserFriends = [NSMutableArray arrayWithArray:friendsMutable];
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         }
         
     }];
    
    [request release];
}

-(void)mrGetUserDataStreem:(ACAccount*)account{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?screen_name=%@",self.account.username]];
    TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:nil requestMethod:TWRequestMethodGET];
    [request setAccount:account];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
     {
         if (responseData)
         {
             
             NSError *error;
             
             NSDictionary *mrUserInfo = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
             
             //NSLog(@"----------- %@",mrUserInfo);
             
             self.mrAccountName.text = [mrUserInfo objectForKey:@"name"];
             
             self.mrAccountFollow.text =  [NSString stringWithFormat:@"%@",[mrUserInfo objectForKey:@"friends_count"]];
             self.mrAccountFollowers.text = [NSString stringWithFormat:@"%@",[mrUserInfo objectForKey:@"followers_count"]];
             self.mrAccountTweets.text = [NSString stringWithFormat:@"%@",[mrUserInfo objectForKey:@"statuses_count"]];
             
             [self.mrAccountAva loadHTMLString:nil baseURL:nil];
             NSURL *url = [NSURL URLWithString:[mrUserInfo objectForKey:@"profile_image_url"]];
             NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
             [self.mrAccountAva loadRequest:urlRequest];
             
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         }
        
     }];
    
    [request release];
    
    NSURL *url2 = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/users/profile_banner.json?screen_name=%@",self.account.username]];
    TWRequest *request2 = [[TWRequest alloc] initWithURL:url2 parameters:nil requestMethod:TWRequestMethodGET];
    [request2 setAccount:account];
    [request2 performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
     {
         if (responseData)
         {
             
            [self.mrAccountBG loadHTMLString:nil baseURL:nil];
             
             NSError *error;
             
             NSDictionary *mrUserInfo = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
             
             //NSLog(@"----------- %@",mrUserInfo);
             
             NSString *BGURL = [[[mrUserInfo objectForKey:@"sizes"]objectForKey:@"mobile_retina"]objectForKey:@"url"];
             
             if(BGURL!=nil)
             {
                 NSURL *url = [NSURL URLWithString:BGURL];
                 NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
                 [self.mrAccountBG loadRequest:urlRequest];
             }
             
         }
     }];
    
    [request2 release];

}

-(void)mrGetUserData:(ACAccount*)account{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?screen_name=%@",self.account.username]];
    TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:nil requestMethod:TWRequestMethodGET];
    [request setAccount:account];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
     {
         if (responseData)
         {
             [self.mrAccountBG loadHTMLString:nil baseURL:nil];
             
             NSError *error;
             
             NSDictionary *mrUserInfo = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
             
             //NSLog(@"------ %@",mrUserInfo);
             
             self.mrAccountName.text = [mrUserInfo objectForKey:@"name"];
             
             self.mrAccountFollow.text =  [NSString stringWithFormat:@"%@",[mrUserInfo objectForKey:@"friends_count"]];
             self.mrAccountFollowers.text = [NSString stringWithFormat:@"%@",[mrUserInfo objectForKey:@"followers_count"]];
             self.mrAccountTweets.text = [NSString stringWithFormat:@"%@",[mrUserInfo objectForKey:@"statuses_count"]];
             
             [self.mrAccountAva loadHTMLString:nil baseURL:nil];
             NSURL *url = [NSURL URLWithString:[mrUserInfo objectForKey:@"profile_image_url"]];
             NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
             [self.mrAccountAva loadRequest:urlRequest];
             
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             
             AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
             [appDelegate removeSplashScreen];
         }
         else
         {
              [self mrGetAccessToTwitterAccounts];
         }
         
     }];
    
    
    [request release];
    
    NSURL *url2 = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/users/profile_banner.json?screen_name=%@",self.account.username]];
    TWRequest *request2 = [[TWRequest alloc] initWithURL:url2 parameters:nil requestMethod:TWRequestMethodGET];
    [request2 setAccount:account];
    [request2 performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
     {
         if (responseData)
         {
             //NSLog(@"------ %@",responseData);
             NSError *error;
             
             NSDictionary *mrUserInfo = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
             NSString *BGURL = [[[mrUserInfo objectForKey:@"sizes"]objectForKey:@"mobile_retina"]objectForKey:@"url"];
             
             if(BGURL!=nil)
             {
                 NSURL *url = [NSURL URLWithString:BGURL];
                 NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
                 [self.mrAccountBG loadRequest:urlRequest];
             }
             
          }
     }];
    
    [request2 release];

}


-(void)mrGetTwDataTimeLine:(ACAccount*)account{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/home_timeline.json"];
    TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:nil requestMethod:TWRequestMethodGET];
    [request setAccount:account];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
     {
         if (responseData)
         {
             NSError *error;
             
             NSArray *timeLineItems = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];

             //NSLog(@"------ %@",timeLineItems);
             NSMutableArray *timelineMutable = [[NSMutableArray alloc] init];
             
             for (int i = 0; i < timeLineItems.count; i++)
             {
                 NSDictionary * oneItemFrom = [timeLineItems objectAtIndex:i];
                 
                 NSURL *url = [NSURL URLWithString:[[oneItemFrom objectForKey:@"user"]objectForKey:@"profile_image_url"]];
                 NSData *data = [NSData dataWithContentsOfURL:url];
                 UIImage *img = [[[UIImage alloc] initWithData:data] autorelease];
                 
                 NSArray *theObjects = [NSArray arrayWithObjects:[oneItemFrom objectForKey:@"text"],
                                                                 [oneItemFrom objectForKey:@"id_str"],
                                                                [[oneItemFrom objectForKey:@"user"]objectForKey:@"name"],
                                                                [[oneItemFrom objectForKey:@"user"]objectForKey:@"screen_name"],
                                                                [oneItemFrom objectForKey:@"created_at"],
                                                                img,
                                                                nil];
                 
                 NSArray *theKeys = [NSArray arrayWithObjects:@"text", @"id", @"name", @"username", @"created", @"ava", nil];
                 NSDictionary *newItem = [NSDictionary dictionaryWithObjects:theObjects forKeys:theKeys];
                 
                
                [timelineMutable addObject:newItem];
                 
                 
             }
             
             self.mrTimelineItems = [NSMutableArray arrayWithArray:timelineMutable];
             [timelineMutable release];
             
             self.mrReloader1.hidden = YES;
             
             [self.mrTimeLineTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         }
    }];

    [request release];
}

-(void)mrGetTwDataMentions:(ACAccount*)account{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1.1/statuses/mentions_timeline.json"];
    TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:nil requestMethod:TWRequestMethodGET];
    [request setAccount:account];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
     {
         if (responseData)
         {
             NSError *error;
             
             NSArray *timeLineItems = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
             
             //NSLog(@"------ %@",timeLineItems);
             
             NSMutableArray *timelineMutable = [[NSMutableArray alloc] init];
             
             for (int i = 0; i < timeLineItems.count; i++)
             {
                 NSDictionary * oneItemFrom = [timeLineItems objectAtIndex:i];
                 
                 NSURL *url = [NSURL URLWithString:[[oneItemFrom objectForKey:@"user"]objectForKey:@"profile_image_url"]];
                 NSData *data = [NSData dataWithContentsOfURL:url];
                 UIImage *img = [[[UIImage alloc] initWithData:data] autorelease];
                 
                 NSArray *theObjects = [NSArray arrayWithObjects:[oneItemFrom objectForKey:@"text"],
                                                                 [oneItemFrom objectForKey:@"id_str"],
                                                                [[oneItemFrom objectForKey:@"user"]objectForKey:@"name"],
                                                                [[oneItemFrom objectForKey:@"user"]objectForKey:@"screen_name"],
                                                                [oneItemFrom objectForKey:@"created_at"],
                                                                img,
                                                                nil];
                 
                 NSArray *theKeys = [NSArray arrayWithObjects:@"text", @"id", @"name", @"username", @"created", @"ava", nil];
                 NSDictionary *newItem = [NSDictionary dictionaryWithObjects:theObjects forKeys:theKeys];
                 
                 
                 [timelineMutable addObject:newItem]; 
                 
             }
             
             
             self.mrMentionsItems = [NSMutableArray arrayWithArray:timelineMutable];
             [timelineMutable release];
             
             self.mrReloader2.hidden = YES;
             
             [self.mrMentionsTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         }
     }];
    
    [request release];
}


-(void)mrGetTwDataUserTweets:(ACAccount*)account{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1.1/statuses/user_timeline.json"];
    TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:nil requestMethod:TWRequestMethodGET];
    [request setAccount:account];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
     {
         if (responseData)
         {
             NSError *error;
             
             NSArray *timeLineItems = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
             
             //NSLog(@"------ %@",timeLineItems);
             
             NSMutableArray *timelineMutable = [[NSMutableArray alloc] init];
             
             for (int i = 0; i < timeLineItems.count; i++)
             {
                 NSDictionary * oneItemFrom = [timeLineItems objectAtIndex:i];
                 
                 NSURL *url = [NSURL URLWithString:[[oneItemFrom objectForKey:@"user"]objectForKey:@"profile_image_url"]];
                 NSData *data = [NSData dataWithContentsOfURL:url];
                 UIImage *img = [[[UIImage alloc] initWithData:data] autorelease];
                 
                 NSArray *theObjects = [NSArray arrayWithObjects:[oneItemFrom objectForKey:@"text"],
                                                                 [oneItemFrom objectForKey:@"id_str"],
                                                                 [[oneItemFrom objectForKey:@"user"]objectForKey:@"name"],
                                                                 [[oneItemFrom objectForKey:@"user"]objectForKey:@"screen_name"],
                                                                 [oneItemFrom objectForKey:@"created_at"],
                                                                 img,
                                                                  nil];
                 
                 NSArray *theKeys = [NSArray arrayWithObjects:@"text", @"id", @"name", @"username", @"created", @"ava", nil];
                 NSDictionary *newItem = [NSDictionary dictionaryWithObjects:theObjects forKeys:theKeys];
                 
                 
                 [timelineMutable addObject:newItem];
                 
             }
             
             
             self.mrUserTweets = [NSMutableArray arrayWithArray:timelineMutable];
             [timelineMutable release];
             
             self.mrReloader3.hidden = YES;
             
             [self.mrUserTweetsTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         }
     }];
    
    [request release];
}





#pragma mark - TSStreamDelegate

- (void)streamDidReceiveMessage:(TSStream*)stream json:(id)json {
    [TSModelParser parseJson:json
                     friends:^(TSFriendsList *model) {
                         //NSLog(@"friends --- %@",[model friendsIds]);
                     } tweet:^(TSTweet *model) {

                         NSURL *url = [NSURL URLWithString:[[model user]ava]];
                         NSData *data = [NSData dataWithContentsOfURL:url];
                         UIImage *img = [[[UIImage alloc] initWithData:data] autorelease];

                         
                         NSArray *theObjects = [NSArray arrayWithObjects:[model text],
                                                [model tweetID],
                                                [[model user] name],
                                                [[model user] screenName],
                                                [model created_at],
                                                img,
                                                nil];
                         
                         NSArray *theKeys = [NSArray arrayWithObjects:@"text", @"id", @"name", @"username", @"created", @"ava", nil];
                         NSDictionary *newItem = [NSDictionary dictionaryWithObjects:theObjects forKeys:theKeys];

                         
                         
                         if(![self.mrTimelineItems containsObject:newItem])
                             [self.mrTimelineItems insertObject:newItem atIndex:0];
                         
                         self.mrReloader1.hidden = NO;
                         
                         //[self.mrTimeLineTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                         
                         /*[self.mrTimeLineTable insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]
                                                     withRowAnimation:UITableViewRowAnimationNone];*/

                         
                         if([[[model user] screenName] isEqualToString:self.account.username])
                         {
                             if(![self.mrUserTweets containsObject:newItem])
                                 [self.mrUserTweets insertObject:newItem atIndex:0];
                             
                             self.mrReloader3.hidden = NO;
                             //[self.mrUserTweetsTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                             
                             /*[self.mrUserTweetsTable insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]
                                                         withRowAnimation:UITableViewRowAnimationNone];*/
                             
                             
                             self.mrAccountTweets.text = [NSString  stringWithFormat:@"%d",([[NSString stringWithFormat:@"%@",self.mrAccountTweets.text]integerValue] + 1)];
                         }
                         
                         NSArray *tweetMentionArray = [model userMentions];
                         
                         if(tweetMentionArray.count > 0)
                         {
                             
                             BOOL findMention = NO;
                             
                             for (int i=0; i<tweetMentionArray.count; i++)
                             {
                                 TSUser *mentionUser = [[model userMentions] objectAtIndex:i];
                                 
                                 if([[mentionUser screenName] isEqualToString:self.account.username])
                                     findMention = YES;
                             }
                             
                           
                             if(findMention)
                             {
                                 if(![self.mrMentionsItems containsObject:newItem])
                                     [self.mrMentionsItems insertObject:newItem atIndex:0];
                                 
                                 self.mrReloader2.hidden = NO;
                                 
                                 //[self.mrMentionsTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                                 
                                 /*[self.mrMentionsTable insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]]
                                                             withRowAnimation:UITableViewRowAnimationNone];*/
                             
                             }
                         }

                                                  
                     } deleteTweet:^(TSTweet *model) {
                         
                         
                         
                         for(int i=0; i<self.mrTimelineItems.count; i++)
                         {
                             if([[[self.mrTimelineItems objectAtIndex:i]objectForKey:@"id"] isEqualToString:model.deleteTwID])
                             {
                                 [self.mrTimelineItems removeObject:[self.mrTimelineItems objectAtIndex:i]];
                                 //[self.mrTimeLineTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                             }
                         }
                         
                         for(int i=0; i<self.mrMentionsItems.count; i++)
                         {
                             if([[[self.mrMentionsItems objectAtIndex:i]objectForKey:@"id"] isEqualToString:model.deleteTwID])
                             {
                                 [self.mrMentionsItems removeObject:[self.mrMentionsItems objectAtIndex:i]];
                                 //[self.mrMentionsTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                             }
                         }
                         
                         for(int i=0; i<self.mrUserTweets.count; i++)
                         {
                             if([[[self.mrUserTweets objectAtIndex:i]objectForKey:@"id"] isEqualToString:model.deleteTwID])
                             {
                                 [self.mrUserTweets removeObject:[self.mrUserTweets objectAtIndex:i]];
                                 //[self.mrUserTweetsTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                                 
                                 self.mrAccountTweets.text = [NSString  stringWithFormat:@"%d",([[NSString stringWithFormat:@"%@",self.mrAccountTweets.text]integerValue] - 1)];
                             }
                         }
                        
                     } follow:^(TSFollow *model) {
                         
                         if([model.source.screenName isEqualToString:self.account.username])
                         {
                             
                             self.mrAccountFollow.text = [NSString  stringWithFormat:@"%d",([[NSString stringWithFormat:@"%@",self.mrAccountFollow.text]integerValue] + 1)];
                             [self mrGetTwDataTimeLine:self.account];
                             
                             [self.mrUserFriends insertObject:model.target.uid atIndex:0];
                         }
                         
                         if([model.target.screenName isEqualToString:self.account.username])
                             self.mrAccountFollowers.text = [NSString  stringWithFormat:@"%d",([[NSString stringWithFormat:@"%@",self.mrAccountFollowers.text]integerValue] + 1)];
                         
                         
                         
                         //NSLog(@"@%@ Followed @%@", model.source.screenName, model.target.screenName);
                         
                     } favorite:^(TSFavorite *model) {
                         //NSLog(@"@%@ favorited tweet by @%@", model.source.screenName, model.tweet.user.screenName);
                     } unfavorite:^(TSFavorite *model) {
                         //NSLog(@"@%@ unfavorited tweet by @%@", model.source.screenName, model.tweet.user.screenName);
                     }userupdate:^(TSUser *model){
                         
                         [self mrGetUserDataStreem:self.account];
                         
                         [self mrGetTwDataTimeLine:self.account];
                         [self mrGetTwDataMentions:self.account];
                         [self mrGetTwDataUserTweets:self.account];
                         
                     } unsupported:^(id json) {
                         
                        self.mrAccountFollow.text = [NSString  stringWithFormat:@"%d",([[NSString stringWithFormat:@"%@",self.mrAccountFollow.text]integerValue] - 1)];
                        [self.mrUserFriends removeObject:[[json objectForKey:@"target"]objectForKey:@"id"]];
                         
                        [self mrGetTwDataTimeLine:self.account];
                         //NSLog(@"Unsupported : %@", json);
                     }];
}

- (void)streamDidReceiveInvalidJson:(TSStream*)stream message:(NSString*)message {
    NSLog(@"--\r\nInvalid JSON!!\r\n--");
}

- (void)streamDidTimeout:(TSStream*)stream {
    NSLog(@"--\r\nStream timeout!!\r\n--");
}

- (void)streamDidFailConnection:(TSStream *)stream {
    NSLog(@"--\r\nStream failed connection!!\r\n--");
    
    // Hack to just restart it, you'll want to handle this nicer :)
    [self.stream performSelector:@selector(start) withObject:nil afterDelay:10];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.accounts = nil;
    self.accountStore = nil;
    self.account = nil;
    self.stream = nil;
    [_mrCellName release];
    [scroll release];
    [_mrView1 release];
    [_mrView2 release];
    [_mrView3 release];
    [_mrTimeLineTable release];
    [_mrMentionsTable release];
    [_mrUserTweetsTable release];
    [_mrTweetBtn release];
    [_mrCellText release];
    [_mrCellUserName release];
    [_mrCellTime release];
    [_mrAccountName release];
    [_mrAccountFollow release];
    [_mrAccountFollowers release];
    [mrAccountTweets release];
    [mrTweetSendView release];
    [_mrAddTwittText release];
    [_mrRemoveTweetBtn release];
    [_mrCellActionView release];
    [_mrAccountBG release];
    [_mrAccountBG release];
    [_mrPictureSelector release];
    [_mrAccountAva release];
    [_mrHeaderSectionButton release];
    [_mrReloader1 release];
    [_mrReloader2 release];
    [_mrReloader3 release];
    [_mrDeleteTweetBtn release];
    [_mrTweetCounter release];
    [_mrCellAva release];
    [_mrReplyTweetBtn release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setMrCellName:nil];
    [self setScroll:nil];
    [self setMrView1:nil];
    [self setMrView2:nil];
    [self setMrView3:nil];
    [self setMrTimeLineTable:nil];
    [self setMrMentionsTable:nil];
    [self setMrUserTweetsTable:nil];
    [self setMrTweetBtn:nil];
    [self setMrCellText:nil];
    [self setMrCellUserName:nil];
    [self setMrCellTime:nil];
    [self setMrAccountName:nil];
    [self setMrAccountFollow:nil];
    [self setMrAccountFollowers:nil];
    [self setMrAccountTweets:nil];
    [self setMrTweetSendView:nil];
    [self setMrAddTwittText:nil];
    [self setMrRemoveTweetBtn:nil];
    [self setMrCellActionView:nil];
    [self setMrAccountBG:nil];
    [self setMrAccountBG:nil];
    [self setMrPictureSelector:nil];
    [self setMrAccountAva:nil];
    [self setMrHeaderSectionButton:nil];
    [self setMrReloader1:nil];
    [self setMrReloader2:nil];
    [self setMrReloader3:nil];
    [self setMrDeleteTweetBtn:nil];
    [self setMrTweetCounter:nil];
    [self setMrCellAva:nil];
    [self setMrReplyTweetBtn:nil];
    [super viewDidUnload];
}

#pragma mark - Send / Remove tweet functionality

- (IBAction)mrViewTweetView:(id)sender {
    
    self.mrDeleteTweetBtn.tag = 2;
    [self.mrTweetSendView setFrame:[[UIScreen mainScreen] bounds]];
    [self.view addSubview:self.mrTweetSendView];
    [self.view bringSubviewToFront:self.mrTweetSendView];
    
    [self mrTweetCounterAction];
    [self.mrAddTwittText becomeFirstResponder];
}

- (void)mrHideTweetView {
    
    [self.mrTweetSendView removeFromSuperview];
}

- (IBAction)mrRemoveTweetAction:(id)sender {

    NSDictionary *oneTweetRow;
    UIButton* btn = (UIButton *)sender;
    
    UIView *mrActView = btn.superview;
    
    if(mrActView.tag == 1)
    {
        oneTweetRow = [self.mrTimelineItems objectAtIndex:btn.tag];
    }
    else if(mrActView.tag == 2)
    {
        oneTweetRow = [self.mrMentionsItems objectAtIndex:btn.tag];
    }
    else
    {
        oneTweetRow = [self.mrUserTweets objectAtIndex:btn.tag];
    }

    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/destroy/%@.json",[oneTweetRow objectForKey:@"id"]]];
    TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:nil requestMethod:TWRequestMethodPOST];
    [request setAccount:self.account];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
     {
         if (responseData)
         {
             NSError *error;
             
             NSArray *twittRemoveResponse = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
             
             
             if(twittRemoveResponse != nil && twittRemoveResponse.count > 0)
             {
                 
             }
             
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         }
     }];
    
    [request release];
}


- (IBAction)mrSendTweetAction:(id)sender {
    
    [self mrSendNewAction];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
	return NO;
}

-(void)mrSendNewAction{

    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    
        NSString *tweetText = self.mrAddTwittText.text;
    
        if(tweetText.length > 140)
            tweetText = [[NSString stringWithFormat:@"%@",self.mrAddTwittText.text] substringToIndex:140];
            
    
        TWRequest *request;
       
        if (self.mrPictureSelector.tag == 100)
        {
            NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"];
            request = [[TWRequest alloc] initWithURL:url parameters:[NSDictionary dictionaryWithObject:tweetText forKey:@"status"] requestMethod:TWRequestMethodPOST];
            [request addMultiPartData:UIImagePNGRepresentation(self.uploadedImage) withName:@"media" type:@"image/jpg"];
        }
        else
        {
            NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
            request = [[TWRequest alloc] initWithURL:url parameters:[NSDictionary dictionaryWithObject:tweetText forKey:@"status"] requestMethod:TWRequestMethodPOST];
        }
        
        [request setAccount:self.account];
        
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
         {
             if (responseData)
             {
                 NSError *error;
                 
                 NSArray *twittAddResponse = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
                 
                 if(twittAddResponse != nil && twittAddResponse.count > 0)
                 {
                     self.mrPictureSelector.tag = 99;
                     [self.mrPictureSelector setBackgroundImage:nil forState:UIControlStateNormal];
                     self.uploadedImage = nil;
                 }
                 
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             }
         }];
        
        [request release];
    
    [self mrHideTweetView];
    self.mrAddTwittText.text = @"";
}


- (IBAction)mrGoToSettings:(id)sender {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate showSplashScreen];
    
    [self mrGetAccessToTwitterAccounts];
}

-(void)mrTweetCounterAction{

    NSString *tweetText = self.mrAddTwittText.text;
    
    int currentCounter = (140 - tweetText.length);
    
    if(currentCounter < 0)
        currentCounter = 0;
    
    self.mrTweetCounter.text = [NSString stringWithFormat:@"%d",currentCounter];
    
}

#pragma mark - Picture Select

- (IBAction)mrSelectPictureAction:(id)sender {
    
    UIActionSheet* sheet = [[[UIActionSheet alloc] initWithTitle:@"Picture upload"
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:nil] autorelease];
    
    [sheet addButtonWithTitle:@"Choose from gallery"];
    [sheet addButtonWithTitle:@"Take with camera"];
    
    sheet.tag = 6;
    
    [sheet showInView:self.view];
}

- (IBAction)mrCloseNewTweetPage:(id)sender {
    [self mrHideTweetView];
}

- (IBAction)mrDeleteNewTweetAction:(id)sender {
    
    NSString *tweetText = [self.mrAddTwittText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if(tweetText.length > 0 || self.mrPictureSelector.tag == 100)
    {
        self.mrDeleteTweetBtn.tag = 1;
        
        self.mrPictureSelector.tag = 99;
        [self.mrPictureSelector setBackgroundImage:nil forState:UIControlStateNormal];
        self.uploadedImage = nil;
        self.mrAddTwittText.text = @"";
    }
    else
    {
        [self mrHideTweetView];
    }
}

/* take photo from camera & goto next page */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    UIImage *cameraImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    UIImage *resultImage = [self mrResizePicture:cameraImage];
    
    [self.mrPictureSelector setBackgroundImage:resultImage forState:UIControlStateNormal];
    self.uploadedImage = resultImage;
    self.mrPictureSelector.tag = 100;
    [self dismissModalViewControllerAnimated:YES];
}

/* take photo from gallery & goto next page */
- (void)takeController:(FDTakeController *)controller gotPhoto:(UIImage *)photo withInfo:(NSDictionary *)info
{
    UIImage *resultImage = [self mrResizePicture:photo];
    
    self.mrPictureSelector.tag = 100;
    self.uploadedImage = resultImage;
    [self.mrPictureSelector setBackgroundImage:resultImage forState:UIControlStateNormal];
}

-(UIImage *)mrResizePicture:(UIImage *)inputImage{

    int max = 1000;
    UIImage *resultImage;
    CGImageRef imgRef = [inputImage CGImage];
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGRect boundsNew;
    
    if (width <= max && height <= max) {
        resultImage = inputImage;
    }
    else
    {
        if(width > height)
        {
            CGFloat ratio = width/height;
            boundsNew.size.width = max;
            boundsNew.size.height = max / ratio;
        }
        else
        {
            CGFloat ratio = height/width;
            boundsNew.size.height = max;
            boundsNew.size.width = max / ratio;
        }
    }
    
    UIGraphicsBeginImageContext(boundsNew.size);
    [inputImage drawInRect:CGRectMake(0.0, 0.0, boundsNew.size.width, boundsNew.size.height)];
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}


#pragma mark - GoTo Profile

- (IBAction)mrGoToProfile:(id)sender {
    
    UIButton* btn = (UIButton *)sender;
    
    UIView *mrView = btn.superview;
    UITableViewCell *mrCell = (UITableViewCell *)mrView;
    
    for (UIView *view in mrCell.subviews)
    {
        if ([view isKindOfClass:[UILabel class]] && view.tag == 55555)
        {
            UILabel *mrLabel = (UILabel *)view;
            
            NSString * firstLetter = [[NSString stringWithFormat:@"%@",mrLabel.text] substringToIndex:1];
            
            if([firstLetter isEqualToString:@"@"])
                [self gotoProfile:[[NSString stringWithFormat:@"%@",mrLabel.text] substringFromIndex:1]];
            else
                [self gotoProfile:[NSString stringWithFormat:@"%@",mrLabel.text]];
        
        }
    
    }
}

- (IBAction)mrReloader1action:(id)sender {
    [self refresh1];
}
- (IBAction)mrReloader2action:(id)sender {
    [self refresh2];
}
- (IBAction)mrReloader3action:(id)sender {
    [self refresh3];
}

- (IBAction)mrReplyAction:(id)sender {
   
    NSDictionary *oneTweetRow;
    UIButton* btn = (UIButton *)sender;
    
    UIView *mrActView = btn.superview;
    
    if(mrActView.tag == 1)
    {
        oneTweetRow = [self.mrTimelineItems objectAtIndex:btn.tag];
    }
    else if(mrActView.tag == 2)
    {
        oneTweetRow = [self.mrMentionsItems objectAtIndex:btn.tag];
    }
    else
    {
        oneTweetRow = [self.mrUserTweets objectAtIndex:btn.tag];
    }
    
    self.mrAddTwittText.text = [NSString stringWithFormat:@"@%@ ",[oneTweetRow objectForKey:@"username"]];
    [self mrViewTweetView:nil];
}


@end
