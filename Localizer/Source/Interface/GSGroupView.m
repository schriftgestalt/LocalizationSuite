//
//  GSGroupView.m
//  Localizer
//
//  Created by Georg Seifert on 22.07.16.
//  Copyright (c) 2016 Localization Suite. All rights reserved.
//

#import "GSGroupView.h"

@implementation GSGroupView

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	[[NSColor textBackgroundColor] set];
	NSRectFill(dirtyRect);
	[[NSColor tertiaryLabelColor] set];
	NSRect bounds = [self bounds];
	NSRect rect = bounds;
	rect.origin.y += NSHeight(rect) - 1;
	rect.size.height = 1;
	NSRectFill(rect);
	if (NSHeight(bounds) < 30 && NSHeight(bounds) > 3) {
		[[NSColor tertiaryLabelColor] set];
		rect.origin.y = 0;
		NSRectFill(rect);
	}
}

@end
