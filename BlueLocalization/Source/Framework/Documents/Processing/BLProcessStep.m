/*!
 @header
 BLProcessStep.m
 Created by Max on 27.04.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLProcessStep.h"

#import "BLProcessManager.h"

@implementation BLProcessStep

#pragma mark - NSOperation Implementation

- (void)main {
	@autoreleasepool {

		// Perform in a secure environment
		@try {
			[self updateDescription];
			[self perform];
		}
		@catch (NSException *e) {
			// Print the error
			BLLog(BLLogError, @"Caught unhandled exception: %@\nReason: %@\nUser Info: %@", [e name], [e reason], [e userInfo]);
		}
	}
}

#pragma mark - BLProcessStep Implementation

@synthesize manager;

- (void)perform {
	[[NSException exceptionWithName:NSGenericException reason:@"-perform called on abstract superclass BLProcessStep" userInfo:nil] raise];
}

- (void)updateDescription {}

#pragma mark - Accessors

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
	return !([key isEqual:@"action"] || [key isEqual:@"description"]);
}

@synthesize action;

- (void)setAction:(NSString *)newAction {
	dispatch_async(dispatch_get_main_queue(), ^{
		[self willChangeValueForKey:@"action"];
		self->action = [newAction copy];
		[self didChangeValueForKey:@"action"];
	});
}

@synthesize description;

- (void)setDescription:(NSString *)newDescription {
	dispatch_async(dispatch_get_main_queue(), ^{
		[self willChangeValueForKey:@"description"];
		self->description = [newDescription copy];
		[self didChangeValueForKey:@"description"];
	});
}

@end
