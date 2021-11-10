/*!
 @header
 BLPropertyListSerialization.h
 Created by Max Seelemann on 24.01.10.

 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */

/*!
 @abstract Whether only active objects should be archived or not.
 @discussion Represented by a NSNumber object hosting a BOOL. The value YES means "do not archive inactive objects".
 */
extern NSString *BLActiveObjectsOnlySerializationKey;

/*!
 @abstract Whether the object should erase all change information during archival.
 @discussion Represented by a NSNumber object hosting a BOOL. The value YES means "erase all change information".
 */
extern NSString *BLClearChangeInformationSerializationKey;

/*!
 @abstract Whether the object should erase all backed up versions of interface files.
 @discussion Represented by a NSNumber object hosting a BOOL. The value YES means "erase all backups".
 */
extern NSString *BLClearAllBackupsSerializationKey;

/*!
 @abstract The languages to be archived.
 @discussion Represented by a NSArray of NSStrings representing language identifiers.
 */
extern NSString *BLLanguagesSerializationKey;

/*!
 @abstract A generic menchanism for serialization to property lists, specially suited for BLObjects.
 */
@protocol BLPropertyListSerialization

/*!
 @abstract Initializes a object with the contents of a given property list.
 @discussion The property list passed here has been created using -propertyListWithAttributes: beforehand.
 */
- (id)initWithPropertyList:(NSDictionary *)plist;

/*!
 @abstract Creates a property list from of the object.
 @discussion Do not call directly! Use BLPropertyListSerializer's +serializeObject:withAttributes: instead. Because then the returned dictionary will be processed as well, serializing all contained objects accordingly.
 Passed alongside is a set of options that should be respected during archiving. Commonly these keys are passed along (see their definition for details): BLActiveObjectsOnlySerializationKey, BLClearChangeInformationSerializationKey, BLLanguagesSerializationKey. If you want to persist files separately from the serialized form, return a BLWrapperHandle object, embedding a file wrapper of the file to write.
 */
- (NSDictionary *)propertyListWithAttributes:(NSDictionary *)attributes;

@end

/*!
 @abstract A utility class for serializing a tree of objects.
 */
@interface BLPropertyListSerializer : NSObject

/*!
 @abstract Creates a property list from of the object.
 @discussion The passed object can be any kind of object. Passed arrays or dictionaries will recursively call this method on their contained objects.
 The resulting property list is then examined, and non-plist objects will either be serialized recursively, or - if the do not support BLPropertyListSerialization - they will be archived using a keyed archiver. If both are not possible, an exception is thrown. The returned wrappers are the file wrappers that were returned during the serialization process.
 */
+ (id)serializeObject:(id)object withAttributes:(NSDictionary *)attributes outWrappers:(NSDictionary **)fileWrappers;

/*!
 @abstract Returns a new object created from the given property list.
 @discussion The passed property list needs not to directly originate form a object. Passed arrays or dictionaries will recursively call this method on their contained objects.
 The property list passed here has been created using +serializeObject:withAttributes:outWrappers: beforehand. The passed file wrappers have to be the same as previously returned by that method.
 */
+ (id)objectWithPropertyList:(id)plist fileWrappers:(NSDictionary *)fileWrappers;

@end

/*!
 @abstract A handle for passing file wrappers in and out of the property list serialization.
 */
@interface BLWrapperHandle : NSObject <BLPropertyListSerialization> {
	NSString *_path;
	NSString *_prefPath;
	NSFileWrapper *_wrapper;
}

/*!
 @abstract Convenience allocator.
 */
+ (BLWrapperHandle *)handleWithWrapper:(NSFileWrapper *)wrapper forPreferredPath:(NSString *)path;

/*!
 @abstract The (full) path the wrapper was stored at.
 */
@property (strong, readonly) NSString *path;

/*!
 @abstract The path of the folder the wrapper should be stored in.
 */
@property (strong) NSString *preferredPath;

/*!
 @abstract The file wrapper that should be stored or has been read.
 */
@property (strong) NSFileWrapper *wrapper;

@end
