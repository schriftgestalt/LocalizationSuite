//
//  GSMenuButton.m
//  Glyphs 3
//
//  Created by Georg Seifert on 08.06.21.
//  Copyright © 2021 schriftgestaltung.de. All rights reserved.
//

#import "GSMenuButton.h"

@implementation GSMenuButton

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	_preferredEdge = NSRectEdgeMaxY;
	self.action = @selector(buttonClicked:);
	self.target = self;
	return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	_preferredEdge = NSRectEdgeMaxY;
	self.action = @selector(buttonClicked:);
	self.target = self;
	return self;
}

- (NSRect)contentBounds {
	NSRect rect = self.bounds;
	if (rect.size.width < rect.size.height) {
		rect = NSInsetRect(rect, 0, (rect.size.height - rect.size.width) / 2);
	}
	return rect;
}

- (IBAction)buttonClicked:(id)sender {
	NSRect bounds = [self contentBounds];
	NSSize menuSize = self.menu.size;
	NSPoint loc;
	if (@available(macOS 10.16, *)) {
		switch (_preferredEdge) {
			case NSRectEdgeMinY:
				loc = NSMakePoint(NSMinX(bounds) + 6, NSMaxY(bounds) + 4);
				break;
			case NSRectEdgeMaxX:
				loc = NSMakePoint(NSMaxX(bounds) + 6 - menuSize.width, NSMaxY(bounds) + 4);
				break;
			default: // NSRectEdgeMaxY
				loc = NSMakePoint(NSMinX(bounds) + 7, NSMinY(bounds) - 26);
		}
	}
	else {
		switch (_preferredEdge) {
			case NSRectEdgeMinY:
				loc = NSMakePoint(NSMinX(bounds) + 5, NSMaxY(bounds) + 2);
				break;
			case NSRectEdgeMaxX:
				loc = NSMakePoint(NSMaxX(bounds) + 5 - menuSize.width, NSMaxY(bounds) + 2);
				break;
			default: // NSRectEdgeMaxY
				loc = NSMakePoint(NSMinX(bounds) + 5, NSMinY(bounds) - 20);
		}
	}
	[self.menu popUpMenuPositioningItem:nil atLocation:loc inView:self];
}

@end
