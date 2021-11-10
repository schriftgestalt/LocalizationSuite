/*!
 @header
 LIImageLoader.m
 Created by Max Seelemann on 19.05.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "LIImageLoader.h"

NSString *LIErrorImageName = @"LIError";
NSString *LIWarningImageName = @"LIWarning";

@implementation LIImageLoader

+ (void)loadImage:(NSString *)name {
	@autoreleasepool {

		NSString *path;
		NSImage *image;

		path = [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:@"png"];
		image = [[NSImage alloc] initWithContentsOfFile:path];
		[image setName:name];
	}
}

@end
