//
//  IntroViewController.h
//  RaspberryPiSDWriter
//
//  Created by Grant Jones on 7/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DriveSelectorViewController.h"

@interface IntroViewController : NSViewController
@property (strong) DriveSelectorViewController *driveSelectorViewController;
@property (unsafe_unretained) IBOutlet NSTextView *textView;

- (IBAction)next:(id)sender;
@end
