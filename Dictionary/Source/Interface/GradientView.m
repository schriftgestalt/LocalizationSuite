//
//  GradientView.m
//  Localization Dictionary
//
//  Created by max on 23.01.10.
//  Copyright 2010 Localization Suite. All rights reserved.
//

#import "GradientView.h"


@implementation GradientView

- (void)drawRect:(NSRect)rect
{
	NSGradient *gradient;
	
	rect = [self bounds];
	
	gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.8 alpha:1]
											 endingColor:[NSColor colorWithCalibratedWhite:0.9 alpha:1]];
	[gradient drawInRect:rect angle:90];
	
	[[NSColor controlShadowColor] set];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(rect), NSMinY(rect) + 0.5) toPoint:NSMakePoint(NSMaxX(rect), NSMinY(rect) + 0.5)];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(NSMinX(rect), NSMaxY(rect) - 0.5) toPoint:NSMakePoint(NSMaxX(rect), NSMaxY(rect) - 0.5)];
}

@end
