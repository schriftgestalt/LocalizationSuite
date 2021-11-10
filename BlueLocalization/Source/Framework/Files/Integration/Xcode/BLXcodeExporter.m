/*!
 @header
 BLXcodeExporter.m
 Created by max on 01.07.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLXcodeExporter.h"

NSString *BLXcodeExporterNibName = @"BLXcodeExporter";

NSString *BLXcodeExporterAddMissingFilesKeyPath = @"xcodeExporter.addMissing";
NSString *BLXcodeExporterFileLimitKeyPath = @"xcodeExporter.fileLimit";
NSString *BLXcodeExporterHasFileLimitKeyPath = @"xcodeExporter.hasFileLimit";
NSString *BLXcodeExporterHasLanguageLimitKeyPath = @"xcodeExporter.hasLanguageLimit";
NSString *BLXcodeExporterLanguageLimitKeyPath = @"xcodeExporter.languageLimit";
NSString *BLXcodeExporterRemoveOldFilesKeyPath = @"xcodeExporter.removeOld";

@interface BLXcodeExporter (BLXcodeExporterInternal)

+ (id)_sharedInstance;

- (void)exportDatabaseDocument:(BLDatabaseDocument *)document;

@end

@implementation BLXcodeExporter

id __sharedXcodeExporter;

- (void)dealloc {
	if (self == __sharedXcodeExporter)
		__sharedXcodeExporter = nil;
}

+ (id)_sharedInstance {
	if (__sharedXcodeExporter == nil)
		__sharedXcodeExporter = [[self alloc] init];

	return __sharedXcodeExporter;
}

#pragma mark - Public Access

+ (void)exportDatabaseDocument:(BLDatabaseDocument *)document {
	[[self _sharedInstance] exportDatabaseDocument:document];
}

#pragma mark - User interface

- (void)exportDatabaseDocument:(BLDatabaseDocument *)document {
	NSUserDefaults *defaults;
	NSOpenPanel *panel;

	// Set some defaults
	defaults = [NSUserDefaults standardUserDefaults];
	if (![defaults objectForKey:BLXcodeExporterAddMissingFilesKeyPath])
		[defaults setBool:YES forKey:BLXcodeExporterAddMissingFilesKeyPath];
	if (![defaults objectForKey:BLXcodeExporterRemoveOldFilesKeyPath])
		[defaults setBool:YES forKey:BLXcodeExporterRemoveOldFilesKeyPath];
	if (![defaults objectForKey:BLXcodeExporterLanguageLimitKeyPath])
		[defaults setFloat:80 forKey:BLXcodeExporterLanguageLimitKeyPath];
	if (![defaults objectForKey:BLXcodeExporterFileLimitKeyPath])
		[defaults setFloat:80 forKey:BLXcodeExporterFileLimitKeyPath];

	// Open the panel
	panel = [NSOpenPanel openPanel];

	if (!optionsView)
		[NSBundle loadNibNamed:BLXcodeExporterNibName owner:self];

	[panel setAllowsMultipleSelection:YES];
	[panel setAllowedFileTypes:[BLXcodeProjectParser pathExtensions]];

	[panel setAccessoryView:optionsView];
	[panel setMessage:NSLocalizedStringFromTableInBundle(@"BLXcodeExportText", @"Localizable", [NSBundle bundleForClass:[self class]], nil)];
	[[panel defaultButtonCell] setTitle:NSLocalizedStringFromTableInBundle(@"Export", @"Localizable", [NSBundle bundleForClass:[self class]], nil)];

	[panel beginSheetModalForWindow:[document windowForSheet]
				  completionHandler:^(NSInteger result) {
					  if (result != NSFileHandlingPanelOKButton)
						  return;

					  // Create the options
					  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

					  NSUInteger options = 0;
					  if ([defaults boolForKey:BLXcodeExporterAddMissingFilesKeyPath])
						  options |= BLXcodeExporterAddMissingFiles;
					  if ([defaults boolForKey:BLXcodeExporterRemoveOldFilesKeyPath])
						  options |= BLXcodeExporterRemoveOldFiles;

					  // Get the limits
					  float langLimit = BLXcodeExporterNoLanguageLimit;
					  if ([defaults boolForKey:BLXcodeExporterHasLanguageLimitKeyPath])
						  langLimit = [defaults floatForKey:BLXcodeExporterLanguageLimitKeyPath] / 100.;
					  float fileLimit = BLXcodeExporterNoLanguageLimit;
					  if ([defaults boolForKey:BLXcodeExporterHasFileLimitKeyPath])
						  fileLimit = [defaults floatForKey:BLXcodeExporterFileLimitKeyPath] / 100.;

					  // Export
					  for (NSURL *url in [panel URLs]) {
						  if ([[url pathExtension] isEqual:@"xcodeproj"])
							  [[self class] exportToXcodeProjectAtPath:[url path] fromDatabaseDocument:document withOptions:options languageLimit:langLimit fileLimit:fileLimit];
					  }
				  }];
}

#pragma mark - Export

+ (void)exportToXcodeProjectAtPath:(NSString *)path fromDatabaseDocument:(BLDatabaseDocument *)document withOptions:(NSUInteger)options languageLimit:(float)languageLimit fileLimit:(float)fileLimit {
	NSArray *localizedGroups, *languages;
	BLXcodeProjectParser *parser;

	BLLogBeginGroup(@"Exporting to Xcode project");
	BLLog(BLLogInfo, @"Project path: %@", path);

	// Open the project
	parser = [BLXcodeProjectParser parserWithProjectFileAtPath:path];
	[parser loadProject];

	if (![parser projectIsLoaded]) {
		BLLog(BLLogError, @"Cannot open Xcode project at path: %@", path);
		return;
	}

	// Calculate the overall valid languages
	languages = [document languages];

	if (languageLimit != BLXcodeExporterNoLanguageLimit) {
		NSMutableArray *filteredLanguages;
		NSUInteger all;

		all = [BLObject numberOfKeysInObjects:[document bundles]];
		filteredLanguages = [NSMutableArray arrayWithCapacity:[languages count]];

		for (NSString *language in languages) {
			NSUInteger missing = [BLObject numberOfKeysMissingForLanguage:language inObjects:[document bundles]];
			if (missing < all * (1 - languageLimit))
				[filteredLanguages addObject:language];
		}

		languages = filteredLanguages;
	}

	// Get the localized file groups
	localizedGroups = [[parser mainGroup] localizedVariantGroups];

	// Update localized variants
	for (BLXcodeProjectItem *group in localizedGroups) {
		NSArray *fileLanguages, *groupLanguages;
		BLFileObject *file;

		// Map item group to file object
		NSString *path = [[[group children] objectAtIndex:0] fullPath];
		file = [document existingFileObjectWithPath:path];

		if (!file)
			continue;

		// Calculate the file's valid languages
		if (fileLimit != BLXcodeExporterNoFileLimit) {
			NSMutableArray *filteredLanguages;
			NSUInteger all;

			all = [file numberOfKeys];
			filteredLanguages = [NSMutableArray arrayWithCapacity:[languages count]];

			for (NSString *language in languages) {
				NSUInteger missing = [file numberOfMissingKeysForLanguage:language];
				if (missing < all * (1 - fileLimit))
					[filteredLanguages addObject:language];
			}

			fileLanguages = filteredLanguages;
		}
		else {
			fileLanguages = languages;
		}

		// Update group languages
		[group updateLocalizationNames];
		groupLanguages = [group localizations];

		if (options & BLXcodeExporterAddMissingFiles) {
			NSMutableArray *langs = [NSMutableArray arrayWithArray:fileLanguages];
			[langs removeObjectsInArray:groupLanguages];

			if ([langs count]) {
				[group addLocalizations:langs];
				BLLog(BLLogInfo, @"Added language(s) %@ to file %@", [langs componentsJoinedByString:@", "], [group name]);
			}
		}
		if (options & BLXcodeExporterRemoveOldFiles) {
			NSMutableArray *langs = [NSMutableArray arrayWithArray:groupLanguages];
			[langs removeObjectsInArray:fileLanguages];
			[langs removeObject:[document referenceLanguage]];

			if ([langs count]) {
				[group removeLocalizations:langs];
				BLLog(BLLogInfo, @"Removed language(s) %@ from file %@", [langs componentsJoinedByString:@", "], [group name]);
			}
		}

		// Update file types and encodings
		for (BLXcodeProjectItem *item in group.children)
			[item updateFileTypeAndEncoding];
	}

	// Then save the changes
	if (![parser writeProject]) {
		BLLog(BLLogError, @"Unable to write changed project!");
		return;
	}

	BLLog(BLLogInfo, @"Export successfully finished.");
	BLLogEndGroup();
}

@end
