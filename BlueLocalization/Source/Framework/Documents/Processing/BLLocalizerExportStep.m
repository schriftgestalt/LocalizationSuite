/*!
 @header
 BLLocalizerExportStep.m
 Created by Max on 08.05.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLLocalizerExportStep.h"

#import "BLDocumentFileWrapper.h"
#import "BLFileInternal.h"

/*!
 @abstract Internal methods of BLLocalizerExportStep.
 */
@interface BLLocalizerExportStep ()

/*!
 @abstract Adds an option to a step.
 */
- (void)_addOption:(NSUInteger)option;

/*!
 @abstract Internal initializer
 */
- (id)initForExportingObjects:(NSArray *)objects toPath:(NSString *)basePath withLanguages:(NSArray *)languages withOptions:(NSUInteger)options;

/*!
 @abstract Filter the dictionary for keys matching the exported keys.
 @discussion This is an extension point specifically for the LocTools framework. Thus the current implementation of this method does nothing.
 */
- (NSArray *)tailoredKeysFromAvailableKeys:(NSArray *)availableKeys;

/*!
 @abstract Convenience to update step's description.
 */
- (void)setDescriptionWithStatus:(NSString *)status;

@end

@implementation BLLocalizerExportStep

+ (NSArray *)stepGroupForExportingLocalizerFilesToPath:(NSString *)basePath fromObjects:(NSArray *)objects forLanguages:(NSArray *)languages withOptions:(NSUInteger)options {
	NSMutableArray *steps;
	BOOL openFolder;

	// Extract whether to open the folder from the options
	openFolder = (options & BLLocalizerExportStepOpenFolderOption) != 0;
	options &= ~((openFolder) ? BLLocalizerExportStepOpenFolderOption : 0);

	// Create steps
	steps = [NSMutableArray array];
	if (options & BLLocalizerExportStepSeparateFilesOption) {
		for (NSString *language in languages)
			[steps addObject:[[self alloc] initForExportingObjects:objects toPath:basePath withLanguages:[NSArray arrayWithObject:language] withOptions:options]];
	}
	else {
		[steps addObject:[[self alloc] initForExportingObjects:objects toPath:basePath withLanguages:languages withOptions:options]];
	}

	// Last step will open the folder
	if (openFolder)
		[[steps lastObject] _addOption:BLLocalizerExportStepOpenFolderOption];

	return steps;
}

- (id)initForExportingObjects:(NSArray *)objects toPath:(NSString *)basePath withLanguages:(NSArray *)languages withOptions:(NSUInteger)options {
	self = [super init];

	if (self) {
		_basePath = basePath;
		_objects = objects;
		_languages = languages;
		_options = options;
	}

	return self;
}

#pragma mark - Utilites

+ (NSString *)nameForLocalizerFileOfLanguage:(NSString *)language inDocument:(NSDocument<BLDocumentProtocol> *)document {
	NSString *name;

	// Exported file name
	name = [[[[document fileURL] path] lastPathComponent] stringByDeletingPathExtension];

	// Append localization file name
	if (language)
		name = [name stringByAppendingFormat:@"-%@", language];
	name = [name stringByAppendingPathExtension:[BLLocalizerFile pathExtension]];

	return name;
}

- (void)_addOption:(NSUInteger)option {
	_options |= option;
}

#pragma mark - Runtime

- (void)updateDescription {
	self.action = NSLocalizedStringFromTableInBundle(@"WritingLocalizer", @"BLProcessStep", [NSBundle bundleForClass:[self class]], nil);
	[self setDescriptionWithStatus:@""];
}

- (void)setDescriptionWithStatus:(NSString *)status {
	self.description = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"WritingLocalizerText", @"BLProcessStep", [NSBundle bundleForClass:[self class]], nil), [[BLLanguageTranslator descriptionsForLanguages:_languages] componentsJoinedByString:@", "], status];
}

- (void)perform {
	NSString *referenceLanguage, *path;
	id<BLDocumentProtocol> document;
	NSFileWrapper *wrapper;
	BOOL success;

	BLLogBeginGroup(@"Creating Localizer file for languages: %@", [_languages componentsJoinedByString:@", "]);

	document = [[self manager] document];

	// Make sure the reference language is included
	referenceLanguage = [document referenceLanguage];
	if (![_languages containsObject:referenceLanguage])
		_languages = [[NSArray arrayWithObject:referenceLanguage] arrayByAddingObjectsFromArray:_languages];

	// Update display with current set of languages
	[self setDescriptionWithStatus:NSLocalizedStringFromTableInBundle(@"WritingLocalizerWriting", @"BLProcessStep", [NSBundle bundleForClass:[self class]], nil)];

	// Gather options and properties
	NSUInteger options = BLFileActiveObjectsOnlyOption | BLFileClearChangedValuesOption;
	if (_options & BLLocalizerExportStepIncludePreviewOption)
		options |= BLFileIncludePreviewOption;

	NSMutableDictionary *properties = [NSMutableDictionary dictionary];
	[properties secureSetObject:referenceLanguage forKey:BLReferenceLanguagePropertyName];
	[properties secureSetObject:_languages forKey:BLLanguagesPropertyName];
	[properties secureSetObject:[NSDictionary dictionary] forKey:BLPreferencesPropertyName];

	// Create the dictionary, if whished
	if (_options & BLLocalizerExportStepEmbedDictionaryOption) {
		[self setDescriptionWithStatus:NSLocalizedStringFromTableInBundle(@"WritingLocalizerCompressing", @"BLProcessStep", [NSBundle bundleForClass:[self class]], nil)];

		// Get and minimize keys
		NSArray *keys = [[BLDictionaryController sharedInstance] availableKeys];
		keys = [self tailoredKeysFromAvailableKeys:keys];

		if ([self isCancelled])
			return;

		// Filter and normalize the dict
		NSDictionary *filter = [NSDictionary dictionaryWithObjectsAndKeys:
												 [NSNumber numberWithBool:YES], BLDictionaryLimitLanguagesFilterSetting,
												 [NSNumber numberWithBool:YES], BLDictionaryNormalizeFilterSetting,
												 referenceLanguage, BLDictionaryNormLanguageFilterSetting,
												 nil];

		// Create the dict, filtering the keys
		BLDictionaryDocument *dictionary = [[BLDictionaryDocument alloc] init];
		dictionary.filterSettings = filter;
		[dictionary addLanguages:_languages ignoreFilter:YES];
		[dictionary setKeys:keys];

		// Add to the file
		[properties secureSetObject:dictionary forKey:BLDictionaryPropertyName];

		// Reset status
		[self setDescriptionWithStatus:NSLocalizedStringFromTableInBundle(@"WritingLocalizerDictionary", @"BLProcessStep", [NSBundle bundleForClass:[self class]], nil)];
	}

	// Create the wrapper and write the file
	wrapper = [BLLocalizerFile createFileForObjects:_objects withOptions:options andProperties:properties];
	if (!wrapper) {
		BLLog(BLLogError, @"Failed encoding file.");
		BLLogEndGroup();
		return;
	}

	// Get the file name
	if (_options & BLLocalizerExportStepSeparateFilesOption) {
		NSMutableSet *languages = [NSMutableSet setWithArray:_languages];
		if ([languages count] > 1)
			[languages removeObject:referenceLanguage];

		path = [[self class] nameForLocalizerFileOfLanguage:[languages anyObject] inDocument:[[self manager] document]];
	}
	else {
		path = [[self class] nameForLocalizerFileOfLanguage:nil inDocument:[[self manager] document]];
	}

	// Add base path
	path = [_basePath stringByAppendingPathComponent:path];

	// Write
	BLLog(BLLogInfo, @"Writing Localizer File to path: %@", path);

	if (NSAppKitVersionNumber < NSAppKitVersionNumber10_6) {
		success = [wrapper writeToFile:path atomically:NO updateFilenames:NO];
	}
	else {
		wrapper = [[BLDocumentFileWrapper alloc] initWithFileWrapper:wrapper];

		NSUInteger options = (_options & BLLocalizerExportStepCompressFilesOption) ? BLDocumentFileWrapperSaveCompressedOption : 0;
		success = [wrapper writeToURL:[NSURL fileURLWithPath:path] options:options originalContentsURL:nil error:NULL];
	}

	if (!success) {
		BLLog(BLLogError, @"Error writing localizer file!");
		return;
	}

	// Open Folder
	if (_options & BLLocalizerExportStepOpenFolderOption) {
		[[self manager] enqueueStep:[BLGenericProcessStep genericStepWithBlock:^{
							NSString *showPath;

							if (self->_options & BLLocalizerExportStepCompressFilesOption)
								showPath = [[NSFileManager defaultManager] pathOfFile:path compressedUsing:BLFileManagerTarGzipCompression];
							else
								showPath = path;

							[[NSWorkspace sharedWorkspace] selectFile:showPath inFileViewerRootedAtPath:_basePath];
						}]];
	}

	// Open in Localizer
	if ((_options & BLLocalizerExportStepOpenInLocalizerOption) == BLLocalizerExportStepOpenInLocalizerOption) {
		[[self manager] enqueueStep:[BLGenericProcessStep genericStepWithBlock:^{
							[[NSWorkspace sharedWorkspace] openFile:path];
						}]];
	}

	// Done
	BLLogEndGroup();
}

- (NSArray *)tailoredKeysFromAvailableKeys:(NSArray *)availableKeys {
	return availableKeys;
}

@end
