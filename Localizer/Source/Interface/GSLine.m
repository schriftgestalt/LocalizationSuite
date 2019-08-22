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
	[[NSColor tertiaryLabelColor] set];
	NSRectFill(dirtyRect);
}

@end
