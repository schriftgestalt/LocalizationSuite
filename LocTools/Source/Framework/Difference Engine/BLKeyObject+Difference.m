//
//  BLKeyObject+Difference.m
//  LocTools
//
//  Created by Peter Kraml on 30.11.13.
//  Copyright (c) 2013 Localization Suite. All rights reserved.
//

#import "BLKeyObject+Difference.h"
#import "LTStringDiffer.h"

@implementation BLKeyObject (Difference)

- (NSAttributedString *)differenceForLanguage:(NSString *)language
{
	if ([_oldObjects objectForKey:language])
	{
		return [LTStringDiffer diffBetween:[_oldObjects objectForKey:language] and:[self stringForLanguage:language]];
	}
	else
	{
		return [[NSAttributedString alloc] initWithString:[self stringForLanguage:language]];
	}
}

@end
