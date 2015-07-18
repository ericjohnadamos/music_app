//
//  BCModalDismissSegue.m
//  BeatClouds
//
//  Created by Eric John Adamos on 2/21/15.
//  Copyright (c) 2015 SouthSoul IT Solutions. All rights reserved.
//

#import "BCModalDismissSegue.h"

@implementation BCModalDismissSegue

- (void) perform
{
  UIViewController* sourceViewController = self.sourceViewController;
  
  if ([sourceViewController.presentingViewController isBeingPresented])
  {
    [sourceViewController.presentingViewController
     dismissViewControllerAnimated: YES
                        completion: nil];
  }
}

@end
