//
//  DiskUtilController.h
//  RaspberryPiSDWriter
//
//  Created by Grant Jones on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DiskUtilController;
@protocol DiskUtilControllerListDelegate <NSObject>
- (void)disksChanged:(DiskUtilController *)duc;

@end

@interface DiskUtilController : NSObject {
	DASessionRef session;	
	
	uint32_t remaining_unmounts;
	dispatch_block_t unmount_finish_block;
	dispatch_block_t eject_finish_block;
}

@property (nonatomic,assign) id <DiskUtilControllerListDelegate> listDelegate;
@property (nonatomic,strong) NSMutableArray *rootDisks;
@property (nonatomic,strong) NSMutableArray *disks;
@property (nonatomic,strong) NSString *rootDisplayName;
@property (nonatomic,assign) int rootVolumeDeviceUnit;

- (void)removeDisk:(DADiskRef)disk;
- (void)addDisk:(DADiskRef)disk;
- (NSArray *)partitionsOnDisk:(NSString *)BSDName;
- (void)unmountDisks:(NSArray *)dlist onComplete:(dispatch_block_t)b;
- (void)unmountComplete;
- (void)ejectDisk:(NSDictionary *)diskInfo onComplete:(dispatch_block_t)cb;
- (void)ejectComplete;
- (BOOL)isRootDisk:(NSDictionary *)diskInfo;
- (NSString *)rawDiskName:(NSDictionary *)diskInfo;
@end
