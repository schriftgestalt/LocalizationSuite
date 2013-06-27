//
//  TitleSplitView.m
//  Localizer
//
//  Created by Max Seelemann on 07.10.07.
//  Copyright 2007 The Blue Technologies Group. All rights reserved.
//

#import "TitleSplitView.h"


@implementation TitleSplitView

- (void)awakeFromNib
{
}

- (void)drawDivider:(NSImage*)anImage inRect:(NSRect)rect betweenView:(RBSplitSubview*)leading andView:(RBSplitSubview*)trailing
{
	NSGradient *gradient;
	
	// Background
	gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.9 alpha:1]
											 endingColor:[NSColor colorWithCalibratedWhite:0.8 alpha:1]];
	[gradient drawInRect:rect angle:90];
	
	// Borders
	[[NSColor controlShadowColor] set];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(rect), NSMinY(rect) + 0.5) toPoint:NSMakePoint(NSMaxX(rect), NSMinY(rect) + 0.5)];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(rect), NSMaxY(rect) - 0.5) toPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect) - 0.5)];
	
	// Label
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys: [NSFont boldSystemFontOfSize: [NSFont smallSystemFontSize]], NSFontAttributeName, [NSColor blackColor], NSForegroundColorAttributeName, nil];
	NSRect textRect = NSInsetRect(rect, 10, 0);
	textRect.size.height = 18.f;
	textRect.origin.y = rect.origin.y + ceilf((rect.size.height + 4 - textRect.size.height) / 2);
	[NSLocalizedStringFromTable([trailing identifier], @"Window", nil) drawInRect:textRect withAttributes:attributes];
	
	// Info
	NSString *info = nil;
	if ([[self delegate] respondsToSelector: @selector(splitView:userInfoForSubviewWithIdentifier:)])
		info = [[self delegate] splitView:self userInfoForSubviewWithIdentifier:[trailing identifier]];
		
	if (info) {
		NSMutableParagraphStyle *pStyle = [[NSMutableParagraphStyle alloc] init];
		[pStyle setAlignment: NSRightTextAlignment];
		attributes = [NSDictionary dictionaryWithObjectsAndKeys: [NSFont systemFontOfSize: [NSFont smallSystemFontSize]], NSFontAttributeName, [NSColor disabledControlTextColor], NSForegroundColorAttributeName, pStyle, NSParagraphStyleAttributeName, nil];
		
		[info drawInRect:textRect withAttributes:attributes];
	}
}

@end
