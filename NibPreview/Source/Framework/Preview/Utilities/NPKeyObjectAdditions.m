/*!
 @header
 NPKeyObjectAdditions.m
 Created by max on 02.09.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "NPKeyObjectAdditions.h"


@implementation BLKeyObject (NPKeyObjectAdditions)

- (NSString *)nibObjectID
{
	NSUInteger pos = [self.key rangeOfString: @"."].location;
	return (pos == NSNotFound) ? nil : [self.key substringToIndex: pos];
}

- (NSString *)propertyName
{
	NSUInteger pos = [self.key rangeOfString: @"."].location;
	return (pos == NSNotFound) ? nil : [self.key substringFromIndex: pos+1];
}

@end
