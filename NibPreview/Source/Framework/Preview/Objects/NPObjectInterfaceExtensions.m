/*!
 @header
 NPObjectInterfaceExtensions.m
 Created by max on 06.08.09.

 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "NPObjectInterfaceExtensions.h"

#define UNFLIP(__rect, __view) (([(__view) isFlipped]) ? NSMakeRect((__rect).origin.x, [(__view) bounds].size.height - NSMaxY((__rect)), (__rect).size.width, (__rect).size.height) : (__rect))

@implementation NSObject (NPObjectInterfaceExtensions)

- (BOOL)canSetFrame {
	return NO;
}

- (void)makeChildVisible:(id)child target:(id)target {
}

- (NSRect)frameOfChild:(id)child {
	return NSZeroRect;
}

- (void)setFrame:(NSRect)rect ofChild:(id)child {
}

@end

@implementation NSView (NPObjectInterfaceExtensions)

- (BOOL)canSetFrame {
	// Special cases
	if ([[self superview] isKindOfClass:[NSTabView class]])
		return NO;

	// In general, we can always set the frame
	return YES;
}

- (void)makeChildVisible:(id)child target:(id)target {
	if ([child isKindOfClass:[NSView class]])
		[self scrollRectToVisible:[child frame]];
}

- (NSRect)frameOfChild:(id)child {
	if (![child isKindOfClass:[NSView class]] || [child superview] != self)
		return [self bounds];
	else
		return [self convertRect:[child bounds] fromView:child];
}

- (void)setFrame:(NSRect)rect ofChild:(id)child {
	if ([child isKindOfClass:[NSView class]])
		[child setFrame:rect];
}

@end

@implementation NSBox (NPObjectInterfaceExtensions)

- (NSRect)frameOfChild:(id)child {
	return [self convertRect:[child frame] fromView:[self contentView]];
}

- (void)setFrame:(NSRect)rect ofChild:(id)child {
	[super setFrame:[self convertRect:rect toView:[self contentView]] ofChild:child];
}

@end

@implementation NSTabView (NPObjectInterfaceExtensions)

- (void)makeChildVisible:(id)child target:(id)target {
	[self selectTabViewItem:child];
}

@end

@implementation NSTabViewItem (NPObjectInterfaceExtensions)

- (NSRect)frameOfChild:(id)child {
	NSRect rect = [[self tabView] contentRect];
	return UNFLIP(rect, [self tabView]);
}

@end

@implementation NSTableView (NPObjectInterfaceExtensions)

- (NSRect)frameOfChild:(id)child {
	NSRect rect;

	rect = [self rectOfColumn:[self.tableColumns indexOfObject:child]];
	rect.size.height = [self.superview.superview frame].size.height;

	return rect;
}

@end

@implementation NSScrollView (NPObjectInterfaceExtensions)

- (void)makeChildVisible:(id)child target:(id)target {
	[[self contentView] scrollRectToVisible:[child frame]];
}

- (NSRect)frameOfChild:(id)child {
	NSRect rect = [child frame];

	rect.origin.x -= [self documentVisibleRect].origin.x;
	rect.origin.y -= [self documentVisibleRect].origin.y;

	return rect;
}

@end

@implementation NSPopUpButton (NPObjectInterfaceExtensions)

- (void)makeChildVisible:(id)child target:(id)target {
	if ([target isKindOfClass:[NSMenuItem class]])
		[self selectItem:target];
}

@end

@implementation NSMatrix (NPObjectInterfaceExtensions)

- (NSRect)frameOfChild:(id)child {
	NSInteger row, column;

	if ([self getRow:&row column:&column ofCell:child])
		return UNFLIP([self cellFrameAtRow:row column:column], self);
	else
		return NSMakeRect(0, 0, [self bounds].size.width, 0);
}

@end
