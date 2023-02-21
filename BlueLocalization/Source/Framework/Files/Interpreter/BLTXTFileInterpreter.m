/*!
 @header
 BLTXTFileInterpreter.m
 Created by Max on 13.11.04.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLTXTFileInterpreter.h>

#import <BlueLocalization/BLFileObject.h>
#import <BlueLocalization/BLKeyObject.h>

// constants
NSString *BLTXTFileContentKeyName = @"content";

// implementation
@implementation BLTXTFileInterpreter

+ (void)load {
	[super registerInterpreterClass:self forFileType:@"txt"];
}

+ (NSUInteger)defaultOptions {
	return BLFileInterpreterReferenceImportCreatesBackup;
}

#pragma mark -

- (BOOL)_interpreteFile:(NSString *)path {
	NSString *string = [NSString stringWithContentsOfFile:path usedEncoding:NULL error:NULL];
	[self _emitKey:BLTXTFileContentKeyName value:string leadingComment:nil inlineComment:nil];

	return YES;
}

@end
