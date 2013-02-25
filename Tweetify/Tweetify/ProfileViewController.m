//
//  ProfileViewController.m
//  Tweetify
//
//  Created by smr on 24.02.13.
//  Copyright (c) 2013 smr. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

@synthesize jobCell;
@synthesize mrUserTweets;
@synthesize refreshControl3;
@synthesize currentUserName;
@synthesize account;
@synthesize mrUserFriends;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)gotoProfile:(NSString *)profileName
{
    if(![self.currentUserName isEqualToString:profileName])
    {
        ProfileViewController *profile = [[[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil] autorelease];
        profile.account = self.account;
        profile.currentUserName = profileName;
        [self.navigationController pushViewController:profile animated:YES];
    }
}

-(void)refresh3{
    
    [self mrGetTwDataUserTweets:self.currentUserName];
    [self.refreshControl3 endRefreshing];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.mrFollowBtn.hidden = YES;
    [self.mrFollowBtn setTitle:@"" forState:UIControlStateNormal];
    self.mrFollowBtn.tag = 0;
   
    self.mrAccountName.text = @"";
    self.mrAccountFollow.text =  @"";
    self.mrAccountFollowers.text = @"";
    self.mrAccountTweets.text = @"";
    [self.mrAccountAva loadHTMLString:nil baseURL:nil];
    [self.mrAccountBG loadHTMLString:nil baseURL:nil];

    
    self.refreshControl3 = [[[ISRefreshControl alloc] init]autorelease];
    [self.mrUserTweetsTable addSubview:self.refreshControl3];
    [self.refreshControl3 addTarget:self
                             action:@selector(refresh3)
                   forControlEvents:UIControlEventValueChanged];
    
    
    [self mrGetTwDataUserTweets:self.currentUserName];
    [self mrGetUserData:self.currentUserName];

}

-(void)mrGetUserData:(NSString*)accountName{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?screen_name=%@",accountName]];
    TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:nil requestMethod:TWRequestMethodGET];
    [request setAccount:self.account];
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
             
             if([self.mrUserFriends containsObject:[mrUserInfo objectForKey:@"id"]])
             {
                 [self.mrFollowBtn setTitle:@"following" forState:UIControlStateNormal];
                 self.mrFollowBtn.tag = 2;
             }
             else
             {
                 [self.mrFollowBtn setTitle:@"follow" forState:UIControlStateNormal];
                 self.mrFollowBtn.tag = 1;
             }
             
             if([self.currentUserName isEqualToString:self.account.username])
                 self.mrFollowBtn.hidden = YES;
             else
                 self.mrFollowBtn.hidden = NO;
             
             
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         }
         else
         {
             [self.navigationController popViewControllerAnimated:YES];
         }
         
     }];
    
    
    [request release];
    
    NSURL *url2 = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/users/profile_banner.json?screen_name=%@",accountName]];
    TWRequest *request2 = [[TWRequest alloc] initWithURL:url2 parameters:nil requestMethod:TWRequestMethodGET];
    [request2 setAccount:self.account];
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


-(void)mrGetTwDataUserTweets:(NSString*)accountName{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1.1/statuses/user_timeline.json"];
    TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:[NSDictionary dictionaryWithObject:accountName forKey:@"screen_name"] requestMethod:TWRequestMethodGET];
    [request setAccount:self.account];
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
             
             [self.mrUserTweetsTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
             
             [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
         }
     }];
    
    [request release];
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


- (IBAction)mrRemoveTweetAction:(id)sender {
    
    UIButton* btn = (UIButton *)sender;
    NSDictionary *oneTweetRow = [self.mrUserTweets objectAtIndex:btn.tag];
    
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


#pragma mark - Table functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mrUserTweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int rowIndex = indexPath.row;
    [[NSBundle mainBundle] loadNibNamed:@"customProfileCell" owner:self options:nil];
    
    UITableViewCell *cell = jobCell;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.jobCell = nil;
    
    self.mrRemoveTweetBtn.tag = rowIndex;
    self.mrHeaderSectionButton.tag = rowIndex;
    
    
    self.mrCellName.text = [[self.mrUserTweets objectAtIndex:rowIndex]objectForKey:@"name"];
    self.mrCellUserName.text = [NSString stringWithFormat:@"%@%@",@"@",[[self.mrUserTweets objectAtIndex:rowIndex]objectForKey:@"username"]];
    self.mrCellText.text = [[self.mrUserTweets objectAtIndex:rowIndex]objectForKey:@"text"];
    
    self.mrCellAva.image = [[self.mrUserTweets objectAtIndex:rowIndex]objectForKey:@"ava"];
        
    self.mrCellTime.text = [self mrGetTimeStrFromDate:[[self.mrUserTweets objectAtIndex:rowIndex]objectForKey:@"created"]];
    self.mrCellActionView.tag = 3;
        
    if([[[self.mrUserTweets objectAtIndex:rowIndex]objectForKey:@"username"] isEqualToString:self.account.username])
        self.mrRemoveTweetBtn.hidden = NO;
    else
        self.mrRemoveTweetBtn.hidden = YES;
    
    
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_mrAccountBG release];
    [_mrAccountAva release];
    [_mrAccountName release];
    [_mrAccountFollow release];
    [_mrAccountFollowers release];
    [_mrAccountTweets release];
    [_mrUserTweetsTable release];
    [_mrCellName release];
    [_mrCellUserName release];
    [_mrCellText release];
    [_mrCellTime release];
    [_mrRemoveTweetBtn release];
    [_mrCellActionView release];
    [_mrHeaderSectionButton release];
    [_mrFollowBtn release];
    [_mrCellAva release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setMrAccountBG:nil];
    [self setMrAccountAva:nil];
    [self setMrAccountName:nil];
    [self setMrAccountFollow:nil];
    [self setMrAccountFollowers:nil];
    [self setMrAccountTweets:nil];
    [self setMrUserTweetsTable:nil];
    [self setMrCellName:nil];
    [self setMrCellUserName:nil];
    [self setMrCellText:nil];
    [self setMrCellTime:nil];
    [self setMrRemoveTweetBtn:nil];
    [self setMrCellActionView:nil];
    [self setMrHeaderSectionButton:nil];
    [self setMrFollowBtn:nil];
    [self setMrCellAva:nil];
    [super viewDidUnload];
}

- (IBAction)mrCloseAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)mrFollowAction:(id)sender {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    if(self.mrFollowBtn.tag == 1)
    {
        [self.mrFollowBtn setTitle:@"following" forState:UIControlStateNormal];
        self.mrFollowBtn.tag = 2;
        
        NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/create.json"];
        TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:[NSDictionary dictionaryWithObject:self.currentUserName forKey:@"screen_name"] requestMethod:TWRequestMethodPOST];
        [request setAccount:self.account];
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
         {
             if (responseData)
             {
                 //NSError *error;
                 //NSArray *response = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
                          
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             }
         }];
    
        [request release];
    }
    else if(self.mrFollowBtn.tag == 2)
    {
        
        [self.mrFollowBtn setTitle:@"follow" forState:UIControlStateNormal];
        self.mrFollowBtn.tag = 1;
        
        NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/friendships/destroy.json"];
        TWRequest *request = [[TWRequest alloc] initWithURL:url parameters:[NSDictionary dictionaryWithObject:self.currentUserName forKey:@"screen_name"] requestMethod:TWRequestMethodPOST];
        [request setAccount:self.account];
        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
         {
             if (responseData)
             {
                 //NSError *error;
                 //NSArray *response = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
                 
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             }
         }];
        
        [request release];
    }
    else
    {
        NSLog(@"ERROR!!!");
    }
}

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

@end
