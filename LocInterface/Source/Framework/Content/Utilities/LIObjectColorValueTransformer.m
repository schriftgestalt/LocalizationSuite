/*!
 @header
 LIObjectColorValueTransformer.m
 Created by max on 09.05.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "LIObjectColorValueTransformer.h"

NSString *LIObjectColorValueTransformerName = @"LIObjectColor";

@implementation LIObjectColorValueTransformer

+ (void)load {
	NSValueTransformer *transformer = [[self alloc] init];
	[NSValueTransformer setValueTransformer:transformer forName:LIObjectColorValueTransformerName];
}

+ (Class)transformedValueClass {
	return [NSColor class];
}

- (id)transformedValue:(id)value {
	BLObject *object;

	if (![value isKindOfClass:[BLObject class]])
		return [NSColor controlTextColor];
	object = (BLObject *)value;

	if ([[object errors] count] > 0)
		return [NSColor redColor];
	else if ([object isKindOfClass:[BLBundleObject class]])
		return [NSColor disabledControlTextColor];
	else
		return [NSColor controlTextColor];
}

@end
