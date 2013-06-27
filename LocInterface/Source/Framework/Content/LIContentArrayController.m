/*!
 @header
 LIContentArrayController.m
 Created by max on 26.08.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "LIContentArrayController.h"

#import "LIAttachmentCell.h"


/*!
 @abstract Internal methods of LIContentArrayController.
 */
@interface LIContentArrayController (LIContentArrayControllerInternal) <NSTableViewDataSource>

/*!
 @abstract Retrieves the row height cache for the given table view.
 @discussion A new cache will be created if no such one exists. This method also registers as observer to the width of all table columns.
 */
- (NSMapTable *)rowHeightsForTableView:(NSTableView *)tableView;

/*!
 @abstract Invalidates the row height cache for the table view.
 */
- (void)clearRowHeightCacheForTableView:(NSTableView *)tableView;

/*!
 @abstract Caluclated the height of a row in a table view according to it's content and column width.
 */
- (CGFloat)calculateHeightOfRow:(NSInteger)row inTableView:(NSTableView *)tableView;

@end



@implementation LIContentArrayController

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder: aDecoder];
	
	if (self) {
		_editAttachments = YES;
		_columnCounts = [NSMapTable mapTableWithWeakToStrongObjects];
		_rowCache = [NSMapTable mapTableWithWeakToStrongObjects];
	}
	
	return self;
}



#pragma mark - Accessors

@synthesize searchPattern=_search;

- (void)setSearchPattern:(NSString *)search
{
	_search = [search copy];
	
	[self rearrangeObjects];
}

@synthesize searchableKeyPaths=_searchPaths;

- (void)setSearchableKeyPaths:(NSArray *)keys
{
	_searchPaths = keys;
	
	[self rearrangeObjects];
}

@synthesize maximumArrangedObjects=_maxCount;

- (void)setMaximumArrangedObjects:(NSUInteger)newCount
{
	_maxCount = newCount;
	[self rearrangeObjects];
}

@synthesize canEditAttachments=_editAttachments;

- (void)setCanEditAttachments:(BOOL)flag
{
	_editAttachments = flag;
	[self rearrangeObjects];
}


#pragma mark - Actions

- (void)setContent:(id)content
{
	for (NSTableView *tableView in [_rowCache keyEnumerator])
		[self clearRowHeightCacheForTableView: tableView];
	
	[super setContent: content];
}

- (void)rearrangeObjects
{
	[super rearrangeObjects];
	
	for (NSTableView *tableView in [_rowCache keyEnumerator])
		[self invalidateRowHeightsForTableView: tableView];
}

- (NSArray *)arrangeObjects:(NSArray *)srcObjects
{
	NSPredicate *filter = [self filterPredicate];
	
	// Perform search and preflight filtering
	if (([_search length] && [_searchPaths count] > 0) || filter) {
		NSMutableArray *objects = [NSMutableArray arrayWithCapacity: [srcObjects count]];
		
		for (NSObject *object in srcObjects) {
			// Filter predicate
			if (filter && ![filter evaluateWithObject: object])
				continue;
			
			// Searching
			if (_search) {
				BOOL success = NO;
				
				for (NSString *keyPath in _searchPaths) {
					id value;
					
					// Extract the value and check for consistency
					value = [object valueForKeyPath: keyPath];
					if ([value isKindOfClass: [NSAttributedString class]])
						value = [value string];
					if (![value isKindOfClass: [NSString class]])
						continue;
					
					// Search
					success = ([value rangeOfString:_search options:NSCaseInsensitiveSearch|NSLiteralSearch].length != 0);
					if (success)
						break;
				}
				
				if (!success)
					continue;
			}
			
			// Match found
			[objects addObject: object];
		}
		
		srcObjects = objects;
	}
	
	// Perform truncating
	if (_maxCount > 0 && [srcObjects count] > _maxCount) {
		srcObjects = [srcObjects subarrayWithRange: NSMakeRange(0, _maxCount)];
	}
	
	// Sorting, etc
	return [super arrangeObjects: srcObjects];
}


#pragma mark -

- (void)invalidateRowHeightsForTableView:(NSTableView *)tableView
{
	NSInteger rows;
	
	rows = [tableView numberOfRows];
	if ([[self arrangedObjects] count] < rows)
		rows = [[self arrangedObjects] count];
	
	[tableView noteHeightOfRowsWithIndexesChanged: [NSIndexSet indexSetWithIndexesInRange: NSMakeRange(0, rows)]];
}

- (void)clearRowHeightCacheForTableView:(NSTableView *)tableView
{
	[[self rowHeightsForTableView: tableView] removeAllObjects];
	[self invalidateRowHeightsForTableView: tableView];
}

- (void)invalidateHeightOfRow:(NSUInteger)row
{
	id object = [[self arrangedObjects] objectAtIndex: row];
	
	for (NSTableView *tableView in [_rowCache keyEnumerator]) {
		[[self rowHeightsForTableView: tableView] removeObjectForKey: object];
		[tableView noteHeightOfRowsWithIndexesChanged: [NSIndexSet indexSetWithIndex: row]];
	}
}

- (NSMapTable *)rowHeightsForTableView:(NSTableView *)tableView
{
	NSMapTable *cache;
	
	// Find the rigth cache
	cache = [_rowCache objectForKey: tableView];
	
	// Create cache it if needed
	if (!cache) {
		cache = [NSMapTable mapTableWithWeakToStrongObjects];
		[_rowCache setObject:cache forKey:tableView];
		
		NSInteger count = [tableView numberOfColumns];
		[_columnCounts setObject:[NSNumber numberWithInt: count] forKey:tableView];
		
		// Register observals
		[tableView addObserver:self forKeyPath:@"numberOfColumns" options:0 context:@"invalidateRows"];
		[tableView addObserver:self forKeyPath:@"frame" options:0 context:@"invalidateRows"];
		[tableView addObserver:self forKeyPath:@"sortDescriptors" options:0 context:@"updateRows"];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tableViewColumnDidResize:) name:NSTableViewColumnDidResizeNotification object:tableView];
	}
	
	return cache;
}

- (CGFloat)calculateHeightOfRow:(NSInteger)row inTableView:(NSTableView *)tableView
{
	NSTableColumn *tableColumn;
	NSInteger column;
	NSCell* dataCell;
	NSArray *columns;
	CGFloat height;
	NSRect rect;
	id value;
	
	columns = [tableView tableColumns];
	height = 0;
	
	for (column=0; column < [columns count]; column++) {
		tableColumn = [columns objectAtIndex: column];
		dataCell = [tableColumn dataCellForRow: row];
		
		if (![dataCell isKindOfClass: [NSTextFieldCell class]] || ![dataCell wraps] || [tableColumn isHidden])
			continue;
		
		value = [self tableView:tableView objectValueForTableColumn:tableColumn row:row];
		[dataCell setObjectValue:value];
		
		rect = NSMakeRect(0, 0, [tableColumn width], 1000);
		height = fmaxf(height, [dataCell cellSizeForBounds: rect].height);
	}
	
	height = fmaxf(height, [tableView rowHeight]);
	
	return height;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == @"updateRows") {
		[self invalidateRowHeightsForTableView: object];
	}
	else if (context == @"invalidateRows") {
		[self clearRowHeightCacheForTableView: object];
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}



#pragma mark - Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [[self arrangedObjects] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	return [[[self arrangedObjects] objectAtIndex: row] valueForKey: [[tableColumn sortDescriptorPrototype] key]];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSString *key = [[tableColumn sortDescriptorPrototype] key];
	
	if (key) {
		[[[self arrangedObjects] objectAtIndex: row] setValue:object forKey:key];
		[self invalidateHeightOfRow: row];
	}
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if ([cell isKindOfClass: [LIAttachmentCell class]]) {
		[cell setEditable: _editAttachments];
		[cell setFileWrapper: [[[self arrangedObjects] objectAtIndex: row] attachedMedia]];
		[cell setRepresentedObject: [NSNumber numberWithInt: row]];
		
		[cell setTarget: self];
		[cell setAction: @selector(deleteAttachedMedia:)];
	}
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
	if (!_editAttachments || row >= [tableView numberOfRows])
		return NSDragOperationNone;
	
	[tableView setDropRow:row dropOperation:NSTableViewDropOn];
	return NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation
{
	NSPasteboard *pboard = [info draggingPasteboard];
	NSFileWrapper *wrapper = nil;
	
	if ([pboard propertyListForType: NSFilenamesPboardType]) {
		NSString *filename = [[pboard propertyListForType: NSFilenamesPboardType] lastObject];
		wrapper = [[NSFileWrapper alloc] initWithPath: filename];
	}
	if ([pboard dataForType: LIAttachmentPasteboardType]) {
		wrapper = (__bridge_transfer NSFileWrapper *)(void *)[[pboard propertyListForType: LIAttachmentPasteboardType] integerValue];
	}
	
	if (wrapper) {
		[[[self arrangedObjects] objectAtIndex: row] setAttachedMedia: wrapper];
		return YES;
	}
	
	return NO;
}


#pragma mark - Delegates

- (void)tableViewColumnDidResize:(NSNotification *)notification
{
	if ([[[NSRunLoop currentRunLoop] currentMode] isEqual: NSDefaultRunLoopMode])
		[self clearRowHeightCacheForTableView: [notification object]];
	else
		[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostWhenIdle coalesceMask:NSNotificationCoalescingOnSender forModes:nil];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
	// Secure against TableView frault
	if (row >= [[self arrangedObjects] count])
		return [tableView rowHeight];
	
	id object = [[self arrangedObjects] objectAtIndex: row];
	
	// Get caches
	NSMapTable *rowHeights = [self rowHeightsForTableView: tableView];
	NSInteger columnCount = [[_columnCounts objectForKey: tableView] integerValue];
	
	// Reset cache
	if (columnCount != [tableView numberOfColumns]) {
		columnCount = [tableView numberOfColumns];
		[_columnCounts setObject:[NSNumber numberWithInt: columnCount] forKey:tableView];
		
		[rowHeights removeAllObjects];
	}
	
	// Get height
	CGFloat height;
	
	if ([rowHeights objectForKey: object]) {
		height = [[rowHeights objectForKey: object] floatValue];
	} else {
		height = [self calculateHeightOfRow:row inTableView:tableView];
		[rowHeights setObject:[NSNumber numberWithFloat:height] forKey:object];
	}
	
    return height;
}

- (void)deleteAttachedMedia:(LIAttachmentCell *)cell
{
	[[[self arrangedObjects] objectAtIndex: [[cell representedObject] integerValue]] setAttachedMedia: nil];
}

@end

