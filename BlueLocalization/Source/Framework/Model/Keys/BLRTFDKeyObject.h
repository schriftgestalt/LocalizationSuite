/*!
 @header
 BLRTFDKeyObject.h
 Created by Max on 13.11.04.

 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLKeyObject.h>

/*!
 @abstract A key object holding rich text content.
 @discussion The content is stored in NSAttributedString objects.
 */
@interface BLRTFDKeyObject : BLKeyObject {
}

/*!
  @abstract Convenience allocator.
  */
+ (id)keyObjectWithKey:(NSString *)key;

@end
