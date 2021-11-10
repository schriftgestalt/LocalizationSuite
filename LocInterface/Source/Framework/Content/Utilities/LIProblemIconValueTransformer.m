/*!
 @header
 LIProblemIconValueTransformer.m
 Created by max on 30.08.09.

 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "LIProblemIconValueTransformer.h"

NSString *LIProblemIconValueTransformerName = @"LIProblemIcon";

@implementation LIProblemIconValueTransformer

+ (void)load {
	NSValueTransformer *transformer = [[self alloc] init];
	[NSValueTransformer setValueTransformer:transformer forName:LIProblemIconValueTransformerName];
}

+ (void)initialize {
	[LIImageLoader loadImage:LIWarningImageName];
	[LIImageLoader loadImage:LIErrorImageName];
}

+ (Class)transformedValueClass {
	return [NSImage class];
}

- (id)transformedValue:(id)value {
	switch ([value intValue]) {
		case LTTranslationProblemWarning:
			return [NSImage imageNamed:LIWarningImageName];
		case LTTranslationProblemError:
			return [NSImage imageNamed:LIErrorImageName];
		default:
			return nil;
	}
}

@end