/*!
 @header
 BLStringsFileCreator.m
 Created by Max on 29.11.04.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLStringsFileCreator.h"

#import "BLStringsFileObject.h"

@implementation BLStringsFileCreator

+ (void)load {
	[super registerCreatorClass:self forFileType:@"strings"];
}

+ (NSUInteger)defaultOptions {
	return BLFileCreatorWriteActiveKeysOnly;
}

#pragma mark -

- (BOOL)_writeFileToPath:(NSString *)path fromObject:(BLFileObject *)object withLanguage:(NSString *)language referenceLanguage:(NSString *)defaultLanguage {
	return [self _writeFileToPath:path fromObject:object withLanguage:language referenceLanguage:defaultLanguage usingEncoding:NSUnicodeStringEncoding];
}

- (BOOL)_writeFileToPath:(NSString *)path fromObject:(BLFileObject *)object withLanguage:(NSString *)language referenceLanguage:(NSString *)referenceLanguage usingEncoding:(NSStringEncoding)encoding {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BLLog(BLLogInfo, @"Creating .strings file \"%@\"", path);

	// Writing a plist file
	if ([object isKindOfClass:[BLStringsFileObject class]] && [(BLStringsFileObject *)object isPlistStringsFile]) {
		BLFileCreator *plistCreator = [BLFileCreator creatorForFileType:@"plist"];
		[plistCreator setOptions:[self options]];
		return [plistCreator writeFileToPath:path fromObject:object withLanguage:language referenceLanguage:referenceLanguage];
	}

	// Get settings
	BOOL activeOnly = [self optionIsActive:BLFileCreatorWriteActiveKeysOnly];
	BOOL inactiveAsReference = [self optionIsActive:BLFileCreatorInactiveKeysAsReference];

	// Filter strings and set concrete values
	NSMutableDictionary *comments = [NSMutableDictionary dictionary];
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	NSMutableArray *keys = [NSMutableArray array];
	NSArray *keyObjects = [object objects];

	for (BLKeyObject *keyObject in keyObjects) {
		NSString *key = [keyObject key];

		// Skip inactive keys
		if (activeOnly && ![keyObject isActive])
			continue;

		// Try to find a non-empty value for the key
		if ((!inactiveAsReference || [keyObject isActive]) && ![keyObject isEmptyForLanguage:language])
			[dict secureSetObject:[keyObject objectForLanguage:language] forKey:key];
		else if (![keyObject isEmptyForLanguage:referenceLanguage])
			[dict secureSetObject:[keyObject objectForLanguage:referenceLanguage] forKey:key];

		// If a value was found, we will print this key
		if ([dict objectForKey:key])
			[keys addObject:key];

		// Try to find a non-empty comment
		if ([[keyObject comment] length] > 0)
			[comments secureSetObject:[keyObject comment] forKey:key];
	}

	// Detect slave mode
	if ([self optionIsActive:BLFileCreatorSlaveMode]) {
		return [dict writeKeysAsStrings:keys withComments:comments toPath:path usingEncoding:encoding];
	}

	// Check for reference file
	NSString *referencePath = [[path stringByDeletingPathExtension] stringByAppendingFormat:@".r.%@", [path pathExtension]];

	NSFileWrapper *reference = [object attachedObjectForKey:BLBackupAttachmentKey];
	[reference writeToURL:[NSURL fileURLWithPath:referencePath] options:NSFileWrapperWritingAtomic originalContentsURL:nil error:nil];

	if (![fileManager fileExistsAtPath:referencePath]) {
		// Copy original if no reference version available
		NSString *originalPath = [BLPathCreator replaceLanguage:language inPath:path withLanguage:referenceLanguage bundle:[object bundleObject]];
		[fileManager copyItemAtPath:originalPath toPath:referencePath error:NULL];
	}

	// No reference found -- use fallback method
	if (![fileManager fileExistsAtPath:referencePath]) {
		BLLog(BLLogWarning, @"Cannot stage or find reference file, using falback method. Do a (forced) rescan of the reference language!");
		return [dict writeKeysAsStrings:keys withComments:comments toPath:path usingEncoding:encoding];
	}
	else {
		BOOL result = [dict writeToPath:path mimicingFileAtPath:referencePath];
		[fileManager removeItemAtPath:referencePath error:NULL];
		return result;
	}
}

@end
