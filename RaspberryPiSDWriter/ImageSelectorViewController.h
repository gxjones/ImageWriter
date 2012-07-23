//
//  ImageSelectorViewController.h
//  RaspberryPiSDWriter
//
//  Created by Grant Jones on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DiskImageView.h"
#import "WriteCompleteViewController.h"

@interface ImageSelectorViewController : NSViewController

@property (nonatomic,strong) NSDictionary *targetDiskInfo;

@property (weak) IBOutlet DiskImageView *sourceImageView;
@property (weak) IBOutlet NSImageView *targetImageView;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSButton *nextButton;
@property (weak) IBOutlet NSButton *prevButton;
@property (weak) IBOutlet NSTextField *sourceLabel;
@property (weak) IBOutlet NSTextField *targetLabel;
@property (nonatomic,strong) WriteCompleteViewController *writeResultViewController;

- (IBAction)next:(id)sender;
- (IBAction)previous:(id)sender;
@end
