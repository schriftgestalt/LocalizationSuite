/*!
 @header
 NPFontAdditions.h
 Created by max on 18.07.08.

 @copyright 2008-2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract NSFont additions processing ibtool output
 */
@interface NSFont (NPFontAdditions)

/*!
 @abstract parses a color dictionary returned from ibtool and converts it into an NSFont
 */
+ (NSFont *)fontFromIBToolDictionary:(NSDictionary *)dict;

@end
