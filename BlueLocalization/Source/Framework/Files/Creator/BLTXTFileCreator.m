/*!
 @header
 BLTXTFileCreator.m
 Created by Max on 29.11.04.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLTXTFileCreator.h>
#import <BlueLocalization/BLTXTFileInterpreter.h>

#import <BlueLocalization/BLFileManagerAdditions.h>
#import <BlueLocalization/BLFileObject.h>
#import <BlueLocalization/BLKeyObject.h>

@implementation BLTXTFileCreator

+ (void)load {
	[super registerCreatorClass:self forFileType:@"txt"];
}

#pragma mark -

- (BOOL)_writeFileToPath:(NSString *)path fromObject:(BLFileObject *)object withLanguage:(NSString *)language referenceLanguage:(NSString *)referenceLanguage {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BLLog(BLLogInfo, @"Creating .txt file \"%@\"", path);

	// Get the key object
	BLKeyObject *keyObject = [object objectForKey:BLTXTFileContentKeyName];

	// Get the content to write
	NSString *string;
	if (![keyObject isEmptyForLanguage:language])
		string = [keyObject objectForLanguage:language];
	else if (![keyObject isEmptyForLanguage:referenceLanguage])
		string = [keyObject objectForLanguage:referenceLanguage];
	else
		return NO;

	// Check for reference file
	NSString *referencePath = [[path stringByDeletingPathExtension] stringByAppendingFormat:@".r.%@", [path pathExtension]];

	NSFileWrapper *reference = [object attachedObjectForKey:BLBackupAttachmentKey];
	[reference writeToFile:referencePath atomically:YES updateFilenames:NO];

	// Try to get the encoding of the reference file
	NSStringEncoding encoding = NSUnicodeStringEncoding;
	if ([fileManager fileExistsAtPath:referencePath]) {
		[NSString stringWithContentsOfFile:referencePath usedEncoding:&encoding error:NULL];
		[fileManager removeItemAtPath:referencePath error:NULL];
	}

	// Create directory and write file
	[fileManager createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:NULL];
	return [[string dataUsingEncoding:encoding] writeToFile:path atomically:YES];
}

@end
