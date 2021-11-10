/*!
 @header
 BLNibFileObject.m
 Created by Max on 13.12.04.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLNibFileObject.h"

#import "BLFileInternal.h"
#import "BLStringKeyObject.h"

@implementation BLNibFileObject

+ (void)load {
	[super registerClass:self forPathExtension:@"nib"];
	[super registerClass:self forPathExtension:@"xib"];
}

+ (Class)classOfStoredKeys {
	return [BLStringKeyObject class];
}

#pragma mark - Accessors

- (NSString *)fileFormatInfo {
	return NSLocalizedStringFromTableInBundle(([[_path pathExtension] isEqual:@"nib"]) ? @"BLNibFileObjectFileFormatNib" : @"BLNibFileObjectFileFormatXib", @"Localizable", [NSBundle bundleForClass:[self class]], nil);
}

@end
