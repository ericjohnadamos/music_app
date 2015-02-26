//
//  BCWebViewController.m
//  BeatClouds
//
//  Created by Eric John Adamos <eric@south-soul.com> on 1/31/15.
//  Copyright (c) 2015 SouthSoul IT Solutions. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "BCWebViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "UserSettings.h"

@interface BCWebViewController ()
  <WKNavigationDelegate, UIBarPositioningDelegate>

@property (nonatomic, strong) WKWebView* webview;

@end

@implementation BCWebViewController

#pragma mark - Synthesize

@synthesize webview = m_webview;

#pragma mark - Lifecycle

- (void) viewDidLoad
{
  [super viewDidLoad];
  
  NSString* URLString = @"http://beatclouds.south-soul.com/html/1.0";
  NSURLRequest* request
    = [NSURLRequest requestWithURL: [NSURL URLWithString: URLString]
                       cachePolicy: NSURLRequestReloadIgnoringCacheData
                   timeoutInterval: 60];
  [self.webview loadRequest: request];
  
  [self.view addSubview: self.webview]; 
}

#pragma mark - Property implementation

- (WKWebView*) webview
{
  if (m_webview == nil)
  {
    WKUserContentController* controller
      = [[WKUserContentController alloc] init];
    [controller addScriptMessageHandler: self
                                   name: @"observe"];
    WKWebViewConfiguration* configuration
      = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = controller;
    
    CGRect frame = self.view.frame;
    frame.origin.y = 20.0f;
    frame.size.height -= 20.0f;
    
    m_webview = [[WKWebView alloc] initWithFrame: frame
                                   configuration: configuration];
    
    m_webview.scrollView.scrollEnabled = NO;
    
    m_webview.navigationDelegate = self;
  }
  return m_webview;
}

- (void)                webView: (WKWebView*)                         webView
decidePolicyForNavigationAction: (WKNavigationAction*)                action
                decisionHandler: (void (^)(WKNavigationActionPolicy)) handler
{
  NSURL* url = action.request.URL;
  NSString* urlString = url.path;
  
  if (urlString.length > 0 && [urlString isEqualToString: @"/html/1.0/logout"])
  {
    handler(WKNavigationActionPolicyCancel);
    
    if (   FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended)
    {
      [FBSession.activeSession closeAndClearTokenInformation];
    }
    
    [UserSettings sharedInstance].token = nil;
    
    [self dismissViewControllerAnimated: YES
                             completion: nil];
    
    return;
  }
  handler(WKNavigationActionPolicyAllow);
}

- (UIBarPosition) positionForBar: (id <UIBarPositioning>) bar
{
  return UIBarPositionTopAttached;
}

- (void) userContentController: (WKUserContentController*) userContentController
       didReceiveScriptMessage: (WKScriptMessage*)         message
{
  if ([message.name isEqualToString:@"observe"])
  {
    NSString* token = [UserSettings sharedInstance].token;
    
    NSLog(@"Token %@", token);
    
    NSString* template = @"setToken(\"%@\");";
    NSString* javascriptFunction = [NSString stringWithFormat: template, token];
    
    [self.webview evaluateJavaScript: javascriptFunction
                   completionHandler: nil];
  }
}

@end
