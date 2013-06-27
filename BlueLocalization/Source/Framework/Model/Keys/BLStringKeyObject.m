/*!
 @header
 BLStringKeyObject.m
 Created by Max on 13.11.04.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLStringKeyObject.h"

@implementation BLStringKeyObject

+ (id)keyObjectWithKey:(NSString *)key
{
    return [[self alloc] initWithKey: key];
}

+ (Class)classOfObjects
{
    return [NSString class];
}

+ (BOOL)isEmptyValue:(id)value
{
	if (![value isKindOfClass: [NSString class]])
		return YES;
	
	NSString *string = value;
	return string == nil || ![string length] || ([string rangeOfCharacterFromSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]].length == [string length]);
}

@end
