/*!
 @header
 BLXcodeImporter.m
 Created by max on 01.07.09.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLXcodeImporter.h"

#import "BLXcodeImportAssociationStep.h"


NSString *BLXcodeImporterNibName	= @"BLXcodeImporter";
NSString *BLXcodeImporterRescanExistingKeyPath	= @"xcodeImporter.rescanExisting";


@interface BLXcodeImporter (BLXcodeImporterInternal) <NSOpenSavePanelDelegate>

+ (id)_sharedInstance;

- (void)importXcodeProjectToDatabaseDocument:(BLDatabaseDocument *)document;

@end

@implementation BLXcodeImporter

id __sharedXcodeImporter;

- (void)dealloc
{
	if (self == __sharedXcodeImporter)
		__sharedXcodeImporter = nil;
}

+ (id)_sharedInstance
{
    if (__sharedXcodeImporter == nil)
        __sharedXcodeImporter = [[self alloc] init];
    
    return __sharedXcodeImporter;
}


#pragma mark - Public Access

+ (void)importXcodeProjectToDatabaseDocument:(BLDatabaseDocument *)document
{
	[[self _sharedInstance] importXcodeProjectToDatabaseDocument: document];
}


#pragma mark - User interface

- (void)importXcodeProjectToDatabaseDocument:(BLDatabaseDocument *)document
{
	NSOpenPanel *panel;
    
	// Open the panel
    panel = [NSOpenPanel openPanel];
	
	if (!optionsView)
		[NSBundle loadNibNamed:BLXcodeImporterNibName owner:self];
	
	[panel setAllowsMultipleSelection: YES];
	[panel setAllowedFileTypes: [BLXcodeProjectParser pathExtensions]];
	
	[panel setAccessoryView: optionsView];
	[panel setMessage: NSLocalizedStringFromTableInBundle(@"BLXcodeImportText", @"Localizable", [NSBundle bundleForClass: [self class]], nil)];
	[[panel defaultButtonCell] setTitle: NSLocalizedStringFromTableInBundle(@"Import", @"Localizable", [NSBundle bundleForClass: [self class]], nil)];
	
	[panel beginSheetModalForWindow:[document windowForSheet] completionHandler:^(NSInteger result) {
		if (result != NSFileHandlingPanelOKButton)
			return;
		
		// Get options
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		NSUInteger options = 0;
		if ([defaults boolForKey: BLXcodeImporterRescanExistingKeyPath])
			options |= BLXcodeImporterRescanExistingFiles;
		
		// Import
		for (NSURL *url in [panel URLs]) {
			if ([[url pathExtension] isEqual: @"xcodeproj"])
				[[self class] importXcodeProjectAtPath:[url path] toDatabaseDocument:document withOptions:options];
		}
	}];
}


#pragma mark - Import

+ (void)importXcodeProjectAtPath:(NSString *)path toDatabaseDocument:(BLDatabaseDocument *)document withOptions:(NSUInteger)options
{
	BLLogBeginGroup(@"Importing Xcode project");
	BLLog(BLLogInfo, @"Project path: %@", path);
	
	NSArray *paths = [self pathsToImportFromXcodeProjectAtPath:path toDatabaseDocument:document withOptions:options];
	
	BLLog(BLLogInfo, @"Adding %d files", [paths count]);
	BLLogEndGroup();
	
	// Then import them
	[document addFiles: paths];
	
	// And update the Xcode projects
	[[document processManager] enqueueStep: [[BLXcodeImportAssociationStep alloc] initWithXcodeProjectAtPath:path document:document andImportedFiles:paths]];
}

+ (NSArray *)pathsToImportFromXcodeProjectAtPath:(NSString *)path toDatabaseDocument:(BLDatabaseDocument *)document withOptions:(NSUInteger)options
{
	// Open the project
	BLXcodeProjectParser *parser = [BLXcodeProjectParser parserWithProjectFileAtPath: path];
	[parser loadProject];
	
	if (![parser projectIsLoaded]) {
		BLLog(BLLogError, @"Cannot open Xcode project at path: %@", path);
		return nil;
	}
	
	// Get the localized files
	NSArray *localizedGroups = [[parser mainGroup] localizedVariantGroups];
	NSMutableArray *filePaths = [NSMutableArray array];
	
	// Flatten the list into an array of paths
	for (BLXcodeProjectItem *group in localizedGroups) {
		for (BLXcodeProjectItem *child in [group children])
			[filePaths addObject: [child fullPath]];
	}
	
	// Filter the paths by existing importers
	[filePaths setArray: [BLFileInterpreter filePathsFromPaths: filePaths]];
	
	// Filter existing files if needed
	if (!(options & BLXcodeImporterRescanExistingFiles)) {
		for (NSInteger i=0; i<[filePaths count]; i++) {
			if ([document existingFileObjectWithPath: [filePaths objectAtIndex: i]])
				[filePaths removeObjectAtIndex: i--];
		}
	}
	
	return filePaths;
}


@end

