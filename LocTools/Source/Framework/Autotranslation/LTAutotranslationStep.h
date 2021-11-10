/*!
 @header
 LTAutotranslationStep.h
 Created by max on 26.06.09.

 @copyright 2009 Localization Suite. All rights reserved.
 */

@class LTMultipleKeyMatcher;

/*!
 @abstract A process step for autotranslating key objects.
 @discussion Using the loaded keys from LTDictionaryController, a LTMultipleKeyMatcher is created and used to find matched in a given reference language, setting the translated value for key objects that are yet empty in language language.
 */
@interface LTAutotranslationStep : BLProcessStep {
	NSString *_language;
	LTMultipleKeyMatcher *_matcher;
	NSArray *_objects;
	NSString *_reference;
}

/*!
 @abstract Creates a process step for autotranslating a set of key objects.
 */
+ (id)stepForAutotranslatingObjects:(NSArray *)objects forLanguage:(NSString *)language andReferenceLanguage:(NSString *)referenceLanguage;

@end
