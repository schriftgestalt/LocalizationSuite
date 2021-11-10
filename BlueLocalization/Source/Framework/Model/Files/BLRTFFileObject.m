/*!
 @header
 BLRTFFileObject.m
 Created by Max on 27.10.04.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLRTFDKeyObject.h>
#import <BlueLocalization/BLRTFFileObject.h>

@implementation BLRTFFileObject

+ (void)load {
	[super registerClass:self forPathExtension:@"rtf"];
	[super registerClass:self forPathExtension:@"rtfd"];
}

+ (Class)classOfStoredKeys {
	return [BLRTFDKeyObject class];
}

@end
