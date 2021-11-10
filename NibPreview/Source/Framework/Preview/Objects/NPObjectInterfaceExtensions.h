/*!
 @header
 NPObjectInterfaceExtensions.h
 Created by max on 06.08.09.

 @copyright 2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract Extensions to NSObject for doing interface actions a common way.
 */
@interface NSObject (NPObjectInterfaceExtensions)

/*!
 @abstract Determines whether the object can have it's frame set.
 @discussion More precisely, this includes, whether the object is a view who's frame can be set. An example for a view who's frame cannot be set is the content view of a tab view, who's frame is determined by the tab view frame only.
 */
- (BOOL)canSetFrame;

/*!
 @abstract Makes a direct descendant of the object visible.
 @discussion Like -setChildren: in NPObjectPropertyExtensions, the passed item is a child according to the nib file's definition. The object should - if possible and needed - make it's child visible. Examples are selecting the right tab or menu item. Default implementation does nothing.
 The target object passed alon is the object ultimately to be made visible. If may be nil, but might provide some additional help.
 */
- (void)makeChildVisible:(id)child target:(id)target;

/*!
 @abstract Calculates the real frame of the given child in respect to callee.
 */
- (NSRect)frameOfChild:(id)child;

/*!
 @abstract Change the frame of a child using the same transformation as done in -frameOfChild.
 */
- (void)setFrame:(NSRect)rect ofChild:(id)child;

@end
