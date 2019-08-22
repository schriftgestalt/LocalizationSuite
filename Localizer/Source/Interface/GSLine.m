//
//  GSLine.m
//  Localizer
//
//  Created by Georg Seifert on 22.07.16.
//  Copyright (c) 2016 Localization Suite. All rights reserved.
//

#import "GSLine.h"

@implementation GSLine

- (void)drawRect:(NSRect)dirtyRect {
	NSRect frame = [self frame];
	if (frame.size.height > frame.size.width) {
		dirtyRect.origin.x += 2;
		dirtyRect.size.width = 1;
	}
	else {
		dirtyRect.origin.y += 2;
		dirtyRect.size.height = 1;
	}
	[[NSColor tertiaryLabelColor] set];
	[NSBezierPath fillRect:dirtyRect];
}

@end
