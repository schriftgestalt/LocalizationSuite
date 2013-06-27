/*!
 @header
 LTTranslationProblem.h
 Created by max on 28.05.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract Possible types of a translation problem.
 */
typedef enum {
	LTTranslationProblemWarning,
	LTTranslationProblemError
} LTTranslationProblemType;

/*!
 @abstract An object representing an warning or an error regarding the localization of a string.
 */
@interface LTTranslationProblem : NSObject
{
	NSString					*_description;
	NSString					*_fix;
	BLKeyObject					*_keyObject;
	NSString					*_language;
	NSString					*_referenceLanguage;
	LTTranslationProblemType	_type;
}

/*!
 @abstract The key object the problem belongs to.
 */
@property(strong, readonly) BLKeyObject *keyObject;

/*!
 @abstract The language the problem was found in.
 */
@property(strong, readonly) NSString *language;

/*!
 @abstract The language that was treated as reference (=correct) language while searching for problems.
 */
@property(strong, readonly) NSString *referenceLanguage;

/*!
 @abstract The type (=severity) of the problem found.
 @discussion See LTTranslationProblemType for possible values.
 */
@property(readonly) LTTranslationProblemType type;

/*!
 @abstract A user-presentable description of the problem.
 */
@property(strong, readonly) NSString *description;

/*!
 @abstract Returns whether the problem has a fix.
 @discussion Returns YES if the problem has a generic fix, NO otherwise.
 */
@property(readonly) BOOL hasFix;

/*!
 @abstract The suggested fix for the problem.
 @discussion This is a replacement string for the problematic translation in the key object. Use -fix for a convenient way to apply it. Returns nil if no generic fix was suggested.
 */
@property(strong, readonly) NSString *fixedValue;

/*!
 @abstract Apply the fix.
 @discussion Replaces the value for language in the keyObject with the fixed value. However, the fix will only be applied if the key object stores string values.
 */
- (void)fix;

@end

