/*!
 @header
 LIHighlightTextFieldCell.h
 Created by max on 27.08.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract A custom text field cell for highlighting search terms.
 */
@interface LIHighlightTextFieldCell : NSTextFieldCell
{
	NSString *_highlight;
}

/*!
 @abstract The string to be highlighted by the cell.
 */
@property(strong) NSString *highlightedString;

@end
