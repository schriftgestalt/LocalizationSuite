//
//  LIProcessDisplay.m
//  LocInterface
//
//  Created by Max Seelemann on 29.04.09.
//  Copyright 2009 The Blue Technologies Group. All rights reserved.
//

#import "LIProcessDisplay.h"

NSString *LIProcessDisplayNibName	= @"LIProcessDisplay";
NSTimeInterval LIProcessDisplayOpenDelay	= 0.2;


@implementation LIProcessDisplay

- (id)initWithProcessManager:(BLProcessManager *)manager
{
	self = [super init];
	
	if (self != nil) {
		_manager = manager;
		[_manager addObserver:self forKeyPath:@"running" options:0 context:NULL];
	}
	
	return self;
}

- (void)finalize
{
	[_manager removeObserver:self forKeyPath:@"running"];
	[_openTimer invalidate];
}


#pragma mark - Accessors

- (BLProcessManager *)manager
{
	return _manager;
}

@synthesize windowForSheet=_window;


#pragma mark - Actions

- (IBAction)cancel:(id)sender
{
	[sender setEnabled: NO];
	[_manager stop];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([_manager isRunning] && ![panel isVisible]) {
		if (!_openTimer)
			_openTimer = [NSTimer scheduledTimerWithTimeInterval:LIProcessDisplayOpenDelay target:self selector:@selector(openSheet) userInfo:nil repeats:NO];
	}
	if (![_manager isRunning]) {
		if (_openTimer) {
			[_openTimer invalidate];
			_openTimer = nil;
		}
		if ([panel isVisible])
			[self closeSheet];
	}
}

- (void)openSheet
{
	NSWindow *window = (_window) ? _window : [[[self manager] document] windowForSheet];
	
	// Load UI lazily
	if (!panel)
		[NSBundle loadNibNamed:LIProcessDisplayNibName owner:self];
	
	[cancelButton setEnabled: YES];
	[NSApp beginSheet:panel modalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:NULL];
}

- (void)closeSheet
{
	[NSApp endSheet: panel];
	[panel close];
}


@end
