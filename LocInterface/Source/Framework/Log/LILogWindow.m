/*!
 @header
 LILogWindow.m
 Created by Max Seelemann on 03.09.06.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "LILogWindow.h"
#import "LILogLevelValueTransformer.h"

NSString *LILogWindowNibName = @"LILogWindow";

@interface LILogWindow (LILogWindowInternal)

- (NSString *)copiedTextFromItem:(BLProcessLogItem *)item;

@end

@implementation LILogWindow

id __sharedLogWindow;

- (id)init {
	self = [super init];

	_displayLevel = BLLogInfo;

	[[BLProcessLog sharedLog] addObserver:self forKeyPath:@"items" options:NSKeyValueObservingOptionOld context:NULL];

	return self;
}

- (void)dealloc {
	__sharedLogWindow = nil;
	[[BLProcessLog sharedLog] removeObserver:self forKeyPath:@"items"];
}

+ (id)logWindow {
	if (!__sharedLogWindow)
		__sharedLogWindow = [[self alloc] init];

	return __sharedLogWindow;
}

#pragma mark - Accessors

- (BLProcessLogLevel)displayLevel {
	return _displayLevel;
}

#pragma mark - Actions

- (void)show {
	if (!window)
		[NSBundle loadNibNamed:LILogWindowNibName owner:self];

	[window orderFront:self];
}

- (BOOL)windowShouldClose:(id)sender {
	_wasClosed = YES;
	return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	// Observe root items
	if ([keyPath isEqual:@"items"] && object == [BLProcessLog sharedLog]) {
		NSMutableSet *newItems;

		newItems = [NSMutableSet setWithArray:[[BLProcessLog sharedLog] items]];
		if ([change objectForKey:NSKeyValueChangeOldKey] != [NSNull null])
			[newItems minusSet:[NSSet setWithArray:[change objectForKey:NSKeyValueChangeOldKey]]];
		[[newItems allObjects] addObserver:self toObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [newItems count])] forKeyPath:@"level" options:0 context:NULL];
		[[newItems allObjects] addObserver:self toObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [newItems count])] forKeyPath:@"items" options:0 context:NULL];

		_wasClosed = NO;
		[outlineView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	}

	// Trigger window open
	if ([keyPath isEqual:@"level"]) {
		if (!_wasClosed && (!window || ![window isVisible]) && [[object valueForKey:@"level"] intValue] >= BLLogWarning)
			[self performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
	}

	// Trigger display update
	if ([keyPath isEqual:@"items"] && [object isKindOfClass:[BLProcessLogItem class]]) {
		[outlineView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	}
}

#pragma mark - Delegates

- (void)copySelectionInOutlineView:(NSOutlineView *)view toPasteboard:(NSPasteboard *)pasteboard {
	NSIndexSet *rows;
	NSString *text;

	// Get the messages
	rows = [outlineView selectedRowIndexes];
	text = @"";

	// No copy when no items
	if (![rows count]) {
		NSBeep();
		return;
	}

	// Generate copied text
	for (NSUInteger index = [rows firstIndex]; index != NSNotFound; index = [rows indexGreaterThanIndex:index])
		text = [text stringByAppendingFormat:@"%@\n", [self copiedTextFromItem:[outlineView itemAtRow:index]]];

	// Add to pasteboard
	[pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
	[pasteboard setString:text forType:NSStringPboardType];
}

- (NSString *)copiedTextFromItem:(BLProcessLogItem *)item {
	NSString *text;

	text = [item message];
	if ([item isGroup]) {
		for (NSUInteger i = 0; i < [[item items] count]; i++)
			text = [text stringByAppendingFormat:@"\n%@", [self copiedTextFromItem:[[item items] objectAtIndex:i]]];
	}

	return text;
}

#pragma mark - DataSource

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
	if (!item)
		return [[[BLProcessLog sharedLog] items] objectAtIndex:index];
	else
		return [[item items] objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
	return [item isGroup];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	if (item == nil)
		return [[[BLProcessLog sharedLog] items] count];
	else
		return [[item items] count];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	NSString *key = [tableColumn identifier];
	id value = [item valueForKey:key];

	if ([key isEqual:@"level"])
		value = [[NSValueTransformer valueTransformerForName:LILogLevelValueTransformerName] transformedValue:value];

	return value;
}

- (CGFloat)outlineView:(NSOutlineView *)aOutlineView heightOfRowByItem:(id)item {
	NSTableColumn *tableColumn;
	NSInteger column;
	NSCell *dataCell;
	NSArray *columns;
	float height;
	NSRect rect;
	id value;

	columns = [aOutlineView tableColumns];
	height = 0;

	for (column = 0; column < [columns count]; column++) {
		tableColumn = [columns objectAtIndex:column];
		dataCell = [tableColumn dataCellForRow:[aOutlineView rowForItem:item]];

		if (![dataCell isKindOfClass:[NSTextFieldCell class]] || ![dataCell wraps] || [tableColumn isHidden])
			continue;

		value = [self outlineView:aOutlineView objectValueForTableColumn:tableColumn byItem:item];
		[dataCell setObjectValue:value];

		rect = NSMakeRect(0, 0, [tableColumn width], 1000);
		if ([aOutlineView outlineTableColumn] == tableColumn)
			rect.size.width -= ([aOutlineView levelForItem:item] + 1) * [aOutlineView indentationPerLevel];
		height = fmaxf(height, [dataCell cellSizeForBounds:rect].height);
	}

	return height;
}

- (void)outlineViewColumnDidResize:(NSNotification *)notification {
	[outlineView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [outlineView numberOfRows])]];
}

@end
