//
//  DiskUtilController.m
//  RaspberryPiSDWriter
//
//  Created by Grant Jones on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DiskUtilController.h"
CFURLRef KextManagerCreateURLForBundleIdentifier( CFAllocatorRef allocator, CFStringRef kextIdentifier);

static void OnDiskAppeared(DADiskRef disk, void *ctx) {
	DiskUtilController *ad = (__bridge DiskUtilController *)ctx;
	[ad addDisk:disk];
}

static void OnDiskDisappeared(DADiskRef disk, void *ctx) {
	DiskUtilController *ad = (__bridge DiskUtilController *)ctx;
//	NSDictionary *descDict = (__bridge_transfer NSDictionary *)DADiskCopyDescription(disk);
	[ad removeDisk:disk];
}

static void UnmountCallback( DADiskRef disk, DADissenterRef dissenter, void * context ) {
	if( dissenter ) {
		NSLog(@"UnmountCallback dissenter: %@", DADissenterGetStatusString(dissenter) );
	}
	DiskUtilController *ad = (__bridge DiskUtilController *)context;
	[ad unmountComplete];
}
static void EjectCallback( DADiskRef disk, DADissenterRef dissenter, void * context ) {
	if( dissenter ) {
		NSLog(@"EjectCallback dissenter: %@", DADissenterGetStatusString(dissenter) );
	}
	DiskUtilController *ad = (__bridge DiskUtilController *)context;
	[ad ejectComplete];
}
@implementation DiskUtilController
@synthesize listDelegate;
@synthesize rootDisks, disks;
@synthesize rootDisplayName, rootVolumeDeviceUnit;

- (id)init
{
    self = [super init];
    if (self) {
		disks = [[NSMutableArray alloc] init];
		rootDisks = [[NSMutableArray alloc] init];
		
		rootDisplayName = [[NSFileManager defaultManager] displayNameAtPath:@"/"];
		rootVolumeDeviceUnit = 0;
		
		// Set up session.
		session = DASessionCreate(kCFAllocatorDefault);
		DARegisterDiskAppearedCallback(session, NULL/*all disks*/, OnDiskAppeared, (__bridge void *)self);
		DARegisterDiskDisappearedCallback(session, NULL, OnDiskDisappeared, (__bridge void *)self);
		
		DASessionScheduleWithRunLoop(session, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);


    }
    return self;
}


- (void)dealloc
{
	DASessionUnscheduleFromRunLoop(session, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);	
    
}
- (void)removeDisk:(DADiskRef)disk {
	NSDictionary *descDict = (__bridge_transfer NSDictionary *)DADiskCopyDescription(disk);
	
	for( NSDictionary *q in [NSArray arrayWithArray:disks] ) {
		if( [[descDict valueForKey:@"DAMediaPath"] isEqualToString:[q valueForKey:@"DAMediaPath"]] ) {
			[disks removeObject:q];
		}
	}
	for( NSDictionary *q in [NSArray arrayWithArray:rootDisks] ) {
		if( [[descDict valueForKey:@"DAMediaPath"] isEqualToString:[q valueForKey:@"DAMediaPath"]] ) {
			[rootDisks removeObject:q];
		}
	}
	if( [self.listDelegate respondsToSelector:@selector(disksChanged:)] ) {
		[self.listDelegate performSelector:@selector(disksChanged:) withObject:self];
	}
}



- (void)addDisk:(DADiskRef)disk {
	NSDictionary *descDict = (__bridge_transfer NSDictionary *)DADiskCopyDescription(disk);

	for( NSDictionary *q in disks ) {
		if( [[descDict valueForKey:@"DAMediaPath"] isEqualToString:[q valueForKey:@"DAMediaPath"]] ) {
			// already in list
			return;
		}
	}
	
	if( ![[descDict valueForKey:(NSString *)kDADiskDescriptionMediaWritableKey] boolValue] ) {
		// disk must be writable
		return;
	}
	
	NSString *bundleID = [[descDict valueForKey:@"DAMediaIcon"] valueForKey:@"CFBundleIdentifier"];
	NSURL *bundleURL = (__bridge_transfer NSURL *)KextManagerCreateURLForBundleIdentifier( NULL, CFBridgingRetain(bundleID) );
	if( bundleURL ) {
		NSBundle *b = [NSBundle bundleWithURL:bundleURL];
		NSURL *iconURL = [b URLForResource:[[descDict valueForKey:@"DAMediaIcon"] valueForKey:@"IOBundleResourceFile"] withExtension:nil];
		NSImage *img = [[NSImage alloc] initWithContentsOfURL:iconURL];

		if( [[descDict valueForKey:(NSString *)kDADiskDescriptionVolumeNameKey] isEqualToString:rootDisplayName] ) {
			// we've found the root volume but we want the actual device unit:
			rootVolumeDeviceUnit = [[descDict valueForKey:(NSString *)kDADiskDescriptionMediaBSDUnitKey] intValue];
		}
		
		NSMutableDictionary *md = [NSMutableDictionary dictionaryWithDictionary:descDict];
		[md setValue:img forKey:@"icon"];

		[disks addObject:md];
		[rootDisks addObject:md];
//		if( ![[descDict valueForKey:(NSString *)kDADiskDescriptionMediaLeafKey] boolValue] ) {
//			[rootDisks addObject:md];
//		}
		
		if( [self.listDelegate respondsToSelector:@selector(disksChanged:)] ) {
			[self.listDelegate performSelector:@selector(disksChanged:) withObject:self];
		}
	}

}
- (NSString *)rawDiskName:(NSDictionary *)diskInfo {
	int mediaBSDUnit = [[diskInfo valueForKey:(NSString *)kDADiskDescriptionMediaBSDUnitKey] intValue];
	return [NSString stringWithFormat:@"/dev/rdisk%d", mediaBSDUnit];
}

- (BOOL)isRootDisk:(NSDictionary *)diskInfo {
	if( [[diskInfo valueForKey:(NSString *)kDADiskDescriptionMediaBSDUnitKey] intValue] == rootVolumeDeviceUnit ) {
		return TRUE;
	}
	return FALSE;
}

- (NSArray *)partitionsOnDisk:(NSString *)BSDName {
	NSMutableArray *result = [[NSMutableArray alloc] init];
	
	for( NSDictionary *q in [NSArray arrayWithArray:disks] ) {
		if( ![[q valueForKey:(NSString *)kDADiskDescriptionMediaBSDNameKey] hasPrefix:BSDName] ) {
			continue;
		}
		
		if( ![[q valueForKey:(NSString *)kDADiskDescriptionMediaLeafKey] boolValue] ) {
			continue;
		}
		
		[result addObject:q];
	}

	return result;
}

- (void)unmountDisks:(NSArray *)dlist onComplete:(dispatch_block_t)cb {
	if(remaining_unmounts > 0) {
		return;
	}
	remaining_unmounts = [dlist count];
	unmount_finish_block = cb;
	for( NSDictionary *diskInfo in dlist ) {
		const char *BSDName = [[diskInfo valueForKey:(NSString *)kDADiskDescriptionMediaBSDNameKey] UTF8String];
		DADiskRef disk = DADiskCreateFromBSDName(NULL, session, BSDName);
//		NSLog(@"disk = %@", diskInfo);
		DADiskUnmount( disk, kDADiskUnmountOptionDefault, UnmountCallback, (__bridge void *)self);	
	}
}
- (void)unmountComplete {
	remaining_unmounts --;
	if( remaining_unmounts == 0 ){
		if(unmount_finish_block) {
			unmount_finish_block();
			unmount_finish_block = nil;
		}
	}
}



- (void)ejectDisk:(NSDictionary *)diskInfo onComplete:(dispatch_block_t)cb {
	eject_finish_block = cb;
	const char *BSDName = [[diskInfo valueForKey:(NSString *)kDADiskDescriptionMediaBSDNameKey] UTF8String];
	DADiskRef disk = DADiskCreateFromBSDName(NULL, session, BSDName);
	DADiskEject( disk, kDADiskEjectOptionDefault, EjectCallback, (__bridge void *)self);	
}
- (void)ejectComplete {
	if( eject_finish_block ) {
		eject_finish_block();
		eject_finish_block = nil;
	}
}

@end
