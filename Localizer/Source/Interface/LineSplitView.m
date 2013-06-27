//
//  LineSplitView.m
//  Localizer
//
//  Created by Max Seelemann on 22.06.07.
//  Copyright 2007 The Blue Technologies Group. All rights reserved.
//

#import "LineSplitView.h"


@implementation LineSplitView

- (void)awakeFromNib
{
}

- (void)drawDivider:(NSImage*)anImage inRect:(NSRect)rect betweenView:(RBSplitSubview*)leading andView:(RBSplitSubview*)trailing
{
	[[NSColor controlShadowColor] set];
	[NSBezierPath fillRect: rect];
}

@end
