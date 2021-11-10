/*!
 @header
 BLTXTFileObject.m
 Created by Max on 27.10.04.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLStringKeyObject.h>
#import <BlueLocalization/BLTXTFileObject.h>

@implementation BLTXTFileObject

+ (void)load {
	[super registerClass:self forPathExtension:@"txt"];
}

+ (Class)classOfStoredKeys {
	return [BLStringKeyObject class];
}

@end
