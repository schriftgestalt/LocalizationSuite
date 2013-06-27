//
//  DocumentUtilities.m
//  Localization Manager
//
//  Created by Max Seelemann on 23.10.08.
//  Copyright 2008 The Blue Technologies Group. All rights reserved.
//

#import "Document.h"
#import "DocumentInternal.h"

#import "Controller.h"
#import "Preferences.h"

#import "NSAlert-Extensions.h"


NSString *DocumentImportLocalizerChangesOnlyKeyPath	= @"localizerImport.changesOnly";
NSString *DocumentImportLocalizerMissingOnlyKeyPath	= @"localizerImport.missingOnly";
NSString *DocumentImportLocalizerWeakImportKeyPath	= @"localizerImport.weakImport";


@implementation Document (DocumentUtilities)


#pragma mark - Import

- (IBAction)importStrings:(id)sender
{
	[BLStringsImporter importStringsToObjects:[self bundles] inDocument:self];
}

- (IBAction)importXcodeProject:(id)sender
{
	[BLXcodeImporter importXcodeProjectToDatabaseDocument: self];
}

- (IBAction)importXLIFF:(id)sender
{
	[BLXLIFFImporter importXLIFFToObjects:[self bundles] inDocument:self];
}


#pragma mark - Export

- (IBAction)exportAsDictionary:(id)sender
{
	[BLDictionaryExporter exportDictionaryFromObjects:[self bundles] forLanguages:[self selectedLanguages] inDocument:self updatingDictionary:NO];
}

- (IBAction)exportIntoDictionary:(id)sender
{
	[BLDictionaryExporter exportDictionaryFromObjects:[self bundles] forLanguages:[self selectedLanguages] inDocument:self updatingDictionary:YES];
}

- (IBAction)exportStrings:(id)sender
{
	[BLStringsExporter exportStringsFromObjects:[self getSelectedObjects: YES] forLanguages:[self selectedLanguages] inDocument:self];
}

- (IBAction)exportToXcodeProject:(id)sender
{
	[BLXcodeExporter exportDatabaseDocument: self];
}

- (IBAction)exportXLIFF:(id)sender
{
	[BLXLIFFExporter exportXLIFFFromObjects:[self getSelectedObjects: YES] forLanguages:[self selectedLanguages] inDocument:self];
}


#pragma mark - Tools

- (IBAction)convertFilesToXIB:(id)sender
{
	NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"ConvertToXibTitle", nil)
									 defaultButton:NSLocalizedString(@"Continue", nil)
								   alternateButton:NSLocalizedString(@"Cancel", nil) 
									   otherButton:nil
						 informativeTextWithFormat:NSLocalizedString(@"ConvertToXibText", nil)];
	[alert beginSheetModalForWindow:[self windowForSheet] completionHandler:^(NSInteger result) {
		if (result != NSAlertDefaultReturn)
			return;
		
		[[self processManager] enqueueStepGroup: [BLNibConverterStep stepGroupForUpgradingObjects: [self getSelectedObjects: YES]]];
		[[self processManager] start];
	}];
}

#pragma mark - Localization Documents

- (IBAction)exportLocalizerFiles:(id)sender
{
	[self exportLocalizerFilesForLanguages:[self selectedLanguages] withAdditionalOptions: 0];
}

- (IBAction)editLocalizerFiles:(id)sender
{
    [self exportLocalizerFilesForLanguages:[self selectedLanguages] withAdditionalOptions: BLLocalizerExportStepOpenInLocalizerOption];
}

- (void)exportLocalizerFilesForLanguages:(NSArray *)languages withAdditionalOptions:(NSUInteger)options
{
	if ([[self.preferences objectForKey: PreferencesOpenFolderAfterWriteoutKey] boolValue])
		options |= BLLocalizerExportStepOpenFolderOption;
	
	[super exportLocalizerFilesForLanguages:languages withAdditionalOptions:options];
}

#pragma mark -

- (IBAction)importLocalizerFiles:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (![defaults objectForKey: DocumentImportLocalizerChangesOnlyKeyPath])
		[defaults setBool:YES forKey:DocumentImportLocalizerChangesOnlyKeyPath];
	if (![defaults objectForKey: DocumentImportLocalizerMissingOnlyKeyPath])
		[defaults setBool:NO forKey:DocumentImportLocalizerMissingOnlyKeyPath];
	if (![defaults objectForKey: DocumentImportLocalizerWeakImportKeyPath])
		[defaults setBool:NO forKey:DocumentImportLocalizerWeakImportKeyPath];
	
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection: YES];
	[panel setAccessoryView: localizerImportOptions];
	if ([self.preferences objectForKey: BLDocumentOpenFolderKey])
		[panel setDirectoryURL: [NSURL fileURLWithPath: [self.preferences objectForKey: BLDocumentOpenFolderKey]]];
	[panel setAllowedFileTypes: [NSArray arrayWithObject: [BLLocalizerFile pathExtension]]];
	
	[panel beginSheetModalForWindow:[self windowForSheet] completionHandler:^(NSInteger result) {
		if (result != NSFileHandlingPanelOKButton)
			return;
		
		[self.preferences setObject:[[[panel URL] path] stringByDeletingLastPathComponent] forKey:BLDocumentOpenFolderKey];
		
		NSUInteger options = 0;
		if ([[NSUserDefaults standardUserDefaults] boolForKey: DocumentImportLocalizerChangesOnlyKeyPath])
			options |= BLLocalizerImportStepChangesOnlyOption;
		if ([[NSUserDefaults standardUserDefaults] boolForKey: DocumentImportLocalizerMissingOnlyKeyPath])
			options |= BLLocalizerImportStepMissingOnlyOption;
		if ([[NSUserDefaults standardUserDefaults] boolForKey: DocumentImportLocalizerWeakImportKeyPath])
			options |= BLLocalizerImportStepMatchKeysByValueOption;
		
		[self importLocalizerFiles:[[panel URLs] valueForKey: @"path"] withOptions:options];
	}];
}

- (IBAction)importLocalizerFilesDirectly:(id)sender
{
	NSMutableArray *files = [NSMutableArray array];
	
	for (NSString *language in [self selectedLanguages]) {
		if ([language isEqual: [self referenceLanguage]])
			continue;
		
		[files addObject: [self pathForLocalizerFileOfLanguage: language]];
	}
	
	[self importLocalizerFiles:files withOptions:BLLocalizerImportStepChangesOnlyOption];
}


#pragma mark - Statistics

- (NSArray *)currentObjectsInTableView:(NSTableView *)tableView
{
	if (tableView == tableBundles)
		return [self getSelectedObjects: NO];
	if (tableView == tableLanguages)
		return [self bundles];
	
	return nil;
}

- (NSArray *)currentLanguagesInTableView:(NSTableView *)tableView
{
	NSString *otherLanguage = [[self selectedLanguages] lastObject];
	
	if (![otherLanguage isEqual: [self referenceLanguage]])
		return [NSArray arrayWithObjects: [self referenceLanguage], otherLanguage, nil];
	else
		return [NSArray arrayWithObjects: [self referenceLanguage], nil];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	[[notification object] updateCurrentObjects];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
	[[notification object] updateCurrentObjects];
}

@end


