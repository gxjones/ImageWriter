//
//  NavigationViewController.m
//  RaspberryPiSDWriter
//
//  Created by Grant Jones on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/*
 Really Quick 'n Dirty Implementation of a NavigationViewController to do them fancy iOS animations.
 
 */

#import "NavigationViewController.h"

@interface NavigationViewController ()

@end

@implementation NavigationViewController
@synthesize viewControllers = _viewControllers;

- (id)initWithRootViewController:(NSViewController *)rootVC
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
		_viewControllers = [[NSMutableArray alloc] initWithObjects:rootVC, nil];

    }
    
    return self;
}

- (void)loadView {
	self.view = [[NSView alloc] initWithFrame:CGRectMake( 0, 0, 100, 100 )];
	self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	NSView *v = ((NSViewController *)[_viewControllers objectAtIndex:0]).view;
	[self.view addSubview:v];
	v.frame = self.view.bounds;
	v.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
}

- (void)pushViewController:(NSViewController *)vc {
	NSViewController *prevVC = [_viewControllers lastObject];
	[_viewControllers addObject:vc];
	[self.view addSubview:vc.view];
	vc.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	
	CGRect r = prevVC.view.frame;
	r.origin.x -= self.view.bounds.size.width;
	[[prevVC.view animator] setFrame:r];

	CGRect newr = self.view.bounds;
	newr.origin.x += self.view.bounds.size.width;
	vc.view.frame = newr;
	[[vc.view animator] setFrame:self.view.bounds];

	
	double delayInSeconds = [[NSAnimationContext currentContext] duration];
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[prevVC.view removeFromSuperview];
	});
}

- (void)popViewController {
	NSViewController *prevVC = [_viewControllers lastObject];
	[_viewControllers removeLastObject];
	NSViewController *vc = [_viewControllers lastObject];
	[self.view addSubview:vc.view];
	vc.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	
	CGRect r = prevVC.view.frame;
	r.origin.x += self.view.bounds.size.width;
	[[prevVC.view animator] setFrame:r];
	
	CGRect newr = self.view.bounds;
	newr.origin.x -= self.view.bounds.size.width;
	vc.view.frame = newr;
	[[vc.view animator] setFrame:self.view.bounds];
	
	
	double delayInSeconds = [[NSAnimationContext currentContext] duration];
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[prevVC.view removeFromSuperview];
	});
}

@end
