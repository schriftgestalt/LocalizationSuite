//
//  MultiActionButton.m
//  Localization Manager
//
//  Created by max on 08.09.09.
//  Copyright 2009 Localization Foundation. All rights reserved.
//

#import "MultiActionButton.h"
#import "MultiActionWindow.h"


@implementation MultiActionButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder: aDecoder];
	
	_lastFlags = 0;
	self.altTitle = self.alternateTitle;
	
	return self;
}


#pragma mark - Accessors

@synthesize altAction=_altAction;
@synthesize altTitle=_altTitle;
@synthesize shiftAction=_shiftAction;
@synthesize shiftTitle=_shiftTitle;


#pragma mark - Events

- (void)viewDidMoveToWindow
{
	[super viewDidMoveToWindow];
	
	if ([[self window] isKindOfClass: [MultiActionWindow class]])
		[(MultiActionWindow *)[self window] registerResponderForFlagsChangedEvents: self];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
	[super viewWillMoveToWindow: newWindow];
	
	if ([[self window] isKindOfClass: [MultiActionWindow class]])
		[(MultiActionWindow *)[self window] deregisterResponderForFlagsChangedEvents: self];
}

- (void)flagsChanged:(NSEvent *)theEvent
{
	[super flagsChanged: theEvent];
	
	_lastFlags = [theEvent modifierFlags];
	[self setNeedsDisplay: YES];
}


#pragma mark - Button customization

- (BOOL)sendAction:(SEL)theAction to:(id)theTarget
{
	// Inject custom actions
	if ((_lastFlags & NSAlternateKeyMask) && _altAction)
		theAction = _altAction;
	if ((_lastFlags & NSShiftKeyMask) && _shiftAction)
		theAction = _shiftAction;
	
	return [super sendAction:theAction to:theTarget];
}

- (void)drawRect:(NSRect)rect
{
	NSString *title = [self title];
	
	// Inject custom titles
	if ((_lastFlags & NSAlternateKeyMask) && [_altTitle length])
		[self setTitle: _altTitle];
	if ((_lastFlags & NSShiftKeyMask) && [_shiftTitle length])
		[self setTitle: _shiftTitle];
	
	[super drawRect: rect];
	[self setTitle: title];
}

@end


