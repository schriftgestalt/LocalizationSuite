/*!
 @header
 NPWindowView.h
 Created by max on 29.01.10.

 @copyright 2008-2010 Localization Suite. All rights reserved.
 */

/*!
 @abstract A view that resembles the look of a window.
 @discussion When initializing this view with a window, the window looses it's content view which will be added to the view's descendants.
 */
@interface NPWindowView : NSView {
	NSView *_contentView;
	NSImage *_titleBarImage;
	NSWindow *_origWindow;
}

/*!
 @abstract Initializes a new window view with a given window.
 */
- (id)initWithWindow:(NSWindow *)original;

/*!
 @abstract The window the view was created from.
 */
@property (readonly) NSWindow *window;

/*!
 @abstract The "content view" of the view, respectively the former content view of the window.
 */
@property (readonly) NSView *contentView;

@end
