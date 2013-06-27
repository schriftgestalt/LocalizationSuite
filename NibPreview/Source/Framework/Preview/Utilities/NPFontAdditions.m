/*!
 @header
 NPFontAdditions.m
 Created by max on 18.07.08.
 
 @copyright 2008-2009 Localization Suite. All rights reserved.
 */

#import "NPFontAdditions.h"

@implementation NSFont (NPFontAdditions)

+ (NSFont *)fontFromIBToolDictionary:(NSDictionary *)dict
{
	return [NSFont fontWithName:[dict objectForKey: @"Name"] size:[[dict objectForKey: @"Size"] floatValue]];
}

@end
