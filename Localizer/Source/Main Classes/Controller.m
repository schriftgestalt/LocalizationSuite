//
//  Controller.m
//  Localizer
//
//  Created by Max on 01.12.2004
//  Copyright (c) 2003-2005 The Blue Technologies Group. All rights reserved.
//

#import "Controller.h"

#import "Document.h"
#import "GSStringToAttributedValueTransformer.h"
#import "Preferences.h"

@implementation Controller

#pragma mark - Setup

- (void)awakeFromNib {
	[LILogWindow logWindow];
	[[SUUpdater sharedUpdater] setDelegate:self];
	NSValueTransformer* transformer = [[GSStringToAttributedValueTransformer alloc] init];
	[NSValueTransformer setValueTransformer:transformer forName:@"GSStringToAttributedValueTransformer"];
}

#pragma mark - Updates

- (id<SUVersionComparison>)versionComparatorForUpdater:(SUUpdater*)updater {
	return self;
}

- (NSComparisonResult)compareVersion:(NSString*)versionA toVersion:(NSString*)versionB {
	return [versionA hexanumericalCompare:versionB];
}

#pragma mark - Localizer Menu

- (IBAction)showPreferences:(id)sender {
	[[Preferences sharedInstance] open];
}

#pragma mark - File Menu

- (IBAction)importStrings:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] importStrings:sender];
}

- (IBAction)importXLIFF:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] importXLIFF:sender];
}

- (IBAction)exportAsDictionary:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] exportAsDictionary:sender];
}

- (IBAction)exportIntoDictionary:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] exportIntoDictionary:sender];
}

- (IBAction)exportStrings:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] exportStrings:sender];
}

- (IBAction)exportXLIFF:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] exportXLIFF:sender];
}

#pragma mark - Edit Menu

- (IBAction)selectNext:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] selectNext:sender];
}

- (IBAction)selectPrevious:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] selectPrevious:sender];
}

#pragma mark - Translation menu

- (IBAction)copyFromReference:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] copyFromReference:sender];
}

- (IBAction)editCopyOfRefernence:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] editCopyOfRefernence:sender];
}

- (IBAction)insertMissingPlaceholders:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] insertMissingPlaceholders:sender];
}

- (IBAction)useFirstMatch:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] useFirstMatch:sender];
}

- (IBAction)useSecondMatch:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] useSecondMatch:sender];
}

- (IBAction)useThirdMatch:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] useThirdMatch:sender];
}

- (IBAction)autotranslate:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] autotranslate:sender];
}

#pragma mark - Window menu

- (IBAction)showDictionaries:(id)sender {
	[[LIDictionarySettings sharedInstance] showWindow:self];
}

- (IBAction)showProcessLog:(id)sender {
	[[LILogWindow logWindow] show];
}

- (IBAction)showStatusDisplay:(id)sender {
	[[LIStatusDisplay statusDisplay] show];
}

#pragma mark - Delegate Methods

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication*)sender {
	return NO;
}

- (BOOL)validateMenuItem:(NSMenuItem*)menuItem {
	Document* document = [[NSDocumentController sharedDocumentController] currentDocument];

	if ([menuItem tag] == 100)
		return (document && [document validateMenuItem:menuItem]);

	return [NSApp validateMenuItem:menuItem];
}

@end
