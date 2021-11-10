/*!
 @header
 BLDatabaseDocumentActions.m
 Created by Max Seelemann on 28.04.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLDatabaseDocumentActions.h"
#import "BLDatabaseDocumentPreferences.h"

#import "BLInterpretationStep.h"
#import "BLXcodeExportUpdateStep.h"
#import "BLXcodeImportUpdateStep.h"

/*!
 @abstract Common actions performed on a database document.
 */
@interface BLDatabaseDocument (BLDatabaseDocumentActionsInternal)

/*!
 @abstract The interpreter parameters determined by the file's preferences.
 @discussion The returned dictionary can be passed as parameters to a BLInterpreterStep. It is generated according to the user's settings and should be used for all file interpretations.
 */
- (NSDictionary *)defaultInterpreterParameters;

@end

@implementation BLDatabaseDocument (BLDatabaseDocumentActions)

- (NSUInteger)defaultInterpreterOptions {
	NSUInteger options;

	options = BLFileInterpreterNoOptions;

	if ([[self.preferences objectForKey:BLDatabaseDocumentImportEmptyStringsKey] boolValue])
		options |= BLFileInterpreterImportEmptyKeys;
	if ([[self.preferences objectForKey:BLDatabaseDocumentDeactivateEmptyStringsKey] boolValue])
		options |= BLFileInterpreterDeactivateEmptyKeys;
	if ([[self.preferences objectForKey:BLDatabaseDocumentDeactivatePlaceholderStringsKey] boolValue])
		options |= BLFileInterpreterDeactivatePlaceholderStrings;
	if ([[self.preferences objectForKey:BLDatabaseDocumentAutotranslateNewStringsKey] boolValue])
		options |= BLFileInterpreterAutotranslateNewKeys;
	if ([[self.preferences objectForKey:BLDatabaseDocumentMarkAutotranslatedAsNotChangedKey] boolValue])
		options |= BLFileInterpreterTrackAutotranslationAsNoUpdate;
	if ([[self.preferences objectForKey:BLDatabaseDocumentValueChangesResetStringsKey] boolValue])
		options |= BLFileInterpreterValueChangesResetKeys;

	return options;
}

+ (NSArray *)defaultIgnoredPlaceholderStrings {
	static NSArray *defaultPlaceholders = nil;

	if (!defaultPlaceholders)
		defaultPlaceholders = [NSArray arrayWithContentsOfURL:[[NSBundle bundleForClass:[BLDatabaseDocument class]] URLForResource:@"BLDefaultPlaceholders" withExtension:@"plist"]];

	return defaultPlaceholders;
}

- (NSDictionary *)defaultInterpreterParameters {
	NSMutableDictionary *parameters = [NSMutableDictionary dictionary];

	if ([self.preferences objectForKey:BLDatabaseDocumentIgnoredPlaceholderStringsKey])
		[parameters setObject:[self.preferences objectForKey:BLDatabaseDocumentIgnoredPlaceholderStringsKey] forKey:BLInterpretationStepIgnoredPlaceholderStringsKey];
	else
		[parameters setObject:[[self class] defaultIgnoredPlaceholderStrings] forKey:BLInterpretationStepIgnoredPlaceholderStringsKey];

	return parameters;
}

#pragma mark - Object Actions

- (BLFileObject *)fileObjectWithPath:(NSString *)path {
	return [self fileObjectWithPath:path create:YES];
}

- (BLFileObject *)existingFileObjectWithPath:(NSString *)path {
	return [self fileObjectWithPath:path create:NO];
}

- (BLFileObject *)fileObjectWithPath:(NSString *)path create:(BOOL)create {
	NSString *bundlePath, *filePath;
	BLBundleObject *bundle;
	BLFileObject *file;

	// Get the paths
	bundlePath = [BLPathCreator bundlePartOfFilePath:path];
	filePath = [BLPathCreator relativePartOfFilePath:path];

	// Find the bundle
	bundle = [self bundleObjectWithPath:bundlePath create:create];

	// Bundle was found or created
	if (bundle) {
		file = [bundle fileWithName:filePath];

		if (!file && create) {
			file = [BLFileObject fileObjectWithPath:filePath];
			[bundle addFile:file];
		}

		return file;
	}
	// Bundle was not found or created
	else {
		return nil;
	}
}

- (BLBundleObject *)bundleObjectWithPath:(NSString *)path {
	return [self bundleObjectWithPath:path create:YES];
}

- (BLBundleObject *)bundleObjectWithPath:(NSString *)path create:(BOOL)create {
	NSString *bundlePath = [[self pathCreator] documentRelativePathOfFullPath:path];

	BLBundleObject *bundle;
	for (bundle in [self bundles]) {
		if ([[[self pathCreator] relativePathForBundle:bundle] isEqual:bundlePath])
			return bundle;
	}

	if (!create)
		return nil;

	bundle = [self createBundleObjectWithPath:path];
	[self addBundle:bundle];

	return bundle;
}

#pragma mark -

- (BLBundleObject *)createBundleObjectWithPath:(NSString *)path {
	BLBundleObject *aBundle;

	aBundle = [BLBundleObject bundleObjectWithPath:path];

	if ([self.preferences objectForKey:BLDatabaseDocumentBundleNamingStyleKey]) {
		BLNamingStyle style = [[self.preferences objectForKey:BLDatabaseDocumentBundleReferencingStyleKey] intValue];
		[aBundle setNamingStyle:style];
	}
	if ([self.preferences objectForKey:BLDatabaseDocumentBundleReferencingStyleKey]) {
		BLReferencingStyle style = [[self.preferences objectForKey:BLDatabaseDocumentBundleReferencingStyleKey] intValue];

		[aBundle setReferencingStyle:style];
		if (style == BLRelativeReferencingStyle)
			[aBundle setPath:[[self pathCreator] documentRelativePathOfFullPath:[aBundle path]]];
	}

	return aBundle;
}

- (BLFileObject *)createFileObjectWithPath:(NSString *)path {
	return [BLFileObject fileObjectWithPath:path];
}

#pragma mark - Processing Threads

- (void)rescan:(BOOL)force {
	[self rescanObjects:_bundles force:force];
}

- (void)rescanObjects:(NSArray *)objects force:(BOOL)force {
	// Reimport Xcode projects
	if ([[self.preferences objectForKey:BLDatabaseDocumentRescanXcodeProjectsEnabledKey] boolValue]) {
		[[self processManager] enqueueStep:[[BLXcodeImportUpdateStep alloc] initWithXcodeProjectsOfBundles:[BLObject containingBundleObjectsFromArray:objects] inProject:self]];
	}

	// Rescan selected objects
	NSUInteger options = [self defaultInterpreterOptions];
	options |= (force) ? BLFileInterpreterIgnoreFileChangeDates : BLFileInterpreterNoOptions;
	[[self processManager] enqueueStep:[BLInterpreterStep stepForInterpertingObjects:objects withOptions:options parameters:[self defaultInterpreterParameters] andLanguages:[NSArray arrayWithObject:_referenceLanguage]]];

	[[self processManager] startWithName:@"Rescanning…"];
}

- (void)addFiles:(NSArray *)files {
	[[self processManager] enqueueStepAtFront:[BLInterpreterStep stepForInterpretingFiles:files withOptions:[self defaultInterpreterOptions] parameters:[self defaultInterpreterParameters]]];
	[[self processManager] startWithName:@"Adding files…"];
}

- (void)reimportFiles:(NSArray *)files forLanguages:(NSArray *)languages {
	NSMutableArray *actualLanguages = [NSMutableArray arrayWithArray:languages];
	[actualLanguages removeObject:[self referenceLanguage]];

	[[self processManager] enqueueStep:[BLInterpreterStep stepForInterpertingObjects:files withOptions:[self defaultInterpreterOptions] | BLFileInterpreterIgnoreFileChangeDates parameters:[self defaultInterpreterParameters] andLanguages:actualLanguages]];
	[[self processManager] startWithName:@"Reimporting…"];
}

- (void)synchronizeObjects:(NSArray *)objects forLanguages:(NSArray *)languages reinject:(BOOL)reinject {
	// Synchronize step
	[[self processManager] enqueueStep:[BLCreatorStep stepForCreatingObjects:objects inLanguages:languages reinject:reinject]];

	// Update Xcode project step
	if ([[self.preferences objectForKey:BLDatabaseDocumentUpdateXcodeProjectsEnabledKey] boolValue]) {
		// Create the options
		NSUInteger options = 0;
		if ([[self.preferences objectForKey:BLDatabaseDocumentUpdateXcodeAddMissingFilesKey] boolValue])
			options |= BLXcodeExporterAddMissingFiles;
		if ([[self.preferences objectForKey:BLDatabaseDocumentUpdateXcodeRemoveNotMatchingFilesKey] boolValue])
			options |= BLXcodeExporterRemoveOldFiles;

		// Create the limits
		float langLimit = BLXcodeExporterNoLanguageLimit;
		if ([[self.preferences objectForKey:BLDatabaseDocumentUpdateXcodeHasLanguageLimitKey] boolValue])
			langLimit = [[self.preferences objectForKey:BLDatabaseDocumentUpdateXcodeLanguageLimitKey] floatValue] / 100.;
		float fileLimit = BLXcodeExporterNoLanguageLimit;
		if ([[self.preferences objectForKey:BLDatabaseDocumentUpdateXcodeHasFileLimitKey] boolValue])
			fileLimit = [[self.preferences objectForKey:BLDatabaseDocumentUpdateXcodeFileLimitKey] floatValue] / 100.;

		[[self processManager] enqueueStep:[[BLXcodeExportUpdateStep alloc] initWithXcodeProjectsOfBundles:[BLObject containingBundleObjectsFromArray:objects] inProject:self withOptions:options languageLimit:langLimit fileLimit:fileLimit]];
	}

	// Start
	[[self processManager] startWithName:@"Synchronizing…"];
}

#pragma mark -

- (void)fileObjectChanged:(BLFileObject *)fileObject {
	[self updateChangeCount:NSChangeDone];
}

- (void)languageChanged:(NSString *)language {
	if (![[self languages] containsObject:language])
		[self addLanguage:language];
}

#pragma mark - Localizer Files

- (void)exportLocalizerFilesForLanguages:(NSArray *)languages withAdditionalOptions:(NSUInteger)options {
	// Remove reference language
	NSMutableArray *actualLanguages = [NSMutableArray arrayWithArray:languages];
	[actualLanguages removeObject:[self referenceLanguage]];

	// Get base path
	NSString *path = [self.preferences objectForKey:BLDatabaseDocumentLocalizerFilesPathKey];
	path = [[self pathCreator] fullPathOfDocumentRelativePath:path];

	// Generate default options
	if (![[self.preferences objectForKey:BLDatabaseDocumentLocalizerFilesSaveToOneFileKey] boolValue])
		options |= BLLocalizerExportStepSeparateFilesOption;
	if ([[self.preferences objectForKey:BLDatabaseDocumentLocalizerFilesIncludePreviewKey] boolValue])
		options |= BLLocalizerExportStepIncludePreviewOption;
	if ([[self.preferences objectForKey:BLDatabaseDocumentLocalizerFilesEmbedDictionaryKey] boolValue])
		options |= BLLocalizerExportStepEmbedDictionaryOption;
	if ([[self.preferences objectForKey:BLDatabaseDocumentLocalizerFilesEmbedDictionaryGuessesKey] boolValue])
		options |= BLLocalizerExportStepIncludeGuessesOption;
	if ([[self.preferences objectForKey:BLDatabaseDocumentLocalizerFilesCompressionKey] boolValue])
		options |= BLLocalizerExportStepCompressFilesOption;

	[[self processManager] enqueueStepGroup:[BLLocalizerExportStep stepGroupForExportingLocalizerFilesToPath:path fromObjects:[self bundles] forLanguages:actualLanguages withOptions:options]];
	[[self processManager] startWithName:@"Exporting Localizer files…"];
}

- (NSString *)pathForLocalizerFileOfLanguage:(NSString *)language {
	NSString *path = [self.preferences objectForKey:BLDatabaseDocumentLocalizerFilesPathKey];
	path = [[self pathCreator] fullPathOfDocumentRelativePath:path];

	path = [path stringByAppendingPathComponent:[BLLocalizerExportStep nameForLocalizerFileOfLanguage:language inDocument:self]];

	return path;
}

- (void)importLocalizerFiles:(NSArray *)files withOptions:(NSUInteger)options {
	[[self processManager] enqueueStepGroup:[BLLocalizerImportStep stepGroupForImportingLocalizerFiles:files withOptions:options]];
	[[self processManager] startWithName:@"Importing Localizer files…"];
}

@end
