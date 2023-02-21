/*!
 @header
 LICopyingOutlineView.h
 Created by Max Seelemann on 19.05.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

/*!
 @abstract A simple outline view that enables users to copy selected rows.
 @discussion This is done using an extension of the outline view delgate protocol, see LICopyingOutlineView for details.
 */
@interface LICopyingOutlineView : NSOutlineView

@end

/*!
 @abstract The extension if NSOutlineView's delegate by LICopyingOutlineView.
 */
@interface NSObject (LICopyingOutlineView)

/*!
 @abstract The copy delegate method.
 @discussion The receiver should, upon receiving this message, copy the (relevant parts of the) currenlty selected contents to the given pasteboard.
 */
- (void)copySelectionInOutlineView:(NSOutlineView *)view toPasteboard:(NSPasteboard *)pasteboard;

@end
