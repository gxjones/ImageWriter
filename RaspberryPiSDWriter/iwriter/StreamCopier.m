//
//  StreamCopier.m
//  RaspberryPiSDWriter
//
//  Created by Grant Jones on 7/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StreamCopier.h"

#define kBufferSize (1024*8)

@implementation StreamCopier
@synthesize updateCB = _updateCB, completeCB = _completeCB;


- (void)copyFromPath:(NSString *)source
			  toPath:(NSString *)dest
	 withUpdateBlock:(update_block_t)updateCB
   withCompleteBlock:(dispatch_block_t)completeCB {
	
	NSError *err = nil;
	NSDictionary *sourceAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:source error:&err];
	bytes_source = [[sourceAttributes valueForKey:NSFileSize] unsignedLongLongValue];
	_updateCB = updateCB;
	_completeCB = completeCB;
	
	istream = [[NSInputStream alloc] initWithFileAtPath:source];
    [istream setDelegate:self];
    [istream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [istream open];
	
	
	// @"/Users/grant/Downloads/RasPiWrite/write_test.dat"
    ostream = [[NSOutputStream alloc] initToFileAtPath:dest append:FALSE];
    [ostream setDelegate:self];
    [ostream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [ostream open];
}


- (BOOL)readAndWrite {
//	NSLog(@"[ostream %@] [istream %@] [buffer %lu]", [ostream hasSpaceAvailable] ? @"W" : @" ", [istream hasBytesAvailable] ? @"R" : @" ", [buffer length] );
	
	if( buffer && [ostream hasSpaceAvailable] ) {
		// already read in some crap to write, use what we got...
		const uint8_t *buf = [buffer bytes];
		NSInteger len = [ostream write:buf maxLength:[buffer length]];
		bytes_written += len;
		
		if(len) {
			if( len == [buffer length] ) {
				// wrote whole buffer
				[buffer release];
				buffer = nil;
			} else {
				// wrote only part of the buffer
				//NSLog(@"partial buffer wrote %ld bytes", len);
				NSData *newBuffer = [NSData dataWithBytes:&buf[len] length:[buffer length]-len];
				[buffer release];
				buffer = newBuffer;
			}
		}
		return TRUE;
	} else if( !buffer && [istream hasBytesAvailable] ) {
		// there is data to read; read it and write it:
		uint8_t buf[kBufferSize];
		unsigned int len = 0;
		
		len = [(NSInputStream *)istream read:buf maxLength:kBufferSize];
		bytes_read += len;
		
		if(len) {
			buffer = [[NSData alloc] initWithBytes:buf length:len];
		} else {
			//NSLog(@"no buffer!");
		}
		return TRUE;
	}
	return FALSE;
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
	if( stream == istream ) {
		switch(eventCode) {
			case NSStreamEventHasBytesAvailable:
			{
				[self readAndWrite];
				double progress = ((double)bytes_written) / ((double)bytes_source);
				if( _updateCB ) {
					_updateCB( progress );
				}
				
				break;
			}
			case NSStreamEventEndEncountered:
			{
				//NSLog(@"end of stream");
				[stream close];
				[stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
				
				//NSLog(@"bytes_written = %llu bytes_read = %llu", bytes_written, bytes_read );
				if( _completeCB ) {
					_completeCB();
				}
				istream = nil; // stream is ivar, so reinit it
				break;
			}
				// continued ...
		}
	} else if( stream == ostream ) {
		// output buffer 
		switch(eventCode) {
			case NSStreamEventHasSpaceAvailable:
			{
				[self readAndWrite];
				double progress = ((double)bytes_written) / ((double)bytes_source);
				if( _updateCB ) {
					_updateCB( progress );
				}
				break;
			}
			case NSStreamEventEndEncountered:
			{
				[stream close];
				[stream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];

				ostream = nil; // oStream is instance variable
				break;
			}

		}
	}
}

@end
