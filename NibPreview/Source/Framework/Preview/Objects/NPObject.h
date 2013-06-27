/*!
 @header
 NPObject.h
 Created by max on 15.06.08.
 
 @copyright 2008-2009 Localization Suite. All rights reserved.
 */

#import "NPObject.h"

/*!
 @abstract An object in the loaded hierarchy of a preview.
 @discussion NPPreviewBuilder loads NPObject's from the description given by ibtool. Each NPObject corresponds to one loadable object from the description of the nib file. The hierarchies of both object trees match: a child of a NPObject (again a NPObject) maps to a child of the original of the same object.
 */
@interface NPObject : NSObject
{
	NSMutableArray	*_children;
	NSArray			*_keyObjects;
	NSString			*_label;
	NSString			*_language;
	NSString			*_objectID;
	id					_original;
	NPObject			*_parent;
	BOOL				_snapshot;
}

/*!
 @abstract Convenience allocator used by NPPreviewBuilder.
 */
+ (NPObject *)previewObjectWithOriginal:(id)original andID:(NSString *)identifier;

/*!
 @abstract Designated initializer.
 */
- (id)initWithOriginal:(id)original andID:(NSString *)identifier;



/*!
 @abstract The root in the preview object tree.
 */
- (NPObject *)rootObject;

/*!
 @abstract The parent NPObject object.
 @discussion Returns nil if the object itself is the root.
 */
@property(nonatomic, strong) NPObject *parent;

/*!
 @abstract An array of all child NPObject objects.
 */
@property(nonatomic, strong) NSArray *children;

/*!
 @abstract The original object encapsulated by this object.
 @discussion The original is the object that has been loaded and instanciated from the nib file. Is forms the root of a tree containing all descending orginal objects. Getting a rootObject's original return the complete root object including all subview/childs as defined in the nib.
 */
@property(nonatomic, strong) id original;

/*!
 @abstract The object identifier from the nib file.
 @discussion Unique per nib file. May be used to find a original object from NPPreviewBuilder's objects dictionary.
 */
@property(nonatomic, strong) NSString *nibObjectID;



/*!
 @abstract The key objects associated with the preview objects.
 @discussion The keys object identifier should match in order to avoid wrong translations. Associated keys' data will be used when translating the interface in a different language.
 */
@property(nonatomic, strong) NSArray *associatedKeyObjects;

/*!
 @abstract Sets the language the object will be translated to.
 @discussion Loads the values for the passed language from the associated key objects, replacing values loaded from the nib file. This operation is destructive. Original values cannot be restored.
 The preview object then attaches itself to it's associated key object to this language and updates it's state accordingly.
 Defaults to nil.
 */
@property(nonatomic, strong) NSString *displayLanguage;

/*!
 @abstract Sets the language the object will be translated to, but sets values from the snapshot instead.
 @discussion Setting snapshot values disables automatic updates upon key object changes.
 */
- (void)setDisplayLanguage:(NSString *)language useSnapshot:(BOOL)snapshot;

/*!
 @abstract The user-given name of the object in the nib file.
 @discussion Can be used to diplay to the user, e.g. when browsing the object hierarchy.
 */
@property(nonatomic, strong) NSString *label;



/*!
 @abstract The frame of the orginal in the rootObject's coordinates.
 @discussion Please be aware that setting this property works only for objects whose originals are views. 
 */
@property(nonatomic, assign) NSRect frameInRootView;

/*!
 @abstract Makes the object's original visible in the original objects view hierarchy.
 @discussion By traversing through the object tree, each original is - if needed and possible - altered to show the passed object's original.
 */
- (void)makeOriginalVisible;

/*!
 @abstract A view that can be shown to the user to get a preview of the object.
 @discussion This might - in some cases - be the original (when the original is a view), a custom view that emulates the look of the object (like a menu or a window) or nil, if the object cannot be easily shown using a view. Each object has at most one displayView that does not change over time (i.e. that is not re-created on each request).
 */
- (NSView *)displayView;

/*!
 @abstract Returns the frame of the orginal in the rootObject's displayView coordinates.
 */
- (NSRect)frameInRootDisplayView;

@end
