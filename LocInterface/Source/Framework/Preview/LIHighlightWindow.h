/*!
 @header
 LIHighlightWindow.h
 Created by max on 01.09.09.

 @copyright 2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract Window class used to highlight preview parts.
 @discussion A window that displays a transparent gray overlay with a blank, free spot in it.
 */
@interface LIHighlightWindow : NSWindow {
	NSRect _highlight;
	NSWindow *_parent;
}

/*!
 @abstract Designated intializer.
 */
- (id)initWithParent:(NSWindow *)parent;

/*!
 @abstract The window the highlight is attached to.
 @discussion Highlight windows will move alongside their parents. Any events will be forwarded to the parent window.
 */
@property (readonly) NSWindow *parentWindow;

/*!
 @abstract The rectangle to be highlighted.
 @discussion Setting this to NSZeroRect will show no highlight.
 */
@property (assign) NSRect highlightRect;

@end

/*!
 @abstract The delegate methods of a highlight window, send to the window's delegate.
 */
@interface NSObject (LIHighlightWindowDelegate)

/*!
 @abstract Sent by the window to it's delegate upon every taken event.
 @discussion This will be mouse events only as the window cannot become key.
 @return Whether the window should forward the event to it's parent or not.
 */
- (BOOL)highlightWindow:(LIHighlightWindow *)window receivedEvent:(NSEvent *)theEvent;

@end
