//
//  IntroViewController.m
//  RaspberryPiSDWriter
//
//  Created by Grant Jones on 7/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IntroViewController.h"
#import "AppDelegate.h"

@interface IntroViewController ()

@end

@implementation IntroViewController
@synthesize driveSelectorViewController = _driveSelectorViewController;
@synthesize textView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)loadView {
	[super loadView];
	
	textView.string = @"WARNING: INCORRECT UES OF THIS TOOL COULD RESULT IN THE DESTRUCTION OF DATA ON ANY OF THE DRIVES ATTACHED TO YOUR COMPUTER. USE WITH CARE AND ALWAYS MAKE SURE YOU ARE WRITING TO THE CORRECT DEVICE.\n\n	This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.";
}

- (IBAction)next:(id)sender {
	_driveSelectorViewController = [[DriveSelectorViewController alloc] initWithNibName:@"DriveSelectorViewController" bundle:nil];
	[[(AppDelegate *)[NSApplication sharedApplication].delegate navCtl] pushViewController:_driveSelectorViewController];
	
}
@end
