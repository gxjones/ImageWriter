//
//  DriveSelectorViewController.m
//  RaspberryPiSDWriter
//
//  Created by Grant Jones on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DriveSelectorViewController.h"
#import "AppDelegate.h"


@interface DriveSelectorViewController ()

@end

@implementation DriveSelectorViewController

@synthesize tableView;
@synthesize imageSelectorViewController = _imageSelectorViewController;
@synthesize nextButton;

- (DiskUtilController *)diskUtilController {
	return [(AppDelegate *)[NSApplication sharedApplication].delegate diskUtilController];	
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		[self diskUtilController].listDelegate = self;
    }
    
    return self;
}
- (void)loadView {
	[super loadView];
	self.nextButton.enabled = FALSE;
}
- (void)disksChanged:(DiskUtilController *)duc {
	[self.tableView deselectAll:nil];
	[self.tableView reloadData];	
}

- (IBAction)next:(id)sender {
	int row = [self.tableView selectedRow];
	if( row < 0 ) {
		return;
	}

	_imageSelectorViewController = [[ImageSelectorViewController alloc] initWithNibName:@"ImageSelectorViewController" bundle:nil];
	_imageSelectorViewController.targetDiskInfo = [[self diskUtilController].rootDisks objectAtIndex:row];
	
	[[(AppDelegate *)[NSApplication sharedApplication].delegate navCtl] pushViewController:_imageSelectorViewController];
}


- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	NSCell *displayCell = cell;
	NSDictionary *descDict = [[self diskUtilController].rootDisks objectAtIndex:row];
	BOOL rootDisk = [[self diskUtilController] isRootDisk:descDict];

	displayCell.enabled = !rootDisk;
}
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
	NSDictionary *descDict = [[self diskUtilController].rootDisks objectAtIndex:row];
	return ![[self diskUtilController] isRootDisk:descDict];
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {

	return [[self diskUtilController].rootDisks count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	return [[[self diskUtilController].rootDisks objectAtIndex:row] valueForKey:tableColumn.identifier];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
	int row = [self.tableView selectedRow];
	if( row < 0 ) {
		self.nextButton.enabled = FALSE;
		return;
	}
	
	nextButton.enabled = TRUE;
	
}


@end
