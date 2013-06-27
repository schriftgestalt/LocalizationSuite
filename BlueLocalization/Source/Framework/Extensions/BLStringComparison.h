/*!
 @header
 BLStringComparisson.h
 Created by Max on 13.05.09.
 
 @copyright 2004-2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract Extension for NSString to make virtually all objects comparable.
 */
@interface NSObject (BLStringComparison)

/*!
 @abstract Designated comparison operator.
 @discussion This currently converts all mutable strings to strings and compares these.
 */
- (NSComparisonResult)compareAsString:(id)other;

@end

/*!
 @abstract Sophisticated string comparisons.
 */
@interface NSString (BLStringComparison)

/*!
 @abstract Compares the string with another one numerically.
 @discussion Recognizes numbers and compares their values before comparing the rest. E.g: "abc-5-blah" is smaller than "abc-10-blah".
 */
- (NSComparisonResult)naturalCompare:(NSString *)aString;

/*!
 @abstract Compares the string with another one hexadecimal.
 @discussion Interpretes the strings as hex numbers (containing other characters).
 */
- (NSComparisonResult)hexanumericalCompare:(NSString *)aString;

@end