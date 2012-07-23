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
@synthesize driveSelectorViewController = _driveSelectorViewController;
@synthesize selectedMediaBSDName = _selectedMediaBSDName;
@synthesize diskUtilController = _diskUtilController;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	_diskUtilController = [[DiskUtilController alloc] init];
	
	_driveSelectorViewController = [[DriveSelectorViewController alloc] initWithNibName:@"DriveSelectorViewController" bundle:nil];
	_navCtl = [[NavigationViewController alloc] initWithRootViewController:_driveSelectorViewController];
	[_view addSubview:_navCtl.view];
	_navCtl.view.frame = _view.bounds;

	

}



- (void)applicationWillTerminate:(NSNotification *)notification {
	
}


@end
