/*!
 @header
 LIHighlightWindow.m
 Created by max on 01.09.09.

 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "LIHighlightWindow.h"

#import "LIHighlightWindowView.h"

@interface LIHighlightWindow (LIHighlightWindowInternal)

/*!
 @abstract Updates the frame to match the one of the parent.
 */
- (void)updateFrame;

@end

@implementation LIHighlightWindow

- (id)initWithParent:(NSWindow *)parent {
	self = [super initWithContentRect:NSMakeRect(0, 0, 10, 10)
							styleMask:NSBorderlessWindowMask
							  backing:NSBackingStoreBuffered
								defer:NO
							   screen:[parent screen]];

	if (self) {
		_highlight = NSMakeRect(20, 20, 0, 0);

		[self setHasShadow:NO];
		[self setOpaque:NO];

		[self setBackgroundColor:[NSColor clearColor]];
		[self setContentView:[[LIHighlightWindowView alloc] initWithFrame:[self frame]]];
		[self setPreferredBackingLocation:NSWindowBackingLocationVideoMemory];

		_parent = parent;

		[self updateFrame];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFrame) name:NSWindowDidMoveNotification object:_parent];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFrame) name:NSWindowDidResizeNotification object:_parent];
		[_parent addObserver:self forKeyPath:@"visible" options:NSKeyValueObservingOptionInitial context:NULL];
	}

	return self;
}

#pragma mark - Accessors

@synthesize parentWindow = _parent;

- (NSRect)highlightRect {
	return _highlight;
}

- (void)setHighlightRect:(NSRect)rect {
	_highlight = rect;

	[self.contentView setNeedsDisplay:YES];
}

#pragma mark - Actions

- (void)updateFrame {
	NSRect frame;

	frame = [_parent contentRectForFrameRect:[_parent frame]];
	frame = [self frameRectForContentRect:frame];

	[self setFrame:frame display:YES];
}

- (void)sendEvent:(NSEvent *)theEvent {
	BOOL send = YES;

	// Ask the delegate whether to send the event
	if ([self delegate] && [[self delegate] respondsToSelector:@selector(highlightWindow:receivedEvent:)])
		send = [(id)[self delegate] highlightWindow:self receivedEvent:theEvent];

	// Forward event to parent window
	if (send)
		[_parent sendEvent:theEvent];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqual:@"visible"]) {
		if ([_parent isVisible]) {
			[_parent addChildWindow:self ordered:NSWindowAbove];
			[self orderFront:self];
		}
		else
			[self orderOut:self];
	}
}

@end
