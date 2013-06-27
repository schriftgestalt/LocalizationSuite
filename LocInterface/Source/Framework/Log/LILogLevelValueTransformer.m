/*!
 @header
 LILogLevelValueTransformer.m
 Created by Max Seelemann on 18.05.09.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "LILogLevelValueTransformer.h"

NSString *LILogLevelValueTransformerName	= @"LILevelImage";

@implementation LILogLevelValueTransformer

+ (void)load
{
	NSValueTransformer *transformer = [[self alloc] init];
	[NSValueTransformer setValueTransformer:transformer forName:LILogLevelValueTransformerName];
	
	[LIImageLoader loadImage: LIErrorImageName];
	[LIImageLoader loadImage: LIWarningImageName];
}

+ (Class)transformedValueClass
{
	return [NSImage class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)value
{
	switch ([value intValue]) {
		case BLLogError:
			return [NSImage imageNamed: LIErrorImageName];
		case BLLogWarning:
			return [NSImage imageNamed: LIWarningImageName];
		default:
			return nil;
	}
}

@end
