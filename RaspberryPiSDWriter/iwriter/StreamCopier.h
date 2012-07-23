//
//  StreamCopier.h
//  RaspberryPiSDWriter
//
//  Created by Grant Jones on 7/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^update_block_t)(float percent);

@interface StreamCopier : NSObject <NSStreamDelegate> {
	NSInputStream *istream;
	NSOutputStream *ostream;
	
	NSData *buffer;
	
	uint64_t bytes_source;
	uint64_t bytes_written;
	uint64_t bytes_read;
}

@property (nonatomic,copy) update_block_t updateCB;
@property (nonatomic,copy) dispatch_block_t completeCB;

- (void)copyFromPath:(NSString *)source toPath:(NSString *)dest withUpdateBlock:(update_block_t)updateCB withCompleteBlock:(dispatch_block_t)completeCB;

@end
