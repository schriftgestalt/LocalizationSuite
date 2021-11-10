/*!
 @header
 NPLazyStringValue.h
 Created by max on 18.07.08.

 @copyright 2008-2009 Localization Suite. All rights reserved.
 */

#import "NPLazyStringValue.h"

@implementation NPLazyStringValue

+ (id)valueWithString:(NSString *)string {
	return [[[self class] alloc] initWithString:string];
}

- (id)initWithString:(NSString *)string {
	self = [super init];

	_string = string;

	return self;
}

#pragma mark - Accessors

- (NSSize)sizeValue {
	return NSSizeFromString(_string);
}

- (NSPoint)pointValue {
	return NSPointFromString(_string);
}

- (NSRect)rectValue {
	return NSRectFromString(_string);
}

- (NSRange)rangeValue {
	return NSRangeFromString(_string);
}

@end
