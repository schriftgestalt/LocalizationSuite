/*!
 @header
 NPLazyStringValue.h
 Created by max on 18.07.08.

 @copyright 2008-2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract An NSValue object that con be initialized with an string.
 @discussion The input string will be given in ibtool's output format, which
 matches the format returned by NSStringFrom*() in AppKit. Basically just
 curly brackets {} containing values separated by commas. The other benefit
 is that this value object decodes common generic values, namely ranges,
 points, sizes and rectangles, lazily. This means, depending on what the caller
 is expecting, a valid value is always returned without throwing exceptions.
 */
@interface NPLazyStringValue : NSValue {
	NSString *_string;
}

/*!
 @abstract Creates an instance, initializing it with the given string.
 @see -initWithString:
 */
+ (id)valueWithString:(NSString *)string;

/*!
 @abstract Initializes a previously allocated instance with the given string.
 @see +valueWithString:
 */
- (id)initWithString:(NSString *)string;

/*!
 @abstract Tries to convert the init string into a NSSize value.
 @discussion This method uses NSSizeFromString, and thus returning an NSZeroSize structure,
 if the given string is not compatible.
 @return The value converted to an NSSize struct.
 */
- (NSSize)sizeValue;

/*!
 @abstract Tries to convert the init string into a NSPoint value.
 @discussion This method uses NSPointFromString, and thus returning an NSZeroPoint structure,
 if the given string is not compatible.
 @return The value converted to an NSPoint struct.
 */
- (NSPoint)pointValue;

/*!
 @abstract Tries to convert the init string into a NSRect value.
 @discussion This method uses NSRectFromString, and thus returning an NSZeroRect structure,
 if the given string is not compatible.
 @return The value converted to an NSRect struct.
 */
- (NSRect)rectValue;

/*!
 @abstract Tries to convert the init string into a NSRange value.
 @discussion This method uses NSRangeFromString, and thus returning an structure where both
 components are set to 0, if the given string is not compatible.
 @return The value converted to an NSRange struct.
 */
- (NSRange)rangeValue;

@end
