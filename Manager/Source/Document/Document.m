//
//  Document.m
//  Localization Manager
//
//  Created by Max on Wed Nov 26 2003.
//  Copyright (c) 2003-2005 The Blue Technologies Group. All rights reserved.
//

#import "Document.h"
#import "DocumentInternal.h"

#import "Controller.h"
#import "FilteredBundleProxy.h"
#import "LanguageCoordinator.h"
#import "LanguageObject.h"
#import "MultiActionButton.h"
#import "Preferences.h"
#import "TableViewAdditions.h"

#import <objc/runtime.h>
#import "NSAlert-Extensions.h"

// Paths
NSString *kLprojPathExtension               = @"lproj";
NSString *kLocalizerPathExtension           = @"loc";
NSString *kDictionaryPathExtension			= @"lod";
NSString *kStringsPathExtension             = @"strings";


#define kReImportLanguageMenuTag	10
#define kReInjectLanguageMenuTag	11


@class BLNibFileObject, BLNibFileInterpreter;

@implementation Document

+ (BOOL)autosavesInPlace
{
	return NO;
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _fileContentWindows = [NSMapTable mapTableWithStrongToWeakObjects];
        _fileDetailWindows = [NSMapTable mapTableWithStrongToWeakObjects];
		_filePreviewWindows = [NSMapTable mapTableWithStrongToWeakObjects];
		
		_processDisplay = [[LIProcessDisplay alloc] initWithProcessManager: [self processManager]];
		
		_filteredBundles = nil;
		_searchString = nil;
		
		[[Preferences sharedInstance] initDocument: self];
	}
    
    return self;
}


- (void)close
{
	[[Preferences sharedInstance] unregisterDocument: self];
	[[BLDictionaryController sharedInstance] unregisterDocument: self];
	
    [tableBundles saveSortDescriptors];
    [languageCoordinator disconnect];
    
    [super close];
}


#pragma mark - NSDocument Implementations

- (NSString *)name
{
	return [self displayName];
}

- (NSString *)windowNibName
{
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib: aController];
	[aController setShouldCloseDocument: YES];
	
	// Update Interface
    [tableBundles setTarget: self];
    [tableBundles setDoubleAction: @selector(showFileContent:)];
    [tableBundles registerForDraggedTypes: [NSArray arrayWithObject: NSFilenamesPboardType]];
    [tableBundles loadSortDescriptors];
	
	[tableBundles.menu itemWithTag: kReImportLanguageMenuTag].submenu.delegate = self;
	[tableBundles.menu itemWithTag: kReInjectLanguageMenuTag].submenu.delegate = self;
    
    [[aController window] setFrameAutosaveName: @"document"];
    [[aController window] makeKeyAndOrderFront: self];
	
	[rescanButton setShiftTitle: NSLocalizedString(@"Rescan All", nil)];
	[rescanButton setShiftAction: @selector(rescanAllReferenceFiles:)];
	[rescanButton setAltAction: @selector(rescanReferenceFilesForced:)];
	
	[syncButton setShiftTitle: NSLocalizedString(@"Synchronize All", nil)];
	[syncButton setShiftAction: @selector(synchronizeAllFiles:)];
	
	[readInButton setAltAction: @selector(importLocalizerFilesDirectly:)];
	
	[[BLDictionaryController sharedInstance] registerDocument: self];
	[[Preferences sharedInstance] registerDocument: self];
}

- (void)showWindows
{
	[super showWindows];
	
	// Check for moved file
	NSString *lastSavePath = [self.preferences objectForKey: BLDocumentLastSavePathKey];
	if (lastSavePath && ![lastSavePath isEqual: [[self fileURL] path]]
		&& (NSAppKitVersionNumber < NSAppKitVersionNumber10_7 || [self isInViewingMode])) {
		// File has been moved, mark dirty and show error
		[self updateChangeCount: NSChangeDone];
		
		NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"ProjectMovedTitle", nil)
										 defaultButton:NSLocalizedString(@"CheckBundlePaths", nil)
									   alternateButton:nil 
										   otherButton:NSLocalizedString(@"Ignore", nil)
							 informativeTextWithFormat:NSLocalizedString(@"ProjectMovedText", nil)];
		[alert beginSheetModalForWindow:[self windowForSheet] completionHandler:^(NSInteger result) {
			if (result != NSAlertDefaultReturn)
				return;
			
			[self checkBundlePaths];
		}];
	}
}

- (void)removeWindowController:(NSWindowController *)windowController
{
	[self detailWindowDidClose: windowController];
	[super removeWindowController: windowController];
}

- (void)canCloseDocumentWithDelegate:(id)delegate shouldCloseSelector:(SEL)shouldCloseSelector contextInfo:(void *)contextInfo
{
    if (![_processManager isRunning])
        [super canCloseDocumentWithDelegate:delegate shouldCloseSelector:shouldCloseSelector contextInfo:contextInfo];
    else
        NSBeep();
}


#pragma mark - File Actions

- (void)checkBundlePaths
{
	// Collect results
	NSMutableArray *missingBundles = [NSMutableArray array];
	NSMutableArray *changedBundles = [NSMutableArray array];
	
	// Sort bundles nicely (better for display)
	NSArray *sortedBundles = [self.bundles sortedArrayUsingDescriptors: [NSArray arrayWithObject: [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]]];
	
	// Check all bundles
	for (BLBundleObject *bundle in sortedBundles) {
		NSString *fullPath = [[self pathCreator] fullPathForBundle: bundle];
		
		// Check existence
		if (![[NSFileManager defaultManager] fileExistsAtPath: fullPath]) {
			[missingBundles addObject: bundle];
			continue;
		}
		
		// Normalize path for relative bundles
		if (bundle.referencingStyle == BLRelativeReferencingStyle) {
			NSString *relativePath = [[self pathCreator] documentRelativePathOfFullPath: fullPath];
			
			if (![bundle.path isEqual: relativePath]) {
				bundle.path = relativePath;
				[changedBundles addObject: bundle];
			}
		}
	}
	
	// Present results
	NSString *message = nil;
	
	if (![missingBundles count] && ![changedBundles count])
		message = NSLocalizedString(@"BundleCheckNoChanges", nil);
	
	if ([missingBundles count]) {
		NSString *bundleList = @"";
		for (BLBundleObject *bundle in missingBundles)
			bundleList = [bundleList stringByAppendingFormat: NSLocalizedString(@"BundleCheckBundleItem", nil), bundle.name, bundle.path];
		message = [NSString stringWithFormat: NSLocalizedString(@"BundleCheckMissing", nil), bundleList];
	}
	if ([changedBundles count]) {
		NSString *bundleList = @"";
		for (BLBundleObject *bundle in changedBundles)
			bundleList = [bundleList stringByAppendingFormat: NSLocalizedString(@"BundleCheckBundleItem", nil), bundle.name, (bundle.path.length) ? bundle.path : @"."];
		
		if (message) {
			message = [message stringByAppendingString: @"\n"];
			message = [message stringByAppendingFormat: NSLocalizedString(@"BundleCheckChanged", nil), bundleList];
		} else
			message = [NSString stringWithFormat: NSLocalizedString(@"BundleCheckChanged", nil), bundleList];
	}
	
	NSBeginInformationalAlertSheet(NSLocalizedString(@"BundleCheckResultTitle", nil), NSLocalizedString(@"OK", nil), NSLocalizedString(@"CloseProject", nil), nil, [self windowForSheet], self, nil, @selector(bundlesChangedSheetDidEnd:returnCode:contextInfo:), NULL, @"%@", message);
}

- (void)bundlesChangedSheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSAlertAlternateReturn)
		[self performSelector:@selector(close) withObject:nil afterDelay:0.1];
}


#pragma mark - Content Accessors

- (NSArray *)selectedLanguages
{
	NSArray *languages;
	
	languages = [[languagesController selectedObjects] arrayWithAllValuesForKeyPath: @"identifier"];
	if (![languages count])
		languages = [self languages];
	
	return languages;
}

- (NSArray *)filteredBundles
{
	if (![_searchString length])
		return [self bundles];
	
	if (!_filteredBundles) {
		NSMutableArray *bundles = [NSMutableArray array];
		
		for (BLBundleObject *bundle in [self bundles]) {
			BLBundleObject *proxy = (id)[[FilteredBundleProxy alloc] initWithBundle:bundle andSearchString:_searchString forLanguages:_languages];
						
			if ([proxy.files count] || [[bundle name] rangeOfString: _searchString].length)
				[bundles addObject: proxy];
			
		}
		
		_filteredBundles = bundles;
	}
	
	return _filteredBundles;
}

+ (NSSet *)keyPathsForValuesAffectingFilteredBundles
{
	return [NSSet setWithObjects: @"bundles", @"searchString", nil];
}

@synthesize searchString=_searchString;

- (void)setSearchString:(NSString *)search
{
	_searchString = search;
	
	_filteredBundles = nil;
}

- (void)setBundles:(NSArray *)bundles
{
	// Remove observation
	if (_bundles && [_bundles count]) {
		[_bundles removeObserver:self fromObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, _bundles.count)] forKeyPath:@"flags" context:@"change"];
		[_bundles removeObserver:self fromObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, _bundles.count)] forKeyPath:@"objects" context:@"objects"];
		
		for (BLBundleObject *bundle in _bundles)
			[bundle.objects removeObserver:self fromObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, bundle.objects.count)] forKeyPath:@"flags" context:@"change"];
	}
	
	// Update
	[super setBundles: bundles];
	
	// Clear filter cache
	_filteredBundles = nil;
	
	// Add observation
	if (bundles && [bundles count]) {
		[bundles addObserver:self toObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, bundles.count)] forKeyPath:@"flags" options:0 context:@"change"];
		[bundles addObserver:self toObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, bundles.count)] forKeyPath:@"objects" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:@"objects"];
		
		for (BLBundleObject *bundle in _bundles)
			[bundle.objects addObserver:self toObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, bundle.objects.count)] forKeyPath:@"flags" options:0 context:@"change"];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == @"change") {
        [self updateChangeCount: NSChangeDone];
    }
	else if (context == @"objects") {
		NSArray *oldObjects = [change valueForKey: NSKeyValueChangeOldKey];
		[oldObjects removeObserver:self fromObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, oldObjects.count)] forKeyPath:@"flags"];
		
		NSArray *newObjects = [change valueForKey: NSKeyValueChangeNewKey];
		[newObjects addObserver:self toObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, newObjects.count)] forKeyPath:@"flags" options:0 context:@"change"];
	}
	else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark - Others

- (NSArray *)getSelectedObjects:(BOOL)extend
{
	NSArray *objects;
	NSInteger row;
	
	// Get selected objects
	objects = [bundlesController selectedObjects];
	
	// Reverse filtering
	NSMutableArray *realObjects = [NSMutableArray arrayWithCapacity: [objects count]];
	for (__strong id object in objects) {
		if (object_getClass(object) == [FilteredBundleProxy class])
			object = [object original];
		
		[realObjects addObject: object];
	}
	
	// Determine whether clicking or not or all
	row = [tableBundles clickedRow];
	if (row != -1 && (![objects count] || ![[tableBundles selectedRowIndexes] containsIndex: row]))
		objects = [NSArray arrayWithObject: [[tableBundles itemAtRow: row] representedObject]];
	if (extend == YES && ![objects count])
		objects = _bundles;
	
	return [NSArray arrayWithArray: objects];
}

- (void)updateChangeCount:(NSDocumentChangeType)change
{
	[super updateChangeCount: change];
	[languageCoordinator updateStatus];
}

- (void)languageChanged:(NSString *)language
{
	[super languageChanged: language];
	[languageCoordinator updateStatusForLanguage: language];
}

+ (NSDictionary *)defaultPreferences
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: [super defaultPreferences]];
	
	[dict setObject:[NSNumber numberWithBool: NO] forKey:PreferencesOpenFolderAfterWriteoutKey];
	[dict setObject:[NSNumber numberWithBool: YES] forKey:PreferencesShowCommentsKey];
	[dict setObject:[NSNumber numberWithBool: YES] forKey:PreferencesShowEmptyStringsKey];
	[dict setObject:[NSNumber numberWithBool: NO] forKey:PreferencesShowRemovedStringsKey];
	
	return dict;
}

+ (NSArray *)userPreferenceKeys
{
	return [[super userPreferenceKeys] arrayByAddingObjectsFromArray: [NSArray arrayWithObjects: PreferencesOpenFolderAfterWriteoutKey, PreferencesLastSelectedLanguageKey, PreferencesShowCommentsKey, PreferencesShowEmptyStringsKey, PreferencesShowRemovedStringsKey, nil]];
}


#pragma mark - Delegates

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	return YES;
}

#pragma mark -

- (void)menuNeedsUpdate:(NSMenu *)menu
{
	NSUInteger tag = [[[menu supermenu] itemAtIndex: [[menu supermenu] indexOfItemWithSubmenu: menu]] tag];
	
	[menu removeAllItems];
	
	for (LanguageObject *language in languageCoordinator.usedLanguageObjects) {
		NSMenuItem *item = [menu addItemWithTitle:[language description] action:nil keyEquivalent:@""];
		
		[item setTarget: self];
		if (tag == kReImportLanguageMenuTag)
			[item setAction: @selector(reimportFilesForLanguage:)];
		else if (tag == kReInjectLanguageMenuTag)
			[item setAction: @selector(reinjectFilesForLanguage:)];
		[item setRepresentedObject: [language identifier]];
	}
}

@end



