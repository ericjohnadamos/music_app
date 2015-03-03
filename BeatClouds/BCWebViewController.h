//
//  BCWebViewController.h
//  BeatClouds
//
//  Created by Eric John Adamos <eric@south-soul.com> on 1/31/15.
//  Copyright (c) 2015 SouthSoul IT Solutions. All rights reserved.
//

#import <WebKit/WebKit.h>
#import <UIKit/UIKit.h>

@class BCWebViewController;
@protocol BCWebViewDelegate <NSObject>

@optional
- (void) webViewControllerDidFinishPostLoad: (BCWebViewController*) controller;

@end

@interface BCWebViewController : UIViewController <WKScriptMessageHandler>

@property (nonatomic, assign) id<BCWebViewDelegate> delegate;

- (void) initWebView;

@end
