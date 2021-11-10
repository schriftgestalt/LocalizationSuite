/*!
 @header
 BLGroupedKeyObject.h
 Created by Max on 27.02.08.

 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLKeyObject.h>

/*!
 @abstract A key object that forwards values of multiple key objects.
 @discussion This key object behaves like a normal key object except a few exceptions: First, the key cannot be altered. Secondy, all read properties are read from the last object in the array of masked key objects. Third, all set values (except the key) are set to all masked key objects.
 */
@interface BLGroupedKeyObject : BLKeyObject {
	NSMutableArray *_keyObjects;
}

/*!
 @abstract Designated initializer.
 */
- (id)initWithKeyObjects:(NSArray *)objects;

/*!
 @abstract Convenience allocator.
 */
+ (id)keyObjectWithKeyObjects:(NSArray *)objects;

/*!
 @abstract The key objects this one masks.
 */
@property (strong) NSArray *keyObjects;

@end
