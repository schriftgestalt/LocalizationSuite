//
//  GSSplitViewWindowController.m
//  GlyphsKit
//
//  Created by Georg Seifert on 01.01.22.
//

#import "GSSplitViewWindowController.h"

@interface GSSplitViewItem : NSSplitViewItem
@property  IBOutlet NSViewController *viewController;
@end

@implementation GSSplitViewItem
@dynamic viewController;
@end

@implementation GSSplitViewWindowController {
	GSSplitViewItem *_sidebarItem;
	GSSplitViewItem *_contentItem;
	NSViewController *_sidebarController;
	NSViewController *_contentController;
}

- (instancetype)init {
	self = [self initWithWindowNibName:self.className];
	return self;
}

- (instancetype)initWithWindowNibName:(NSNibName)windowNibName owner:(nonnull id)owner {
	self = [super init];
	NSNib *nib = [[NSNib alloc] initWithNibNamed:windowNibName bundle:[NSBundle bundleForClass:self.class]];
	NSMutableArray *topLevelObjects = [NSMutableArray new];
	[nib instantiateWithOwner:owner topLevelObjects:&topLevelObjects];
	for (NSView *object in topLevelObjects) {
		if ([object isKindOfClass:[NSView class]]) {
			if ([object.identifier isEqualToString:@"SidebarView"]) {
				_sidebarView = object;
			}
			else if ([object.identifier isEqualToString:@"MainView"]) {
				_contentView = object;
			}
		}
		if ([object isKindOfClass:[NSWindow class]]) {
			self.window = (NSWindow *)object;
		}
	}
	if (_sidebarView && _contentView) {
		_sidebarController = [NSViewController new];
		_contentController = [NSViewController new];
		_sidebarController.view = _sidebarView;
		_contentController.view = _contentView;
		_sidebarItem = [GSSplitViewItem new];
		_contentItem = [GSSplitViewItem new];
		_sidebarItem.viewController = _sidebarController;
		_contentItem.viewController = _contentController;
		_splitViewController = [NSSplitViewController new];
		[_sidebarItem setValue:@(NSSplitViewItemBehaviorSidebar) forKey:@"behavior"];
		[_splitViewController setValue:@[_sidebarItem, _contentItem] forKey:@"splitViewItems"];
		[self.window setContentViewController:_splitViewController];
	}

	[owner windowControllerDidLoadNib:self];
	return self;
}

- (void)windowDidLoad {
	[super windowDidLoad];
}

@end
