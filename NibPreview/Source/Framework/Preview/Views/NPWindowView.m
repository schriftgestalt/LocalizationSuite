/*!
 @header
 NPWindowView.m
 Created by max on 29.01.10.
 
 @copyright 2008-2010 Localization Suite. All rights reserved.
 */

#import "NPWindowView.h"

/*!
 @abstract Internal methods of NPWindowView.
 */
@interface NPWindowView (NPWindowViewInternal)

/*!
 @abstract Initializes the view after setting the window and contentView.
 */
- (void)initializeView;

@end

@implementation NPWindowView

- (id)initWithWindow:(NSWindow *)window
{
	self = [super initWithFrame: NSZeroRect];
	
	if (self) {
		_origWindow = window;
		_contentView = [_origWindow contentView];
		[_origWindow setContentView: nil];
		
		_titleBarImage = [[NSImage alloc] initByReferencingFile: [[NSBundle bundleForClass: [self class]] pathForResource:@"WindowBar" ofType:@"png"]];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResize:) name:NSWindowDidResizeNotification object:_origWindow];
		
		[self initializeView];
	}
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	
}


#pragma mark - Accessors

@synthesize window=_origWindow;
@synthesize contentView=_contentView;

- (NSRect)titleBarRect
{
	NSRect rect = [self bounds];
	rect.origin.y = rect.size.height - [_titleBarImage size].height;
	rect.size.height = [_titleBarImage size].height;
	
	return rect;
}


#pragma mark - Actions

- (void)initializeView
{
	// Clean
	[[self subviews] makeObjectsPerformSelector: @selector(removeFromSuperview)];
	
	// Init
	CGFloat barHeight = [self titleBarRect].size.height;
	
	// Size
	NSRect rect = [_origWindow contentRectForFrameRect: [_origWindow frame]];
	rect.size.height += barHeight;
	[self setFrameSize: rect.size];
	
	// Title text
	rect = [self titleBarRect];
	rect.size.height = 17;
	rect.origin.y += 2;
	
	NSTextField *titleText = [[NSTextField alloc] initWithFrame: rect];
	[titleText setBordered: NO];
	[titleText setSelectable: NO];
	[titleText setDrawsBackground: NO];
	[titleText setAlignment: NSCenterTextAlignment];
	[titleText bind:@"value" toObject:_origWindow withKeyPath:@"title" options:nil];
	
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowOffset: NSMakeSize(0, -1)];
	[shadow setShadowColor: [NSColor colorWithDeviceWhite:1.0 alpha:0.8]];
	[titleText setWantsLayer: YES];
	[titleText setShadow: shadow];
	
	[self addSubview: titleText];
	
	// Add content view
	rect = [self bounds];
	rect.size.height -= barHeight;
	
	[_contentView setFrame: rect];
	[self addSubview: _contentView];
}

- (void)windowDidResize:(NSNotification *)notification
{
	[self initializeView];
}

- (void)drawRect:(NSRect)rect
{
	// Background
	[[NSColor windowBackgroundColor] set];
	[NSBezierPath fillRect: [self bounds]];
	
	// Title Bar
	NSRect target = [self titleBarRect];
	NSRect source;
	
	source.origin = NSZeroPoint;
	source.size = [_titleBarImage size];
	
	// Bar
	source.origin.x = source.size.width - 1;
	source.size.width = 1;
	[_titleBarImage drawInRect:target fromRect:source operation:NSCompositeSourceOver fraction:1.0];
	
	// Buttons
	source.size.width = source.origin.x + 1;
	source.origin.x = 0;
	target.size.width = source.size.width;
	[_titleBarImage drawInRect:target fromRect:source operation:NSCompositeSourceOver fraction:1.0];
}

@end
