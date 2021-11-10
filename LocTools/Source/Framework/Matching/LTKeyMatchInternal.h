/*!
 @header
 LTKeyMatchInternal.h
 Created by max on 26.06.09.

 @copyright 2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract Internal methods of LTDictionaryMatch used by LTDictionaryMatcher.
 */
@interface LTKeyMatch (LTKeyMatchInternal)

- (id)initWithKeyObject:(BLKeyObject *)match matchPercentage:(float)percentage forTargetLanguage:(NSString *)language actualTargetLanguage:(NSString *)actualLanguage andMatchLanguage:(NSString *)matchLanguage;

@end