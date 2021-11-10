/*!
 @header
 LIHighlightTextFieldCell.m
 Created by max on 27.08.09.

 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "LIHighlightTextFieldCell.h"

/*!
 @abstract Internal methods of LIHighlightTextFieldCell.
 */
@interface LIHighlightTextFieldCell (LIHighlightTextFieldCellInternal)

/*!
 @abstract Highlights a term in a string.
 @discussion If the passed object is a string or a attributed string, the term passed to the property highlightedString will be beveled with a organge highlight.
 */
- (id)highlightTermInObject:(id)object;

@end

@implementation LIHighlightTextFieldCell

@synthesize highlightedString = _highlight;

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	id value = [self objectValue];

	if ([_highlight length])
		[self setObjectValue:[self highlightTermInObject:value]];
	[super drawInteriorWithFrame:cellFrame inView:controlView];

	[self setObjectValue:value];
}

- (id)highlightTermInObject:(id)object {
	NSMutableAttributedString *attrString;
	NSString *string;
	NSRange range;

	// Extract string if needed
	if ([object isKindOfClass:[NSAttributedString class]])
		object = [object string];
	if (![object isKindOfClass:[NSString class]])
		return nil;
	string = object;

	// Get range
	range = [string rangeOfString:_highlight options:NSCaseInsensitiveSearch | NSLiteralSearch];
	if (range.length == 0)
		return object;

	// Convert object
	if ([object isKindOfClass:[NSAttributedString class]])
		attrString = [[NSMutableAttributedString alloc] initWithAttributedString:object];
	else
		attrString = [[NSMutableAttributedString alloc] initWithString:string];

	// Get all ranges and add attributes
	do {
		[attrString addAttribute:NSBackgroundColorAttributeName value:[NSColor colorWithDeviceRed:242. / 255. green:225. / 255. blue:77. / 255. alpha:1.0] range:range];

		// Find next
		range.location = NSMaxRange(range);
		range.length = [string length] - range.location;
		range = [string rangeOfString:_highlight options:NSCaseInsensitiveSearch range:range];
	} while (range.location != NSNotFound);

	return attrString;
}

@end
