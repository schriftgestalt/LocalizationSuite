/*!
 @header
 LIContentController.m
 Created by max on 25.08.09.

 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "LIContentController.h"

#import "LIAttachmentCell.h"
#import "LIContentArrayController.h"
#import "LIContentTableView.h"
#import "LIHighlightTextFieldCell.h"
#import "LIObjectStatusCell.h"

#import <BlueLocalization/BLRTFDKeyObject.h>

NSString *LIContentControllerNibName = @"LIContent";
NSString *LIContentControllerStringsName = @"LIContent";

NSString *LIContentStatusColumnIdentifier = @"status";
NSString *LIContentActiveColumnIdentifier = @"active";
NSString *LIContentUpdatedColumnIdentifier = @"updated";
NSString *LIContentFileColumnIdentifier = @"file";
NSString *LIContentKeyColumnIdentifier = @"key";
NSString *LIContentLeftColumnIdentifier = @"leftLanguage";
NSString *LIContentRightColumnIdentifier = @"rightLanguage";
NSString *LIContentCommentColumnIdentifier = @"comment";
NSString *LIContentMediaColumnIdentifier = @"media";

/*!
 @abstract Internal methods of LIContentController.
 */
@interface LIContentController (LIContentControllerInternal)

/*!
 @abstract Changes the contents of a table column to a different key path.
 */
- (void)updateTableColumn:(NSTableColumn *)column withContentKeyPath:(NSString *)keyPath;

/*!
 @abstract Updates the searchabel key paths according to visible columns.
 */
- (void)updateSearchableKeyPaths;

@end

@implementation LIContentController

- (id)init {
	self = [super init];

	if (self) {
		[NSBundle loadNibNamed:LIContentControllerNibName owner:self];

		[self updateSearchableKeyPaths];
		[arrayController addObserver:self forKeyPath:@"selectedObjects" options:0 context:@"selectedObjects"];
		[[tableView tableColumns] addObserver:self toObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [tableView numberOfColumns])] forKeyPath:@"hidden" options:0 context:@"hidden"];
		[tableView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, LIAttachmentPasteboardType, nil]];

		_previewPath = nil;
	}

	return self;
}

- (void)awakeFromNib {
	if (hostView) {
		[scrollView setFrameSize:[hostView frame].size];
		[scrollView setFrameOrigin:NSZeroPoint];

		[hostView addSubview:scrollView];

		[tableView sizeLastColumnToFit];
	}
}

- (void)dealloc {
	if (_previewPath) {
		[[NSFileManager defaultManager] removeItemAtPath:_previewPath error:NULL];
	}
}

#pragma mark - Accessors

- (NSScrollView *)view {
	return scrollView;
}

- (NSTableView *)contentView {
	return tableView;
}

@synthesize objects = _objects;

- (void)setObjects:(NSArray *)newObjects {
	_objects = newObjects;

	[self willChangeValueForKey:@"keyObjects"];
	[arrayController setContent:[BLObject keyObjectsFromArray:_objects]];
	[self didChangeValueForKey:@"keyObjects"];
}

- (NSArray *)keyObjects {
	return [arrayController content];
}

+ (NSSet *)keyPathsForValuesAffectingKeyObjects {
	return [NSSet setWithObjects:@"objects", nil];
}

- (NSUInteger)maximumVisibleObjects {
	return arrayController.maximumArrangedObjects;
}

- (void)setMaximumVisibleObjects:(NSUInteger)count {
	arrayController.maximumArrangedObjects = count;
}

- (NSArray *)visibleObjects {
	return [arrayController arrangedObjects];
}

+ (NSSet *)keyPathsForValuesAffectingVisibleObjects {
	return [NSSet setWithObjects:@"keyObjects", @"search", @"filterPredicate", @"leftLanguage", @"rightLanguage", @"maximumVisibleObjects", nil];
}

@synthesize leftLanguage = _leftLanguage;

- (void)setLeftLanguage:(NSString *)language {
	// End editing before changing column
	if ([tableView editedColumn] != -1)
		[[tableView window] makeFirstResponder:tableView];

	_leftLanguage = language;

	[self updateTableColumn:[tableView tableColumnWithIdentifier:LIContentLeftColumnIdentifier] withContentKeyPath:_leftLanguage];
}

@synthesize rightLanguage = _rightLanguage;

- (void)setRightLanguage:(NSString *)language {
	// End editing before changing column
	if ([tableView editedColumn] != -1)
		[[tableView window] makeFirstResponder:tableView];

	_rightLanguage = language;

	[self updateTableColumn:[tableView tableColumnWithIdentifier:LIContentRightColumnIdentifier] withContentKeyPath:_rightLanguage];
}

- (BOOL)leftLanguageEditable {
	return [[tableView tableColumnWithIdentifier:LIContentLeftColumnIdentifier] isEditable];
}

- (void)setLeftLanguageEditable:(BOOL)flag {
	[[tableView tableColumnWithIdentifier:LIContentLeftColumnIdentifier] setEditable:flag];
}

- (BOOL)rightLanguageEditable {
	return [[tableView tableColumnWithIdentifier:LIContentRightColumnIdentifier] isEditable];
}

- (void)setRightLanguageEditable:(BOOL)flag {
	[[tableView tableColumnWithIdentifier:LIContentRightColumnIdentifier] setEditable:flag];
}

- (BOOL)attachedMediaEditable {
	return arrayController.canEditAttachments;
}

- (void)setAttachedMediaEditable:(BOOL)flag {
	arrayController.canEditAttachments = flag;
}

- (BLKeyObject *)selectedObject {
	return [[arrayController selectedObjects] lastObject];
}

- (void)setSelectedObject:(BLKeyObject *)object {
	[arrayController setSelectedObjects:(object) ? [NSArray arrayWithObject:object] : nil];
	[tableView scrollRowToVisible:[[arrayController selectionIndexes] firstIndex]];
}

- (BOOL)allowsMultipleSelection {
	return tableView.allowsMultipleSelection;
}

- (void)setAllowsMultipleSelection:(BOOL)flag {
	tableView.allowsMultipleSelection = flag;
}

- (NSArray *)selectedObjects {
	return arrayController.selectedObjects;
}

- (void)setSelectedObjects:(NSArray *)selectedObjects {
	arrayController.selectedObjects = selectedObjects;
}

- (NSString *)search {
	return [arrayController searchPattern];
}

- (void)setSearch:(NSString *)string {
	for (NSTableColumn *column in [tableView tableColumns]) {
		NSCell *cell = [column dataCell];
		if ([cell isKindOfClass:[LIHighlightTextFieldCell class]])
			[(LIHighlightTextFieldCell *)cell setHighlightedString:string];
	}

	[arrayController setSearchPattern:string];
}

- (NSArray *)visibleColumnIdentifiers {
	NSMutableArray *identifiers;

	identifiers = [NSMutableArray arrayWithCapacity:[tableView numberOfColumns]];
	for (NSTableColumn *column in [tableView tableColumns]) {
		if (![column isHidden])
			[identifiers addObject:[column identifier]];
	}

	return identifiers;
}

- (void)setVisibleColumnIdentifiers:(NSArray *)identifiers {
	for (NSTableColumn *column in [tableView tableColumns])
		[column setHidden:![identifiers containsObject:[column identifier]]];
}

- (NSPredicate *)filterPredicate {
	return [arrayController filterPredicate];
}

- (void)setFilterPredicate:(NSPredicate *)predicate {
	[arrayController setFilterPredicate:predicate];
}

#pragma mark - Actions

- (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options {
	if ([binding isEqual:@"objects"]) {
		[observable addObserver:self forKeyPath:keyPath options:0 context:@"objects"];
	}

	[super bind:binding toObject:observable withKeyPath:keyPath options:options];
}

- (void)unbind:(NSString *)binding {
	if ([binding isEqual:@"objects"]) {
		[[[self infoForBinding:binding] objectForKey:NSObservedObjectKey] removeObserver:self forKeyPath:[[self infoForBinding:binding] objectForKey:NSObservedKeyPathKey]];
	}

	[super unbind:binding];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == @"objects") {
		[self setObjects:[object valueForKeyPath:keyPath]];
	}
	else if (context == @"hidden") {
		[self updateSearchableKeyPaths];
	}
	else if (context == @"selectedObjects") {
		[self willChangeValueForKey:@"selectedObject"];
		[self willChangeValueForKey:@"selectedObjects"];

		NSDictionary *info;
		if ((info = [self infoForBinding:@"selectedObject"]))
			[[info objectForKey:NSObservedObjectKey] setValue:self.selectedObject forKeyPath:[info objectForKey:NSObservedKeyPathKey]];
		if ((info = [self infoForBinding:@"selectedObjects"]))
			[[info objectForKey:NSObservedObjectKey] setValue:self.selectedObjects forKeyPath:[info objectForKey:NSObservedKeyPathKey]];

		[self didChangeValueForKey:@"selectedObject"];
		[self didChangeValueForKey:@"selectedObjects"];

		[tableView scrollRowToVisible:[[arrayController selectionIndexes] firstIndex]];
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)updateTableColumn:(NSTableColumn *)column withContentKeyPath:(NSString *)keyPath {
	// Update the column
	if ([keyPath length]) {
		[column bind:@"value" toObject:arrayController withKeyPath:[NSString stringWithFormat:@"arrangedObjects.%@", keyPath] options:nil];

		[[column headerCell] setStringValue:[BLLanguageTranslator descriptionForLanguage:keyPath] ?: keyPath];
		[[column sortDescriptorPrototype] setValue:keyPath forKey:@"key"];
		[column.tableView.headerView setNeedsDisplay:YES];
	}

	// Update the search paths
	[self updateSearchableKeyPaths];
}

- (void)updateSearchableKeyPaths {
	NSMutableArray *keyPaths = [NSMutableArray array];

	for (NSTableColumn *column in [tableView tableColumns]) {
		if ([column isHidden])
			continue;

		if ([column.identifier isEqual:LIContentLeftColumnIdentifier] && _leftLanguage)
			[keyPaths addObject:_leftLanguage];
		else if ([column.identifier isEqual:LIContentRightColumnIdentifier] && _rightLanguage)
			[keyPaths addObject:_rightLanguage];
		else if (column.identifier)
			[keyPaths addObject:column.identifier];
	}

	[arrayController setSearchableKeyPaths:keyPaths];
}

- (void)setColumnWithIdentifier:(NSString *)identifier isVisible:(BOOL)visible {
	[[tableView tableColumnWithIdentifier:identifier] setHidden:!visible];
}

- (void)removeColumnWithIdentifier:(NSString *)identifier {
	NSTableColumn *column = [tableView tableColumnWithIdentifier:identifier];

	[column removeObserver:self forKeyPath:@"hidden"];
	[tableView removeTableColumn:column];
	[tableView sizeToFit];
}

- (IBAction)selectNext:(id)sender {
	NSInteger editedColumn, row;

	editedColumn = [tableView editedColumn];
	row = [tableView selectedRow] + 1;

	if (row >= [tableView numberOfRows])
		row = 0;
	if (row != [tableView numberOfRows]) {
		[tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
		if (editedColumn >= 0)
			[tableView editColumn:editedColumn row:row withEvent:nil select:YES];
	}
}

- (IBAction)selectPrevious:(id)sender {
	NSInteger editedColumn, row;

	editedColumn = [tableView editedColumn];
	row = [tableView selectedRow];

	if (row > [tableView numberOfRows] || row <= 0)
		row = [tableView numberOfRows];
	if (row > 0) {
		[tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row - 1] byExtendingSelection:NO];
		if (editedColumn >= 0)
			[tableView editColumn:editedColumn row:row - 1 withEvent:nil select:YES];
	}
}

#pragma mark - Delegates

- (CGFloat)tableView:(NSTableView *)aTableView heightOfRow:(NSInteger)row {
	return [arrayController tableView:aTableView heightOfRow:row];
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	// We cannot edit RTFD contents at this time
	return ![[[self keyObjects] objectAtIndex:row] isKindOfClass:[BLRTFDKeyObject class]];
}

- (BOOL)tableView:(NSTableView *)aTableView shouldShowCellExpansionForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	if ([[tableColumn identifier] isEqual:LIContentStatusColumnIdentifier])
		return NO;
	return YES;
}

- (NSString *)tableView:(NSTableView *)aTableView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation {
	if ([[tableColumn identifier] isEqual:LIContentStatusColumnIdentifier])
		return [(LIObjectStatusCell *)cell toolTip];

	return nil;
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	[arrayController tableView:aTableView willDisplayCell:cell forTableColumn:tableColumn row:row];
}

- (BOOL)tableView:(NSTableView *)tableView shouldTrackCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	return YES;
}

- (NSString *)tableView:(NSTableView *)aTableView customNameForColumn:(NSTableColumn *)column {
	if ([[column identifier] isEqual:LIContentStatusColumnIdentifier])
		return NSLocalizedStringFromTableInBundle([column identifier], LIContentControllerStringsName, [NSBundle bundleForClass:[self class]], nil);
	if ([[column identifier] isEqual:LIContentActiveColumnIdentifier])
		return NSLocalizedStringFromTableInBundle([column identifier], LIContentControllerStringsName, [NSBundle bundleForClass:[self class]], nil);
	if ([[column identifier] isEqual:LIContentUpdatedColumnIdentifier])
		return NSLocalizedStringFromTableInBundle([column identifier], LIContentControllerStringsName, [NSBundle bundleForClass:[self class]], nil);

	return [[column headerCell] stringValue];
}

#pragma mark -

- (NSArray *)currentObjectsInTableView:(LIContentTableView *)aTableView {
	return [arrayController selectedObjects];
}

- (NSArray *)currentLanguagesInTableView:(LIContentTableView *)aTableView {
	return [NSArray arrayWithObjects:self.leftLanguage, self.rightLanguage, nil];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
	[[notification object] updateCurrentObjects];
}

- (void)tableViewShouldCopySelection:(LIContentTableView *)aTableView {
	NSPasteboard *pboard = [NSPasteboard generalPasteboard];

	[pboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:aTableView];
	[pboard setString:[self.selectedObject stringForLanguage:self.rightLanguage] forType:NSStringPboardType];
}

#pragma mark -

- (id<QLPreviewPanelDataSource>)dataSourceForPreviewPanel:(QLPreviewPanel *)previewPanel inTableView:(LIContentTableView *)aTableView {
	return self;
}

- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel {
	return (self.selectedObject.attachedMedia) ? 1 : 0;
}

- (id<QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index {
	NSFileWrapper *media = self.selectedObject.attachedMedia;

	if (_previewPath) {
		[[NSFileManager defaultManager] removeItemAtPath:_previewPath error:NULL];
		_previewPath = nil;
	}
	if (media) {
		_previewPath = [@"/tmp/" stringByAppendingPathComponent:[media preferredFilename]];
		[media writeToURL:[NSURL fileURLWithPath:_previewPath] options:NSFileWrapperWritingAtomic originalContentsURL:nil error:nil];

		return [NSURL fileURLWithPath:_previewPath];
	}

	return nil;
}

@end
