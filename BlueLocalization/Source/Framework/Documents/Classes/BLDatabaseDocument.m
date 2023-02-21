/*!
 @header
 BLDatabaseDocument.m
 Created by Max Seelemann on 28.04.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLDatabaseDocument.h"
#import "BLDatabaseDocumentActions.h"
#import "BLDatabaseDocumentPreferences.h"

// Preference Keys
NSString *BLDatabaseDocumentBundleNamingStyleKey = @"defaultBundleNaming";
NSString *BLDatabaseDocumentBundleReferencingStyleKey = @"defaultBundleReferencing";

NSString *BLDatabaseDocumentLocalizerFilesSaveToOneFileKey = @"saveToOneFile";
NSString *BLDatabaseDocumentLocalizerFilesIncludePreviewKey = @"includeInterfacePreview";
NSString *BLDatabaseDocumentLocalizerFilesEmbedDictionaryKey = @"embedDictionary";
NSString *BLDatabaseDocumentLocalizerFilesEmbedDictionaryGuessesKey = @"embedDictionaryGuesses";
NSString *BLDatabaseDocumentLocalizerFilesPathKey = @"localizerSavePath";
NSString *BLDatabaseDocumentLocalizerFilesCompressionKey = @"compressLocalizationFiles";

NSString *BLDatabaseDocumentImportEmptyStringsKey = @"importEmptyStrings";
NSString *BLDatabaseDocumentDeactivateEmptyStringsKey = @"deactivateEmptyStrings";
NSString *BLDatabaseDocumentDeactivatePlaceholderStringsKey = @"deactivatePlaceholderStrings";
NSString *BLDatabaseDocumentIgnoredPlaceholderStringsKey = @"ignoredPlaceholderStrings";
NSString *BLDatabaseDocumentAutotranslateNewStringsKey = @"autotranslateNewStrings";
NSString *BLDatabaseDocumentMarkAutotranslatedAsNotChangedKey = @"markAutotranslatedAsNotChanged";
NSString *BLDatabaseDocumentValueChangesResetStringsKey = @"valueChangesResetStrings";

NSString *BLDatabaseDocumentRescanXcodeProjectsEnabledKey = @"rescanXcodeProjects";
NSString *BLDatabaseDocumentUpdateXcodeProjectsEnabledKey = @"updateXcodeProjects";
NSString *BLDatabaseDocumentUpdateXcodeAddMissingFilesKey = @"XcodeAddMissingFiles";
NSString *BLDatabaseDocumentUpdateXcodeRemoveNotMatchingFilesKey = @"XcodeRemoveNotMatchingFiles";
NSString *BLDatabaseDocumentUpdateXcodeHasLanguageLimitKey = @"XcodeHasLanguageLimit";
NSString *BLDatabaseDocumentUpdateXcodeLanguageLimitKey = @"XcodeLanguageLimit";
NSString *BLDatabaseDocumentUpdateXcodeHasFileLimitKey = @"XcodeHasFileLimit";
NSString *BLDatabaseDocumentUpdateXcodeFileLimitKey = @"XcodeFileLimit";

// Implementation
@implementation BLDatabaseDocument

- (id)init {
	self = [super init];

	if (self) {
		_pathCreator = [[BLPathCreator alloc] initWithDocument:self];
		_processManager = [[BLProcessManager alloc] initWithDocument:self];

		_bundles = [[NSMutableArray alloc] init];
		_languages = [[NSMutableArray alloc] init];
		_referenceLanguage = nil;
	}

	return self;
}

#pragma mark - Persistence

- (NSFileWrapper *)fileWrapperOfType:(NSString *)typeName error:(NSError **)outError {
	NSMutableDictionary *properties = [NSMutableDictionary dictionary];

	// Persistent properties
	if (_languages) {
		[properties setObject:_languages forKey:BLLanguagesPropertyName];
	}
	[properties setObject:_preferences forKey:BLPreferencesPropertyName];
	[properties setObject:_userPreferences forKey:BLUserPreferencesPropertyName];
	if (_referenceLanguage)
		[properties setObject:_referenceLanguage forKey:BLReferenceLanguagePropertyName];

	// Options
	NSUInteger options = 0;

	return [BLDatabaseFile createFileForObjects:_bundles withOptions:options andProperties:properties];
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError **)outError {
	NSDictionary *properties;
	NSArray *bundles = [BLDatabaseFile objectsFromFile:fileWrapper readingProperties:&properties];

	self.bundles = bundles;
	self.languages = [properties objectForKey:BLLanguagesPropertyName];

	[_userPreferences addEntriesFromDictionary:[properties objectForKey:BLUserPreferencesPropertyName]];
	[_preferences addEntriesFromDictionary:[properties objectForKey:BLPreferencesPropertyName]];

	_referenceLanguage = [properties objectForKey:BLReferenceLanguagePropertyName];

	return YES;
}

#pragma mark - Managing Objects

- (BLPathCreator *)pathCreator {
	return _pathCreator;
}

- (BLProcessManager *)processManager {
	return _processManager;
}

#pragma mark - Bundles

@synthesize bundles = _bundles;

- (void)addBundle:(BLBundleObject *)bundle {
	if ([_bundles containsObject:bundle])
		return;

	self.bundles = [self.bundles arrayByAddingObject:bundle];
	[self updateChangeCount:NSChangeDone];
}

- (void)removeBundle:(BLBundleObject *)bundle {
	if ([self.bundles indexOfObject:bundle] == NSNotFound)
		return;

	NSMutableArray *allBundles = [NSMutableArray arrayWithArray:self.bundles];
	[allBundles removeObject:bundle];
	self.bundles = allBundles;

	[self updateChangeCount:NSChangeDone];
}

#pragma mark - Languages

@synthesize languages = _languages;

- (void)addLanguage:(NSString *)language {
	if ([_languages containsObject:language])
		return;

	self.languages = [self.languages arrayByAddingObject:language];

	if (!_referenceLanguage)
		[self setReferenceLanguage:language];

	[self updateChangeCount:NSChangeDone];
}

- (void)removeLanguage:(NSString *)language {
	if ([self.languages indexOfObject:language] == NSNotFound)
		return;

	NSMutableArray *allLanguages = [NSMutableArray arrayWithArray:self.languages];
	[allLanguages removeObject:language];
	self.languages = allLanguages;

	[self updateChangeCount:NSChangeDone];
}

#pragma mark - Reference Language

- (NSString *)referenceLanguage {
	if (!_referenceLanguage)
		return @"en";
	else
		return _referenceLanguage;
}

- (void)setReferenceLanguage:(NSString *)referenceLanguage {
	_referenceLanguage = referenceLanguage;

	// Add language if it's not yet added
	if (_referenceLanguage && ![[self languages] containsObject:_referenceLanguage])
		[self addLanguage:_referenceLanguage];

	// Update change count
	[self updateChangeCount:NSChangeDone];
}

#pragma mark - Preferences

+ (NSDictionary *)defaultPreferences {
	NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithDictionary:[super defaultPreferences]];

	[prefs setObject:@(BLIdentifiersNamingStyle) forKey:BLDatabaseDocumentBundleNamingStyleKey];
	[prefs setObject:@(BLRelativeReferencingStyle) forKey:BLDatabaseDocumentBundleReferencingStyleKey];

	[prefs setObject:@NO forKey:BLDatabaseDocumentLocalizerFilesSaveToOneFileKey];
	[prefs setObject:@YES forKey:BLDatabaseDocumentLocalizerFilesIncludePreviewKey];
	[prefs setObject:@NO forKey:BLDatabaseDocumentLocalizerFilesEmbedDictionaryKey];
	[prefs setObject:@NO forKey:BLDatabaseDocumentLocalizerFilesEmbedDictionaryGuessesKey];
	[prefs setObject:@NO forKey:BLDatabaseDocumentLocalizerFilesCompressionKey];

	[prefs setObject:@YES forKey:BLDatabaseDocumentImportEmptyStringsKey];
	[prefs setObject:@YES forKey:BLDatabaseDocumentDeactivateEmptyStringsKey];
	[prefs setObject:@YES forKey:BLDatabaseDocumentDeactivatePlaceholderStringsKey];
	[prefs setObject:@YES forKey:BLDatabaseDocumentAutotranslateNewStringsKey];
	[prefs setObject:@YES forKey:BLDatabaseDocumentMarkAutotranslatedAsNotChangedKey];
	[prefs setObject:@NO forKey:BLDatabaseDocumentValueChangesResetStringsKey];

	[prefs setObject:@NO forKey:BLDatabaseDocumentRescanXcodeProjectsEnabledKey];
	[prefs setObject:@NO forKey:BLDatabaseDocumentUpdateXcodeProjectsEnabledKey];
	[prefs setObject:@YES forKey:BLDatabaseDocumentUpdateXcodeAddMissingFilesKey];
	[prefs setObject:@NO forKey:BLDatabaseDocumentUpdateXcodeRemoveNotMatchingFilesKey];
	[prefs setObject:@YES forKey:BLDatabaseDocumentUpdateXcodeHasLanguageLimitKey];
	[prefs setObject:@90.0 forKey:BLDatabaseDocumentUpdateXcodeLanguageLimitKey];
	[prefs setObject:@YES forKey:BLDatabaseDocumentUpdateXcodeHasFileLimitKey];
	[prefs setObject:@75.0 forKey:BLDatabaseDocumentUpdateXcodeFileLimitKey];

	return prefs;
}

+ (NSArray *)userPreferenceKeys {
	return [[super userPreferenceKeys] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:BLDatabaseDocumentLocalizerFilesPathKey, BLDatabaseDocumentLocalizerFilesSaveToOneFileKey, nil]];
}

@end
