//
//  DiskImageView.h
//  RaspberryPiSDWriter
//
//  Created by Grant Jones on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DiskImageView : NSImageView
@property (nonatomic,strong) NSString *filePath;
@property (nonatomic,copy) dispatch_block_t updateBlock;

@end
