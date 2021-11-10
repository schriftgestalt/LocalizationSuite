/*!
 @header
 BLLocalizerImportStep.m
 Created by Max on 09.05.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLLocalizerImportStep.h"

#import "BLDocumentFileWrapper.h"
#import "BLFileInternal.h"

/*!
 @abstract Internal methods of BLLocalizerExportStep.
 */
@interface BLLocalizerImportStep ()

/*!
 @abstract Internal initializer
 */
- (id)initForImportingLocalizerFile:(NSString *)path withOptions:(NSUInteger)options;

/*!
 @abstract The actual import of a file object.
 */
- (void)importFileObject:(BLFileObject *)import toObject:(BLFileObject *)original;

@end

@implementation BLLocalizerImportStep

+ (NSArray *)stepGroupForImportingLocalizerFiles:(NSArray *)filenames withOptions:(NSUInteger)options {
	NSMutableArray *group = [NSMutableArray arrayWithCapacity:[filenames count]];
	for (NSUInteger i = 0; i < [filenames count]; i++)
		[group addObject:[[self alloc] initForImportingLocalizerFile:[filenames objectAtIndex:i] withOptions:options]];
	return group;
}

- (id)initForImportingLocalizerFile:(NSString *)path withOptions:(NSUInteger)options {
	self = [super init];

	if (self) {
		_languages = nil;
		_options = options;
		_path = path;
	}

	return self;
}

#pragma mark - Runtime

- (void)updateDescription {
	self.action = NSLocalizedStringFromTableInBundle(@"ReadingLocalizer", @"BLProcessStep", [NSBundle bundleForClass:[self class]], nil);
	self.description = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"ReadingLocalizerText", @"BLProcessStep", [NSBundle bundleForClass:[self class]], nil), [_path lastPathComponent], [[BLLanguageTranslator descriptionsForLanguages:_languages] componentsJoinedByString:@", "]];
}

- (void)perform {
	NSDocument<BLDocumentProtocol> *document;
	NSString *referenceLanguage;
	BLPathCreator *pathCreator;
	NSMutableArray *languages;
	NSDictionary *properties;
	NSFileWrapper *wrapper;
	NSArray *objects;

	document = [[self manager] document];
	pathCreator = [document pathCreator];
	referenceLanguage = [document referenceLanguage];

	// Check existence
	if (![NSFileManager.defaultManager fileExistsAtPath:_path]) {
		BLLog(BLLogWarning, @"No localizer file found at path %@, skipping.", _path);
		return;
	}

	// Read in the file
	wrapper = [[BLDocumentFileWrapper alloc] initWithPath:_path];
	objects = [BLLocalizerFile objectsFromFile:wrapper readingProperties:&properties];

	if (!objects)
		return;

	// Get the languages and update display
	languages = [NSMutableArray arrayWithArray:[properties objectForKey:BLLanguagesPropertyName]];
	[languages removeObject:referenceLanguage];
	_languages = languages;

	[self updateDescription];

	// Get the file objects
	objects = [BLObject fileObjectsFromArray:objects];

	for (NSUInteger i = 0; i < [objects count]; i++) {
		BLFileObject *import, *original;
		NSString *path;

		import = [objects objectAtIndex:i];
		path = [pathCreator absolutePathForFile:import andLanguage:referenceLanguage];
		if (!path)
			path = [import path];

		// Try to find a matching original
		original = [document existingFileObjectWithPath:path];
		if (!original && [path containsString:@"en.lproj"] && [path containsString:@".xib"]) {
			path = [path stringByReplacingOccurrencesOfString:@"en.lproj" withString:@"Base.lproj"];
			original = [document existingFileObjectWithPath:path];
		}
		if (!original) {
			BLLog(BLLogWarning, @"Cannot find matching database file for imported file %@.", [import name]);
			continue;
		}
		original = [BLObjectProxy proxyWithObject:original];

		// Import the data
		[self importFileObject:import toObject:original];

		// Notify object changes
		if ([document respondsToSelector:@selector(fileObjectChanged:)])
			[document fileObjectChanged:original];
	}

	// Notify language changes
	if ([document respondsToSelector:@selector(languageChanged:)]) {
		for (NSUInteger l = 0; l < [_languages count]; l++)
			[document languageChanged:[_languages objectAtIndex:l]];
	}
}

- (void)importFileObject:(BLFileObject *)import toObject:(BLFileObject *)original {
	NSArray *importObjects, *originalObjects, *sorting;
	BOOL changesOnly, missingOnly, matchKeysByValue;
	NSString *referenceLanguage, *matchKey;

	changesOnly = (_options & BLLocalizerImportStepChangesOnlyOption) != 0;
	missingOnly = (_options & BLLocalizerImportStepMissingOnlyOption) != 0;
	matchKeysByValue = (_options & BLLocalizerImportStepMatchKeysByValueOption) != 0;

	importObjects = [import objects];
	originalObjects = [original objects];
	referenceLanguage = [[[self manager] document] referenceLanguage];

	// Sort object arrays
	if (!matchKeysByValue)
		matchKey = @"key";
	else
		matchKey = referenceLanguage;

	sorting = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:matchKey ascending:YES selector:@selector(compareAsString:)]];
	importObjects = [importObjects sortedArrayUsingDescriptors:sorting];
	originalObjects = [originalObjects sortedArrayUsingDescriptors:sorting];

	// Run through all key objects
	NSUInteger i, j;

	for (i = 0, j = 0; i < [originalObjects count] && j < [importObjects count]; i++) {
		@autoreleasepool {
			BLKeyObject *importKeyObject, *keyObject;
			NSArray *languages;

			// Get the key objects
			keyObject = [originalObjects objectAtIndex:i];
			importKeyObject = [importObjects objectAtIndex:j];

			// Search for the right import object
			while ([[keyObject valueForKey:matchKey] compareAsString:[importKeyObject valueForKey:matchKey]] == NSOrderedDescending && j < [importObjects count] - 1)
				importKeyObject = [importObjects objectAtIndex:++j];

			// No key object found
			if ([[keyObject valueForKey:matchKey] compareAsString:[importKeyObject valueForKey:matchKey]] != NSOrderedSame)
				continue;
			// No changes found
			if (changesOnly && ![importKeyObject didChange])
				continue;

			// Get the languages to import
			if (changesOnly)
				languages = [importKeyObject changedValues];
			else
				languages = [importKeyObject languages];

			// Import actual values
			for (NSUInteger l = 0; l < [languages count]; l++) {
				NSString *language = [languages objectAtIndex:l];

				// Do not import the reference language
				if ([language isEqual:referenceLanguage])
					continue;
				// Do not import strings if value is present and missing only is on
				if (missingOnly && ![keyObject isEmptyForLanguage:language])
					continue;
				// Do not import empty values
				if ([importKeyObject isEmptyForLanguage:language])
					continue;

				// Only import non-reference languages that are not empty
				[keyObject setObject:[importKeyObject objectForLanguage:language] forLanguage:language];
			}
		}
	}
}

@end
