/*!
 @header
 LICustomColumnTableViewHeaderView.m
 Created by max on 11.03.05.

 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "LICustomColumnTableViewHeaderView.h"

#import "LICustomColumnTableView.h"

@implementation LICustomColumnTableViewHeaderView

#pragma mark - Event Actions

- (void)mouseDown:(NSEvent *)theEvent {
	if (([theEvent modifierFlags] & NSControlKeyMask) != 0)
		[self rightMouseDown:theEvent];
	else
		[super mouseDown:theEvent];
}

- (void)rightMouseDown:(NSEvent *)theEvent {
	if (NSPointInRect([self convertPoint:[theEvent locationInWindow] fromView:nil], [self frame]))
		[self showMenu:theEvent];
	else
		[super rightMouseDown:theEvent];
}

#pragma mark - Menu

- (void)showMenu:(NSEvent *)theEvent {
	NSMenu *theMenu;
	id delegate;

	delegate = [[self tableView] delegate];
	theMenu = [[NSMenu alloc] init];

	for (NSTableColumn *column in [[self tableView] tableColumns]) {
		NSMenuItem *item;
		NSString *title;

		if ([delegate respondsToSelector:@selector(tableView:customNameForColumn:)])
			title = [delegate tableView:[self tableView] customNameForColumn:column];
		else
			title = [[column headerCell] title];

		item = [[NSMenuItem alloc] initWithTitle:title action:@selector(changeVisibility:) keyEquivalent:@""];
		[item setState:![column isHidden]];
		[item setRepresentedObject:column];

		[theMenu addItem:item];
	}

	[NSMenu popUpContextMenu:theMenu withEvent:theEvent forView:self withFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
}

- (void)changeVisibility:(id)sender {
	NSTableColumn *column = [sender representedObject];
	[column setHidden:![column isHidden]];
}

@end
