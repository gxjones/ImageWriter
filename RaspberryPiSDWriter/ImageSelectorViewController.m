//
//  ImageSelectorViewController.m
//  RaspberryPiSDWriter
//
//  Created by Grant Jones on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageSelectorViewController.h"
#import "AppDelegate.h"
#import "BLAuthentication.h"

@interface ImageSelectorViewController ()

@end

@implementation ImageSelectorViewController
@synthesize sourceImageView = _sourceImageView;
@synthesize targetDiskInfo = _targetDiskInfo;
@synthesize targetImageView = _targetImageView;
@synthesize progressIndicator = _progressIndicator;
@synthesize nextButton = _nextButton;
@synthesize prevButton = _prevButton;
@synthesize sourceLabel = _sourceLabel;
@synthesize targetLabel = _targetLabel;
@synthesize writeResultViewController = _writeResultViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    
    return self;
}

- (DiskUtilController *)diskUtilController {
	return [(AppDelegate *)[NSApplication sharedApplication].delegate diskUtilController];	
}
- (void)loadView {
	[super loadView];

	_targetImageView.image = [_targetDiskInfo valueForKey:@"icon"];
	_sourceImageView.updateBlock = ^{
		_sourceLabel.stringValue = [_sourceImageView.filePath lastPathComponent];
		_nextButton.enabled = TRUE;
	};
	NSString *rawDiskName = [[self diskUtilController] rawDiskName:_targetDiskInfo];
	NSString *mediaName = [_targetDiskInfo valueForKey:(NSString *)kDADiskDescriptionMediaNameKey];
	_targetLabel.stringValue = [NSString stringWithFormat:@"%@ (%@)", mediaName, rawDiskName];
	_progressIndicator.hidden = TRUE;
	_nextButton.enabled = FALSE;
}

- (void)performWrite {
#if 1
	NSString *rawDiskName = [[self diskUtilController] rawDiskName:_targetDiskInfo];
#else
	NSString *rawDiskName = @"/Users/grant/Downloads/RasPiWrite/test.bin";
#endif
	
	_progressIndicator.indeterminate = FALSE;
	_progressIndicator.minValue = 0;
	_progressIndicator.maxValue = 1;
	
	
	NSString *iwriterPath = [[NSBundle mainBundle] pathForResource:@"iwriter" ofType:nil];
	
	[[BLAuthentication sharedInstance] authenticate:iwriterPath];
	
	NSFileHandle *fh = [[BLAuthentication sharedInstance] executeCommandAsync:iwriterPath withArgs:[NSArray arrayWithObjects:_sourceImageView.filePath, rawDiskName, nil]];

	if(!fh ) {
		// user didn't authorize or something else happened.
		_progressIndicator.hidden = TRUE;
		_nextButton.enabled = TRUE;
		_prevButton.enabled = TRUE;
		return;
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(getData:) 
												 name: NSFileHandleReadCompletionNotification 
											   object: fh];
	[fh readInBackgroundAndNotify];	
}

- (void)getData:(NSNotification *)note {
	NSFileHandle *fh = [note object];
	NSData *d = [[note userInfo] valueForKey:NSFileHandleNotificationDataItem];
	if( [d length] == 0 ) {
		_progressIndicator.indeterminate = TRUE;

		[[self diskUtilController] ejectDisk:_targetDiskInfo onComplete:^{
			_writeResultViewController = [[WriteCompleteViewController alloc] initWithNibName:@"WriteCompleteViewController" bundle:nil];
			[[(AppDelegate *)[NSApplication sharedApplication].delegate navCtl] pushViewController:_writeResultViewController];
		}];
		
		return;
	}

	// XXX: hackish because we're going to just assume this string contains a nicely aligned float value as a string
	NSString *s = [NSString stringWithUTF8String:[d bytes]];
	NSString *f = [[s componentsSeparatedByString:@"\n"] objectAtIndex:0];
	
	NSScanner *scanner = [NSScanner scannerWithString:f];
	float percent = 0;
	if( [scanner scanFloat:&percent] ) {
		[_progressIndicator setDoubleValue:percent]; 	
	}
	
	[fh readInBackgroundAndNotify];
}

- (IBAction)next:(id)sender {
	_nextButton.enabled = FALSE;
	_prevButton.enabled = FALSE;
	_sourceImageView.enabled = FALSE;
	NSString *targetDeviceName = [_targetDiskInfo valueForKey:(NSString *)kDADiskDescriptionMediaNameKey];
	
	NSAlert *alert = [NSAlert alertWithMessageText:@"Confirm and Verify Action" defaultButton:@"Cancel" alternateButton:@"Continue" otherButton:nil informativeTextWithFormat:@"This program will write the source image \"%@\" to destination device \"%@\". Confirm this action is correct by selecting Continue.", _sourceImageView.filePath, targetDeviceName,nil];
	NSInteger selection = [alert runModal];
	NSLog(@"selection = %ld", selection );
	if( selection != 0 ) {
		NSLog(@"failure to confirm.");
		_nextButton.enabled = TRUE;
		_prevButton.enabled = TRUE;
		return;
	}
	
	uint64_t target_sz = [[_targetDiskInfo valueForKey:(NSString *)kDADiskDescriptionMediaSizeKey] unsignedLongLongValue];
	NSLog(@"target_sz = %llu", target_sz );
	
	NSError *err = nil;
	NSDictionary *d = [[NSFileManager defaultManager] attributesOfItemAtPath:_sourceImageView.filePath error:&err];
	if(err) {
		NSAlert *alert = [NSAlert alertWithError:err];
		[alert runModal];
		_nextButton.enabled = TRUE;
		_prevButton.enabled = TRUE;
		return;
	}
	
	uint64_t source_sz = [[d valueForKey:NSFileSize] unsignedLongLongValue];
	NSLog(@"source_sz = %llu", source_sz );

	if( source_sz > target_sz ) {
		NSAlert *alert = [NSAlert alertWithMessageText:@"Source image is too large for destination device" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Source image \"%@\" is too large for destination device \"%@\"", _sourceImageView.filePath, targetDeviceName,nil];
		[alert runModal];	
		_nextButton.enabled = TRUE;
		_prevButton.enabled = TRUE;
		return;
	}
	
	NSArray *unmountPartitions = [[self diskUtilController] partitionsOnDisk:[_targetDiskInfo valueForKey:(NSString *)kDADiskDescriptionMediaBSDNameKey]];
	_progressIndicator.hidden = FALSE;
	_progressIndicator.indeterminate = TRUE;
	[_progressIndicator startAnimation:nil];
	[[self diskUtilController] unmountDisks:unmountPartitions onComplete:^{
		[_progressIndicator stopAnimation:nil];
		[self performWrite];
	}];

}

- (IBAction)previous:(id)sender {
	[[(AppDelegate *)[NSApplication sharedApplication].delegate navCtl] popViewController];
}
@end
