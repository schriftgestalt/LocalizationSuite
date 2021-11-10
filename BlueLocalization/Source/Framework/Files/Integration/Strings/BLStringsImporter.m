/*!
 @header
 BLStringsImporter.m
 Created by max on 27.02.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLStringsImporter.h"

#import "BLStringsExporter.h"

@interface BLStringsImporter () <NSOpenSavePanelDelegate>

+ (id)_sharedInstance;

- (void)importStringsToObjects:(NSArray *)objects inDocument:(NSDocument<BLDocumentProtocol> *)document;

+ (void)importStringsFromDirectory:(NSString *)path withLanguage:(NSString *)language andReferenceLanguage:(NSString *)referenceLanguage toObjects:(NSArray *)objects bundle:(BLBundleObject *)bundle;
+ (void)importStringsFile:(NSString *)path withLanguage:(NSString *)language andReferenceLanguage:(NSString *)referenceLanguage toFileObjects:(NSArray *)fileObjects;

+ (NSString *)languageForExportPath:(NSString *)path;
+ (NSString *)realNameForExportPath:(NSString *)path;

@end

@interface BLFileObject (BLStringsImporterExtension)

- (void)importKeysInDictionary:(NSDictionary *)dictionary fromLanguage:(NSString *)language1 toLanguage:(NSString *)language2;

@end

@implementation BLStringsImporter

id __sharedStringsImporter;

- (void)dealloc {
	if (self == __sharedStringsImporter)
		__sharedStringsImporter = nil;
}

+ (id)_sharedInstance {
	if (__sharedStringsImporter == nil)
		__sharedStringsImporter = [[self alloc] init];

	return __sharedStringsImporter;
}

#pragma mark - Public Access

+ (void)importStringsToObjects:(NSArray *)objects inDocument:(NSDocument<BLDocumentProtocol> *)document {
	[[self _sharedInstance] importStringsToObjects:objects inDocument:document];
}

#pragma mark - Interface

- (void)importStringsToObjects:(NSArray *)objects inDocument:(NSDocument<BLDocumentProtocol> *)document {
	// Remember document
	_document = document;

	// Open the open panel
	NSOpenPanel *panel = [NSOpenPanel openPanel];

	[panel setCanChooseDirectories:YES];
	[panel setAllowsMultipleSelection:YES];
	[panel setDelegate:self];
	[[panel defaultButtonCell] setTitle:NSLocalizedStringFromTableInBundle(@"Import", @"Localizable", [NSBundle bundleForClass:[self class]], nil)];

	[panel beginSheetModalForWindow:[document windowForSheet]
				  completionHandler:^(NSInteger returnCode) {
					  [panel close];

					  // User aborted
					  if (returnCode != NSFileHandlingPanelOKButton)
						  return;

					  // Create Step
					  NSArray *paths = [[panel URLs] valueForKey:@"path"];

					  BLGenericProcessStep *step = [BLGenericProcessStep genericStepWithBlock:^{
						  [[self class] importStringsFromFiles:paths forReferenceLanguage:[document referenceLanguage] toObjects:objects];
					  }];

					  [step setAction:NSLocalizedStringFromTableInBundle(@"ImportingStrings", @"BLProcessStep", [NSBundle bundleForClass:[self class]], nil)];
					  [step setDescription:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"ImportingStringsText", @"BLProcessStep", [NSBundle bundleForClass:[self class]], nil), [paths count], [[paths valueForKey:@"lastPathComponent"] componentsJoinedByString:@"“, “"]]];

					  // Enqueue or execute
					  if ([document respondsToSelector:@selector(processManager)] && [document processManager]) {
						  [[document processManager] enqueueStep:step];
						  [[document processManager] startWithName:@"Importing strings files…"];
					  }
					  else {
						  [step perform];
					  }

					  [document updateChangeCount:NSChangeDone];

					  // Clean up
					  _document = nil;
				  }];
}

- (BOOL)panel:(id)sender shouldShowFilename:(NSString *)filename {
	NSDictionary *attributes;

	attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filename error:NULL];

	if (![[attributes objectForKey:NSFileType] isEqual:NSFileTypeRegular]) {
		return YES;
	}
	else {
		NSString *language = [[self class] languageForExportPath:filename];
		return ([[filename pathExtension] isEqual:kStringsPathExtension] && language && [[_document languages] containsObject:language]);
	}
}

#pragma mark - Actions

+ (void)importStringsFromFiles:(NSArray *)paths forReferenceLanguage:(NSString *)referenceLanguage toObjects:(NSArray *)objects {
	BLLogBeginGroup(@"Importing strings files from paths %@", paths);

	// Get real paths
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSMutableArray *realPaths = [NSMutableArray array];
	NSMutableArray *refPaths = [NSMutableArray array];
	NSMutableArray *allPaths = [NSMutableArray arrayWithArray:paths];

	for (NSUInteger i = 0; i < [allPaths count]; i++) {
		BOOL isDirectory;
		NSString *path;

		path = [allPaths objectAtIndex:i];
		[fileManager fileExistsAtPath:path isDirectory:&isDirectory];

		if (!isDirectory) {
			// Valid strings files only
			if ([[path pathExtension] isEqual:kStringsPathExtension] && [self languageForExportPath:path]) {
				if ([[self languageForExportPath:path] isEqual:referenceLanguage])
					[refPaths addObject:path];
				else
					[realPaths addObject:path];
			}
		}
		else {
			// Valid language folders only
			if ([self languageForExportPath:path]) {
				if ([[self languageForExportPath:path] isEqual:referenceLanguage])
					[refPaths addObject:path];
				else
					[realPaths addObject:path];
			}
			// Otherwise traverse
			else {
				for (NSString *subPath in [fileManager contentsOfDirectoryAtPath:path error:NULL])
					[allPaths addObject:[path stringByAppendingPathComponent:subPath]];
			}
		}
	}

	// Add reference strings to the end
	[realPaths addObjectsFromArray:refPaths];

	// Import files/directories
	for (NSString *path in realPaths) {
		NSString *language;
		BOOL isDirectory;

		// Get language and type
		language = [self languageForExportPath:path];
		[fileManager fileExistsAtPath:path isDirectory:&isDirectory];

		if (!isDirectory) {
			// Single strings file
			BLLog(BLLogInfo, @"Importing single file: %@ language:%@", [path lastPathComponent], language);
			[self importStringsFile:path withLanguage:language andReferenceLanguage:referenceLanguage toFileObjects:[BLObject fileObjectsFromArray:objects]];
		}
		else
			// Directory
			[self importStringsFromDirectory:path withLanguage:language andReferenceLanguage:referenceLanguage toObjects:objects bundle:nil];
	}

	BLLogEndGroup();
}

+ (void)importStringsFromDirectory:(NSString *)path withLanguage:(NSString *)language andReferenceLanguage:(NSString *)referenceLanguage toObjects:(NSArray *)objects bundle:(BLBundleObject *)bundle {
	NSMutableArray *stringsFiles, *regularFiles, *directories;
	NSFileManager *fileManager;
	NSArray *directoryContents;
	BOOL isDirectory;

	// Init
	fileManager = [NSFileManager defaultManager];

	stringsFiles = [NSMutableArray array];
	regularFiles = [NSMutableArray array];
	directories = [NSMutableArray array];

	// Get contents
	directoryContents = [fileManager contentsOfDirectoryAtPath:path error:NULL];

	// Split contents by type
	for (NSString *file in directoryContents) {
		NSString *fullPath;

		fullPath = [path stringByAppendingPathComponent:file];
		[fileManager fileExistsAtPath:fullPath isDirectory:&isDirectory];

		if (!isDirectory) {
			if ([[fullPath pathExtension] isEqual:kStringsPathExtension])
				[stringsFiles addObject:fullPath];
			else
				[regularFiles addObject:fullPath];
		}
		else {
			[directories addObject:fullPath];
		}
	}

	// Ignore folders if we are already in a bundle
	if (!bundle) {
		// Call recursively
		for (NSString *directory in directories) {
			NSArray *bundles;

			bundles = [BLObject bundleObjectsWithName:[directory lastPathComponent] inArray:objects];

			for (BLBundleObject *aBundle in bundles)
				// Import directory to a bundle, changing the objects scope
				[self importStringsFromDirectory:directory withLanguage:language andReferenceLanguage:referenceLanguage toObjects:[aBundle files] bundle:aBundle];
		}
	}

	// Switch focus to file objects only
	objects = [BLObject fileObjectsFromArray:objects];

	// Import regular files
	for (NSString *file in regularFiles) {
		NSArray *fileObjects = [BLObject fileObjectsWithName:[file lastPathComponent] inArray:objects];
		BLLog(BLLogInfo, @"Importing regular file:%@ (%d found) language:%@ bundle:%@", [file lastPathComponent], [fileObjects count], language, [bundle name]);
		for (BLFileObject *fileObject in fileObjects)
			[[BLFileInterpreter interpreterForFileObject:fileObject] interpreteFile:file intoObject:fileObject withLanguage:language referenceLanguage:referenceLanguage];
	}

	// Import strings files
	if (!bundle && [stringsFiles count] == 1 && [[[stringsFiles objectAtIndex:0] lastPathComponent] isEqual:[BLStringsExporterExportFileName stringByAppendingPathExtension:kStringsPathExtension]]) {
		// Only our single default export strings file
		BLLog(BLLogInfo, @"Importing single strings file:%@ language:%@", [[stringsFiles objectAtIndex:0] lastPathComponent], language);
		[self importStringsFile:[stringsFiles objectAtIndex:0] withLanguage:language andReferenceLanguage:referenceLanguage toFileObjects:objects];
	}
	else {
		// One strings file per original file
		for (NSString *file in stringsFiles) {
			NSArray *fileObjects = [BLObject fileObjectsWithName:[self realNameForExportPath:file] inArray:objects];
			BLLog(BLLogInfo, @"Importing strings file:%@[=%@] (%d found) language:%@ bundle:%@", [file lastPathComponent], [self realNameForExportPath:file], [fileObjects count], language, [bundle name]);
			[self importStringsFile:file withLanguage:language andReferenceLanguage:referenceLanguage toFileObjects:fileObjects];
		}
	}
}

+ (void)importStringsFile:(NSString *)path withLanguage:(NSString *)language andReferenceLanguage:(NSString *)referenceLanguage toFileObjects:(NSArray *)fileObjects {
	NSDictionary *contents;

	// Get contents
	contents = [NSDictionary dictionaryWithStringsAtPath:path];
	if (!contents)
		return;

	// Import
	for (BLFileObject *fileObject in fileObjects)
		[fileObject importKeysInDictionary:contents fromLanguage:referenceLanguage toLanguage:language];
}

#pragma mark - Utilities

+ (NSString *)languageForExportPath:(NSString *)path {
	NSString *file, *language;
	NSRange range;

	file = [path lastPathComponent];
	file = [file stringByDeletingPathExtension];

	// Find the language divider
	range = [file rangeOfString:@" " options:NSBackwardsSearch];
	if (range.location == NSNotFound)
		return nil;

	// Find the language
	language = [file substringFromIndex:NSMaxRange(range)];
	language = [BLLanguageTranslator identifierForLanguage:language];

	return language;
}

+ (NSString *)realNameForExportPath:(NSString *)path {
	NSString *name;

	name = [path lastPathComponent];
	if (![[name pathExtension] isEqual:kStringsPathExtension])
		return name;

	// something like .nib.strings - check for a original interpreter
	if ([BLFileInterpreter interpreterForFileType:[[name stringByDeletingPathExtension] pathExtension]])
		name = [name stringByDeletingPathExtension];

	return name;
}

@end

@implementation BLFileObject (BLStringsImporterExtension)

- (void)importKeysInDictionary:(NSDictionary *)dictionary fromLanguage:(NSString *)language1 toLanguage:(NSString *)language2 {
	for (BLKeyObject *keyObject in self.objects) {
		NSString *key, *value;

		key = [keyObject stringForLanguage:language1];
		value = [dictionary objectForKey:key];

		if (!value || ![value length])
			continue;

		if (key && value)
			// This is type-secure, because it only accepts values of the correct type (strings)
			[keyObject setObject:value forLanguage:language2];
	}
}

@end
