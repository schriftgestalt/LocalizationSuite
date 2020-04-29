//
//  Document.h
//  Localization Manager
//
//  Created by Max on Wed Nov 26 2003.
//  Copyright (c) 2003-2005 The Blue Technologies Group. All rights reserved.
//

@class LanguageCoordinator, MultiActionButton;

@interface Document : BLDatabaseDocument <LIStatusObjectsTableViewDelegate> {
	// Interface
	IBOutlet NSTreeController *bundlesController;
	IBOutlet NSArrayController *languagesController;
	IBOutlet LanguageCoordinator *languageCoordinator;
	IBOutlet NSView *localizerImportOptions;
	IBOutlet MultiActionButton *readInButton;
	IBOutlet MultiActionButton *rescanButton;
	IBOutlet MultiActionButton *syncButton;
	IBOutlet NSTableView *tableLanguages;
	IBOutlet NSOutlineView *tableBundles;

	// temporary instance variables
	NSMapTable *_fileContentWindows;
	NSMapTable *_fileDetailWindows;
	NSMapTable *_filePreviewWindows;
	NSArray *_filteredBundles;
	LIProcessDisplay *_processDisplay;
	NSString *_searchString;
}

@property (nonatomic, strong, readonly) NSArray *filteredBundles;
@property (nonatomic, strong) NSString *searchString;

@property (nonatomic, strong, readonly) NSArray *selectedLanguages;

@end

@interface Document (DocumentLanguages)

// Manage Languages
- (IBAction)addNewLanguage:(id)sender;
- (IBAction)addCustomLanguage:(id)sender;
- (IBAction)removeLanguages:(id)sender;

- (IBAction)updateLanguage:(id)sender;
- (IBAction)resetLanguage:(id)sender;
- (IBAction)reimportLanguage:(id)sender;

- (IBAction)changeReferenceLanguage:(id)sender;

@end

@interface Document (DocumentFiles)

// Manage Files
- (IBAction)addFile:(id)sender;
- (IBAction)removeFile:(id)sender;

- (IBAction)rescanReferenceFiles:(id)sender;
- (IBAction)rescanAllReferenceFiles:(id)sender;
- (IBAction)rescanReferenceFilesForced:(id)sender;

- (IBAction)reimportFiles:(id)sender;
- (IBAction)reimportFilesForLanguage:(id)sender;

- (IBAction)synchronizeFiles:(id)sender;
- (IBAction)synchronizeAllFiles:(id)sender;

- (IBAction)reinjectFiles:(id)sender;
- (IBAction)reinjectFilesForLanguage:(id)sender;

- (IBAction)showFileDetail:(id)sender;
- (IBAction)showFilePreview:(id)sender;
- (IBAction)showFileContent:(id)sender;
- (IBAction)revealFile:(id)sender;

@end

@interface Document (DocumentUtilities)

// Import
- (IBAction)importStrings:(id)sender;
- (IBAction)importXcodeProject:(id)sender;
- (IBAction)importXLIFF:(id)sender;

// Export
- (IBAction)exportAsDictionary:(id)sender;
- (IBAction)exportIntoDictionary:(id)sender;

- (IBAction)exportStrings:(id)sender;
- (IBAction)exportToXcodeProject:(id)sender;
- (IBAction)exportXLIFF:(id)sender;

// Tools
- (IBAction)convertFilesToXIB:(id)sender;

// Localization Files
- (IBAction)exportLocalizerFiles:(id)sender;
- (IBAction)editLocalizerFiles:(id)sender;
- (IBAction)importLocalizerFiles:(id)sender;

@end
