/*!
 @header
 BLDatabaseFile.m
 Created by Max on 29.11.04.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLDatabaseFile.h"

#import "BLFileInternal.h"
#import "BLNibFileObject.h"
#import "BLStringsFileObject.h"


NSString *BLDatabaseFilePathExtension		= @"ldb";
NSString *BLDatabaseFileContentsFileName	= @"Contents.plist";
NSString *BLDatabaseFileResourcesDirectory	= @"Resources";

NSString *BLPreferencesPropertyName		= @"preferences";
NSString *BLUserPreferencesPropertyName	= @"userPreferences";


/*!
 @abstract Version History
 
 Version 1:		Bundle support, language identifiers.
 Version 2:		Relative write path referencing.
 Version 3:		Editable reference reflected in different change states.
 Version 4:		Switched to bundle-based database files.
 Version 5:		Added per-user preferences.
 */
#define BLDatabaseFileVersionNumber    5


@interface BLDatabaseFile (BLFileInternal)

/*!
 @abstract Converts a legacy file wrapper to the new bundle-based format.
 */
+ (NSMutableDictionary *)convertLegacyDatabaseFile:(NSData *)data;

/*!
 @abstract Update the contents of the Info.plist structure before instantiation the objects.
 */
+ (BOOL)updateDatabaseFile:(NSMutableDictionary *)dict;

/*!
 @abstract Perform update operations on the contained objects after having read them from the dictionary.
 */
+ (BOOL)updateDatabaseObjects:(NSMutableArray *)objects fromFile:(NSMutableDictionary *)dict;

@end

/*!
 @abstract Legacy methods of BLObject classes.
 */
@interface BLObject (BLObjectLegacy)

- (id)initWithCoder:(NSCoder *)aDecoder;

@end



@implementation BLDatabaseFile

+ (NSString *)pathExtension
{
	return BLDatabaseFilePathExtension;
}

+ (NSArray *)requiredProperties
{
	return [NSArray arrayWithObjects: BLLanguagesPropertyName, BLPreferencesPropertyName, BLUserPreferencesPropertyName, nil];
}


#pragma mark - Primary methods

+ (NSFileWrapper *)createFileForObjects:(NSArray *)bundles withOptions:(NSUInteger)options andProperties:(NSDictionary *)properties
{
    BLLog(BLLogInfo, @"Generating Database File");
	
	// Check input
	for (NSString *key in [self requiredProperties]) {
		if (![properties objectForKey: key])
			[NSException raise:NSInternalInconsistencyException format:@"Missing value for key %@", key];
	}
	if (![[BLObject bundleObjectsFromArray: bundles] isEqual: bundles])
		[NSException raise:NSInternalInconsistencyException format:@"Only bundles should be written to a database file!"];
    
	// Build document
	NSMutableDictionary *fileWrappers = [NSMutableDictionary dictionary];
	
    // Archive all bundles
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSNumber numberWithBool: (options & BLFileActiveObjectsOnlyOption) != 0], BLActiveObjectsOnlySerializationKey,
								[NSNumber numberWithBool: (options & BLFileClearChangedValuesOption) != 0], BLClearChangeInformationSerializationKey,
								[properties objectForKey: BLLanguagesPropertyName], BLLanguagesSerializationKey,
								nil];
	
	NSDictionary *resources = [NSDictionary dictionary];
    NSArray *archivedBundles = [BLPropertyListSerializer serializeObject:bundles withAttributes:attributes outWrappers:&resources];
    
	// Create Resources directory
	NSFileWrapper *wrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers: resources];
    [fileWrappers setObject:wrapper forKey:BLDatabaseFileResourcesDirectory];
    
    // Create Contents.plist
	NSMutableDictionary *contents = [NSMutableDictionary dictionary];
	[contents setObject:archivedBundles forKey:BLFileBundlesKey];
	[contents secureSetObject:[properties objectForKey: BLReferenceLanguagePropertyName] forKey:BLFileReferenceLanguageKey];
    [contents secureSetObject:[properties objectForKey: BLLanguagesPropertyName] forKey:BLFileLanguagesKey];
	[contents secureSetObject:[properties objectForKey: BLPreferencesPropertyName] forKey:BLFilePreferencesKey];
    [contents setObject:[NSNumber numberWithInt: BLDatabaseFileVersionNumber] forKey:BLFileVersionKey];
    
	wrapper = [[NSFileWrapper alloc] initRegularFileWithContents: [NSPropertyListSerialization dataFromPropertyList:contents format:NSPropertyListXMLFormat_v1_0 errorDescription:nil]];
	[fileWrappers setObject:wrapper forKey:BLDatabaseFileContentsFileName];
	
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
	BLLogBeginGroup(@"Reading Database File");
	
	NSMutableDictionary *userPrefs = [NSMutableDictionary dictionary];
	NSMutableDictionary *contents = nil;
	NSMutableArray *bundles = nil;
    
	// Check version
	if (![wrapper isDirectory]) {
		// Legacy support
		contents = [self convertLegacyDatabaseFile: [wrapper regularFileContents]];
		bundles = [NSMutableArray arrayWithArray: [contents objectForKey: BLFileBundlesKey]];
		
		if (!contents) {
			BLLogEndGroup();
			return nil;
		}
	} else {
		// Read regular file
		NSDictionary *fileWrappers = [wrapper fileWrappers];
		
		// Unarchive contents
		contents = [NSPropertyListSerialization propertyListFromData:[[fileWrappers objectForKey: BLDatabaseFileContentsFileName] regularFileContents] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:nil errorDescription:nil];
		if (![self updateDatabaseFile: contents]) {
			BLLogEndGroup();
			return nil;
		}
		
		// Deserialize bundles
		NSArray *inBundles = [contents objectForKey: BLFileBundlesKey];
		inBundles = [BLPropertyListSerializer objectWithPropertyList:inBundles fileWrappers:[[fileWrappers objectForKey: BLDatabaseFileResourcesDirectory] fileWrappers]];
		bundles = [NSMutableArray arrayWithArray: inBundles];
		
		// Update bundles
		if (![self updateDatabaseObjects:bundles fromFile:contents]) {
			BLLogEndGroup();
			return nil;
		}
		
		// Collect user preferences
		for (NSString *file in [fileWrappers allKeys]) {
			if (![[file pathExtension] isEqual: BLFileUserFileExtension])
				continue;
			
			[userPrefs setObject:[NSPropertyListSerialization propertyListFromData:[[fileWrappers objectForKey: file] regularFileContents] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:nil errorDescription:nil] forKey:[file stringByDeletingPathExtension]];
		}
	}
    
    // Generate properties
    if (outProperties) {
        NSMutableDictionary *properties = [NSMutableDictionary dictionary];
        
		[properties secureSetObject:[contents objectForKey: BLFileReferenceLanguageKey] forKey:BLReferenceLanguagePropertyName];
        [properties secureSetObject:[contents objectForKey: BLFileLanguagesKey] forKey:BLLanguagesPropertyName];
        [properties secureSetObject:[contents objectForKey: BLFilePreferencesKey] forKey:BLPreferencesPropertyName];
		[properties secureSetObject:userPrefs forKey:BLUserPreferencesPropertyName];
        
        (*outProperties) = properties;
     }
    
	BLLogEndGroup();
    return bundles;
}


#pragma mark - Update methods

+ (NSMutableDictionary *)convertLegacyDatabaseFile:(NSData *)data
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: [NSKeyedUnarchiver unarchiveObjectWithData: data]];
    NSUInteger version = [[dict objectForKey: BLFileVersionKey] intValue];
	
	// Upgrade old versions
	if (version < 1) {
        NSMutableArray *languages;
        BLBundleObject *bundle;
        
        // Create bundle
        bundle = [BLBundleObject bundleObjectWithPath: [dict objectForKey: @"basePath"]];
        [bundle setFiles: [dict objectForKey: @"files"]];
        [dict setObject:[NSArray arrayWithObject: bundle] forKey:@"bundles"];
        
        // Fix languages
        [[bundle files] makeObjectsPerformSelector: @selector(fixLanguages)];
        [dict setObject:[BLLanguageTranslator identifierForLanguage: [dict objectForKey: @"referenceLanguage"]] forKey:@"referenceLanguage"];
        
        languages = [NSMutableArray arrayWithArray: [dict objectForKey: @"languages"]];
        for (unsigned i=0; i<[languages count]; i++)
            [languages replaceObjectAtIndex:i withObject:[BLLanguageTranslator identifierForLanguage: [languages objectAtIndex: i]]];
        [dict setObject:languages forKey:@"languages"];
		
        [dict setObject:[NSDictionary dictionary] forKey:@"preferences"];
    }
    if (version < 2) {
        NSMutableDictionary *prefs;
        
        // Update preferences
        prefs = [NSMutableDictionary dictionaryWithDictionary: [dict objectForKey: @"preferences"]];
        [prefs setObject:nil forKey:@"lastSavePath"];
        [dict setObject:prefs forKey:@"preferences"];
    }
	if (version < 3) {
		NSString *reference = [dict objectForKey: @"referenceLanguage"];
		
		for (BLBundleObject *bundle in [dict objectForKey: @"bundles"]) {
			for (BLFileObject *file in bundle.files) {
				if ([file valueDidChange: reference]) {
					[file setValue:reference didChange:NO];
					file.referenceChanged = YES;
				}
			}
		}
	}
	
	// Build the new document structure
	NSMutableDictionary *contents = [NSMutableDictionary dictionary];
	[contents secureSetObject:[dict objectForKey: @"bundles"] forKey:BLFileBundlesKey];
	[contents secureSetObject:[dict objectForKey: @"languages"] forKey:BLFileLanguagesKey];
	[contents secureSetObject:[dict objectForKey: @"preferences"] forKey:BLFilePreferencesKey];
	[contents secureSetObject:[dict objectForKey: @"referenceLanguage"] forKey:BLFileReferenceLanguageKey];
	
	return contents;
}

+ (BOOL)updateDatabaseFile:(NSMutableDictionary *)dict
{
	NSUInteger version = [[dict objectForKey: BLFileVersionKey] intValue];
	
	if (version < 5) {
		NSMutableDictionary *prefs = [dict objectForKey: BLFilePreferencesKey];
		[prefs removeObjectsForKeys: [BLDatabaseDocument userPreferenceKeys]];
	}
	
	return YES;
}

+ (BOOL)updateDatabaseObjects:(NSMutableArray *)bundles fromFile:(NSMutableDictionary *)dict
{
//	NSUInteger version = [[dict objectForKey: BLFileVersionKey] intValue];
	
	return YES;
}

@end


@implementation BLObject (BLObjectLegacy)

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    
	if (self) {
		[self setChangeDate: [aDecoder decodeObjectForKey: @"ObjectChangeDate"]];
		[self setFlags: [aDecoder decodeIntForKey: @"ObjectFlags"]];
		
		[self setErrors: [aDecoder decodeObjectForKey: @"ObjectErrors"]];
		[_changedValues setArray: [aDecoder decodeObjectForKey: @"ObjectChangedValues"]];
	}
    
    return self;
}

@end

@implementation BLBundleObject (BLObjectLegacy)

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    
	if (self) {
		[self setFiles: [aDecoder decodeObjectForKey: @"BundleObjectFiles"]];
		[self setName: [aDecoder decodeObjectForKey: @"BundleObjectName"]];
		[self setNamingStyle: [aDecoder decodeIntForKey: @"BundleObjectNamingStyle"]];
		[self setPath: [aDecoder decodeObjectForKey: @"BundleObjectPath"]];
		[self setReferencingStyle: [aDecoder decodeIntForKey: @"BundleObjectReferencingStyle"]];
		
		[_changedValues setArray: [aDecoder decodeObjectForKey: @"ObjectChangedValues"]];
	}
    
    return self;
}

@end

@implementation BLFileObject (BLObjectLegacy)

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    
	if (self) {
		[self setCustomFileType: [aDecoder decodeObjectForKey: @"FileObjectCustomType"]];
		[self setHashValue: [aDecoder decodeObjectForKey: @"FileObjectHashValue"]];
		[self setObjects: [aDecoder decodeObjectForKey: @"FileObjectObjects"]];
		[self setOldObjects: [aDecoder decodeObjectForKey: @"FileObjectOldObjects"]];
		[self setPath: [aDecoder decodeObjectForKey: @"FileObjectPath"]];
		
		[_changedValues setArray: [aDecoder decodeObjectForKey: @"ObjectChangedValues"]];
	}
    
    return self;
}

@end

@implementation BLStringsFileObject (BLObjectLegacy)

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    
	if (self) {
		[self setIsPlistStringsFile: [aDecoder decodeBoolForKey: @"StringsFileObjectPlistFile"]];
	}
    
    return self;
}

@end

@implementation BLNibFileObject (BLObjectLegacy)

- (void)writeBackup:(NSData *)backup toFile:(NSString *)path
{	
	// Backup should exist
	if (!backup)
		return;
	
	NSTask *tar = [[NSTask alloc] init];
	
	// Create temp folder
	NSString *tempFolder = [path stringByDeletingPathExtension];
	tempFolder = [tempFolder stringByAppendingFormat: @".%d", arc4random()];
	[[NSFileManager defaultManager] createDirectoryAtPath:tempFolder withIntermediateDirectories:NO attributes:nil error:NULL];
	
	NSString *tempPath = [tempFolder stringByAppendingPathComponent: [path lastPathComponent]];
	tempPath = [tempPath stringByAppendingPathExtension: @"tbz"];
	
	NSError *error = nil;
	if (![backup writeToFile:tempPath options:0 error:&error]) {
		BLLog(BLLogInfo, @"Cannot write backup. Reason: %@", [error localizedFailureReason]);
		return;
	}
	
	// set up
	[tar setLaunchPath: @"/usr/bin/tar"];
	[tar setCurrentDirectoryPath: tempFolder];
	[tar setArguments: [NSArray arrayWithObjects: @"-xjf", [tempPath lastPathComponent], [[self name] lastPathComponent], nil]];
	[tar setStandardError: BLLogOpenPipe(@"Extracting backup using Tar")];
    
    // run
	[tar launch];
	
	NSUInteger cycles = 0;
	while ([tar isRunning] && cycles++ < 500)
		[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.01]];
	
	// Check for result
	tempPath = [tempFolder stringByAppendingPathComponent: [[self name] lastPathComponent]];
	if (![[NSFileManager defaultManager] fileExistsAtPath: tempPath]) {
		BLLog(BLLogInfo, @"Extraction of backup failed. Result file not found");
	} else {
		[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
		[[NSFileManager defaultManager] moveItemAtPath:tempPath toPath:path error:NULL];
	}
	
	// Remove temporary folder
	[[NSFileManager defaultManager] removeItemAtPath:tempFolder error:NULL];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    
	if (self) {
		// Stage backup and re-import it as fiel wrapper
		NSString *tmpPath = @"/tmp/locsuitetmp";
		[self writeBackup:[aDecoder decodeObjectForKey: @"NibFileObjectBackup"] toFile:tmpPath];
		
		NSFileWrapper *wrapper = [[NSFileWrapper alloc] initWithPath: tmpPath];
		[[NSFileManager defaultManager] removeItemAtPath:tmpPath error:NULL];
		[wrapper setPreferredFilename: [[self name] lastPathComponent]];
		
		// Set the right version for all languages
		NSMutableSet *languages = [NSMutableSet set];
		for (BLKeyObject *key in self.objects)
			[languages addObjectsFromArray: [key languages]];
		for (NSString *lang in languages)
			[self setVersion:1 forLanguage:lang];
		
		// Set the attached backup
		if (wrapper)
			[self setAttachedObject:wrapper forKey:BLBackupAttachmentKey version:1];
	}
    
    return self;
}

@end

@implementation BLKeyObject (BLObjectLegacy)

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
	
	if (self) {
		// values first
		[self setComment: [aDecoder decodeObjectForKey: @"KeyObjectComment"]];
		[self setKey: [aDecoder decodeObjectForKey: @"KeyObjectKey"]];
		
		// strings
		if ([[self class] classOfObjects] == [NSString class])
			[_objects setDictionary: [aDecoder decodeObjectForKey: @"KeyObjectStrings"]];
		else
			[_objects setDictionary: [aDecoder decodeObjectForKey: @"KeyObjectData"]];
		
		// set changes
		[_changedValues setArray: [aDecoder decodeObjectForKey: @"KeyObjectChangedValues"]];
	}
    
    return self;
}

@end


