/*!
 @header
 BLFile.h
 Created by Max Seelemann on 05.10.07.
 
 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */

#import "BLFile.h"


NSString *BLFileUserFileExtension		= @"locuser";

// Creation Attribute Keys
NSString *BLLanguagesPropertyName           = @"languages";
NSString *BLReferenceLanguagePropertyName   = @"referenceLanguage";

// Keys for Localization File
NSString *BLFileAttachmentsKey			= @"attachments";
NSString *BLFileAttributesKey           = @"attributes";
NSString *BLFileBackupKey				= @"backup";
NSString *BLFileBundlesKey              = @"bundles";
NSString *BLFileChangeDateKey           = @"change date";
NSString *BLFileClassKey                = @"class";
NSString *BLFileChangedValuesKey        = @"changed values";
NSString *BLFileCommentKey              = @"comment";
NSString *BLFileCustomTypeKey           = @"custom type";
NSString *BLFileErrorsKey               = @"errors";
NSString *BLFileFilesKey                = @"files";
NSString *BLFileFilterSettingsKey		= @"filter settings";
NSString *BLFileFlagsKey                = @"flags";
NSString *BLFileHashKey                 = @"hash";
NSString *BLFileHistoryKey              = @"history";
NSString *BLFileIncludesPreviewKey		= @"supports preview";
NSString *BLFileIsPlistFileKey          = @"plist file";
NSString *BLFileKeyKey                  = @"key";
NSString *BLFileKeysKey                 = @"keys";
NSString *BLFileLanguagesKey            = @"languages";
NSString *BLFileLocalizationsKey        = @"localizations";
NSString *BLFilePreviousLocalizationsKey= @"previous localizations";
NSString *BLFileNameKey                 = @"name";
NSString *BLFileNamingStyleKey          = @"naming style";
NSString *BLFileObjectsKey              = @"objects";
NSString *BLFileOldObjectsKey           = @"old objects";
NSString *BLFileOptionsKey              = @"options";
NSString *BLFilePreferencesKey			= @"preferences";
NSString *BLFileReferenceLanguageKey    = @"reference language";
NSString *BLFileReferencingStyleKey     = @"referencing style";
NSString *BLFileSnapshotsKey			= @"snapshots";
NSString *BLFileUserNameKey             = @"user name";
NSString *BLFileVersionKey              = @"version";
NSString *BLFileVersionsKey				= @"versions";
NSString *BLFileWarningsKey             = @"warnings";
NSString *BLFileXcodeProjectsKey		= @"associated Xcode projects";



@implementation BLFile

+ (NSString *)pathExtension
{
	return nil;
}

+ (NSArray *)requiredProperties
{
	return [NSArray array];
}

+ (NSFileWrapper *)createFileForObjects:(NSArray *)objects withOptions:(NSUInteger)options andProperties:(NSDictionary *)properties
{
	if ([self class] == [BLFile class])
		[NSException raise:NSGenericException format:@"Do not call the abstract superclass BLFile directly!"];
	
	return nil;
}

+ (NSArray *)objectsFromFile:(NSFileWrapper *)wrapper readingProperties:(NSDictionary **)properties
{
	if ([self class] == [BLFile class])
		[NSException raise:NSGenericException format:@"Do not call the abstract superclass BLFile directly!"];
	
	return nil;
}

@end