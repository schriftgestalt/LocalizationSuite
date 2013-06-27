/*!
 @header
 LIPreviewContent.h
 Created by max on 05.04.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract The content object for previewing. Abstract Class.
 @discussion These objects are responsible for loading and storing all data necessary for a preview, including creating the view in which it will be hosted.
 */
@interface LIPreviewContent : NSObject
{
	id				_document;
	BLFileObject	*_fileObject;
	BLKeyObject		*_keyObject;
	NSString		*_language;
	NSString		*_referenceLanguage;
}

/*!
 @abstract Returns the LIPreviewContent subclass for the given BLFileObject subclass, or Nil otherwise.
 @discussion This can also be called with subclasses of a registered file object class. Mainly for internal use.
 */
+ (Class)contentClassForFileObjectClass:(Class)fileClass;

/*!
 @abstract Registers a LIPreviewContent subclass for a BLFileObject subclass.
 @discussion Mainly for internal use. Also works if no autorelease pool is present.
 */
+ (void)registerContentClass:(Class)aClass forFileObjectClass:(Class)fileClass;

/*!
 @abstract Creates a new preview content object for the given file object.
 @discussion Building a cache is highly recomended, as creating a preview may be quite time-consuming.
 */
+ (LIPreviewContent *)contentWithFileObject:(BLFileObject *)object inDocument:(id <BLDocumentProtocol>)document;

/*!
 @abstract Designated Initializer.
 @discussion No big setup should be done here. Properties will be set afterwards and heavy work should happen only in -load.
 */
- (id)init;

/*!
 @abstract The file object whose contents are to be prepared for previewing.
 @discussion Must be set before loading the preview using -load. Should not be changed afterwards.
 */
@property(strong) BLFileObject *fileObject;

/*!
 @abstract The language in which the contents are to be prepared for previewing.
 */
@property(strong) NSString *language;

/*!
 @abstract The document the file object is hosted in. Required as the path creator gives the path to load.
 @discussion Must be set before loading the preview using -load. Should not be changed afterwards.
 */
@property(strong) id <BLDocumentProtocol> document;

/*!
 @abstract Notifies the subclass when to load the preview.
 @discussion Default implementation just returns NO.
 @return YES on success, or NO on failure.
 */
- (BOOL)load;

/*!
 @abstract The currently displayed root item.
 @discussion This property is KVO-observable!
 */
- (NSObject<LIPreviewRootItem> *)rootItem;

/*!
 @abstract The root items available for viewing.
 @discussion Root items are to be understood as multiple items contained in one content object that can not (or at least are not) dsiplayed at the same time. An example would be multiple windows in one nib file.
 Returns an array of LIPreviewRootItem-conformant objects, no assumptions about them should be made whatsoever. If only one view is available, this method might also return nil or an empty array.
 */
- (NSArray *)availableRootItems;

/*!
 @abstract Change the currently displayed root item to be a different one.
 @discussion This will likely trigger a change of the root view. Default implementation does nothing.
 */
- (void)changeRootItem:(NSObject<LIPreviewRootItem> *)item;

/*!
 @abstract Returns a view displaying the content.
 @discussion If maybe the focus changes and thus the rootView needs to be switched, you will receive a KVO message for this property. Propably the root view will be linked to the current root item.
 */
- (NSView *)rootView;

/*!
 @abstract The key object that is currently focussed.
 @discussion Basically this should - if possible - move the passed key object into the user's focus (whatever this means in respect to the content). If, during setting the focus, the rootView needs to be changed, just do so but send a kvo message of it's change.
 */
@property(strong) BLKeyObject *focussedKeyObject;

/*!
 @abstract The rectangle in which the focussed key object is visible.
 @discussion Mainly used to display a focus overlay. If no rect can be determined or the item is not visible, return NSZeroRect. Coordinates are in respect to the rootView.
 */
- (NSRect)rectOfFocussedKeyObject;

/*!
 @abstract The key object displayed at a given point.
 @discussion Used for direct user interaction like focus. If no key object can be determined, return nil. If multiple key objects would fit, return the most appropriate.  Coordinates are in respect to the rootView.
 */
- (BLKeyObject *)keyObjectAtPoint:(NSPoint)point;

@end


