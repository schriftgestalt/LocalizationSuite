//
//  MultiActionWindow.m
//  Localization Manager
//
//  Created by max on 09.09.09.
//  Copyright 2009 Localization Foundation. All rights reserved.
//

#import "MultiActionWindow.h"

@implementation MultiActionWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
	self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag];

	_flagResponders = [[NSMutableArray alloc] init];

	return self;
}

- (void)registerResponderForFlagsChangedEvents:(id)responder {
	[_flagResponders addObject:responder];
}

- (void)deregisterResponderForFlagsChangedEvents:(id)responder {
	[_flagResponders removeObject:responder];
}

- (void)flagsChanged:(NSEvent *)theEvent {
	static NSEvent *aEvent = nil;

	if (theEvent == aEvent)
		return;

	[super flagsChanged:theEvent];

	aEvent = theEvent;
	for (id responder in _flagResponders)
		[responder flagsChanged:theEvent];
	aEvent = nil;
}

@end
