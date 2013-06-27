/*!
 @header
 LTKeyMatch.h
 Created by max on 16.08.06.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract An object representing a match result with a key object from a dictionary.
 */
@interface LTKeyMatch : NSObject
{
    NSString    *_actualTargetLanguage;
    NSString    *_targetLanguage;
    BLKeyObject *_object;
    float       _percentage;
    NSString    *_matchLanguage;
}

/*!
 @abstract The key object the match was found in.
 */
- (BLKeyObject *)keyObject;

/*!
 @abstract The language for which the match was found.
 */
- (NSString *)targetLanguage;

/*!
 @abstract The language in which the match was actually found.
 @discussion If a match is claculated for a language like pt_BR but only pt is available in the matchable keys, the actual target language will be the more general language name.
 */
- (NSString *)actualTargetLanguage;

/*!
 @abstract The language the match was found in.
 */
- (NSString *)matchLanguage;

/*!
 @abstract The quality of the match in percent.
 */
- (float)matchPercentage;

/*!
 @abstract The match percentage as a colored string.
 @discussion Returns a formatted and colored percentage string. Exactly 100% gives a green, above or eqal to 50% a orange and percentages below return a red string.
 */
- (NSAttributedString *)percentageString;

/*!
 @abstract Convenience accessor returning the matched value.
 */
- (NSString *)matchedValue;

/*!
 @abstract Convenience accessor returning the according translated value.
 @discussion Uses the actual target language, if present.
 */
- (NSString *)targetValue;

/*!
 @abstract Compare with a dictionary match.
 */
- (BOOL)isEqual:(id)object;

@end
