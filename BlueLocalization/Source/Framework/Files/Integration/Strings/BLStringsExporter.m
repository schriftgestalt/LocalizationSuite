/*!
 @header
 BLStringsExporter.m
 Created by max on 27.02.09.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLStringsExporter.h"

#import "BLStringKeyObject.h"


NSString *BLStringsExporterNibName	= @"BLStringsExporter";

NSString *BLStringsExporterIncludeCommentsKeyPath		= @"stringsExporter.includeComments";
NSString *BLStringsExporterMissingStringsOnlyKeyPath	= @"stringsExporter.missingStringsOnly";
NSString *BLStringsExporterSeparateFilesKeyPath			= @"stringsExporter.separateFiles";
NSString *BLStringsExporterIncludeOthersKeyPath			= @"stringsExporter.includeOthers";
NSString *BLStringsExporterGroupByBundleKeyPath			= @"stringsExporter.groupByBundle";
NSString *BLStringsExporterExportAllFilesKeyPath		= @"stringsExporter.exportAllFiles";
NSString *BLStringsExporterExportReferenceKeyPath		= @"stringsExporter.exportReference";

NSString *kStringsPathExtension				= @"strings";
NSString *BLStringsExporterExportFileName	= @"Localizable";


@interface BLStringsExporter (BLStringsExporterInternal)

+ (id)_sharedInstance;

- (void)exportStringsFromObjects:(NSArray *)objects forLanguages:(NSArray *)languages inDocument:(NSDocument<BLDocumentProtocol> *)document;

@end

@interface BLFileObject (BLStringsExporterExtension)

- (NSDictionary *)dictionaryFromLanguage:(NSString *)language1 toLanguage:(NSString *)language2 ofKeyObjectsPassingTest:(BOOL (^)(BLKeyObject *object))test;
- (NSDictionary *)commentsWithKeysForLanguage:(NSString *)language;

@end


@implementation BLStringsExporter

id __sharedStringsExporter;

- (void)dealloc
{
    __sharedStringsExporter = nil;
}

+ (id)_sharedInstance
{
    if (__sharedStringsExporter == nil)
        __sharedStringsExporter = [[self alloc] init];
    
    return __sharedStringsExporter;
}


#pragma mark - Public Access

+ (void)exportStringsFromObjects:(NSArray *)objects forLanguages:(NSArray *)languages inDocument:(NSDocument<BLDocumentProtocol> *)document
{
	[[self _sharedInstance] exportStringsFromObjects:objects forLanguages:languages inDocument:document];
}


#pragma mark - User Interaction

- (void)initUserDefaults
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if (![defaults objectForKey: BLStringsExporterIncludeCommentsKeyPath])
		[defaults setBool:YES forKey:BLStringsExporterIncludeCommentsKeyPath];
	if (![defaults objectForKey: BLStringsExporterMissingStringsOnlyKeyPath])
		[defaults setBool:NO forKey:BLStringsExporterMissingStringsOnlyKeyPath];
	if (![defaults objectForKey: BLStringsExporterSeparateFilesKeyPath])
		[defaults setBool:YES forKey:BLStringsExporterSeparateFilesKeyPath];
	if (![defaults objectForKey: BLStringsExporterIncludeOthersKeyPath])
		[defaults setBool:YES forKey:BLStringsExporterIncludeOthersKeyPath];
	if (![defaults objectForKey: BLStringsExporterGroupByBundleKeyPath])
		[defaults setBool:YES forKey:BLStringsExporterGroupByBundleKeyPath];
	if (![defaults objectForKey: BLStringsExporterExportAllFilesKeyPath])
		[defaults setBool:YES forKey:BLStringsExporterExportAllFilesKeyPath];
	if (![defaults objectForKey: BLStringsExporterExportReferenceKeyPath])
		[defaults setBool:NO forKey:BLStringsExporterExportReferenceKeyPath];
}

- (void)exportStringsFromObjects:(NSArray *)objects forLanguages:(NSArray *)languages inDocument:(NSDocument<BLDocumentProtocol> *)document
{
	// Remember the objects
	[self willChangeValueForKey: @"languages"];
	_languages = languages;
	_document = document;
	[self didChangeValueForKey: @"languages"];
	
	// Set some defaults
	[self initUserDefaults];
    
	// Open the save panel
    NSSavePanel *panel = [NSSavePanel savePanel];
	
	if (!optionsView)
		[NSBundle loadNibNamed:BLStringsExporterNibName owner:self];
	
    [panel setCanCreateDirectories: YES];
	[panel setAccessoryView: optionsView];
	[[panel defaultButtonCell] setTitle: NSLocalizedStringFromTableInBundle(@"Export", @"Localizable", [NSBundle bundleForClass: [self class]], nil)];
	
    [panel beginSheetModalForWindow:[document windowForSheet] completionHandler: ^(NSInteger returnCode) {
		 [panel close];
		 
		 if (returnCode != NSFileHandlingPanelOKButton)
			 return;
		 
		 // Read options
		 NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		 NSUInteger options = 0;
		 
		 if ([defaults boolForKey: BLStringsExporterIncludeCommentsKeyPath])
			 options |= BLStringsExporterIncludeComments;
		 if ([defaults boolForKey: BLStringsExporterMissingStringsOnlyKeyPath])
			 options |= BLStringsExporterMissingStringsOnly;
		 if ([defaults boolForKey: BLStringsExporterSeparateFilesKeyPath])
			 options |= BLStringsExporterSeparateFiles;
		 if ([defaults boolForKey: BLStringsExporterIncludeOthersKeyPath])
			 options |= BLStringsExporterIncludeOthers;
		 if ([defaults boolForKey: BLStringsExporterGroupByBundleKeyPath])
			 options |= BLStringsExporterGroupByBundle;
		 
		 BOOL exportReference = [defaults boolForKey: BLStringsExporterExportReferenceKeyPath];
		 BOOL exportAllFiles = [defaults boolForKey: BLStringsExporterExportAllFilesKeyPath];
		 
		 // Preprocess arguments
		 NSArray *exportObjects = objects;
		 if (exportAllFiles) {
			 if ([document respondsToSelector: @selector(bundles)])
				 exportObjects = [(id)document bundles];
		 }
		 
		 // Enqueue process steps
		 NSMutableArray *steps = [NSMutableArray array];
		 NSString *reference = [document referenceLanguage];
		 NSString *path = [[panel URL] path];
		 
		 for (NSString *language in languages) {
			 if ([language isEqual: reference] && !exportReference)
				 continue;
			 
			 // Create Step
			 BLGenericProcessStep *step = [BLGenericProcessStep genericStepWithBlock: ^{
				[[self class] exportStringsFromObjects:exportObjects forLanguage:language andReferenceLanguage:reference withOptions:options toPath:path];
			 }];
			 
			 [step setAction: NSLocalizedStringFromTableInBundle(@"ExportingStrings", @"BLProcessStep", [NSBundle bundleForClass: [self class]], nil)];
			 [step setDescription: [NSString stringWithFormat: NSLocalizedStringFromTableInBundle(@"ExportingStringsText", @"BLProcessStep", [NSBundle bundleForClass: [self class]], nil), [BLLanguageTranslator descriptionForLanguage: language]]];
			 
			 [steps addObject: step];
		 }
		 
		 if ([document respondsToSelector: @selector(processManager)] && [document processManager]) {
			 [[document processManager] enqueueStepGroup: steps];
			 [[document processManager] startWithName: @"Exporting strings files…"];
		 } else {
			 [steps makeObjectsPerformSelector: @selector(perform)];
		 }
	 }];
	
	// Clean up
	_languages = nil;
	_document = nil;
}

- (BOOL)includesReferenceLanguage
{
	return [_languages containsObject: [_document referenceLanguage]];
}

+ (NSSet *)keyPathsForValuesAffectingIncludesReferenceLanguage
{
	return [NSSet setWithObjects: @"languages", nil];
}


#pragma mark - Export

+ (void)exportStringsFromObjects:(NSArray *)objects forLanguage:(NSString *)language andReferenceLanguage:(NSString *)referenceLanguage withOptions:(NSUInteger)options toPath:(NSString *)path
{
	BOOL includeComments, missingOnly, createFolders, separateFiles, includeOthers, groupByBundle;
	NSString *languagePath;
	NSArray *files;
	
	// Get options
	includeComments = (options & BLStringsExporterIncludeComments) != 0;
	missingOnly = (options & BLStringsExporterMissingStringsOnly) != 0;
	separateFiles = (options & BLStringsExporterSeparateFiles) != 0;
	includeOthers = (options & BLStringsExporterIncludeOthers) != 0;
	groupByBundle = (options & BLStringsExporterGroupByBundle) != 0;
	createFolders = (separateFiles || includeOthers);
	
	// Initialize
	path = [path stringByDeletingPathExtension];
	files = [BLObject fileObjectsFromArray: objects];
	
	// Create Path
	languagePath = [path stringByAppendingFormat: @" %@", language];
	if (createFolders) {
		if ([[NSFileManager defaultManager] fileExistsAtPath: languagePath])
			[[NSFileManager defaultManager] removeItemAtPath:languagePath error:nil];
		[[NSFileManager defaultManager] createDirectoryAtPath:languagePath withIntermediateDirectories:NO attributes:nil error:NULL];
	}
	
	// Gather all data
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	NSMutableDictionary *comments = [NSMutableDictionary dictionary];
	
	for (BLFileObject *fileObject in files) {
		NSString *bundlePath;
		BOOL isStringsFile;
		
		// Skip disabled files and bundles
		if (![fileObject isActive] || ![fileObject.bundleObject isActive])
			continue;
		
		// Determine whether to export to strings
		isStringsFile = ([[fileObject class] classOfStoredKeys] == [BLStringKeyObject class]);
		
		// Create Bundle directory
		if (groupByBundle) {
			bundlePath = [languagePath stringByAppendingPathComponent: fileObject.bundleObject.name];
			[[NSFileManager defaultManager] createDirectoryAtPath:bundlePath withIntermediateDirectories:NO attributes:nil error:NULL];
		} else {
			bundlePath = languagePath;
		}
		
		// Regular file
		if (!isStringsFile && includeOthers) {
			NSString *writePath = [bundlePath stringByAppendingPathComponent: [fileObject name]];
			[[BLFileCreator creatorForFileObject: fileObject] writeFileToPath:writePath fromObject:fileObject withLanguage:language referenceLanguage:referenceLanguage];
		}
		
		// Strings file
		if (isStringsFile) {
			NSDictionary *fileDict, *fileComments;
			
			// Get content
			fileDict = [fileObject dictionaryFromLanguage:referenceLanguage toLanguage:language ofKeyObjectsPassingTest:
						^ BOOL (BLKeyObject *object) {
							return (!missingOnly || [object isEmptyForLanguage: language]);
						}];
			
			if (includeComments)
				fileComments = [fileObject commentsWithKeysForLanguage: referenceLanguage];
			else
				fileComments = [NSDictionary dictionary];
			
			// Write to separate files
			if (separateFiles) {
				NSString *writePath;
				
				// Get the write path and appen .strings extension if necessary
				writePath = [bundlePath stringByAppendingPathComponent: [fileObject name]];
				if (![[writePath pathExtension] isEqual: kStringsPathExtension])
					writePath = [writePath stringByAppendingPathExtension: kStringsPathExtension];
				
				[fileDict writeAsStringsWithComments:fileComments toPath:writePath usingEncoding:NSUnicodeStringEncoding];
			}
			// Write to a single file, so collect data
			else {
				[dict addEntriesFromDictionary: fileDict];
				[comments addEntriesFromDictionary: fileComments];
			}
		}
	}
	
	// All strings in one file
	if (!separateFiles) {
		NSString *writePath;
		
		if (createFolders) {
			writePath = [languagePath stringByAppendingPathComponent: BLStringsExporterExportFileName];
			writePath = [writePath stringByAppendingPathExtension: kStringsPathExtension];
		} else {
			writePath = [languagePath stringByAppendingPathExtension: kStringsPathExtension];
		}
		
		[dict writeAsStringsWithComments:comments toPath:writePath usingEncoding:NSUnicodeStringEncoding];
	}
}

@end


#pragma mark -

@implementation BLFileObject (BLStringsExporterExtension)

- (NSDictionary *)dictionaryFromLanguage:(NSString *)language1 toLanguage:(NSString *)language2 ofKeyObjectsPassingTest:(BOOL (^)(BLKeyObject *object))test
{
    NSMutableDictionary *dict;
    
    dict = [NSMutableDictionary dictionary];
    
    for (BLKeyObject *keyObject in self.objects) {
		NSString *key, *value;
		
		if (![keyObject isActive] || !test(keyObject))
			continue;
		
		key = [keyObject stringForLanguage: language1];
		value = [keyObject stringForLanguage: language2];
		
		if (!value)
			value = @"";
		if (key && value)
			[dict setObject:value forKey:key];
	}
	
    return dict;
}

- (NSDictionary *)commentsWithKeysForLanguage:(NSString *)language
{
    NSMutableDictionary *dict;
    
    dict = [NSMutableDictionary dictionary];
    
    for (BLKeyObject *keyObject in self.objects) {
		NSString *key, *value;
		
		if (![keyObject isActive])
			continue;
		
		key = [keyObject stringForLanguage: language];
		value = [keyObject comment];
		
		if (key && value)
			[dict setObject:value forKey:key];
	}
	
    return dict;
}

@end

