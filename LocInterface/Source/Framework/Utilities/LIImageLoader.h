/*!
 @header
 LIImageLoader.h
 Created by Max Seelemann on 19.05.09.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

/*!
 @abstract The name of the error image.
 @discussion A little red rectangle with a white exclamation mark. Size: 18x16 px
 */
extern NSString *LIErrorImageName;

/*!
 @abstract The name of the warning image.
 @discussion A little yellow/orange rectangle with a black exclamation mark. Size: 18x16 px
 */
extern NSString *LIWarningImageName;

/*!
 @abstract Loads images and registers them as for a name, because they're often used or need to be cached.
 */
@interface LIImageLoader : NSObject
{
}

/*!
 @abstract Loads the image with the given name from the LocInterface bundle (only!) and registers it using name.
 @discussion after calling this method, NSImage's +imageNamed: will return exactly the loaded image.
 */
+ (void)loadImage:(NSString *)name;

@end
