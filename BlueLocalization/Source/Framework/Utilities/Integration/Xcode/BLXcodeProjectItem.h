/*!
 @header
 BLXcodeProjectItem.h
 Created by max on 02.07.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

@class BLXcodeProjectParser;

/*!
 @abstract Possible types for Xcode project items.

 @const BLXcodeItemTypeUnknown			The type of the item is none of the following.

 @const BLXcodeItemTypeFile				The item represents a file and therefor has no children.
 @const BLXcodeItemTypeGroup			The item represents a regular group and has both a parent and children.
 @const BLXcodeItemTypeVariantGroup		The item represents a group and holds multiple variants (i.e. languages) of the same file.
 */
typedef enum {
	BLXcodeItemTypeUnknown = -1,

	BLXcodeItemTypeFile,
	BLXcodeItemTypeGroup,
	BLXcodeItemTypeVariantGroup
} BLXcodeItemType;

/*!
 @abstract Possible referencing styles for a item in relation to is containing group.
 @discussion Currently unsupported (aka unknown) referencing types are "Relative to Build Results", "Relative to Xcode Folder", "Relative to current SDK directory".

 @const BLXcodePathTypeUnknown		A referencing type that is currently unsupported has been supplied for this item.

 @const BLXcodePathTypeAbsolute		The item's path is absolute and therefor should start with a "/".
 @const BLXcodePathTypeGroup		The item's path is relative to the containing group.
 @const BLXcodePathTypeProject		The item's path is relative to project folder or source root.
 */
typedef enum {
	BLXcodePathTypeUnknown = -1,

	BLXcodePathTypeAbsolute,
	BLXcodePathTypeGroup,
	BLXcodePathTypeProject
} BLXcodePathType;

/*!
 @abstract Represents an object in the Xcode file tree.
 */
@interface BLXcodeProjectItem : NSObject

/*!
 @abstract Creates a new blank item that can be inserted to the tree.
 @discussion The item's path type will be BLXcodePathTypeGroup.
 */
+ (BLXcodeProjectItem *)blankItemWithType:(BLXcodeItemType)type;

/*!
 @abstract The structural type of the item.
 @discussion See BLXcodeProjectItemType for possible values.
 */
@property (nonatomic, readonly) BLXcodeItemType itemType;

/*!
 @abstract The name of the item as given by the Xcode user.
 @discussion The name is meta-information only, is has no influence on the actual paths.
 */
@property (nonatomic, strong) NSString *name;

/*!
 @abstract The file type of the item that it's treated for by Xcode.
 @discussion The file type is meta-information only. The value "nil" means that no file type is specified.
 */
@property (nonatomic, strong) NSString *fileType;

/*!
 @abstract The file type of the item that it's treated for by Xcode.
 @discussion The file type is meta-information only. A value of "0" means that no encoding be specified.
 */
@property (nonatomic, assign) NSStringEncoding encoding;

/*!
 @abstract An array of project items represneting the children.
 @discussion While this method is transparent, the array of child items is created lazily on demand. Use addChild: and removeChild: to modify.
 */
@property (weak, nonatomic, readonly) NSArray *children;

/*!
 @abstract Adds a child to this item.
 @discussion Throws if the target object is actually a file. The added item must not have any children, otherwise this method will throw as well.
 */
- (void)addChild:(BLXcodeProjectItem *)item;

/*!
 @abstract Removes a child from the item.
 @discussion Throws if the target object is actually a file. The removed item must not have any children, otherwise this method will throw as well.
 */
- (void)removeChild:(BLXcodeProjectItem *)item;

/*!
 @abstract The parent item containing this item.
 */
@property (weak, nonatomic, readonly) BLXcodeProjectItem *parent;

/*!
 @abstract The path associated with the item.
 @discussion Please pay attention that this path is subject to the item's path type which cannot be changed! See class discussion!
 */
@property (nonatomic, copy) NSString *path;

/*!
 @abstract The referencing type to be used in conjunction with the item's path.
 @discussion Please pay attention to the fact that this referencing style cannot be changed and that newly created items always have BLXcodePathTypeGroup referencing style.
 */
@property (nonatomic, readonly) BLXcodePathType pathType;

/*!
 @abstract The full path of the represented item.
 */
@property (weak, nonatomic, readonly) NSString *fullPath;

@end
