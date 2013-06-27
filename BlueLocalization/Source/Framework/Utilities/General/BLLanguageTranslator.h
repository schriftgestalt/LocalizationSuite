/*!
 @header
 BLLanguageTranslator.h
 Created by Max Seelemann on 04.08.06.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

/*!
 @abstract A class that transfroms language names into identifiers and vice versa.
 @discussion Internally, NSLocale is heavily used, caches are created and if no direct match is found, various things are tried to get a identifier.
 */
@interface BLLanguageTranslator : NSObject

/*!
 @abstract Returns whether the given identifier is a valid language identifier.
 */
+ (BOOL)isLanguageIdentifier:(NSString *)language;

/*!
 @abstract Generates the identifier for a language.
 @discussion The argument given can be both - a language name or a identifier. There is absolutely no difference between these two arguments.
 @return A string containing an identifier or nil, if no such was found.
 */
+ (NSString *)identifierForLanguage:(NSString *)language;

/*!
 @abstract Generates the description for a language.
 @discussion The argument given can be both - a language name or a identifier. There is absolutely no difference between these two arguments.
 @return A string containing the english name of the language or nil, if no such was found.
 */
+ (NSString *)descriptionForLanguage:(NSString *)language;

/*!
 @abstract Generates the description for the passed languages.
 @discussion Using descriptionForLanguage: all objects will be replaced by a matchting description. The order is retained, languages without a description will be omitted.
 */
+ (NSArray *)descriptionsForLanguages:(NSArray *)languages;

/*!
 @abstract Returns all available identifiers.
 @discussion Basically this is the list of all available language and country codes in Mac OS X. Will contain a few hundred items.
 */
+ (NSArray *)allLanguageIdentifiers;

/*!
 @abstract Returns a NSLocale for a given language string.
 @discussion The argument given can be both - a language name or a identifier. There is absolutely no difference between these two arguments.
 */
+ (NSLocale *)localeForLanguage:(NSString *)language;

/*!
 @abstract Converts a language identifier from a RFC 4646 identifier.
 @discussion If the conversion is possible, this method returns a string holding an internally usable ISO language code. Otherwise the result is nil.
 */
+ (NSString *)languageIdentifierFromRFCLanguage:(NSString *)language;

/*!
 @abstract Converts language identifiers.
 @discussion If the conversion is possible, this method returns a string holding an RFC4646 language code, which is generated from a given ISO language code.
 */
+ (NSString *)RFCLanguageFromLanguageIdentifier:(NSString *)identifier;

@end


/*!
 @abstract Additons to NSString by BLLanguageTranslator.
 */
@interface NSString (BLLanguageTranslator)

/*!
 @abstract Convenience method treating the string as a language and returning it's description.
 @discussion Basically this is just a forward to -descriptionForLanguage: of BLLanguageTranslator.
 */
@property(readonly) NSString *languageDescription;

/*!
 @abstract Convenience method treating the string as a language and returning it's identifier.
 @discussion Basically this is just a forward to -identifierForLanguage: of BLLanguageTranslator.
 */
@property(readonly) NSString *languageIdentifier;

@end



/*!
 @abstract The registered names of the value transformers with which it can be used in bindings.
 */
extern NSString *BLLanguageNameValueTransformerName;
extern NSString *BLLanguageIdentifierValueTransformerName;

/*!
 @abstract A value transfromer that translates language identifiers to user-readable strings and vice versa.
 @discussion Transfromation examples are "en" to "English" or "de" to "German" and back. For the tranformations, @link BLLanguageTranslator BLLanguageTranslator @/link is being used. This transformer is always registered automatically opon loading the framework and has the name "LanguageName". The value transfromer can be used with the name BLLanguageValueTransformerName.
 In addition, a transformer with the name "LanguageIdentifier" is registered that is the reverse of "Language Name".
 */
@interface BLLanguageValueTransformer : NSValueTransformer

@property(nonatomic) BOOL isReversed;

@end

