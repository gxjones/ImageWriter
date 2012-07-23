//
//  DiskSizeFormatter.m
//  RaspberryPiSDWriter
//
//  Created by Grant Jones on 7/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DiskSizeFormatter.h"

@implementation DiskSizeFormatter
- (NSString *)stringForObjectValue:(id)obj {
	if(![obj isKindOfClass:[NSNumber class]] ) {
		return [super stringForObjectValue:obj];
	}
	double i = [obj doubleValue];
	NSString *unit = @"Bytes";
	
	
	if( i >= 1000 ) {
		unit = @"KB";
		i = i / 1000;
	}
	if( i >= 1000 ) {
		unit = @"MB";
		i = i / 1000;
	}
	if( i >= 1000 ) {
		unit = @"GB";
		i = i / 1000;
	}
	if( i >= 1000 ) {
		unit = @"TB";
		i = i / 1000;
	}
	
	
	
	NSNumber *newNum = [NSNumber numberWithInteger:roundf(i)];
	return [NSString stringWithFormat:@"%@ %@", [super stringForObjectValue:newNum], unit];
}



@end
