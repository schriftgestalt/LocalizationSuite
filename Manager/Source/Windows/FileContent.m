//
//  FileContentWindow.m
//  Localization Manager
//
//  Created by Max on 28.01.05.
//  Copyright 2005 The Blue Technologies Group. All rights reserved.
//

#import "FileContent.h"

#import "Document.h"
#import "Preferences.h"
#import "TableViewAdditions.h"

// Defines
NSString *FileContentWindowNibName	= @"FileContent";

@interface FileContent (FileContentInternal)

/*!
 @abstract Just a class-cast for -document.
 */
@property(readonly) Document *parentDocument;

@end


@implementation FileContent

- (id)init
{
    self = [super init];
	
    if (self) {
		_fileObject = nil;
		_otherLanguage = nil;
		_processDisplay = nil;
		_processManager = nil;
		_searchString = nil;
		_showComments = YES;
		_showEmptyStrings = NO;
		_showRemovedStrings = YES;
		
		[self setShouldCloseDocument: NO];
		[self setShouldCascadeWindows: YES];
	}
    
    return self;
}


- (void)close
{
    [self.parentDocument removeObserver:self forKeyPath:@"referenceLanguage"];
	[super close];
}

#pragma mark - Interface

- (NSString *)windowNibName
{
	return FileContentWindowNibName;
}

- (Document *)parentDocument
{
	return (Document *)[self document];
}

- (void)windowDidLoad
{
	// Init content
    [self.parentDocument addObserver:self forKeyPath:@"referenceLanguage" options:0 context:@"reference"];
	
	// Load preferences
    [self setOtherLanguage: [self.parentDocument.preferences objectForKey: PreferencesLastSelectedLanguageKey]];
    [self setShowEmptyStrings: [[self.parentDocument.preferences objectForKey: PreferencesShowEmptyStringsKey] boolValue]];
    [self setShowRemovedStrings: [[self.parentDocument.preferences objectForKey: PreferencesShowRemovedStringsKey] boolValue]];
	[self setShowComments: [[self.parentDocument.preferences objectForKey: PreferencesShowCommentsKey] boolValue]];
    
	// Update interface
	[content bind:@"objects" toObject:self withKeyPath:@"fileObject.objects" options:nil];
	[content bind:@"leftLanguage" toObject:self withKeyPath:@"parentDocument.referenceLanguage" options:nil];
	[content bind:@"rightLanguage" toObject:self withKeyPath:@"otherLanguage" options:nil];
	[content bind:@"search" toObject:self withKeyPath:@"searchString" options:nil];
	
	[oldContent bind:@"objects" toObject:self withKeyPath:@"fileObject.oldObjects" options:nil];
	[oldContent bind:@"leftLanguage" toObject:self withKeyPath:@"parentDocument.referenceLanguage" options:nil];
	[oldContent bind:@"rightLanguage" toObject:self withKeyPath:@"otherLanguage" options:nil];
	[oldContent bind:@"search" toObject:self withKeyPath:@"searchString" options:nil];
	
	// Add active and updated columns
	NSButtonCell *cell = [[NSButtonCell alloc] init];
	[cell setImagePosition: NSImageOnly];
	[cell setControlSize: NSMiniControlSize];
	[cell setButtonType: NSSwitchButton];
	
	[content removeColumnWithIdentifier: LIContentFileColumnIdentifier];
	content.leftLanguageEditable = YES;
	content.rightLanguageEditable = YES;
	content.attachedMediaEditable = YES;
	content.allowsMultipleSelection = YES;
	
	[oldContent.contentView setAutosaveName: nil];
	[oldContent removeColumnWithIdentifier: LIContentStatusColumnIdentifier];
	[oldContent removeColumnWithIdentifier: LIContentActiveColumnIdentifier];
	[oldContent removeColumnWithIdentifier: LIContentUpdatedColumnIdentifier];
	[oldContent removeColumnWithIdentifier: LIContentFileColumnIdentifier];
	[oldContent removeColumnWithIdentifier: LIContentCommentColumnIdentifier];
	[oldContent removeColumnWithIdentifier: LIContentMediaColumnIdentifier];
	oldContent.leftLanguageEditable = NO;
	oldContent.rightLanguageEditable = NO;
	
	// Load sorting
	[content.contentView loadSortDescriptors];
	[oldContent.contentView loadSortDescriptors];
	
	// Create window document binding
	[splitview adjustSubviews];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
	return [NSString stringWithFormat: NSLocalizedString(@"ContentWindowTitle", nil), displayName, [self.fileObject name]];
}


#pragma mark - Content Accessors

- (NSString *)otherLanguage
{
    return _otherLanguage;
}

- (NSArray *)availableOtherLanguages
{
    NSMutableArray *array;
    NSDictionary *dict;
    
    array = [NSMutableArray arrayWithArray: [self.parentDocument languages]];
    [array removeObject: [self.parentDocument referenceLanguage]];
	
    dict = [NSDictionary dictionaryWithObjects:[[NSValueTransformer valueTransformerForName: BLLanguageNameValueTransformerName] transformedValue: array]
									   forKeys:array];
    [array setArray: [dict keysSortedByValueUsingSelector: @selector(naturalCompare:)]];
    
    return array;
}

- (void)setOtherLanguage:(NSString *)newLanguage
{
    // Make sure the language is available
	NSArray *availableLanguages = [self availableOtherLanguages];
	if (![availableLanguages containsObject: newLanguage])
		newLanguage = ([availableLanguages count]) ? [availableLanguages objectAtIndex: 0] : nil;
	
	// Change the language
    _otherLanguage = newLanguage;
	
	// Save as preference
	if (newLanguage)
		[self.parentDocument.preferences setObject:newLanguage forKey:PreferencesLastSelectedLanguageKey];
	else
		[self.parentDocument.preferences removeObjectForKey: PreferencesLastSelectedLanguageKey];
}

@synthesize fileObject=_fileObject;

- (void)setFileObject:(BLFileObject *)object
{
	if (_fileObject) {
		[_fileObject removeObserver:self forKeyPath:@"changedValues"];
		[_fileObject removeObserver:self forKeyPath:@"objects"];
		[self endObservationOfObjects: _fileObject.objects];
	}
	
	_fileObject = object;
	
	if (_fileObject) {
		[_fileObject addObserver:self forKeyPath:@"changedValues" options:0 context:@"change"];
		[_fileObject addObserver:self forKeyPath:@"objects" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:@"objects"];
		[self beginObservationOfObjects: _fileObject.objects];
	}
}

@synthesize searchString=_searchString;
@synthesize showComments=_showComments;

- (void)setShowComments:(BOOL)flag
{
	_showComments = flag;
	[[NSUserDefaults standardUserDefaults] setBool:_showComments forKey:PreferencesShowCommentsKey];
	
	[content setColumnWithIdentifier:LIContentCommentColumnIdentifier isVisible:flag];
}

@synthesize showRemovedStrings=_showRemovedStrings;

- (void)setShowRemovedStrings:(BOOL)flag
{
	if (_showRemovedStrings == flag)
		return;
	
	_showRemovedStrings = flag;
	[self.parentDocument.preferences setObject:[NSNumber numberWithBool: _showRemovedStrings] forKey:PreferencesShowRemovedStringsKey];
	
	if (!flag) {
		[removedStringsView removeFromSuperview];
	} else {
		NSView *other = [splitview.subviews objectAtIndex: 0];
		[other setFrameSize: NSMakeSize(splitview.frame.size.width, splitview.frame.size.height - splitview.dividerThickness - removedStringsView.frame.size.height)];
		[splitview addSubview:removedStringsView positioned:NSWindowAbove relativeTo:other];
	}
}

- (BOOL)showEmptyStrings
{
    return _showEmptyStrings;
}

- (void)setShowEmptyStrings:(BOOL)flag
{
    _showEmptyStrings = flag;
	[[NSUserDefaults standardUserDefaults] setBool:_showEmptyStrings forKey:PreferencesShowEmptyStringsKey];
	
	if (!_showEmptyStrings) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%K != NIL && %K != ''", [self.parentDocument referenceLanguage], [self.parentDocument referenceLanguage]];
		[content setFilterPredicate: predicate];
		[oldContent setFilterPredicate: predicate];
	} else {
		[content setFilterPredicate: nil];
		[oldContent setFilterPredicate: nil];
	}
}


#pragma mark - Actions

- (IBAction)markAsActive:(id)sender
{
    [content.selectedObjects setValue:[NSNumber numberWithBool: ![sender selectedSegment]] forKeyPath: @"isActive"];
    [self.parentDocument updateChangeCount: NSChangeDone];
}

- (IBAction)markAsUpdated:(id)sender
{
    [content.selectedObjects setValue:[NSNumber numberWithBool: ![sender selectedSegment]] forKeyPath: @"wasUpdated"];
    [self.parentDocument updateChangeCount: NSChangeDone];
}

- (IBAction)autotranslate:(id)sender
{
	if (!_processManager)
		_processManager = [[BLProcessManager alloc] initWithDocument: (id)self.parentDocument];
	if (!_processDisplay) {
		_processDisplay = [[LIProcessDisplay alloc] initWithProcessManager: _processManager];
		_processDisplay.windowForSheet = [self window];
	}
	
	[_processManager enqueueStep: [LTAutotranslationStep stepForAutotranslatingObjects:content.visibleObjects forLanguage:[self otherLanguage] andReferenceLanguage:[self.parentDocument referenceLanguage]]];
	[_processManager startWithName: @"Autotranslating"];
}

- (IBAction)copyFromReference:(id)sender
{
	NSResponder *responder = [self.window firstResponder];
	[self.window makeFirstResponder: nil];
	
	for (BLKeyObject *object in content.selectedObjects)
		[object setObject:[object objectForLanguage: [self.parentDocument referenceLanguage]] forLanguage:_otherLanguage];
	
	[self.window makeFirstResponder: responder];
}

- (IBAction)deleteTranslation:(id)sender
{
	NSResponder *responder = [self.window firstResponder];
	[self.window makeFirstResponder: nil];
	
	for (BLKeyObject *object in content.selectedObjects)
		[object setObject:nil forLanguage:_otherLanguage];
	
	[self.window makeFirstResponder: responder];
}

- (void)beginObservationOfObjects:(NSArray *)objects
{
	NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, [objects count])];
	
	[objects addObserver:self toObjectsAtIndexes:indexes forKeyPath:@"flags" options:0 context:@"change"];
	[objects addObserver:self toObjectsAtIndexes:indexes forKeyPath:@"attachedMedia" options:0 context:@"change"];
}

- (void)endObservationOfObjects:(NSArray *)objects
{
	NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, [objects count])];
	
	[objects removeObserver:self fromObjectsAtIndexes:indexes forKeyPath:@"flags"];
	[objects removeObserver:self fromObjectsAtIndexes:indexes forKeyPath:@"attachedMedia"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == @"reference") {
		[self.window makeFirstResponder: nil];
		
		[self willChangeValueForKey: @"availableOtherLanguages"];
		[self didChangeValueForKey: @"availableOtherLanguages"];
	}
	if (context == @"objects") {
		[self endObservationOfObjects: [change objectForKey: NSKeyValueChangeOldKey]];
		[self beginObservationOfObjects: [change objectForKey: NSKeyValueChangeNewKey]];
	}
	if (context == @"change") {
		[self.parentDocument updateChangeCount: NSChangeDone];
	}
}

#pragma mark - Delegate methodes

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if (   [menuItem action] == @selector(copyFromReference:)
		|| [menuItem action] == @selector(deleteTranslation:))
		return ([self.window firstResponder] == content.contentView && [content.selectedObjects count]);
	
	return YES;
}

- (void)windowWillClose:(NSNotification *)notification
{
	[[self window] makeFirstResponder: nil];
	[content.contentView saveSortDescriptors];
}

@end

