/*!
 @header
 BLLocalizerFile.m
 Created by Max on 29.11.04.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLLocalizerFile.h"
#import "BLFileInternal.h"


NSString *BLLocalizerFilePathExtension		= @"loc";
NSString *BLLocalizerFileContentsFileName	= @"Contents.plist";
NSString *BLLocalizerFileDictionaryFileName	= @"Dictionary.lod";
NSString *BLLocalizerFileResourcesDirectory	= @"Resources";

NSString *BLIncludesPreviewPropertyName	= @"includesPreview";
NSString *BLDictionaryPropertyName		= @"dictionary";


/*!
 @abstract Version History
 
 Version 1:		Transition form arbitrary language names to standardized language identifiers.
 Version 2:		Drops support for non-bundle (file) localizer files, includes preview files for all kind of files.
 Version 3:		Adds support for embedded dictionaries.
 Version 4:		Switched to new common bundle format.
 */
#define BLLocalizerFileVersionNumber    4


@interface BLLocalizerFile (BLFileInternal)

+ (NSArray *)excludedFilenames;

+ (BOOL)updateLocalizerFile:(NSMutableDictionary *)dict;
+ (BOOL)updateLocalizerObjects:(NSMutableArray *)objects fromFile:(NSMutableDictionary *)dict;

@end

@interface BLObject (BLLocalizerFileUtilities)

- (void)fixLanguages;

@end


@implementation BLLocalizerFile

+ (NSString *)pathExtension
{
	return BLLocalizerFilePathExtension;
}

+ (NSArray *)requiredProperties
{
	return [NSArray arrayWithObjects: BLLanguagesPropertyName, BLReferenceLanguagePropertyName, BLFilePreferencesKey, nil];
}

+ (NSArray *)excludedFilenames
{
	return [NSArray arrayWithObjects: @".svn", nil];
}


#pragma mark - Primary methods

+ (NSFileWrapper *)createFileForObjects:(NSArray *)bundles withOptions:(NSUInteger)options andProperties:(NSDictionary *)properties
{
    BLLog(BLLogInfo, @"Generating Localizer File for languages: %@", [[properties objectForKey: BLLanguagesPropertyName] componentsJoinedByString: @", "]);
	
	// Check input
	for (NSString *key in [self requiredProperties]) {
		if (![properties objectForKey: key])
			[NSException raise:NSInternalInconsistencyException format:@"Missing value for key %@", key];
	}
	
	// General setup
    NSMutableDictionary *fileWrappers = [NSMutableDictionary dictionary];
	
    // Archive all bundles
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithBool: (options & BLFileActiveObjectsOnlyOption) != 0], BLActiveObjectsOnlySerializationKey,
								[NSNumber numberWithBool: (options & BLFileClearChangedValuesOption) != 0], BLClearChangeInformationSerializationKey,
								[NSNumber numberWithBool: (options & BLFileIncludePreviewOption) == 0], BLClearAllBackupsSerializationKey,
								[properties objectForKey: BLLanguagesPropertyName], BLLanguagesSerializationKey,
								nil];
	
	NSDictionary *resources = [NSDictionary dictionary];
    NSArray *archivedBundles = [BLPropertyListSerializer serializeObject:[BLObject bundleObjectsFromArray: bundles] withAttributes:attributes outWrappers:&resources];
    
	// Create Resources directory
	NSFileWrapper *wrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers: resources];
    [fileWrappers setObject:wrapper forKey:BLLocalizerFileResourcesDirectory];
	
    // Create Contents.plist
	NSMutableDictionary *contents = [NSMutableDictionary dictionary];
	[contents setObject:archivedBundles forKey:BLFileBundlesKey];
	[contents secureSetObject:[properties objectForKey: BLReferenceLanguagePropertyName] forKey:BLFileReferenceLanguageKey];
    [contents secureSetObject:[properties objectForKey: BLLanguagesPropertyName] forKey:BLFileLanguagesKey];
	[contents secureSetObject:[properties objectForKey: BLPreferencesPropertyName] forKey:BLFilePreferencesKey];
    [contents setObject:[NSNumber numberWithBool: (options & BLFileIncludePreviewOption) != 0] forKey:BLFileIncludesPreviewKey];
    [contents setObject:[NSNumber numberWithInt: BLLocalizerFileVersionNumber] forKey:BLFileVersionKey];
    
    // Create file wrapper for contents.plist file
    wrapper = [[NSFileWrapper alloc] initRegularFileWithContents: [NSPropertyListSerialization dataFromPropertyList:contents format:NSPropertyListXMLFormat_v1_0 errorDescription:nil]];
    [fileWrappers setObject:wrapper forKey:BLLocalizerFileContentsFileName];
	
	// Embedded dictionary
	BLDictionaryDocument *dictionary = [properties objectForKey: BLDictionaryPropertyName];
	if (dictionary) {
		wrapper = [dictionary fileWrapperOfType:nil error:NULL];
		[fileWrappers secureSetObject:wrapper forKey:BLLocalizerFileDictionaryFileName];
	}
	
	// Create per-user settings
	NSDictionary *userPreferences = [properties objectForKey: BLUserPreferencesPropertyName];
	for (NSString *username in userPreferences) {
		NSDictionary *settings = [userPreferences objectForKey: username];
		NSString *filename = [username stringByAppendingPathExtension: BLFileUserFileExtension];
		
		wrapper = [[NSFileWrapper alloc] initRegularFileWithContents: [NSPropertyListSerialization dataFromPropertyList:settings format:NSPropertyListXMLFormat_v1_0 errorDescription:nil]];
		[fileWrappers setObject:wrapper forKey:filename];
	}
    
    return [[NSFileWrapper alloc] initDirectoryWithFileWrappers: fileWrappers];
}

+ (NSArray *)objectsFromFile:(NSFileWrapper *)wrapper readingProperties:(NSDictionary **)outProperties
{
	BLLogBeginGroup(@"Reading Localizer File");
    
    // Init
    NSDictionary *fileWrappers = [wrapper fileWrappers];
	
	// Unarchive contents
    NSMutableDictionary *contents = [NSPropertyListSerialization propertyListFromData:[[fileWrappers objectForKey: BLLocalizerFileContentsFileName] regularFileContents] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:nil errorDescription:nil];
    if (![self updateLocalizerFile: contents]) {
		BLLogEndGroup();
		return nil;
	}
	
    // Deserialize bundles
	NSArray *inBundles = [contents objectForKey: BLFileBundlesKey];
	inBundles = [BLPropertyListSerializer objectWithPropertyList:inBundles fileWrappers:[[fileWrappers objectForKey: BLLocalizerFileResourcesDirectory] fileWrappers]];
	NSMutableArray *bundles = [NSMutableArray arrayWithArray: inBundles];
	    
    // Update bundles
    if (![self updateLocalizerObjects:bundles fromFile:contents]) {
		BLLogEndGroup();
		return nil;
	}
	
	// Collect user preferences
	NSMutableDictionary *userPrefs = [NSMutableDictionary dictionary];
	for (NSString *file in [fileWrappers allKeys]) {
		if (![[file pathExtension] isEqual: BLFileUserFileExtension])
			continue;
		
		[userPrefs setObject:[NSPropertyListSerialization propertyListFromData:[[fileWrappers objectForKey: file] regularFileContents] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:nil errorDescription:nil] forKey:[file stringByDeletingPathExtension]];
	}
    
    // Generate properties
    if (outProperties != nil) {
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        
		[properties secureSetObject:[contents objectForKey: BLFileReferenceLanguageKey] forKey:BLReferenceLanguagePropertyName];
        [properties secureSetObject:[contents objectForKey: BLFileLanguagesKey] forKey:BLLanguagesPropertyName];
        [properties secureSetObject:[contents objectForKey: BLFileIncludesPreviewKey] forKey:BLIncludesPreviewPropertyName];
        [properties secureSetObject:[contents objectForKey: BLFilePreferencesKey] forKey:BLPreferencesPropertyName];
		[properties secureSetObject:userPrefs forKey:BLUserPreferencesPropertyName];
		
		// Load dictionary
		NSFileWrapper *dictionaryWrapper = [fileWrappers objectForKey: BLLocalizerFileDictionaryFileName];
		BLDictionaryDocument *dictionary = [[BLDictionaryDocument alloc] init];
		if (dictionaryWrapper && [dictionary readFromFileWrapper:dictionaryWrapper ofType:nil error:NULL])
			[properties secureSetObject:dictionary forKey:BLDictionaryPropertyName];
		
        (*outProperties) = properties;
     }
    
	BLLogEndGroup();
    return bundles;
}


#pragma mark - Update methods

+ (BOOL)updateLocalizerFile:(NSMutableDictionary *)dict
{
    NSUInteger version = [[dict objectForKey: BLFileVersionKey] intValue];
	
	if (version < 2) {
		if (![dict objectForKey: BLFileBundlesKey]) {
			BLLog(BLLogError, @"Old Localizer files without bundles are no longer supported!");
			return NO;
		}
	}
	if (version < 4) {
		if ([[dict objectForKey: BLFileIncludesPreviewKey] boolValue]) {
			[dict setObject:[NSNumber numberWithBool: NO] forKey:BLFileIncludesPreviewKey];
			BLLog(BLLogWarning, @"Interface preview not supported for legacy Localizer files. Please re-create it.");
		}
	}
	
	return YES;
}

+ (BOOL)updateLocalizerObjects:(NSMutableArray *)bundles fromFile:(NSMutableDictionary *)dict
{
    NSUInteger version = [[dict objectForKey: BLFileVersionKey] intValue];
    
    if (version < 1) {
        NSMutableArray *languages;
        NSUInteger i;
        
        [bundles makeObjectsPerformSelector: @selector(fixLanguages)];
        
        languages = [dict objectForKey: BLFileLanguagesKey];
        for (i=0; i<[languages count]; i++)
            [languages replaceObjectAtIndex:i withObject:[BLLanguageTranslator identifierForLanguage: [languages objectAtIndex: i]]];
        
        [dict setObject:[BLLanguageTranslator identifierForLanguage: [dict objectForKey: BLFileReferenceLanguageKey]] forKey:BLFileReferenceLanguageKey];
     }
	
	return YES;
}

@end

@implementation BLObject (BLLocalizerFileUtilities)

- (void)fixLanguages
{
    [[self objects] makeObjectsPerformSelector: @selector(fixLanguages)];
}

@end

@implementation BLKeyObject (BLLocalizerFileUtilities)

- (void)fixLanguages
{
    NSMutableArray *changes;
    NSArray *languages;
    NSUInteger i;
    
    changes = [[NSMutableArray alloc] initWithCapacity: [[self changedValues] count]];
    
    // update changes
    for (i=0; i<[[self changedValues] count]; i++) {
        if ([BLLanguageTranslator localeForLanguage: [[self changedValues] objectAtIndex: i]])
            [changes addObject: [BLLanguageTranslator identifierForLanguage: [[self changedValues] objectAtIndex: i]]];
        else
            [changes addObject: [[self changedValues] objectAtIndex: i]];
    }
    
    // update strings
    languages = [self languages];
    for (i=0; i<[languages count]; i++) {
        id object = [self objectForLanguage: [languages objectAtIndex: i]];
        [self setObject:object forLanguage:[BLLanguageTranslator identifierForLanguage: [languages objectAtIndex: i]]];
        [self setObject:nil forLanguage:[languages objectAtIndex: i]];
    }
    
    // save changes
    [self setChangedValues: changes];
}

@end


