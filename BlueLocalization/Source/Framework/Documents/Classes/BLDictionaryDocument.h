/*!
 @header
 BLDictionaryDocument.h
 Created by Max Seelemann on 28.06.09.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLDocument.h>

/*!
 @abstract Determines whether language filtering is applied or not.
 @discussion This isetting is to ensure that whenever the dictionary will be modified externaly or internally, no new languages can be introduced. This is good for keeping a bi-lingual dictionary straight. Refers to a NSNumber object containing a BOOL value.
 */
extern NSString *BLDictionaryLimitLanguagesFilterSetting;

/*!
 @abstract Determines whether the dictionary will be normalized.
 @discussion Basically this just reduces the number of key objects and basically minimizes size. However, this may also loose some content. Refers to a NSNumber object containing a BOOL value.
 */
extern NSString *BLDictionaryNormalizeFilterSetting;

/*!
 @abstract If normalizing, this is the language it's performed on.
 @discussion Refers to a NSString of a language identifier.
 */
extern NSString *BLDictionaryNormLanguageFilterSetting;

/*!
 @abstract A basic dictionary storage document that does all the data handling but has no interface support whatsoever.
 @discussion To add user interaction or other custom functionality, override this class. This is the only BlueLocalization document class that does not fully implement the BLDocumentProtocol - as it's simple key-object-only data model does not support files and bundles. Therefore -pathCreator and -referenceLanguage will always return nil.
 */
@interface BLDictionaryDocument : BLDocument
{
	NSMutableDictionary	*_filterSettings;
	NSArray				*_keyObjects;
	NSLock				*_keysLock;
	NSMutableArray		*_languages;
	BLProcessManager	*_processManager;
}

/*!
 @abstract Returns the document's process manager.
 */
- (BLProcessManager *)processManager;

/*!
 @abstract The key objects of the document.
 @discussion Use the accessor methods defined in the BLDictionaryDocumentActions category, to modify this property.
 */
@property(weak, readonly) NSArray *keys;

/*!
 @abstract The languages contained in the document.
 @discussion Use the accessor methods defined in the BLDictionaryDocumentActions category, to modify this property.
 */
@property(readonly) NSArray *languages;

/*!
 @abstract The settings for the contained key objects.
 @discussion Depending on the concrete settings, several filters can be applied. Here's a short overview:
 - Language Filter: If BLDictionaryLimitLanguagesFilterSetting is YES, all languages except the ones in BLDictionaryLimitedLanguagesFilterSetting should be removed from the key objects.
 - Normalization: If the value for BLDictionaryNormalizeFilterSetting is YES, then the number of keys is minimized by merging identical strings of the lanuage in BLDictionaryNormLanguageFilterSetting.
 */
@property(strong) NSDictionary *filterSettings;

@end

/*!
 @abstract Methods of BLDocumentProtocol that are NOT supported by BLDictionaryDocument.
 */
@interface BLDictionaryDocument (BLDictionaryDocumentUnsupported)

/*!
 @abstract Always returns nil, see class description for details.
 */
- (BLPathCreator *)pathCreator;

/*!
 @abstract Always returns nil, see class description for details.
 */
- (NSString *)referenceLanguage;

@end
