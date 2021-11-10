/*!
 @header
 LTTranslationChecker.h
 Created by max on 24.02.05.

 @copyright 2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract A class that checks translations of strings and returns errors and warning that have been found.
 */
@interface LTTranslationChecker : NSObject {
}

/*!
 @abstract Calculates all translation problems for the given key object and language.
 @discussion The returned value is an NSArray of LTTranslationProblem objects.
 */
+ (NSArray *)calculateTranslationErrorsForKeyObject:(BLKeyObject *)object forLanguage:(NSString *)language withReference:(NSString *)refLanguage;

/*!
 @abstract Searches for placeholders in a string.
 @discussion Returns an NSArray of NSDictionaries containing the string of the placeholder for key "placeholder" and the range for the key "range".
 */
+ (NSArray *)extractPlaceholdersFromString:(NSString *)string;

@end
