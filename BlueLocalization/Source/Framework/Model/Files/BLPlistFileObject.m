/*!
 @header
 BLPlistFileObject.m
 Created by Max Seelemann on 04.09.06.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLPlistFileObject.h>
#import <BlueLocalization/BLStringKeyObject.h>

@implementation BLPlistFileObject

+ (void)load {
	[super registerClass:self forPathExtension:@"plist"];
}

+ (Class)classOfStoredKeys {
	return [BLStringKeyObject class];
}

@end
