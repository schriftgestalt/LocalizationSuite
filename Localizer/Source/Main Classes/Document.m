//
//  Document.m
//  Localizer
//
//  Created by Max on 01.12.2004
//  Copyright (c) 2003-2005 The Blue Technologies Group. All rights reserved.
//

#import "Document.h"

#import "Editor.h"
#define OBJC_OLD_DISPATCH_PROTOTYPES 0
#import <objc/message.h>

#import "GSSplitViewWindowController.h"

BOOL(*objc_msgSendPerform)
(id self, SEL _cmd, NSString *referenceLanguage, NSString *targetLanguage) = (void *)objc_msgSend;

// Keys
NSString *DocumentViewOptionDisplayEqualsAsOne = @"displayEqualStringsAsOne";
NSString *DocumentViewOptionFilter = @"filter";
NSString *DocumentViewOptionLeftLanguage = @"leftLanguage";
NSString *DocumentViewOptionRightLanguage = @"rightLanguage";
NSString *DocumentViewOptionSearch = @"search";
NSString *DocumentViewOptionSegmentation = @"segmentation";
NSString *DocumentViewOptionShowComments = @"showComments";
NSString *DocumentViewOptionShowEditor = @"showEditor";
NSString *DocumentViewOptionShowPreview = @"showPreview";
NSString *DocumentViewOptionShowProblems = @"showTranslationProblems";

NSString *DocumentNibName = @"Document";
NSString *DocumentWindowAutosaveName = @"window";

typedef enum {
	DocumentKeyViewAllKeys = 0,
	DocumentKeyViewChangedKeysOnly = 1,
	DocumentKeyViewEditedKeysOnly = 2,
	DocumentKeyViewMissingKeysOnly = 3,
	DocumentKeyViewAutotranslatedKeys = 4,
	DocumentKeyViewProblematicKeys = 5
} DocumentKeyView;

@interface BLKeyObject (DocumentActions)

- (BOOL)copyFromReference:(NSString *)referenceLanguage toLanguage:(NSString *)targetLanguage;
- (BOOL)copyMissingPlaceholdersFromReference:(NSString *)referenceLanguage toLanguage:(NSString *)targetLanguage;

@end

// Implementation
@implementation Document

+ (BOOL)autosavesInPlace {
	return NO;
}

- (id)init {
	self = [super init];

	if (self) {
		_selectedObject = nil;
		_processDisplay = [[LIProcessDisplay alloc] initWithProcessManager:[self processManager]];

		[[LIPreferences sharedInstance] initDocument:self];
	}

	return self;
}

#pragma mark - Interface

- (void)makeWindowControllers {
	// Preview
	if ([[[self properties] objectForKey:BLIncludesPreviewPropertyName] boolValue]) {
		_previewController = [[LIPreviewController alloc] init];
		[_previewController bind:@"keyObject" toObject:self withKeyPath:@"selectedObject" options:nil];
		[_previewController bind:@"languages" toObject:self withKeyPath:@"languages" options:nil];
		[_previewController bind:@"windowIsVisible" toObject:self withKeyPath:@"preferences.showPreview" options:nil];

		_previewController.currentLanguage = [self.preferences objectForKey:DocumentViewOptionRightLanguage];

		[self addWindowController:_previewController];
	}

	// Main window
	_windowController = [[GSSplitViewWindowController alloc] initWithWindowNibName:DocumentNibName owner:self];
	[self addWindowController:_windowController];
	[_windowController setWindowFrameAutosaveName:DocumentWindowAutosaveName];
	[_windowController setShouldCloseDocument:YES];
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
	// Remove unwanted columns
	[content removeColumnWithIdentifier:LIContentActiveColumnIdentifier];
	[content removeColumnWithIdentifier:LIContentUpdatedColumnIdentifier];

	// Set up content data
	[content bind:@"objects" toObject:self withKeyPath:@"filteredKeys" options:nil];
	[content bind:@"leftLanguage" toObject:self withKeyPath:@"preferences.leftLanguage" options:nil];
	[content bind:@"leftLanguageEditable" toObject:editor withKeyPath:@"leftFieldEditable" options:nil];
	[content bind:@"rightLanguage" toObject:self withKeyPath:@"preferences.rightLanguage" options:nil];
	[content bind:@"rightLanguageEditable" toObject:editor withKeyPath:@"rightFieldEditable" options:nil];
	[content bind:@"selectedObject" toObject:self withKeyPath:@"selectedObject" options:nil];
	[content bind:@"search" toObject:self withKeyPath:@"preferences.search" options:nil];

	// adjust content view
	NSRect frame = content.view.frame;
	frame.size.height += 1;
	content.view.frame = frame;
	//[content.view setBorderType: NSNoBorder];

	// set double action
	[content.contentView setDoubleAction:@selector(openSeparateEditor:)];
	[content.contentView setTarget:self];

	// set up interface dependencies
	[self.preferences addObserver:self forKeyPath:DocumentViewOptionFilter options:0 context:NULL];

	// sorting
	[bundlesController setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES]]];

	// call super
	[super windowControllerDidLoadNib:aController];

	// Set up content observal
	[bundlesController addObserver:self forKeyPath:@"selectedObjects" options:0 context:@"filteredKeys"];
	[self.preferences addObserver:self forKeyPath:DocumentViewOptionFilter options:0 context:@"filteredKeys"];
	[self.preferences addObserver:self forKeyPath:DocumentViewOptionSegmentation options:0 context:@"filteredKeys"];
	[self.preferences addObserver:self forKeyPath:DocumentViewOptionDisplayEqualsAsOne options:0 context:@"filteredKeys"];

	[_bundles addObserver:self toObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [_bundles count])] forKeyPath:@"changedValues" options:0 context:@"change"];

	// Editor
	[editor setUp];

	[[BLDictionaryController sharedInstance] registerDocument:self];
	[[LIPreferences sharedInstance] registerDocument:self];

	if (self.languages.count <= 2) {
		self.languageSelectionView.hidden = YES;
	}
	if (@available(macOS 11, *)) {
		self.bundleListTableView.style = NSTableViewStyleSourceList;
	}
}

- (void)showWindows {
	[_previewController showWindow:nil];
	[_windowController showWindow:nil];
}

- (NSWindow *)windowForSheet {
	return [_windowController window];
}

- (void)shouldCloseWindowController:(NSWindowController *)windowController delegate:(id)delegate shouldCloseSelector:(SEL)shouldCloseSelector contextInfo:(void *)contextInfo {
	[super shouldCloseWindowController:windowController delegate:delegate shouldCloseSelector:shouldCloseSelector contextInfo:contextInfo];
}

- (void)canCloseDocumentWithDelegate:(id)delegate shouldCloseSelector:(SEL)shouldCloseSelector contextInfo:(void *)contextInfo {
	[[self windowForSheet] makeFirstResponder:nil];
	[super canCloseDocumentWithDelegate:delegate shouldCloseSelector:shouldCloseSelector contextInfo:contextInfo];
}

#pragma mark - File Loading / Saving

- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError **)outError {

	BOOL result = [super readFromFileWrapper:fileWrapper ofType:typeName error:outError];
	if (!result) {
		return NO;
	}
	[self setSelectedObject:nil];

	// Process languages
	NSArray *languages = [self languages];
	[self.preferences setObject:[languages objectAtIndex:0] forKey:DocumentViewOptionLeftLanguage];

	if ([languages count] > 1)
		[self.preferences setObject:[languages objectAtIndex:1] forKey:DocumentViewOptionRightLanguage];
	else
		[self.preferences setObject:[languages objectAtIndex:0] forKey:DocumentViewOptionRightLanguage];

	return YES;
}

- (void)close {
	if (editor) {
		[editor cleanUp];
		editor = nil;
	}
	[[BLDictionaryController sharedInstance] unregisterDocument:self];
	[[LIPreferences sharedInstance] unregisterDocument:self];

	// release remaining instances
	if (_previewController != nil) {
		_previewController = nil;
	}

	// call super
	[super close];
}

+ (NSDictionary *)defaultPreferences {
	NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithDictionary:[super defaultPreferences]];

	[prefs setObject:[NSNumber numberWithBool:NO] forKey:DocumentViewOptionShowComments];
	[prefs setObject:[NSNumber numberWithBool:YES] forKey:DocumentViewOptionShowEditor];
	[prefs setObject:[NSNumber numberWithBool:NO] forKey:DocumentViewOptionShowPreview];
	[prefs setObject:[NSNumber numberWithBool:YES] forKey:DocumentViewOptionShowProblems];
	[prefs setObject:[NSNumber numberWithInt:DocumentKeyViewAllKeys] forKey:DocumentViewOptionFilter];
	[prefs setObject:[NSNumber numberWithInt:0] forKey:DocumentViewOptionSegmentation];
	[prefs setObject:[NSNumber numberWithBool:NO] forKey:DocumentViewOptionDisplayEqualsAsOne];

	return prefs;
}

+ (NSArray *)userPreferenceKeys {
	return [[super userPreferenceKeys] arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:DocumentViewOptionShowComments, DocumentViewOptionShowEditor, DocumentViewOptionShowPreview, DocumentViewOptionShowProblems, DocumentViewOptionFilter, DocumentViewOptionSegmentation, DocumentViewOptionDisplayEqualsAsOne, nil]];
}

#pragma mark - Accessors

- (NSString *)name {
	return [self displayName];
}

@synthesize selectedObject = _selectedObject;

- (NSUInteger)progress {
	NSUInteger total = [BLObject numberOfKeysInObjects:_bundles];
	if (total < 1)
		return 0;

	NSUInteger missing = [BLObject numberOfKeysMissingForLanguage:[self.preferences objectForKey:DocumentViewOptionRightLanguage] inObjects:_bundles];

	if (missing == 0)
		return 100;

	return 99 - (missing * 99) / total;
}

+ (NSSet *)keyPathsForValuesAffectingProgress {
	return [NSSet setWithObjects:@"preferences.rightLanguage", nil];
}

#pragma mark - Interface Actions

- (void)performActionOnCurrentObject:(SEL)action moveForward:(BOOL)moveSelection alwaysBeginEditing:(BOOL)alwaysBeginEditing {
	// Current editing state
	NSInteger editedColumn = [[content contentView] editedColumn];
	BOOL isEditing = [editor isEditing];

	BLKeyObject *object = [self selectedObject];
	NSString *referenceLanguage = [self referenceLanguage];

	// Determine target language
	NSString *targetLanguage = [self.preferences objectForKey:DocumentViewOptionRightLanguage];
	if ([referenceLanguage isEqual:targetLanguage])
		targetLanguage = [self.preferences objectForKey:DocumentViewOptionLeftLanguage];
	if ([referenceLanguage isEqual:targetLanguage])
		// Both languages seem to be the reference
		return;

	// End editing
	[[self windowForSheet] endEditingFor:nil];

	// Copy string
	BOOL needsEditing = objc_msgSendPerform(object, action, referenceLanguage, targetLanguage);
	[self updateChangeCount:NSChangeDone];

	// Move selection
	if (moveSelection)
		[self selectNext:nil];

	// Enforce editing
	if (alwaysBeginEditing || needsEditing) {
		if (editedColumn < 0 && [[self windowForSheet] firstResponder] == [content contentView])
			editedColumn = [[content contentView] columnWithIdentifier:LIContentRightColumnIdentifier];
		else if (!isEditing)
			isEditing = YES;
	}

	// Restart editing
	if (editedColumn >= 0)
		[[content contentView] editColumn:editedColumn row:[[content contentView] selectedRow] withEvent:nil select:YES];
	else if (isEditing)
		[editor beginEditing];
}

- (IBAction)copyFromReference:(id)sender {
	[self performActionOnCurrentObject:@selector(copyFromReference:toLanguage:) moveForward:YES alwaysBeginEditing:NO];
}

- (IBAction)editCopyOfRefernence:(id)sender {
	[self performActionOnCurrentObject:@selector(copyFromReference:toLanguage:) moveForward:NO alwaysBeginEditing:YES];
}

- (IBAction)insertMissingPlaceholders:(id)sender {
	[self performActionOnCurrentObject:@selector(copyMissingPlaceholdersFromReference:toLanguage:) moveForward:NO alwaysBeginEditing:NO];
}

- (IBAction)openSeparateEditor:(id)sender {
	NSTableView *contentView;
	NSTableColumn *column;

	// Skip if nothing selected
	if ([self selectedObject] == nil)
		return;

	// Open separate editor, if clicked at a non-editable column
	contentView = content.contentView;
	column = [[contentView tableColumns] objectAtIndex:[contentView clickedColumn]];

	// Skip non-text columns
	if (![[column dataCell] isKindOfClass:[NSTextFieldCell class]])
		return;

	// Open separate editor
	if (![column isEditable]) {
		[self.preferences setObject:[NSNumber numberWithBool:YES] forKey:DocumentViewOptionShowEditor];
		[editor beginEditing];
	}
	// Begin editing in place
	else {
		[contentView editColumn:[contentView clickedColumn] row:[contentView clickedRow] withEvent:nil select:YES];
	}
}

- (IBAction)editDictionaries:(id)sender {
	[[LIDictionarySettings sharedInstance] showWindow:self];
}

#pragma mark -

- (IBAction)selectNext:(id)sender {
	BOOL editing = [editor isEditing];

	[content selectNext:nil];

	if (editing)
		[editor beginEditing];
}

- (IBAction)selectPrevious:(id)sender {
	BOOL editing = [editor isEditing];

	[content selectPrevious:nil];

	if (editing)
		[editor beginEditing];
}

#pragma mark -

- (IBAction)useFirstMatch:(id)sender {
	[editor useMatchAtIndex:0];
}

- (IBAction)useSecondMatch:(id)sender {
	[editor useMatchAtIndex:1];
}

- (IBAction)useThirdMatch:(id)sender {
	[editor useMatchAtIndex:2];
}

#pragma mark -

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	SEL action = [menuItem action];

	if (action == @selector(useFirstMatch:))
		return ([editor.matches count] >= 1);
	if (action == @selector(useSecondMatch:))
		return ([editor.matches count] >= 2);
	if (action == @selector(useThirdMatch:))
		return ([editor.matches count] >= 3);

	if (action == @selector(copyFromReference:) || action == @selector(editCopyOfRefernence:))
		return ([self selectedObject] != nil);

	return YES;
}

#pragma mark - Import

- (IBAction)importStrings:(id)sender {
	[BLStringsImporter importStringsToObjects:[self bundles] inDocument:self];
}

- (IBAction)importXLIFF:(id)sender {
	[BLXLIFFImporter importXLIFFToObjects:[self bundles] inDocument:self];
}

#pragma mark - Export

- (NSArray *)languagesForExport {
	return [NSArray arrayWithObjects:[self.preferences objectForKey:DocumentViewOptionLeftLanguage], [self.preferences objectForKey:DocumentViewOptionRightLanguage], nil];
}

- (IBAction)exportAsDictionary:(id)sender {
	[BLDictionaryExporter exportDictionaryFromObjects:[self bundles] forLanguages:[self languages] inDocument:self updatingDictionary:NO];
}

- (IBAction)exportIntoDictionary:(id)sender {
	[BLDictionaryExporter exportDictionaryFromObjects:[self bundles] forLanguages:[self languages] inDocument:self updatingDictionary:YES];
}

- (IBAction)exportStrings:(id)sender {
	[BLStringsExporter exportStringsFromObjects:[self bundles] forLanguages:[self languagesForExport] inDocument:self];
}

- (IBAction)exportXLIFF:(id)sender {
	[BLXLIFFExporter exportXLIFFFromObjects:[self bundles] forLanguages:[self languagesForExport] inDocument:self];
}

#pragma mark - Data Preparation

- (NSArray *)filteredKeys {
	NSString *leftLanguage, *rightLanguage, *referenceLanguage, *otherLanguage;
	NSMutableArray *keyObjects;

	// Init
	leftLanguage = [self.preferences objectForKey:DocumentViewOptionLeftLanguage];
	rightLanguage = [self.preferences objectForKey:DocumentViewOptionRightLanguage];

	referenceLanguage = [self referenceLanguage];
	otherLanguage = (![rightLanguage isEqual:referenceLanguage]) ? rightLanguage : leftLanguage;

	keyObjects = [NSMutableArray arrayWithArray:[BLObject keyObjectsFromArray:[bundlesController selectedObjects]]];

	// Apply view filter
	switch ([[self.preferences objectForKey:DocumentViewOptionFilter] intValue]) {
		case DocumentKeyViewChangedKeysOnly: {
			for (NSInteger i = [keyObjects count] - 1; i >= 0; i--) {
				if (!([[keyObjects objectAtIndex:i] flags] & BLObjectUpdatedFlag))
					[keyObjects removeObjectAtIndex:i];
			}
			break;
		}
		case DocumentKeyViewEditedKeysOnly: {
			for (NSInteger i = [keyObjects count] - 1; i >= 0; i--) {
				if ([[keyObjects objectAtIndex:i] didChange] == NO)
					[keyObjects removeObjectAtIndex:i];
			}
			break;
		}
		case DocumentKeyViewMissingKeysOnly: {
			for (NSInteger i = [keyObjects count] - 1; i >= 0; i--) {
				if ([[[keyObjects objectAtIndex:i] stringForLanguage:otherLanguage] length] > 0)
					[keyObjects removeObjectAtIndex:i];
			}
			break;
		}
		case DocumentKeyViewAutotranslatedKeys: {
			for (NSInteger i = [keyObjects count] - 1; i >= 0; i--) {
				if (!([[keyObjects objectAtIndex:i] flags] & BLKeyObjectAutotranslatedFlag))
					[keyObjects removeObjectAtIndex:i];
			}
			break;
		}
		case DocumentKeyViewProblematicKeys: {
			for (NSInteger i = [keyObjects count] - 1; i >= 0; i--) {
				if (![[LTTranslationChecker calculateTranslationErrorsForKeyObject:[keyObjects objectAtIndex:i] forLanguage:otherLanguage withReference:referenceLanguage] count])
					[keyObjects removeObjectAtIndex:i];
			}
		}
		default:
		case DocumentKeyViewAllKeys: {
			// we want all, so we do nothing
			break;
		}
	}

	// Apply segmentation
	NSUInteger segmentation = [[self.preferences objectForKey:DocumentViewOptionSegmentation] intValue];
	if (segmentation > 0) {
		NSMutableArray *newObjects = [NSMutableArray arrayWithCapacity:[keyObjects count]];

		for (BLKeyObject *key in keyObjects)
			[newObjects addObjectsFromArray:[BLSegmentedKeyObject segmentKeyObject:key byType:segmentation]];

		keyObjects = newObjects;
	}

	// Merge equal strings
	if ([[self.preferences objectForKey:DocumentViewOptionDisplayEqualsAsOne] boolValue]) {
		NSSortDescriptor *descriptor;
		NSString *value, *lastValue;
		NSRange equalRange;

		descriptor = [[NSSortDescriptor alloc] initWithKey:referenceLanguage ascending:YES selector:@selector(compareAsString:)];
		[keyObjects sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];

		lastValue = nil;
		equalRange = NSMakeRange(0, 0);

		for (NSInteger i = 0; i < [keyObjects count]; i++) {
			value = [[keyObjects objectAtIndex:i] stringForLanguage:referenceLanguage];

			if (![value isEqual:lastValue]) {
				if (equalRange.length > 1) {
					BLGroupedKeyObject *group;

					group = [BLGroupedKeyObject keyObjectWithKeyObjects:[keyObjects subarrayWithRange:equalRange]];
					[keyObjects replaceObjectsInRange:equalRange withObjectsFromArray:[NSArray arrayWithObject:group]];

					i -= equalRange.length - 1;
				}

				equalRange = NSMakeRange(i, 1);
				lastValue = value;
			}
			else {
				equalRange.length++;
			}
		}
	}

	return keyObjects;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([[self.preferences objectForKey:DocumentViewOptionFilter] intValue] == DocumentKeyViewProblematicKeys)
		[self.preferences setObject:[NSNumber numberWithBool:YES] forKey:DocumentViewOptionShowProblems];
	if (context == @"filteredKeys") {
		[self willChangeValueForKey:@"filteredKeys"];
		[self didChangeValueForKey:@"filteredKeys"];
	}
	if (context == @"change") {
		[self updateChangeCount:NSChangeDone];

		[self willChangeValueForKey:@"progress"];
		[self didChangeValueForKey:@"progress"];
	}
}

#pragma mark - Autotranslation

- (IBAction)autotranslate:(id)sender {
	NSString *language;

	if (![[self referenceLanguage] isEqual:[self.preferences objectForKey:DocumentViewOptionRightLanguage]])
		language = [self.preferences objectForKey:DocumentViewOptionRightLanguage];
	else
		language = [self.preferences objectForKey:DocumentViewOptionLeftLanguage];

	// Autotranslation
	[_processManager enqueueStep:[LTAutotranslationStep stepForAutotranslatingObjects:content.keyObjects forLanguage:language andReferenceLanguage:[self referenceLanguage]]];

	// Display update
	[_processManager enqueueStep:[BLGenericProcessStep genericStepWithBlock:^{
						 [self updateChangeCount:NSChangeDone];
					 }]];

	// Start
	[_processManager start];
}

#pragma mark - Delegates

- (NSArray *)currentObjectsInTableView:(NSTableView *)tableView {
	return [bundlesController selectedObjects];
}

- (NSArray *)currentLanguagesInTableView:(NSTableView *)tableView {
	return [NSArray arrayWithObjects:[self.preferences objectForKey:DocumentViewOptionLeftLanguage], [self.preferences objectForKey:DocumentViewOptionRightLanguage], nil];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
	[[notification object] updateCurrentObjects];
}

#pragma mark -

@end

@implementation BLKeyObject (DocumentActions)

- (BOOL)copyFromReference:(NSString *)referenceLanguage toLanguage:(NSString *)targetLanguage {
	[self setObject:[self objectForLanguage:referenceLanguage] forLanguage:targetLanguage];
	return NO;
}

- (BOOL)copyMissingPlaceholdersFromReference:(NSString *)referenceLanguage toLanguage:(NSString *)targetLanguage {
	// String keys only
	if ([[self class] classOfObjects] != [NSString class])
		return NO;

	NSString *value = [self stringForLanguage:targetLanguage];
	NSArray *targetPlaceholders = [LTTranslationChecker extractPlaceholdersFromString:value];
	NSArray *referencePlaceholders = [LTTranslationChecker extractPlaceholdersFromString:[self stringForLanguage:referenceLanguage]];

	// All placeholders are present
	if (targetPlaceholders.count == referencePlaceholders.count)
		return NO;

	// Copy missing placeholders
	if (!value)
		value = @"";

	for (NSUInteger i = targetPlaceholders.count; i < referencePlaceholders.count; i++) {
		if (value.length)
			value = [value stringByAppendingString:@" "];
		value = [value stringByAppendingString:[[referencePlaceholders objectAtIndex:i] objectForKey:@"placeholder"]];
	}
	[self setObject:value forLanguage:targetLanguage];

	return YES;
}

#if 0 // TODO: it is not called and I don’t know why???
- (NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex {
	NSView *subView = splitView.subviews[dividerIndex];
	if (subView) {
		NSLog(@"___ %@ >> %@", subView, subView.subviews);
	}
	return NSZeroRect;
}
#endif

@end
