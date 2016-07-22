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
	[[NSColor colorWithCalibratedWhite:0.6 alpha:1] set];
	NSRectFill(dirtyRect);
}

@end
