//
//  Controller.m
//  Localizer
//
//  Created by Max on 01.12.2004
//  Copyright (c) 2003-2005 The Blue Technologies Group. All rights reserved.
//

#import "Controller.h"

#import "Document.h"

@implementation Controller

id sharedControllerInstance;

- (id)init {
	self = [super init];

	if (self) {
		sharedControllerInstance = self;
	}

	return self;
}

+ (Controller *)sharedInstance {
	if (sharedControllerInstance == nil)
		sharedControllerInstance = [[Controller alloc] init];

	return sharedControllerInstance;
}

- (void)dealloc {
	sharedControllerInstance = nil;
}

#pragma mark - Setup

- (void)awakeFromNib {
	[LILogWindow logWindow];
	[[SUUpdater sharedUpdater] setDelegate:self];
}

#pragma mark - Updates

- (id<SUVersionComparison>)versionComparatorForUpdater:(SUUpdater *)updater {
	return self;
}

- (NSComparisonResult)compareVersion:(NSString *)versionA toVersion:(NSString *)versionB {
	return [versionA hexanumericalCompare:versionB];
}

#pragma mark - General Actions

- (IBAction)showAboutBox:(id)sender {
	//[[[BTAboutBox aboutBox] window] makeKeyAndOrderFront: self];
}

#pragma mark - File Menu

- (IBAction)importFiles:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] beginImportFiles:sender];
}

- (IBAction)exportDictionary:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] exportDictionary:sender];
}

- (IBAction)exportTMX:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] exportTMX:sender];
}

#pragma mark - Edit Menu

- (IBAction)selectNext:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] selectNext:sender];
}

- (IBAction)selectPrevious:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] selectPrevious:sender];
}

#pragma mark - Dictionary menu

- (IBAction)showFilterSettings:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] showFilterSettings:sender];
}

- (IBAction)deleteKey:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] deleteKey:sender];
}

- (IBAction)addKey:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] addKey:sender];
}

- (IBAction)deleteLanguage:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] beginDeleteLanguage:sender];
}

- (IBAction)addLanguage:(id)sender {
	[[[NSDocumentController sharedDocumentController] currentDocument] beginAddLanguage:sender];
}

#pragma mark - Window menu

- (IBAction)showProcessLog:(id)sender {
	[[LILogWindow logWindow] show];
}

- (IBAction)showStatusDisplay:(id)sender {
	[[LIStatusDisplay statusDisplay] show];
}

#pragma mark - Delegates

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	if ([menuItem action] == @selector(openAboutBox:))
		return YES;

	return ([[NSDocumentController sharedDocumentController] currentDocument] != nil);
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
	return NO;
}

@end
