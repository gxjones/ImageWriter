//
//  NavigationViewController.h
//  RaspberryPiSDWriter
//
//  Created by Grant Jones on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NavigationViewController : NSViewController

@property (nonatomic,strong) NSMutableArray *viewControllers;

- (id)initWithRootViewController:(NSViewController *)rootVC;
- (void)pushViewController:(NSViewController *)vc;
- (void)popViewController;

@end
