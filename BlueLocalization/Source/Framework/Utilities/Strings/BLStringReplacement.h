/*!
 @header
 BLStringReplacement.h
 Created by Max on 10.08.05.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

/*!
 @abstract NSMutableString extensions used mainly by the BLStringsScanner.
 */
@interface NSMutableString (BLStringReplacement)

/*!
 @abstract The default replacements used by several classes in BlueLocalization.
 @discussion Basically, this quotes newline, backslashes and quotes so that the string can be written to a strings file.
 */
extern NSDictionary *BLStandardStringReplacements;

/*!
 @abstract Replaces all keys in dictionary with values.
 @discussion Replaces all occurences of every key with the according value. If reverse is YES, the proedure is inverted, trating values as keys and keys as values.
 There are no double replacements as ranges are being precomputed and replaced after that. Keys and values shouldn't be substrings of each other as the behaviour for this is undefined.
 */
- (void)applyReplacementDictionary:(NSDictionary *)dict reverseDirection:(BOOL)reverse;

/*!
 @abstract Replaces all escaped character codes with the actual characters, including the ones from BLStandardStringReplacements (which get preference).
 */
- (void)replaceEscapedCharacters;

/*!
 @abstract Replaces all composed unicode characters with an appropriate escape sequence.
 */
- (void)replaceUnescapedComposedCharacters;

@end

/*!
 @abstract String extensions used by the BLStringReplacement category of NSMutableString.
 */
@interface NSString (BLStringReplacement)

/*!
 @abstract Searches for all occurences of str.
 @return An array with NSValues holding NSRanges.
 */
- (NSArray *)rangesOfString:(NSString *)str;

@end
