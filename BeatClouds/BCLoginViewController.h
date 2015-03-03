//
//  BCLoginViewController.h
//  BeatClouds
//
//  Created by Eric John Adamos <eric@south-soul.com> on 1/23/15.
//  Copyright (c) 2015 SouthSoul IT Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@class BCLoginViewController;

@protocol BCLoginViewDelegate <NSObject>

@optional
- (void) loginViewControllerDidLogin: (BCLoginViewController*) controller;
- (void) loginViewControllerDidLogout: (BCLoginViewController*) controller;
- (void) loginViewController: (BCLoginViewController*) controller
            didFetchUserInfo: (id<FBGraphUser>)        user;
- (void) loginViewController: (BCLoginViewController*) controller
                didShowError: (NSError*)               error;

@end

@interface BCLoginViewController : UIViewController

@property (nonatomic, assign) id<BCLoginViewDelegate> delegate;

@end
