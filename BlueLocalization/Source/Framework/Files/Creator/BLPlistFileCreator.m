/*!
 @header
 BLPlistFileCreator.m
 Created by Max Seelemann on 04.09.06.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLPlistFileCreator.h>

#import <BlueLocalization/BLPlistFileInterpreter.h>

@implementation BLPlistFileCreator

+ (void)load {
	[super registerCreatorClass:self forFileType:@"plist"];
}

#pragma mark -

- (BOOL)_writeFileToPath:(NSString *)path fromObject:(BLFileObject *)object withLanguage:(NSString *)language referenceLanguage:(NSString *)referenceLanguage {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BLLogBeginGroup(@"Creating .plist file \"%@\"", path);

	// Build translation dictionary
	NSMutableDictionary *translation = [NSMutableDictionary dictionary];
	for (BLKeyObject *string in [object objects]) {
		if (![string isEmptyForLanguage:language])
			[translation secureSetObject:[string objectForLanguage:language] forKey:[string key]];
		else if (![string isEmptyForLanguage:referenceLanguage])
			[translation secureSetObject:[string objectForLanguage:referenceLanguage] forKey:[string key]];
	}

	// Check for reference file
	NSString *referencePath = [[path stringByDeletingPathExtension] stringByAppendingFormat:@".r.%@", [path pathExtension]];

	NSFileWrapper *reference = [object attachedObjectForKey:BLBackupAttachmentKey];
	[reference writeToURL:[NSURL fileURLWithPath:referencePath] options:0 originalContentsURL:nil error:nil];

	// Copy original if no reference version available
	if (![fileManager fileExistsAtPath:referencePath]) {
		NSString *originalPath = [BLPathCreator replaceLanguage:language inPath:path withLanguage:referencePath bundle:[object bundleObject]];
		[fileManager copyItemAtPath:originalPath toPath:referencePath error:NULL];
	}

	// No original file found cannot proceed!
	if (![fileManager fileExistsAtPath:referencePath]) {
		BLLog(BLLogError, @"Cannot stage or find reference file. Do a (forced) rescan of the reference language!");
		BLLogEndGroup();
		return NO;
	}

	// Get the localization dictionary
	NSData *data = [NSData dataWithContentsOfFile:referencePath];
	[fileManager removeItemAtPath:referencePath error:NULL];

	// Load property list
	NSError *error;
	id plist = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:&error];
	if (!plist) {
		BLLog(BLLogError, @"Failed to parse plist. Reason: %@", error);
		BLLogEndGroup();
		return NO;
	}

	// Inject translation
	[plist localizeUsingDictionary:translation];

	// Write file
	[[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:NULL];
	BOOL success = [plist writeToFile:path atomically:YES];

	BLLogEndGroup();
	return success;
}

@end
