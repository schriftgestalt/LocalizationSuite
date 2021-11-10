/*!
 @header
 LIPreviewController.m
 Created by max on 05.04.09.

 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "LIPreviewController.h"

#import "LIHighlightWindow.h"
#import "LIPreviewContent.h"
#import "LIPreviewContentView.h"

NSString *LIPreviewWindowNibName = @"LIPreviewWindow";

NSString *LIPreviewLanguageToolbarItem = @"language";
NSString *LIPreviewRootViewToolbarItem = @"rootView";

@interface LIPreviewController (LIPreviewControllerInternal)

/*!
 @abstract Updates the preview.
 @discussion This should be called if any relevant value changes, namely the fileObject or the language.
 */
- (void)updatePreview;

/*!
 @abstract Loads the actual preview content.
 @discussion This method is always called in a separate thread.
 */
- (void)loadPreviewContent;

/*!
 @abstract Updates the highlighted rect in the highlight window.
 */
- (void)updateHighlight;

/*!
 @abstract Notify that the content has changed.
 */
- (void)setPreviewContent:(LIPreviewContent *)object;

/*!
 @abstract Sets the preview view or clears display
 */
- (void)updateContentView;

/*!
 @abstract Initializes the toolbar by first creating all items and then adding the default layout.
 @discussion Default layout means a language selector on the right side.
 */
- (void)initToolbar;

/*!
 @abstract Creates the toolbar items.
 @discussion This method must be called before loading the window.
 */
- (void)createToolbarItems;

/*!
 @abstract Creates the highlight window for the preview.
 */
- (void)createHighlightWindow;

/*!
 @abstract If a bound object exists, this method updates the value that was bound.
 */
- (void)updateBinding:(NSString *)binding;

@end

@implementation LIPreviewController

- (id)init {
	self = [super initWithWindowNibPath:[self windowNibPath] owner:self];

	if (self != nil) {
		_content = nil;
		_contentCache = [NSMapTable mapTableWithStrongToStrongObjects];
		_currentLanguage = nil;
		_file = nil;
		_key = nil;
		_languages = nil;
		_toolbarItems = nil;
		_visible = YES;
	}

	return self;
}

#pragma mark - WindowController Accessors

- (NSString *)windowNibPath {
	return [[NSBundle bundleForClass:[LIPreviewController class]] pathForResource:LIPreviewWindowNibName ofType:@"nib"];
}

#pragma mark - Accessors

- (BOOL)windowIsVisible {
	return [self.window isVisible];
}

- (void)setWindowIsVisible:(BOOL)visible {
	_visible = visible;

	if (visible && ![self.window isVisible])
		[self.window orderWindow:NSWindowBelow relativeTo:[[NSApp keyWindow] windowNumber]];
	if (!visible && [self.window isVisible])
		[self.window orderOut:self];
}

@synthesize currentLanguage = _currentLanguage;

- (void)setCurrentLanguage:(NSString *)aLanguage {
	if (![aLanguage isEqual:_currentLanguage]) {
		_currentLanguage = aLanguage;

		[self updatePreview];
	}
}

@synthesize languages = _languages;

- (void)setLanguages:(NSArray *)someLanguages {
	_languages = someLanguages;

	if ((!_currentLanguage || ![_languages containsObject:_currentLanguage]) && [_languages count])
		self.currentLanguage = [_languages objectAtIndex:0];
}

@synthesize fileObject = _file;

- (void)setFileObject:(BLFileObject *)object {
	if (_file == object)
		return;

	// Switch the file object
	_file = object;

	[self updateBinding:@"fileObject"];

	// Unselect any key object
	if (_key) {
		[self willChangeValueForKey:@"keyObject"];
		_key = nil;
		[self didChangeValueForKey:@"keyObject"];

		[self updateBinding:@"keyObject"];
	}

	// Update the preview
	[self updatePreview];
}

@synthesize keyObject = _key;

- (void)setKeyObject:(BLKeyObject *)object {
	BOOL fileChanged = NO;

	if (_key == object)
		return;

	// Change the file object if needed
	BLFileObject *newFile = [object fileObject];
	if (newFile != _file) {
		fileChanged = YES;

		[self willChangeValueForKey:@"fileObject"];
		_file = newFile;
		[self didChangeValueForKey:@"fileObject"];

		[self updateBinding:@"fileObject"];
	}

	// Switch the key object
	_key = object;

	[self updateBinding:@"keyObject"];

	// Update the preview as needed
	if (fileChanged)
		[self updatePreview];
	else
		[self updateContentView];
}

- (void)setDocument:(NSDocument *)document {
	[super setDocument:document];
	[self updatePreview];
}

- (NSObject<LIPreviewRootItem> *)currentRootItem {
	return _content.rootItem;
}

- (void)setCurrentRootItem:(NSObject<LIPreviewRootItem> *)item {
	[_content changeRootItem:item];
}

- (NSArray *)availableRootItems {
	return _content.availableRootItems;
}

#pragma mark - Actions

- (void)windowDidLoad {
	[self createHighlightWindow];

	[self createToolbarItems];
	[self initToolbar];

	[self updatePreview];

	[super windowDidLoad];
}

- (void)showWindow:(id)sender {
	if (_visible)
		[super showWindow:sender];
}

- (void)createHighlightWindow {
	_highlightWindow = [[LIHighlightWindow alloc] initWithParent:[self window]];
	[_highlightWindow setDelegate:self];
}

- (BOOL)highlightWindow:(LIHighlightWindow *)window receivedEvent:(NSEvent *)theEvent {
	if ([theEvent type] == NSScrollWheel && !_updateTimer)
		_updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(updateHightlightTimed:) userInfo:nil repeats:NO];

	if ([theEvent type] != NSLeftMouseDown)
		return YES;

	NSPoint point = [theEvent locationInWindow];
	point = [_content.rootView convertPoint:point fromView:nil];

	BLKeyObject *object = [_content keyObjectAtPoint:point];

	if ([self keyObject] != object) {
		[self setKeyObject:object];
		return NO;
	}
	else {
		// Selection was not changed - perform event
		return YES;
	}
}

- (void)updateBinding:(NSString *)binding {
	NSDictionary *info;

	info = [self infoForBinding:binding];
	if (!info)
		return;

	[[info objectForKey:NSObservedObjectKey] setValue:[self valueForKey:binding] forKeyPath:[info objectForKey:NSObservedKeyPathKey]];
}

#pragma mark - Content

- (void)updatePreview {
	// Load content if not yet cached
	if (self.fileObject && self.document) {
		LIPreviewContent *newContent;

		newContent = [_contentCache objectForKey:self.fileObject];

		// Content was never requested
		if (!newContent) {
			[_contentCache setObject:[NSNull null] forKey:self.fileObject];
			[NSThread detachNewThreadSelector:@selector(loadPreviewContent) toTarget:self withObject:nil];
		}
		// Content is still loading
		if (newContent && [newContent isKindOfClass:[NSNull class]])
			newContent = nil;

		// Notify if needed
		[self setPreviewContent:newContent];
	}

	// Display a Loading status when no content exists yet
	if (!_content)
		[contentView setStatusText:NSLocalizedStringFromTableInBundle(@"Loading", LIPreviewWindowNibName, [NSBundle bundleForClass:[self class]], nil)];

	// Update the language if necessary
	if (_content && ![self.currentLanguage isEqual:_content.language])
		_content.language = self.currentLanguage;

	// Update the display
	[self updateContentView];
}

- (void)loadPreviewContent {
	@autoreleasepool {
		LIPreviewContent *newContent;
		NSString *status;

		// Try to load content
		newContent = [LIPreviewContent contentWithFileObject:self.fileObject inDocument:self.document];

		if (newContent) {
			newContent.language = self.currentLanguage;
			[newContent addObserver:self forKeyPath:@"rootView" options:0 context:NULL];
			[newContent addObserver:self forKeyPath:@"rootItem" options:NSKeyValueObservingOptionPrior context:NULL];
			[_contentCache setObject:newContent forKey:self.fileObject];

			[self performSelectorOnMainThread:@selector(setPreviewContent:) withObject:newContent waitUntilDone:YES];

			// Delete status message
			status = nil;
		}
		else {
			// Content cannot be loaded
			status = NSLocalizedStringFromTableInBundle(@"NoPreview", LIPreviewWindowNibName, [NSBundle bundleForClass:[self class]], nil);
		}

		// Update interface
		[self performSelectorOnMainThread:@selector(updateContentView) withObject:nil waitUntilDone:YES];
		[contentView performSelectorOnMainThread:@selector(setStatusText:) withObject:status waitUntilDone:YES];
	}
}

- (void)setPreviewContent:(LIPreviewContent *)object {
	if (object == _content)
		return;

	[self willChangeValueForKey:@"availableRootItems"];
	[self willChangeValueForKey:@"currentRootItem"];

	_content = object;

	[self didChangeValueForKey:@"availableRootItems"];
	[self didChangeValueForKey:@"currentRootItem"];
}

- (void)updateContentView {
	if (_content && _content.rootView) {
		// Set the focussed element
		if (_content.focussedKeyObject != _key)
			_content.focussedKeyObject = _key;

		// Put the view up font
		if (_content.rootView.superview != contentView)
			[contentView setSubviews:[NSArray arrayWithObject:_content.rootView]];
	}
	else {
		// Display nothing
		[contentView setSubviews:[NSArray array]];
	}

	// Update highlight
	[self updateHighlight];
}

- (void)updateHighlight {
	if (_content && _content.rootView) {
		NSRect highlight = [_content rectOfFocussedKeyObject];
		highlight = [_content.rootView convertRect:highlight toView:nil];
		[_highlightWindow setHighlightRect:highlight];
	}
	else {
		[_highlightWindow setHighlightRect:NSZeroRect];
	}
}

- (void)updateHightlightTimed:(NSTimer *)timer {
	_updateTimer = nil;
	[self updateHighlight];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqual:@"rootView"] && object == _content) {
		[self updateContentView];
	}
	if ([keyPath isEqual:@"rootItem"] && object == _content) {
		if ([[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue])
			[self willChangeValueForKey:@"currentRootItem"];
		else
			[self didChangeValueForKey:@"currentRootItem"];
	}
}

#pragma mark - Toolbar

- (void)createToolbarItems {
	NSMutableDictionary *dict;
	NSToolbarItem *item;

	dict = [NSMutableDictionary dictionary];

	// Build the language selector
	item = [[NSToolbarItem alloc] initWithItemIdentifier:LIPreviewLanguageToolbarItem];
	[item setView:languageView];
	[dict setObject:item forKey:LIPreviewLanguageToolbarItem];

	// Build the object selector
	item = [[NSToolbarItem alloc] initWithItemIdentifier:LIPreviewRootViewToolbarItem];
	[item setView:objectView];
	[dict setObject:item forKey:LIPreviewRootViewToolbarItem];

	_toolbarItems = dict;
}

- (void)initToolbar {
	NSToolbar *toolbar;
	NSUInteger index;

	// Get the toolbar
	toolbar = [[NSToolbar alloc] initWithIdentifier:[NSString stringWithFormat:@"%p", self]];
	toolbar.sizeMode = NSToolbarSizeModeSmall;
	toolbar.displayMode = NSToolbarDisplayModeIconOnly;
	toolbar.showsBaselineSeparator = YES;
	toolbar.delegate = self;

	self.window.toolbar = toolbar;
	self.window.showsToolbarButton = NO;

	// Clear it
	while (toolbar.items.count)
		[toolbar removeItemAtIndex:0];

	// Set default state
	index = 0;
	for (NSString *identifier in [self toolbarDefaultItemIdentifiers:toolbar])
		[toolbar insertItemWithItemIdentifier:identifier atIndex:index++];
}

#pragma mark -

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
	return [_toolbarItems objectForKey:itemIdentifier];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar {
	return [NSArray arrayWithObjects:LIPreviewRootViewToolbarItem, NSToolbarFlexibleSpaceItemIdentifier, LIPreviewLanguageToolbarItem, nil];
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar {
	return [NSArray arrayWithObjects:NSToolbarSeparatorItemIdentifier, NSToolbarSpaceItemIdentifier, NSToolbarFlexibleSpaceItemIdentifier, LIPreviewRootViewToolbarItem, LIPreviewLanguageToolbarItem, nil];
}

@end
