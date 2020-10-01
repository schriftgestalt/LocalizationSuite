//
//  Document.m
//  Localization Dictionary
//
//  Created by Max on 14.03.05.
//  Copyright The Blue Technologies Group 2005 . All rights reserved.
//

#import "Document.h"

#import <BlueLocalization/BLStringKeyObject.h>
#import "NSAlert-Extensions.h"


NSString *DocumentViewOptionLeftLanguage	= @"leftLanguage";
NSString *DocumentViewOptionRightLanguage	= @"rightLanguage";
NSString *DocumentViewOptionSearch			= @"search";


@interface Document (DocumentInternal)

- (void)updateViewOptions;

@end


@implementation Document

+ (BOOL)autosavesInPlace
{
	return YES;
}

+ (BOOL)preservesVersions
{
	return YES;
}

- (id)init
{
    self = [super init];
    
    if (self) {
		_processDisplay = [[LIProcessDisplay alloc] initWithProcessManager: [self processManager]];
		[[self processManager] addObserver:self forKeyPath:@"isRunning" options:0 context:NULL];
		
        _viewOptions = [[NSMutableDictionary alloc] init];
		_selectedObject = nil;
	}
    
    return self;
}

- (void)dealloc
{
	[[self processManager] removeObserver:self forKeyPath:@"isRunning"];
	
    
}


#pragma mark - Interface

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
	// Remove non-content columns
	[content removeColumnWithIdentifier: LIContentStatusColumnIdentifier];
	[content removeColumnWithIdentifier: LIContentActiveColumnIdentifier];
	[content removeColumnWithIdentifier: LIContentUpdatedColumnIdentifier];
	[content removeColumnWithIdentifier: LIContentFileColumnIdentifier];
	[content removeColumnWithIdentifier: LIContentKeyColumnIdentifier];
	[content removeColumnWithIdentifier: LIContentCommentColumnIdentifier];
	[content removeColumnWithIdentifier: LIContentMediaColumnIdentifier];
	
	// Set up content
	[content bind:@"objects" toObject:self withKeyPath:@"keys" options:nil];
	[content bind:@"selectedObject" toObject:self withKeyPath:@"selectedObject" options:nil];
	[content bind:@"leftLanguage" toObject:self withKeyPath:@"viewOptions.leftLanguage" options:nil];
	[content bind:@"rightLanguage" toObject:self withKeyPath:@"viewOptions.rightLanguage" options:nil];
	[content bind:@"search" toObject:self withKeyPath:@"viewOptions.search" options:nil];
	
	[[content view] setBorderType: NSNoBorder];
	
	// Other
	[[aController window] setFrameUsingName: @"window"];
	[aController setWindowFrameAutosaveName: @"window"];
	[aController setShouldCascadeWindows: YES];
	
    // call super
    [super windowControllerDidLoadNib: aController];
}

- (void)updateViewOptions
{
	// Init view options if needed
	NSString *leftLanguage = [_viewOptions objectForKey: DocumentViewOptionLeftLanguage];
	if (![_languages containsObject: leftLanguage] && [_languages count] >= 1)
		[_viewOptions setObject:[_languages objectAtIndex: 0] forKey:DocumentViewOptionLeftLanguage];
	
	NSString *rightLanguage = [_viewOptions objectForKey: DocumentViewOptionRightLanguage];
	if (![_languages containsObject: rightLanguage] && [_languages count] >= 2)
		[_viewOptions setObject:[_languages objectAtIndex: 1] forKey:DocumentViewOptionRightLanguage];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqual: @"isRunning"]) {
		content.maximumVisibleObjects = ([[self processManager] isRunning]) ? 100 : 0;
	}
}

- (void)didChangeValueForKey:(NSString *)key
{
	[super didChangeValueForKey: key];
	
	if ([[NSArray arrayWithObjects: @"keys", @"languages", nil] containsObject: key])
		[self updateChangeCount: NSChangeDone];
}

- (NSString *)filterDescription
{
	NSString *desc = @"";
	
	// Normalization
	if ([self.filterSettings objectForKey: BLDictionaryNormalizeFilterSetting]) {
		desc = [desc stringByAppendingFormat: NSLocalizedString(@"NormalizationSettings", nil), [BLLanguageTranslator descriptionForLanguage: [self.filterSettings objectForKey: BLDictionaryNormLanguageFilterSetting]]];
		desc = [desc stringByAppendingString: @"\n"];
	}
	// Filtering
	if ([self.filterSettings objectForKey: BLDictionaryLimitLanguagesFilterSetting]) {
		desc = [desc stringByAppendingFormat: NSLocalizedString(@"LanguageFilterSettings", nil), [[self.languages valueForKey: @"languageDescription"] componentsJoinedByString: @"“, “"]];
		desc = [desc stringByAppendingString: @"\n"];
	}
	
	if ([desc length])
		return desc;
	else
		return NSLocalizedString(@"NoFilterSettings", nil);
}

+ (NSSet *)keyPathsForValuesAffectingFilterDescription
{
	return [NSSet setWithObjects:
			[NSString stringWithFormat: @"filterSettings.%@", BLDictionaryNormalizeFilterSetting],
			[NSString stringWithFormat: @"filterSettings.%@", BLDictionaryNormLanguageFilterSetting],
			[NSString stringWithFormat: @"filterSettings.%@", BLDictionaryLimitLanguagesFilterSetting],
			@"languages", nil];
}


#pragma mark - File Loading / Saving

- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError **)outError
{
	BOOL result = [super readFromFileWrapper:fileWrapper ofType:typeName error:outError];
	if (result) {
		self.selectedObject = nil;
		[self updateViewOptions];
	
		[self updateChangeCount: NSChangeCleared];
	}
	
	return result;
}


#pragma mark - Accessors

- (NSString *)windowNibName
{
    return @"Document";
}

- (NSDictionary *)viewOptions
{
    return _viewOptions;
}

- (void)setViewOptions:(NSDictionary *)dict
{
    [_viewOptions setDictionary: dict];
}

@synthesize selectedObject=_selectedObject;

- (void)addLanguages:(NSArray *)someLanguages ignoreFilter:(BOOL)ignore
{
	[super addLanguages:someLanguages ignoreFilter:ignore];
	[self updateViewOptions];
}

- (void)removeLanguages:(NSArray *)someLanguages applyFilter:(BOOL)filter
{
	[super removeLanguages:someLanguages applyFilter:filter];
	[self updateViewOptions];
}


#pragma mark - Import

- (IBAction)beginImportFiles:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
	
    [panel setAllowsMultipleSelection: YES];
	[panel setAllowedFileTypes: [[self class] pathExtensionsForImport]];
	[panel setMessage: NSLocalizedString(@"ImportDescription", nil)];
    
	[panel beginSheetModalForWindow:[self windowForSheet] completionHandler:^(NSInteger result) {
		if (result != NSFileHandlingPanelOKButton)
			return;
		
		[self importFiles: [[panel URLs] valueForKey: @"path"]];
	}];
}


#pragma mark - Export

- (IBAction)exportDictionary:(id)sender
{
	[BLDictionaryExporter exportDictionaryFromObjects:self.keys forLanguages:self.languages inDocument:self updatingDictionary:NO];
}

- (IBAction)exportTMX:(id)sender
{
	[BLTMXExporter exportTMXFromObjects:self.keys inDocument:self];
}


#pragma mark - General Actions

- (IBAction)selectNext:(id)sender
{
	[content selectNext: sender];
}

- (IBAction)selectPrevious:(id)sender
{
	[content selectPrevious: sender];
}

- (IBAction)addKey:(id)sender
{
	NSIndexSet *indexes = [NSIndexSet indexSetWithIndex: [_keyObjects count]];
	BLKeyObject *newKey = [BLStringKeyObject keyObjectWithKey: nil];
	
	// Clear the search if necessary
	if ([[_viewOptions objectForKey: DocumentViewOptionSearch] length] > 0)
		[_viewOptions removeObjectForKey: DocumentViewOptionSearch];
	
	// Add the object
	[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"keys"];
	_keyObjects = [_keyObjects arrayByAddingObject: newKey];
	[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"keys"];

	// Select object and begin editing
	self.selectedObject = newKey;
	[content.contentView editColumn:0 row:[content.contentView selectedRow] withEvent:nil select:YES];
	
	// Make document dirty
	[self updateChangeCount: NSChangeDone];
}

- (IBAction)deleteKey:(id)sender
{
	// Remember the deleted item
	BLKeyObject *deletedObject = self.selectedObject;
	
	// Select the next item
	NSArray *visibleObjects = content.visibleObjects;
	NSInteger index = [visibleObjects indexOfObject: self.selectedObject];
	
	index++;
	// If we are the end select the previous one
	if (index == [visibleObjects count])
		index -= 2;
	
	if (index >= 0 && index < [visibleObjects count])
		self.selectedObject = [visibleObjects objectAtIndex: index];
	
	// Remove the previous item
	NSMutableArray *keyObjects = [NSMutableArray arrayWithArray: self.keys];
	[keyObjects removeObject: deletedObject];
	[self setKeys: keyObjects];

	// Make document dirty
	[self updateChangeCount: NSChangeDone];
}

- (IBAction)beginAddLanguage:(id)sender
{
	LILanguageSelection *selection = [LILanguageSelection languageSelection];
	
	// Display
	[selection setMessageText: NSLocalizedString(@"AddLanguagesTitle", nil)];
	[selection setInformativeText: NSLocalizedString(@"AddLanguagesText", nil)];
	[selection addButtonWithTitle: NSLocalizedString(@"Add", nil)];
	[selection addButtonWithTitle: NSLocalizedString(@"Cancel", nil)];
	
	// Languages
	NSMutableArray *languages = [NSMutableArray arrayWithArray: [BLLanguageTranslator allLanguageIdentifiers]];
	[languages removeObjectsInArray: self.languages];
	selection.availableLanguages = languages;
	selection.allowMultipleSelection = YES;
	
	[selection beginSheetModalForWindow:[self windowForSheet] completionHandler:^(NSInteger result) {
		if (result != NSAlertFirstButtonReturn)
			return;
		
		[self addLanguages:selection.selectedLanguages ignoreFilter:YES];
	}];
}

- (IBAction)beginDeleteLanguage:(id)sender
{
	LILanguageSelection *selection = [LILanguageSelection languageSelection];
	
	// Display
	[selection setMessageText: NSLocalizedString(@"RemoveLanguagesTitle", nil)];
	[selection setInformativeText: NSLocalizedString(@"RemoveLanguagesText", nil)];
	[selection addButtonWithTitle: NSLocalizedString(@"Remove", nil)];
	[selection addButtonWithTitle: NSLocalizedString(@"Cancel", nil)];
	
	selection.availableLanguages = self.languages;
	selection.allowMultipleSelection = YES;
	
	[selection beginSheetModalForWindow:[self windowForSheet] completionHandler:^(NSInteger result) {
		if (result != NSAlertFirstButtonReturn)
			return;
		
		[self removeLanguages:selection.selectedLanguages applyFilter:YES];
	}];
}


#pragma mark -

- (IBAction)showFilterSettings:(id)sender
{
	[NSApp beginSheet:filterSettingsPanel modalForWindow:[self windowForSheet] modalDelegate:nil didEndSelector:nil contextInfo:NULL];
}

- (IBAction)closeFilterSettings:(id)sender
{
	// Apply changes
	[self setKeys: [self keys]];
	
	// Close sheet
	[NSApp endSheet: filterSettingsPanel];
	[filterSettingsPanel close];
}

@end


