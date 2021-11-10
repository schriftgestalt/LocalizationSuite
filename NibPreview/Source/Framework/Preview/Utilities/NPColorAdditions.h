/*!
 @header
 NPColorAdditions.h
 Created by max on 18.07.08.

 @copyright 2008-2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract NSColor additions processing ibtool output
 */
@interface NSColor (NPColorAdditions)

/*!
 @abstract parses a color string returned from ibtool and converts it into an NSColor
 */
+ (NSColor *)colorFromIBToolString:(NSString *)string;

@end
