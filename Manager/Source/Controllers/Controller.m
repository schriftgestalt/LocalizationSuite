//
//  Controller.m
//  Localization Manager
//
//  Created by Max on Wed Nov 26 2003.
//  Copyright (c) 2003-2005 The Blue Technologies Group. All rights reserved.
//

#import "Controller.h"

#import "Document.h"
#import "FileContent.h"
#import "Preferences.h"

@implementation Controller

id __sharedControllerInstance;

+ (Controller *)sharedInstance
{
	if (__sharedControllerInstance == nil)
	    __sharedControllerInstance = [[Controller alloc] init];
	
	return __sharedControllerInstance;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	__sharedControllerInstance = nil;
}

#pragma mark - Setup

- (void)awakeFromNib
{
	[LILogWindow logWindow];
	[[SUUpdater sharedUpdater] setDelegate: self];
}


#pragma mark - Updates

- (id <SUVersionComparison>)versionComparatorForUpdater:(SUUpdater *)updater
{
	return self;
}

- (NSComparisonResult)compareVersion:(NSString *)versionA toVersion:(NSString *)versionB
{
	return [versionA hexanumericalCompare: versionB];
}


#pragma mark - Open Files

- (IBAction)newDocument:(id)sender
{
	[[NSDocumentController sharedDocumentController] newDocument: self];
	[[[NSDocumentController sharedDocumentController] currentDocument] saveDocumentWithDelegate:self didSaveSelector:@selector(document:didSave:contextInfo:) contextInfo:NULL];
}

- (IBAction)newFromXcodeProject:(id)sender
{
	[[NSDocumentController sharedDocumentController] newDocument: self];
	[[[NSDocumentController sharedDocumentController] currentDocument] saveDocumentWithDelegate:self didSaveSelector:@selector(document:didSave:contextInfo:) contextInfo:@"Xcode"];
}

- (void)document:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)contextInfo
{
	if (!didSave) {
		[[doc windowForSheet] close];
		return;
	}
	
	if (contextInfo == @"Xcode") {
		[[[NSDocumentController sharedDocumentController] currentDocument] importXcodeProject: nil];
	}
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	return NO;
}

#pragma mark - Interface Actions

- (IBAction)showPreferences:(id)sender
{
	[[Preferences sharedInstance] open];
}

#pragma mark -

- (IBAction)importXcodeProject:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] importXcodeProject: sender];
}

- (IBAction)importStrings:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] importStrings: sender];
}

- (IBAction)importXLIFF:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] importXLIFF: sender];
}

- (IBAction)exportAsDictionary:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] exportAsDictionary: sender];
}

- (IBAction)exportIntoDictionary:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] exportIntoDictionary: sender];
}

- (IBAction)exportStrings:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] exportStrings: sender];
}

- (IBAction)exportToXcodeProject:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] exportToXcodeProject: sender];
}

- (IBAction)exportXLIFF:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] exportXLIFF: sender];
}

#pragma mark -

- (IBAction)convertFilesToXIB:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] convertFilesToXIB: sender];
}

#pragma mark -

- (IBAction)rescanFiles:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] rescanReferenceFiles: sender];
}

- (IBAction)rescanAllFiles:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] rescanAllReferenceFiles: sender];
}

- (IBAction)rescanFilesForced:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] rescanReferenceFilesForced: sender];
}

- (IBAction)synchronizeFiles:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] synchronizeFiles: sender];
}

- (IBAction)synchronizeAllFiles:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] synchronizeAllFiles: sender];
}

- (IBAction)showProcessLog:(id)sender
{
	[[LILogWindow logWindow] show];
}

- (IBAction)showStatusDisplay:(id)sender
{
	[[LIStatusDisplay statusDisplay] show];
}

- (IBAction)showDictionaries:(id)sender
{
	[[LIDictionarySettings sharedInstance] showWindow: sender];
}

- (IBAction)copyFromReference:(id)sender
{
	NSWindowController *controller = [[NSApp keyWindow] windowController];
	
	if ([controller isKindOfClass: [FileContent class]])
		[(FileContent *)controller copyFromReference: sender];
}

- (IBAction)deleteTranslation:(id)sender
{
	NSWindowController *controller = [[NSApp keyWindow] windowController];
	
	if ([controller isKindOfClass: [FileContent class]])
		[(FileContent *)controller deleteTranslation: sender];
}

- (IBAction)autotranslate:(id)sender
{
	NSWindowController *controller = [[NSApp keyWindow] windowController];
	
	if ([controller isKindOfClass: [FileContent class]])
		[(FileContent *)controller autotranslate: sender];
}

#pragma mark -

- (IBAction)addLanguage:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] addNewLanguage: sender];
}

- (IBAction)addCustomLanguage:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] addCustomLanguage: sender];
}

- (IBAction)removeLanguage:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] removeLanguages: sender];
}

- (IBAction)updateLanguage:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] updateLanguage: sender];
}

- (IBAction)resetLanguage:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] resetLanguage: sender];
}

- (IBAction)reimportLanguage:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] reimportLanguage: sender];
}

- (IBAction)changeReferenceLanguage:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] changeReferenceLanguage: sender];
}

#pragma mark -

- (IBAction)addFile:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] addFile: sender];
}

- (IBAction)removeFile:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] removeFile: sender];
}

- (IBAction)viewFilePreview:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] showFilePreview: sender];
}

- (IBAction)viewFileContents:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] showFileContent: sender];
}

- (IBAction)viewFileDetails:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] showFileDetail: sender];
}

- (IBAction)reInjectFile:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] reinjectFiles: sender];
}

- (IBAction)reImportFile:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] reimportFiles: sender];
}


#pragma mark -

- (IBAction)setSaveLocation:(id)sender
{
	[[Preferences sharedInstance] setSaveLocation: sender];
}

- (IBAction)exportLocalizerFiles:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] exportLocalizerFiles: sender];
}

- (IBAction)importLocalizerFiles:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] importLocalizerFiles: sender];
}

- (IBAction)importLocalizerFilesDirectly:(id)sender
{
	[(Controller*)[[NSDocumentController sharedDocumentController] currentDocument] importLocalizerFilesDirectly: sender];
}

- (IBAction)editLocalizerFiles:(id)sender
{
	[[[NSDocumentController sharedDocumentController] currentDocument] editLocalizerFiles: sender];
}

#pragma mark - Menu Validation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	// Allways active items
	if ([menuItem tag] == 100)
	    return YES;
	
	// Get some needed resources
	NSWindowController *controller = [[NSApp keyWindow] windowController];
	NSDocument *document = [[NSDocumentController sharedDocumentController] currentDocument];
	SEL action = [menuItem action];
	
	if (!document)
		return NO;
	if (   action == @selector(copyFromReference:)
		|| action == @selector(deleteTranslation:)
		|| action == @selector(autotranslate:)) {
		if (controller && [controller isKindOfClass: [FileContent class]])
			return [(FileContent *)controller validateMenuItem: menuItem];
		else 
			return NO;
	}
	
	return [document validateMenuItem: menuItem];
}

@end
