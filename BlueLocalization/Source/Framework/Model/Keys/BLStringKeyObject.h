/*!
 @header
 BLStringKeyObject.h
 Created by Max on 13.11.04.
 
 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLKeyObject.h>

/*!
 @abstract A key object holding plain text content.
 @discussion The content is stored in NSString objects.
 */
@interface BLStringKeyObject : BLKeyObject
{
    NSMutableDictionary *_strings;
}

/*!
 @abstract Convenience allocator.
 */
+ (id)keyObjectWithKey:(NSString *)key;

@end
