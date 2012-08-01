//
//  AppDelegate.m
//  RaspberryPiSDWriter
//
//  Created by Grant Jones on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize view = _view;
@synthesize navCtl = _navCtl;
@synthesize selectedMediaBSDName = _selectedMediaBSDName;
@synthesize diskUtilController = _diskUtilController;
@synthesize introViewController = _introViewController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	_diskUtilController = [[DiskUtilController alloc] init];

	_introViewController = [[IntroViewController alloc] initWithNibName:@"IntroViewController" bundle:nil];
	_navCtl = [[NavigationViewController alloc] initWithRootViewController:_introViewController];
	[_view addSubview:_navCtl.view];
	_navCtl.view.frame = _view.bounds;

	

}



- (void)applicationWillTerminate:(NSNotification *)notification {
	
}


@end
