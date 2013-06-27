/*!
 @header
 BLRTFDKeyObject.m
 Created by Max on 13.11.04.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLRTFDKeyObject.h"

@implementation BLRTFDKeyObject

+ (id)keyObjectWithKey:(NSString *)key
{
    return [[self alloc] initWithKey: key];
}

+ (Class)classOfObjects
{
    return [NSAttributedString class];
}

- (NSString *)stringForLanguage:(NSString *)lang
{
    return [[self objectForLanguage: lang] string];
}

+ (BOOL)isEmptyValue:(id)value
{
	if (![value isKindOfClass: [NSAttributedString class]])
		return YES;
	
	NSAttributedString *string = value;
	return ([string length] == 0);
}

+ (BOOL)value:(id)value isEqual:(id)other
{
	return (!value && !other) || [[value string] isEqual: [other string]];
}

- (NSString *)description
{
	NSMutableDictionary *content = [NSMutableDictionary dictionary];
	for (NSString *key in [_objects allKeys])
		[content setObject:[[_objects objectForKey: key] string] forKey:key];
	
    return [NSString stringWithFormat: @"<%@ %p>[%@] %@", NSStringFromClass([self class]), self, [self key], content];
}

@end
