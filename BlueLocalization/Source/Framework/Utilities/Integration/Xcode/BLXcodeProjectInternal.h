/*!
 @header
 BLXcodeProjectInternal.h
 Created by max on 02.07.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

extern NSString *BLXcodeProjectContentsFileName;

extern NSString *BLXcodeProjectArchiveVersionKey;
extern NSString *BLXcodeProjectObjectVersionKey;
extern NSString *BLXcodeProjectRootObjectKeyKey;
extern NSString *BLXcodeProjectObjectsKey;

extern NSString *BLXcodeProjectItemMainGroupKey;
extern NSString *BLXcodeProjectItemTypeKey;
extern NSString *BLXcodeProjectItemFileTypeKey;
extern NSString *BLXcodeProjectItemEncodingKey;
extern NSString *BLXcodeProjectItemChildrenKey;
extern NSString *BLXcodeProjectItemNameKey;
extern NSString *BLXcodeProjectItemPathKey;
extern NSString *BLXcodeProjectItemTreeTypeKey;

extern NSString *BLXcodeProjectItemTypeFile;
extern NSString *BLXcodeProjectItemTypeGroup;
extern NSString *BLXcodeProjectItemTypeVariantGroup;

extern NSString *BLXcodeProjectTreeTypeAbsolute;
extern NSString *BLXcodeProjectTreeTypeGroup;
extern NSString *BLXcodeProjectTreeTypeProject;

extern NSString *BLXcodeProjectFileTypeNib;
extern NSString *BLXcodeProjectFileTypePlist;
extern NSString *BLXcodeProjectFileTypeRTF;
extern NSString *BLXcodeProjectFileTypeStrings;
extern NSString *BLXcodeProjectFileTypeXib;

/*!
 @abstract Internal methods of BLXcodeProjectParser.
 */
@interface BLXcodeProjectParser ()

/*!
 @abstract Initializes a new parser.
 */
- (id)initWithProjectFileAtPath:(NSString *)path;

/*!
 @abstract Retuns the object with the given identifier.
 */
- (NSMutableDictionary *)objectWithIdentifier:(NSString *)identifier;

/*!
 @abstract Generates a new, unused identifier for a new object.
 */
- (NSString *)createUniqueIdentifier;

/*!
 @abstract Adds an object, returning it's new unique identifier.
 */
- (NSString *)addObject:(NSMutableDictionary *)dictionary;

/*!
 @abstract Removes a object with a given identifier.
 */
- (void)removeObjectWithIdentifier:(NSString *)identifier;

/*!
 @abstract Marks the project as dirty.
 */
- (void)noteProjectWasChanged;

@end

/*!
 @abstract Internal methods of BLXcodeProjectItem.
 */
@interface BLXcodeProjectItem ()

/*!
 @abstract Convenience allocator for existing items.
 */
+ (BLXcodeProjectItem *)itemFromDictionary:(NSMutableDictionary *)dictionary withParent:(BLXcodeProjectItem *)parent andParser:(BLXcodeProjectParser *)parser;

/*!
 @abstract Initializes a blank item that can be inserted to the tree.
 */
- (id)initBlankItemWithType:(BLXcodeItemType)type;

/*!
 @abstract Initializes an existing item that was read by a parser.
 */
- (id)initFromDictionary:(NSMutableDictionary *)dictionary withParent:(BLXcodeProjectItem *)parent andParser:(BLXcodeProjectParser *)parser;

/*!
 @abstract Set the type of a project item.
 */
- (void)setItemType:(BLXcodeItemType)newType;

/*!
 @abstract Change the parent of a project item.
 */
- (void)setParent:(BLXcodeProjectItem *)newParent;

/*!
 @abstract Changes the path type of a project item.
 @discussion Do NOT use this, it is for item creation purposes only!
 */
- (void)setPathType:(BLXcodePathType)newType;

/*!
 @abstract Changes the parser of a project item.
 @discussion You should not use this, it is needed for Children managemant only.
 */
- (void)setParser:(BLXcodeProjectParser *)aParser;

/*!
 @abstract Returns the dictionary wrapped by the item.
 @discussion You should not use this, it is needed for Children managemant only.
 */
- (NSMutableDictionary *)dictionary;

@end
