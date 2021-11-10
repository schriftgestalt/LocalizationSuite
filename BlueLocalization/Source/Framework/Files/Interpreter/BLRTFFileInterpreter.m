/*!
 @header
 BLRTFFileInterpreter.m
 Created by Max on 13.11.04.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLRTFFileInterpreter.h>

#import <BlueLocalization/BLFileObject.h>
#import <BlueLocalization/BLKeyObject.h>

// constants
NSString *BLRTFFileContentKeyName = @"content";
NSString *kRTFDHashSubpath = @"TXT.rtf";

// implementation
@implementation BLRTFFileInterpreter

+ (void)load {
	[super registerInterpreterClass:self forFileType:@"rtf"];
	[super registerInterpreterClass:self forFileType:@"rtfd"];
}

#pragma mark -

- (NSString *)actualPathForHashValueGeneration:(NSString *)path {
	if ([[path pathExtension] isEqual:@"rtfd"])
		return [path stringByAppendingPathComponent:kRTFDHashSubpath];
	else
		return path;
}

#pragma mark -

- (BOOL)_interpreteFile:(NSString *)path {
	NSAttributedString *string;

	string = [[NSAttributedString alloc] initWithPath:path documentAttributes:nil];
	[self _emitKey:BLRTFFileContentKeyName value:string leadingComment:nil inlineComment:nil];

	return YES;
}

@end
