//
//  AppDelegate.h
//  Tweetify
//
//  Created by smr on 20.02.13.
//  Copyright (c) 2013 smr. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIImageView* splashView;
@property (strong, nonatomic) UINavigationController *mainNavi;

- (void)removeSplashScreen;
- (void)splashScreenAddActivity;
- (void)showSplashScreen;

@end
