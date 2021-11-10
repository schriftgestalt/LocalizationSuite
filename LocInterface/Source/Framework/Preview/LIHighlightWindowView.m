/*!
 @header
 LIHighlightWindowView.m
 Created by max on 01.09.09.

 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "LIHighlightWindowView.h"
#import "LIHighlightWindow.h"

@implementation LIHighlightWindowView

- (void)drawRect:(NSRect)dirtyRect {
	NSColor *clearColor, *darkColor;
	NSRect highlight;

	// Init
	highlight = [(LIHighlightWindow *)[self window] highlightRect];
	clearColor = [NSColor colorWithCalibratedWhite:0.5 alpha:0.05];
	darkColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.3];

	// No highlight
	if (NSEqualSizes(highlight.size, NSZeroSize)) {
		[clearColor set];
		[NSBezierPath fillRect:dirtyRect];
		return;
	}

	// Draw clear area
	highlight = NSInsetRect(highlight, -2, -2);
	NSBezierPath *innerPath = [NSBezierPath bezierPathWithRoundedRect:highlight xRadius:4 yRadius:4];

	[clearColor set];
	[innerPath fill];

	// Draw border line
	highlight = NSInsetRect(highlight, -1, -1);
	NSBezierPath *linePath = [NSBezierPath bezierPathWithRoundedRect:highlight xRadius:5 yRadius:5];
	[linePath setLineWidth:2];

	[darkColor set];
	[linePath stroke];

	// Draw dark area
	NSBezierPath *outerPath = [NSBezierPath bezierPathWithRect:[self bounds]];
	[outerPath appendBezierPath:[innerPath bezierPathByReversingPath]];

	[darkColor set];
	[outerPath fill];
}

@end
