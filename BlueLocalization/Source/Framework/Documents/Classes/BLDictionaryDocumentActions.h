/*!
 @header
 BLDictionaryDocumentActions.h
 Created by Max Seelemann on 24.01.10.
 
 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLDictionaryDocument.h>

/*!
 @abstract Common actions performed on or by a dictionary document.
 */
@interface BLDictionaryDocument (BLDictionaryDocumentActions)

/*!
 @abstract Applies the filter settings on the given set of key objects.
 @discussion Returns only those key objects that match the set filter settings. Whenever a key object would need to be modified, a copy is created and returned instead.
 */
- (NSArray *)filterKeys:(NSArray *)someKeys;

/*!
 @abstract Applies the normalization settings on the given set of key objects.
 @discussion If normalization is disabled or no language is set, this is the identity function. This method returns BLStringKeyObjects only, RTF data will be converted.
 */
- (NSArray *)normalizeKeys:(NSArray *)someKeys;

/*!
 @abstract Sets the key objects of the dictionary.
 @discussion This method first filters the objects using -filterKeys: and then normalizes all keys using -normalizeKeys:.
 */
- (void)setKeys:(NSArray *)newKeys;

/*!
 @abstract Adds the key objects to the dictionary.
 @discussion This method first filters the objects using -filterKeys: and then normalizes all keys using -normalizeKeys:.
 */
- (void)addKeys:(NSArray *)someKeys;

/*!
 @abstract Adds a couple of languages.
 @discussion Beware that, if ignoreFilter is set to NO and language filtering is active for the document, this method simply ignores the added languages.
 */
- (void)addLanguages:(NSArray *)someLanguages ignoreFilter:(BOOL)ignore;

/*!
 @abstract Removes a couple of languages.
 @discussion Beware that, if filter is set to YES, this method applies all appropriate filter settings on the keys in this dictionary. The filter will be adjusted to accomondate the changes languages.
 */
- (void)removeLanguages:(NSArray *)someLanguages applyFilter:(BOOL)filter;

/*!
 @abstract The path extensions a dictionary can import.
 @discussion This is just a forward from BLDictionaryFileImportStep's +availablePathExtensions.
 */
+ (NSArray *)pathExtensionsForImport;

/*!
 @abstract Importes a set of given files.
 @discussion Creates an asynchronous process.
 */
- (void)importFiles:(NSArray *)files;

@end
