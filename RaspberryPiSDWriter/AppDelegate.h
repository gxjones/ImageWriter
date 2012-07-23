//
//  AppDelegate.h
//  RaspberryPiSDWriter
//
//  Created by Grant Jones on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NavigationViewController.h"
#import "DriveSelectorViewController.h"
#import "DiskUtilController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate> {

}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSView *view;
@property (nonatomic,strong) NSString *selectedMediaBSDName;
@property (nonatomic,strong) NavigationViewController *navCtl;
@property (nonatomic,strong) DiskUtilController *diskUtilController;

@property (strong) DriveSelectorViewController *driveSelectorViewController;

@end
