/*!
 @header
 LIPreviewContentView.m
 Created by max on 05.04.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "LIPreviewContentView.h"


#define LIPreviewContentViewInset	20.0

@implementation LIPreviewContentView

@synthesize statusText=_statusText;

- (id)initWithFrame:(NSRect)frameRect
{
	self = [super initWithFrame: frameRect];
	
	if (self != nil) {
		NSShadow *shadow;
		
		shadow = [NSShadow new];
		shadow.shadowBlurRadius = 20;
		shadow.shadowOffset = NSMakeSize(0, -5);
		
		self.shadow = shadow;
		
		_statusText = nil;
	}
	return self;
}


#pragma mark - Accessors

- (BOOL)isFlipped
{
	return YES;
}

- (void)addSubview:(NSView *)aView
{
	[super addSubview: aView];
	[self resizeSubviewsWithOldSize: self.frame.size];
}

- (void)setStatusText:(NSString *)text
{
	_statusText = text;
	
	[self setNeedsDisplay: YES];
}


#pragma mark - Actions

- (void)resizeSubviewsWithOldSize:(NSSize)oldSize
{
	NSRect subviewFrame;
	NSView *subview;
	NSSize size;
	
	// Nothing to lay out?
	if (!self.subviews.count) {
		[self setNeedsDisplay: YES];
		return;
	}
	
	// Calculate the right size
	subview = [self.subviews objectAtIndex: 0];
	subviewFrame = subview.frame;
	size = self.superview.frame.size;
	
	size.width = fmaxf(size.width, subviewFrame.size.width + 2 * LIPreviewContentViewInset);
	size.height = fmaxf(size.height, subviewFrame.size.height + 2 * LIPreviewContentViewInset);
	
	if (!NSEqualSizes(size, self.frame.size))
		[self setFrameSize: size];
	
	// Center the content view
	subviewFrame.origin.x = floorf((size.width - subviewFrame.size.width) / 2);
	subviewFrame.origin.y = floorf((size.height - subviewFrame.size.height) / 2);
	[subview setFrameOrigin: subviewFrame.origin];
	
	[self setNeedsDisplay: YES];
}

- (void)drawRect:(NSRect)rect
{
	NSRect viewRect;
	
	if (self.subviews.count) {
		// Draw the bevel
		viewRect = [[self.subviews objectAtIndex: 0] frame];

		[self.shadow set];
		[[NSColor windowBackgroundColor] set];
		[NSBezierPath fillRect: viewRect];
	}
	else if (_statusText) {
		// Draw the status text
		NSDictionary *attributes;
		NSRect rect;
		
		attributes = [NSDictionary dictionaryWithObjectsAndKeys: [NSFont systemFontOfSize: 15], NSFontAttributeName, [NSColor colorWithCalibratedWhite:0.3 alpha:1], NSForegroundColorAttributeName, nil];
		rect.size = [_statusText sizeWithAttributes: attributes];
		
		rect.origin.x = floorf((self.bounds.size.width - rect.size.width) / 2);
		rect.origin.y = floorf((self.bounds.size.height - rect.size.height) / 2);
		
		[_statusText drawAtPoint:rect.origin withAttributes:attributes];
	}
}


@end
