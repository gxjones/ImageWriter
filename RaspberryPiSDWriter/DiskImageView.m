//
//  DiskImageView.m
//  RaspberryPiSDWriter
//
//  Created by Grant Jones on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DiskImageView.h"

@implementation DiskImageView
@synthesize filePath = _filePath;
@synthesize updateBlock = _updateBlock;

- (void)viewWillMoveToSuperview:(NSView *)newSuperview {
	_filePath = nil;
	[self registerForDraggedTypes:[NSArray arrayWithObjects: NSFilenamesPboardType, nil]];	
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
	
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];

    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
		return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
	
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
	
	if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		
        // Depending on the dragging source and modifier keys,
        // the file data may be copied or linked
		_filePath = [files objectAtIndex:0];
		self.image = [[NSWorkspace sharedWorkspace] iconForFile:_filePath];
		if( _updateBlock ) {
			_updateBlock();
		}
	}
    return YES;
}

@end
