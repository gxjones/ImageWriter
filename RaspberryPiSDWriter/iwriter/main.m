// gcc -framework Foundation main.m StreamCopier.m -o iwriter
//
//  ImageSelectorViewController.m
//  RaspberryPiSDWriter
//
//  Created by Grant Jones on 7/22/12.
//  Copyright (c) 2012 Grant Jones. All rights reserved.
//
//
//  Sort of like dd but prints out the progress of the transfer


#import <Foundation/Foundation.h>
#import "StreamCopier.h"

int main( int argc, char *argv[] ) {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	StreamCopier *sc = [[StreamCopier alloc] init];
	static int running = 1;
	static float lastProgress = 0;
	if(argc != 3) {
		NSLog(@"requires [source arg] [destination arg]");
		return -1;
	}
	NSString *source = [NSString stringWithUTF8String:argv[1]];
	NSString *dest = [NSString stringWithUTF8String:argv[2]];

	[sc	copyFromPath:source
			  toPath:dest
	 withUpdateBlock:^(float p) { lastProgress = p; }
   withCompleteBlock:^{ running = 0; }];

	const CFTimeInterval kForOneSecond = 1.0;
	const Boolean kAndReturnAfterHandlingSource = TRUE;
	CFAbsoluteTime lt = CFAbsoluteTimeGetCurrent();
	while(running) {
    	(void)CFRunLoopRunInMode(kCFRunLoopDefaultMode, kForOneSecond, kAndReturnAfterHandlingSource);
    	CFAbsoluteTime t = CFAbsoluteTimeGetCurrent();
    	if( t - lt > 0.1 ) {
    		printf("%f\n", lastProgress);
    		fflush(stdout);	
    		lt = t;
    	}
	}
	[pool drain];
	return 0;
}