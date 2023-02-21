/*!
 @header
 BLProcessLog.m
 Created by Max Seelemann on 15.05.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLProcessLog.h"

/*!
 @abstract Internal methods of BLProcessLog.
 */
@interface BLProcessLog (BLProcessLogInternal)

/*!
 @abstract Returns the group items are currently being written to.
 */
- (BLProcessLogItem *)currentGroup;

/*!
 @abstract Puts a new group on top of the thread's stack.
 @discussion Also adds the group to the current group.
 */
- (void)pushGroup:(BLProcessLogItem *)group;

/*!
 @abstract Pops the last group from the top of the thread's stack.
 */
- (void)popGroup;

@end

/*!
 @abstract Internal methods of BLLogItem.
 */
@interface BLProcessLogItem (BLProcessLogItemInternal)

/*!
 @abstract Set a new level for the item.
 */
- (void)setLevel:(BLProcessLogLevel)newLevel;

/*!
 @abstract Set a new message of the item.
 */
- (void)setMessage:(NSString *)newMessage;

/*!
 @abstract Replaces the items of the item.
 */
- (void)setItems:(NSArray *)newItems;

/*!
 @abstract Adds an item to a group.
 @discussion Will turn any item into a group no matter if it is one or not.
 */
- (void)addItem:(BLProcessLogItem *)newItem;

/*!
 @abstract Reads the data as logged status and tries to convert it to something usefull.
 */
- (void)parseData:(NSData *)data;

/*!
 @abstract Reads the complete data as if it was a propertiy list.
 */
- (BOOL)parsePlist:(NSData *)data;

/*!
 @abstract Parses a IBTool property list error output into a log item tree.
 */
- (void)parseIBToolError:(NSDictionary *)error;

/*!
 @abstract Reads the complete message as string.
 */
- (void)parseMessage:(NSString *)message;

@end

@interface BLPipeLogItem : BLProcessLogItem {
	NSPipe *_pipe;
}

- (NSPipe *)pipe;

@end

#pragma mark -

@implementation BLProcessLog

BLProcessLog *__sharedProcessLog;

- (id)init {
	if (__sharedProcessLog) {
		return __sharedProcessLog;
	}

	self = [super init];

	if (self) {
		_itemRoot = [[BLProcessLogItem alloc] init];
		[_itemRoot addObserver:self forKeyPath:@"items" options:NSKeyValueObservingOptionPrior context:NULL];

		_rootGroup = nil;
		_threads = [NSMapTable strongToStrongObjectsMapTable];

		__sharedProcessLog = self;
	}

	return self;
}

- (void)dealloc {
	[_itemRoot removeObserver:self forKeyPath:@"items"];
}

+ (id)sharedLog {
	if (!__sharedProcessLog)
		__sharedProcessLog = [[BLProcessLog alloc] init];
	return __sharedProcessLog;
}

#pragma mark - Accessors

- (NSArray *)items {
	return [_itemRoot items];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue])
		[self willChangeValueForKey:@"items"];
	else
		[self didChangeValueForKey:@"items"];
}

#pragma mark - Actions

- (void)clear {
	@synchronized(_rootGroup) {
		@synchronized(_threads) {
			_rootGroup = nil;
			[_threads removeAllObjects];
			[_itemRoot setItems:nil];
		}
	}
}

- (void)openRootGroup:(NSString *)name {
	@synchronized(_rootGroup) {
		if (_rootGroup)
			[[NSException exceptionWithName:NSInternalInconsistencyException reason:@"A root group has been opened before!" userInfo:nil] raise];

		_rootGroup = [[BLProcessLogItem alloc] init];
		[_rootGroup setMessage:name];
		[_itemRoot addItem:_rootGroup];
	}
}

- (void)closeRootGroup {
	@synchronized(_rootGroup) {
		if (!_rootGroup)
			[[NSException exceptionWithName:NSInternalInconsistencyException reason:@"No open root group!" userInfo:nil] raise];
		_rootGroup = nil;
	}
}

#pragma mark - Groups

- (BLProcessLogItem *)currentGroup {
	BLProcessLogItem *group;

	if ((group = [[_threads objectForKey:[NSThread currentThread]] lastObject]))
		return group;
	if (_rootGroup)
		return _rootGroup;

	return _itemRoot;
}

- (void)pushGroup:(BLProcessLogItem *)group {
	@synchronized(_threads) {
		NSArray *groups;

		// Add item to supergroup
		[[self currentGroup] addItem:group];

		// Make new group stack
		groups = [_threads objectForKey:[NSThread currentThread]];
		if (!groups)
			groups = [NSArray arrayWithObject:group];
		else
			groups = [groups arrayByAddingObject:group];

		// Updte stack
		[_threads setObject:groups forKey:[NSThread currentThread]];
	}
}

- (void)popGroup {
	@synchronized(_threads) {
		NSArray *groups;

		// Remove group from stack
		groups = [_threads objectForKey:[NSThread currentThread]];
		if ([groups count] == 0)
			[[NSException exceptionWithName:NSInternalInconsistencyException reason:@"No open group" userInfo:nil] raise];

		groups = [groups subarrayWithRange:NSMakeRange(0, [groups count] - 1)];
		[_threads setObject:groups forKey:[NSThread currentThread]];
	}
}

@end

#pragma mark -

@implementation BLProcessLogItem

- (id)init {
	self = [super init];

	if (self) {
		_date = [[NSDate alloc] init];
		_items = nil;
		_level = BLLogInfo;
		_message = nil;
	}

	return self;
}

- (void)dealloc {
	[self setItems:nil];
}

#pragma mark - Accessors

- (NSDate *)date {
	return _date;
}

- (BLProcessLogLevel)level {
	BLProcessLogLevel maximum;

	if (![self isGroup])
		return _level;

	maximum = BLLogInfo;
	for (NSUInteger i = 0; i < [_items count]; i++) {
		BLProcessLogLevel itemLevel = [(BLProcessLogItem *)[_items objectAtIndex:i] level];
		if (itemLevel > maximum)
			maximum = itemLevel;
	}

	return maximum;
}

- (void)setLevel:(BLProcessLogLevel)newLevel {
	_level = newLevel;
}

+ (NSSet *)keyPathsForValuesAffectingLevel {
	return [NSSet setWithObject:@"items"];
}

- (NSString *)message {
	return _message;
}

- (void)setMessage:(NSString *)newMessage {
	_message = newMessage;
}

- (BOOL)isGroup {
	return (_items != nil);
}

+ (NSSet *)keyPathsForValuesAffectingIsGroup {
	return [NSSet setWithObject:@"items"];
}

- (NSArray *)items {
	@synchronized(_items) {
		return [NSArray arrayWithArray:_items];
	}
}

- (void)setItems:(NSArray *)newItems {
	@synchronized(_items) {
		[_items removeObserver:self fromObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [_items count])] forKeyPath:@"level"];

		_items = newItems;

		[_items addObserver:self toObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [_items count])] forKeyPath:@"level" options:NSKeyValueObservingOptionPrior context:NULL];
	}
}

- (void)addItem:(BLProcessLogItem *)newItem {
	@synchronized(self) {
		[self willChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:[_items count]] forKey:@"items"];

		if (!_items) {
			_items = [NSArray arrayWithObject:newItem];
		}
		else {
			_items = [_items arrayByAddingObject:newItem];
		}

		[newItem addObserver:self forKeyPath:@"level" options:NSKeyValueObservingOptionPrior context:NULL];
		[self didChange:NSKeyValueChangeInsertion valuesAtIndexes:[NSIndexSet indexSetWithIndex:[_items count] - 1] forKey:@"items"];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue])
		[self willChangeValueForKey:@"level"];
	else
		[self didChangeValueForKey:@"level"];
}

#pragma mark - Data import

- (void)parseData:(NSData *)data {
	NSString *message;
	BOOL success;

	message = [NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding];
	success = NO;

	// Special import for xml data
	if ([message hasPrefix:@"<?xml"])
		success = [self parsePlist:data];

	// Regular text import
	if (!success) {
		NSArray *lines = [message componentsSeparatedByString:@"\n"];
		for (NSString *line in lines) {
			BLProcessLogItem *item = [[BLProcessLogItem alloc] init];
			[item parseMessage:line];
			[self addItem:item];
		}
	}
}

- (BOOL)parsePlist:(NSData *)data {
	BLProcessLogItem *item;
	id plist;

	// Convert
	plist = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:NULL];
	if (!plist)
		return NO;

	// Search for array of errors and warnings
	if ([plist isKindOfClass:[NSDictionary class]]) {
		NSArray *objects;

		objects = [plist objectForKey:@"com.apple.ibtool.warnings"];
		for (NSUInteger i = 0; i < [objects count]; i++) {
			item = [[BLProcessLogItem alloc] init];
			[item setLevel:BLLogWarning];
			[item parseIBToolError:[objects objectAtIndex:i]];
			[self addItem:item];
		}
		objects = [plist objectForKey:@"com.apple.ibtool.errors"];
		for (NSUInteger i = 0; i < [objects count]; i++) {
			item = [[BLProcessLogItem alloc] init];
			[item setLevel:BLLogError];
			[item parseIBToolError:[objects objectAtIndex:i]];
			[self addItem:item];
		}
	}
	// Just use the items
	else {
		for (NSUInteger i = 0; i < [plist count]; i++) {
			item = [[BLProcessLogItem alloc] init];
			[item parseMessage:[[plist objectAtIndex:i] description]];
			[self addItem:item];
		}
	}

	return YES;
}

- (void)parseIBToolError:(NSDictionary *)error {
	[self setMessage:[error objectForKey:@"description"]];

	// Recovery?
	if ([error objectForKey:@"recovery-suggestion"]) {
		BLProcessLogItem *child = [[BLProcessLogItem alloc] init];
		[child setMessage:[error objectForKey:@"recovery-suggestion"]];
		[child setLevel:[self level]];
		[self addItem:child];
	}

	// Underlying errors?
	for (NSDictionary *underlying in [error objectForKey:@"underlying-errors"]) {
		BLProcessLogItem *child = [[BLProcessLogItem alloc] init];
		[child setLevel:[self level]];
		[child parseIBToolError:underlying];
		[self addItem:child];
	}
}

- (void)parseMessage:(NSString *)message {
	// Keep the old message
	if (![message length])
		return;

	[self setMessage:message];

	// Calculate level
	message = [message lowercaseString];
	if ([message rangeOfString:@"error"].length > 0)
		[self setLevel:BLLogError];
	else if ([message rangeOfString:@"warning"].length > 0)
		[self setLevel:BLLogWarning];
	else
		[self setLevel:BLLogInfo];
}

@end

#pragma mark -

@implementation BLPipeLogItem

- (id)init {
	self = [super init];

	if (self) {
		_pipe = [[NSPipe alloc] init];
		[NSThread detachNewThreadSelector:@selector(read) toTarget:self withObject:nil];
	}

	return self;
}

- (NSPipe *)pipe {
	return _pipe;
}

#pragma mark - Pipe support

- (void)read {
	@autoreleasepool {
		// Read
		NSData *data = [[_pipe fileHandleForReading] readDataToEndOfFile];

		// Message
		if (data && [data length])
			[self parseData:data];

		// Finish
		_pipe = nil;
		[NSThread exit];
	}
}

@end

#pragma mark - Functions

void BLLog(BLProcessLogLevel level, NSString *format, ...) {
	BLProcessLogItem *item;
	NSString *string;
	va_list args;

	va_start(args, format);
	string = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);

	NSLog(@"%@", string);

	item = [[BLProcessLogItem alloc] init];
	[item setLevel:level];
	[item setMessage:string];

	[[[BLProcessLog sharedLog] currentGroup] addItem:item];
}

NSPipe *BLLogOpenPipe(NSString *format, ...) {
	BLPipeLogItem *item;
	NSString *string;
	va_list args;
	NSPipe *pipe;

	va_start(args, format);
	string = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);

	item = [[BLPipeLogItem alloc] init];
	[item setMessage:string];

	[[[BLProcessLog sharedLog] currentGroup] addItem:item];

	pipe = [item pipe];

	return pipe;
}

void BLLogData(NSData *data, NSString *format, ...) {
	BLProcessLogItem *item;
	NSString *string;
	va_list args;

	va_start(args, format);
	string = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);

	item = [[BLProcessLogItem alloc] init];
	[item setMessage:string];
	[item parseData:data];

	[[[BLProcessLog sharedLog] currentGroup] addItem:item];
}

void BLLogBeginGroup(NSString *format, ...) {
	BLProcessLogItem *group;
	NSString *string;
	va_list args;

	va_start(args, format);
	string = [[NSString alloc] initWithFormat:format arguments:args];
	va_end(args);

	NSLog(@"%@", string);

	group = [[BLProcessLogItem alloc] init];
	[group setMessage:string];

	[[BLProcessLog sharedLog] pushGroup:group];
}

void BLLogEndGroup() {
	[[BLProcessLog sharedLog] popGroup];
}
