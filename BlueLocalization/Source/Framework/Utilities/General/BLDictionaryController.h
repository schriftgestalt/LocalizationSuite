/*!
 @header
 BLDictionaryController.h
 Created by max on 16.08.06.

 @copyright 2009 Localization Suite. All rights reserved.
 */

@interface BLDictionaryController : NSObject {
	NSMutableArray *_dictionaries;
	NSMutableArray *_documents;
	NSMutableArray *_keys;
	BOOL _useDocuments;
}

/*!
 @abstract Returns the single shared dictionary controller.
 */
+ (id)sharedInstance;

/*!
 @abstract The available keys according to settings.
 @discussion This always returns a different autoreleased NSArray per call. This means it's save to use this array in a multithreaded context while new dictionaries or documents can be added or removed. This property is KVO-observable.
 */
- (NSArray *)availableKeys;

/*!
 @abstract Returns an array of BLDictionaryDocument's.
 */
- (NSArray *)loadedDictionaries;

/*!
 @abstract Loads the dictionary file at the given url.
 @discussion The loaded file will be added as BLDictionaryDocument to the loaded dictionaries.
 */
- (void)registerDictionaryAtURL:(NSURL *)url;

/*!
 @abstract Removes a dictionary from the loaded ones.
 */
- (void)unregisterDictionary:(BLDictionaryDocument *)aDocument;

/*!
 @abstract An array of BLDocumentProtocol-conforming documents currently registered.
 */
- (NSArray *)loadedDocuments;

/*!
 @abstract Returns whether to use registered documents.
 @discussion The return value is YES, if keys from registered documents are included in the -availableKeys array, NO otherwise.
 */
- (BOOL)useDocuments;

/*!
 @abstract Set whether to use registered documents.
 */
- (void)setUseDocuments:(BOOL)flag;

/*!
 @abstract Register an already opened document.
 @discussion In addition to conforming to the BLDocumentProtocol, the given document has to implement a -bundles method, returning the BLBundleObjects in the document. Throws if these conditions are not met.
 */
- (void)registerDocument:(id)aDocument;

/*!
 @abstract Unregister an document from the controller, e.g. when it's closed.
 */
- (void)unregisterDocument:(id)aDocument;

@end
