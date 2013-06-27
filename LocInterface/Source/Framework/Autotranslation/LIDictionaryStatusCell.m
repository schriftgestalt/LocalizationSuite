/*!
 @header
 LIDictionaryStatusCell.m
 Created by max on 31.07.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */


#import "LIDictionaryStatusCell.h"


@implementation LIDictionaryStatusCell

- (id)objectValue
{
	return _document;
}

- (void)setObjectValue:(id)obj
{
	_document = obj;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSRect target;
	
	NSString *path = [[_document fileURL] path];
	NSColor *altColor = ([self isHighlighted] && [[controlView window] firstResponder] == controlView && [[controlView window] isKeyWindow]) ? [NSColor whiteColor] : nil;
	
	// Contains dict?
	BOOL containsDict = ([_document isKindOfClass: [BLLocalizerDocument class]] && [_document embeddedDictionary]);
	
	// Draw the icon
	NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile: path];
	NSRect source = {{0, 0}, {[icon size].width, [icon size].height}};
	target = cellFrame;
	target.size.width = target.size.height;
	[icon setFlipped: YES];
	[icon drawInRect:target fromRect:source operation:NSCompositeSourceOver fraction:1.0];
	
	// Draw the file name
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys: [NSFont systemFontOfSize: 13], NSFontAttributeName, (altColor) ? altColor : [NSColor blackColor], NSForegroundColorAttributeName, nil];
	target.origin = NSMakePoint(target.size.width + 6, 2 + cellFrame.origin.y);
	target.size = NSMakeSize(cellFrame.size.width - target.origin.x - 150, 17);
	[[[path lastPathComponent] stringByDeletingPathExtension] drawInRect:target withAttributes:attributes];
	
	// Draw the path
	attributes = [NSDictionary dictionaryWithObjectsAndKeys: [NSFont systemFontOfSize: 9], NSFontAttributeName, (altColor) ? altColor : [NSColor controlShadowColor], NSForegroundColorAttributeName, nil];
	target.origin.y = 20 + cellFrame.origin.y;
	target.size.width = cellFrame.size.width - target.origin.x - 5;
	if (containsDict)
		target.size.width -= 100;
	[path drawInRect:target withAttributes:attributes];
	
	// Get the stats
	NSUInteger keys = 0;
	if ([_document respondsToSelector: @selector(keys)])
		keys = [[(BLDictionaryDocument *)_document keys] count];
	else if ([_document respondsToSelector: @selector(bundles)])
		keys = [BLObject numberOfKeysInObjects: [(BLLocalizerDocument *)_document bundles]];
	NSUInteger languages = [[_document languages] count];
	
	// Draw the stats
	NSString *stats = [NSString stringWithFormat: NSLocalizedStringFromTableInBundle(@"KeysLanguages", @"LIDictionarySettings", [NSBundle bundleForClass: [self class]], nil), keys, languages];
	
	target.origin = NSMakePoint(cellFrame.size.width - 150, 5 + cellFrame.origin.y);
	target.size = NSMakeSize(145, 13);
	
	NSMutableParagraphStyle *pStyle = [[NSMutableParagraphStyle alloc] init];
	[pStyle setAlignment: NSRightTextAlignment];
	attributes = [NSDictionary dictionaryWithObjectsAndKeys: [NSFont systemFontOfSize: 9], NSFontAttributeName, (altColor) ? altColor : [NSColor darkGrayColor], NSForegroundColorAttributeName, pStyle, NSParagraphStyleAttributeName, nil];
	
	[stats drawInRect:target withAttributes:attributes];
	
	// Draw dict info text
	if (containsDict) {
		NSString *text = NSLocalizedStringFromTableInBundle(@"ContainsDict", @"LIDictionarySettings", [NSBundle bundleForClass: [self class]], nil);
		target.origin.y += 15;
		[text drawInRect:target withAttributes:attributes];
	}
}

@end
