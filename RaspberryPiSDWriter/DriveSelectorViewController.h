//
//  DriveSelectorViewController.h
//  RaspberryPiSDWriter
//
//  Created by Grant Jones on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ImageSelectorViewController.h"
#import "DiskUtilController.h"

@interface DriveSelectorViewController : NSViewController <DiskUtilControllerListDelegate>
@property (weak) IBOutlet NSTableView *tableView;

@property (strong) ImageSelectorViewController *imageSelectorViewController;
@property (weak) IBOutlet NSButton *nextButton;

- (IBAction)next:(id)sender;
- (IBAction)prev:(id)sender;
- (DiskUtilController *)diskUtilController;

@end
