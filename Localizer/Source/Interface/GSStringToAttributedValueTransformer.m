//
//  GSStringToAttributedValueTransformer.m
//  LocInterface
//
//  Created by Georg Seifert on 22.08.19.
//  Copyright © 2019 Localization Suite. All rights reserved.
//

#import "GSStringToAttributedValueTransformer.h"

@implementation GSStringToAttributedValueTransformer

+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (Class)transformedValueClass {
	return [NSAttributedString class];
}

- (NSAttributedString*)transformedValue:(NSString*)value {
	if (!value) {
		return nil;
	}
	if ([value isKindOfClass:[NSAttributedString class]])
		value = [(NSAttributedString*)value string];
	return [[NSAttributedString alloc] initWithString:value attributes:@{NSFontAttributeName: [NSFont systemFontOfSize:15], NSForegroundColorAttributeName: [NSColor textColor]}];
}

- (NSString*)reverseTransformedValue:(NSAttributedString*)value {
	if (!value) {
		return nil;
	}
	if ([value isKindOfClass:[NSString class]])
		return (NSString*)value;
	return [value string];
}
@end
