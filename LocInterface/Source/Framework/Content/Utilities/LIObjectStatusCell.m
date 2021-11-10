/*!
 @header
 LIObjectStatusCell.h
 Created by max on 18.11.09.

 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "LIObjectStatusCell.h"

@implementation LIObjectStatusCell

- (NSString *)labelForFlags:(NSUInteger)flags {
	if (flags & BLKeyObjectAutotranslatedFlag)
		return NSLocalizedStringFromTableInBundle(@"A", @"LIContent", [NSBundle bundleForClass:[self class]], nil);
	if (flags & BLObjectDeactivatedFlag)
		return NSLocalizedStringFromTableInBundle(@"D", @"LIContent", [NSBundle bundleForClass:[self class]], nil);
	if (flags & BLObjectUpdatedFlag)
		return NSLocalizedStringFromTableInBundle(@"U", @"LIContent", [NSBundle bundleForClass:[self class]], nil);

	return nil;
}

- (NSColor *)colorForFlags:(NSUInteger)flags {
	if (flags & BLKeyObjectAutotranslatedFlag)
		return [NSColor colorWithCalibratedRed:0.000 green:0.529 blue:0.763 alpha:1.000];
	if (flags & BLObjectDeactivatedFlag)
		return [NSColor colorWithCalibratedWhite:0.623 alpha:1.000];
	if (flags & BLObjectUpdatedFlag)
		return [NSColor colorWithCalibratedRed:0.000 green:0.763 blue:0.063 alpha:1.000];

	return nil;
}

- (NSString *)toolTipForFlags:(NSUInteger)flags {
	NSMutableArray *status = [NSMutableArray array];

	if (flags & BLKeyObjectAutotranslatedFlag)
		[status addObject:NSLocalizedStringFromTableInBundle(@"Autotranslated", @"LIContent", [NSBundle bundleForClass:[self class]], nil)];
	if (flags & BLObjectDeactivatedFlag)
		[status addObject:NSLocalizedStringFromTableInBundle(@"Deactivated", @"LIContent", [NSBundle bundleForClass:[self class]], nil)];
	if (flags & BLObjectUpdatedFlag)
		[status addObject:NSLocalizedStringFromTableInBundle(@"Updated", @"LIContent", [NSBundle bundleForClass:[self class]], nil)];

	if ([status count])
		return [status componentsJoinedByString:@", "];
	else
		return nil;
}

- (NSString *)toolTip {
	return [self toolTipForFlags:[self intValue]];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	NSUInteger flags;

	flags = [self intValue];

	// Background
	NSRect rect = cellFrame;
	rect.size = NSMakeSize(11, 11);
	rect.origin.x += floorf((cellFrame.size.width - rect.size.width) / 2);
	rect.origin.y += floorf((cellFrame.size.height - rect.size.height) / 2);

	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:2 yRadius:2];
	NSColor *color = [self colorForFlags:flags];

	if (!color)
		return;

	[color set];
	[path fill];

	// Label
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
												 [NSFont fontWithName:@"Helvetica Bold"
																 size:10],
												 NSFontAttributeName,
												 [NSColor textBackgroundColor], NSForegroundColorAttributeName,
												 nil];
	rect.origin.x += 2;
	rect.origin.y -= 1;
	[[self labelForFlags:flags] drawInRect:rect withAttributes:attributes];
}

@end
