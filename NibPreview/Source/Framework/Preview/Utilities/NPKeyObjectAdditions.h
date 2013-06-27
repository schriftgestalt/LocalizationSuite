/*!
 @header
 NPKeyObjectAdditions.h
 Created by max on 02.09.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract Addtions to BLKeyObject related to interface previews.
 */
@interface BLKeyObject (NPKeyObjectAdditions)

/*!
 @abstract Tries to retrieve a nib object ID from the objects key.
 @discussion Returns nil if no such key was found.
 */
- (NSString *)nibObjectID;

/*!
 @abstract Tries to retrieve a KVC-compliant property name from the objects key.
 @discussion Returns nil if no such name was found. Property may also be a key path!
 */
- (NSString *)propertyName;

@end
