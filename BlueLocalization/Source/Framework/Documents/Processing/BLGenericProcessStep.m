//
//  BLGenericProcessStep.m
//  BlueLocalization
//
//  Created by Max Seelemann on 09.05.09.
//  Copyright 2009 The Blue Technologies Group. All rights reserved.
//

#import "BLGenericProcessStep.h"


@interface BLGenericProcessStep ()

- (id)initWithBlock:(BLGenericBlock)block;

@end


@implementation BLGenericProcessStep

+ (id)genericStepWithBlock:(BLGenericBlock)block
{
	return [[self alloc] initWithBlock: block];
}

- (id)initWithBlock:(BLGenericBlock)block
{
	self = [super init];
	
	if (self) {
		self.action = NSLocalizedStringFromTableInBundle(@"Processing", @"BLProcessStep", [NSBundle bundleForClass: [self class]], nil);
		_block = [block copy];
	}
	
	return self;
}

- (void)perform
{
	_block();
}

@end
