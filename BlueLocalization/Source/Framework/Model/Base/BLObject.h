/*!
 @header
 BLObject.h
 Created by Max Seelemann on 24.07.06.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLPropertyListSerialization.h>

/*!
 @abstract This key will appear in the changed values of an object if the reference file was changed.
 */
extern NSString *BLObjectReferenceChangedKey;

// Possible values for errors
extern NSString *BLObjectFiletypeUnknownError;
extern NSString *BLObjectFileNotFoundError;
extern NSString *BLObjectFileUnimportableError;

// And-Masks for the flags property
enum {
	BLObjectUpdatedFlag = 1 << 0,
	BLObjectDeactivatedFlag = 1 << 1
};

/*!
 @abstract The abstract base class for all objects (bundles, files, keys) in a localization file.
 */
@interface BLObject : NSObject <NSCopying, BLPropertyListSerialization> {
	NSDate *_changeDate;
	NSMutableArray *_changedValues;
	NSMutableArray *_errors;
	NSUInteger _flags;
}

/*!
 @abstract Returns wether the array of changed values is empty or not.
 */
@property (readonly) BOOL didChange;

/*!
 @abstract The values (properties) that were changed of the object.
 @discussion Currently this includes among others the language identifiers and BLObjectReferenceChangedKey.
 */
@property (strong) NSArray *changedValues;

/*!
 @abstract Convenience access to whether the changed values contain BLObjectReferenceChangedKey or not.
 */
@property (assign) BOOL referenceChanged;

/*!
 @abstract Convenience access to the languages in the changed values of an object.
 */
@property (strong) NSArray *changedLanguages;

/*!
 @abstract Set multiple values as changed.
 @discussion This forwards to -setValue:didChange: with YES as changed.
 */
- (void)addChangedValues:(NSArray *)array;

/*!
 @abstract Returns whether a value did change or not.
 */
- (BOOL)valueDidChange:(NSString *)key;

/*!
 @abstract Sets that the value "key" did change or not in the object.
 @discussion This is both propagated to parent object and child objects.
 */
- (void)setValue:(NSString *)key didChange:(BOOL)changed;

/*!
 @abstract Invoked by a child object, when one of it's values changed or not.
 @discussion This is both propagated to parent object and child objects.
 */
- (void)setObjectValue:(NSString *)key didChange:(BOOL)changed;

/*!
 @abstract Erases all changed values.
 */
- (void)setNothingDidChange;

/*!
 @abstract A user-presentable string of the changed values.
 @discussion This behavior is overridden when the object has errors, which are printen instead then.
 */
@property (weak, readonly) NSString *changeDescription;

/*!
 @abstract The date of the last object's change.
 */
@property (strong) NSDate *changeDate;

/*!
 @abstract The errors currently recognized for the object.
 */
@property (strong) NSArray *errors;

/*!
 @abstract Convenience accessor for adding object to the objects errors.
 */
- (void)addObjectErrors:(NSArray *)newErrors;

/*!
 @abstract The objects flags, denoting a state.
 @discussion The single flags ar logically or-ed together. Possible flags include: BLObjectUpdatedFlag and BLObjectDeactivatedFlag
 */
@property (assign) NSUInteger flags;

/*!
 @abstract Convenience access to whether the BLObjectDeactivatedFlag is not set in the object's flags.
 */
@property (assign) BOOL isActive;

/*!
 @abstract Convenience access to whether the BLObjectUpdatedFlag is set in the object's flags or not.
 */
@property (assign) BOOL wasUpdated;

/*!
 @abstract Common means of accessing the children in the tree of objects.
 */
- (NSArray *)objects;

/*!
 @abstract Common means of accessing the parent the tree of objects.
 */
- (id)parentObject;

/*!
 @abstract Common means of accessing the name of all kinds of objects.
 */
- (NSString *)name;

/*!
 @abstract Recursively determines the parent that does not have a parent object.
 */
- (id)rootObject;

/*!
 @abstract The object identity.
 */
- (id)object;

@end
