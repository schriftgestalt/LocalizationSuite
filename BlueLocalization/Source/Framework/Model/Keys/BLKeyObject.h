/*!
 @header
 BLKeyObject.h
 Created by Max on 13.11.04.

 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLObject.h>

@class BLFileObject;

/*!
 @abstract Additional flags for key objects.

 @const BLKeyObjectAutotranslatedFlag		A flag signaling that the key object was translated using an autotranlation algorithm.
 */
enum {
	BLKeyObjectAutotranslatedFlag = 1 << 2
};

/*!
 @abstract Represents the basic unit of translation, a key/value pair.
 @discussion Each key object can hold a number of localizations for a string. No primary localization is stored inside of the key, but might appear outside. In addition to that, a key object also holds an identification string, named "key" (thus the name key object), and a comment.

 Subclasses must implement the following six methods: -objectForLanguage:, -stringForLanguage:, -setObject:forLanguage:, -languages, +isEmptyValue:, +classOfObjects.
 */
@interface BLKeyObject : BLObject {
	NSFileWrapper *_attachedMedia;
	NSString *_comment;
	BLFileObject *_fileObject;
	NSString *_key;
	NSMutableDictionary *_objects;
	NSMutableDictionary *_snapshot;
}

/*!
 @abstract Designated initializer.
 @discussion Initializes an empty key object with the given key.
 */
- (id)initWithKey:(NSString *)key;

/*!
 @abstract Returns the class of the objects stored by this class of key objects.
 @discussion Currently two implementations exists for hosting NSString and NSAttributedString objects.
 */
+ (Class)classOfObjects;

/*!
 @abstract The key of the object.
 @discussion The primary (if not only) identification method to retrieve a specific object form a set of key objects. Appart from that, the key might also be empty in some special cases. Examples for this are the occurrence in a dictionary or in a class of files having only a single key to be translated.
 */
@property (strong) NSString *key;

/*!
 @abstract The comment associated with the object.
 @discussion While this has no technical importance, it is widely used to transport additional information to a key object.
 */
@property (strong) NSString *comment;

/*!
 @abstract The file object containing the key object.
 */
@property (strong) BLFileObject *fileObject;

/*!
 @abstract All languages that this object knows.
 @discussion "Knows" is to be seen as has a value set for it, but that value might be empty. As such, the languages returned by this method always contain all non-empty languages but these are not necessarily all.
 */
- (NSArray *)languages;

/*!
 @abstract Return the object representing the localization in the given language.
 @discussion The returned object will be of the class returned by +classOfObjects, which is in turn the storage class.
 */
- (id)objectForLanguage:(NSString *)language;

/*!
 @abstract Returns the localization object for a language converted to a string.
 @discussion Subclasses should try it's best effort to convert the otherwise implementation-specific storage class to a regular string. This access is used for various kind of usages, e.g. searching within a set of key objects.
 */
- (NSString *)stringForLanguage:(NSString *)language;

/*!
 @abstract Sets an object to represent the localization in the given language.
 @discussion The passed object must be of the class returned by +classOfObjects, which is in turn the storage class.
 */
- (void)setObject:(id)object forLanguage:(NSString *)language;

/*!
 @abstract Removes an object for a given language.
 */
- (void)removeObjectForLanguage:(NSString *)language;

/*!
 @abstract Will create a snapshot of object for the language, replacing any older snapshot.
 */
- (void)snapshotLanguage:(NSString *)language;

/*!
 @abstract Returns the snapshot value for the language.
 @discussion Returns nil if no snapshot was created previously.
 */
- (id)snapshotForLanguage:(NSString *)language;

/*!
 @abstract Determines whether all languages of the object are empty.
 @discussion Checks for each language in the key, whether -isEmptyForLanguage: returns YES. If all languages are empty this method also returns YES, otherwise NO.
 */
- (BOOL)isEmpty;

/*!
 @abstract Determines whether a given language is empty.
 @discussion See +isEmptyValue: for details.
 */
- (BOOL)isEmptyForLanguage:(NSString *)language;

/*!
 @abstract Returns whether the passed value is empty or not.
 @discussion This is to be seen in the context of possible objects for languages only. This method should decide upon the object being "empty" as having no localization-relevant content. As such, a string of length zero might be interpreted as empty.
 */
+ (BOOL)isEmptyValue:(id)value;

/*!
 @abstract Compute whether an object is equal to an another one.
 @discussion This is to be seen in the context of the possible values for a language. Currently only used to compare two opjects for the -isEqual: implementation. The default implementation applies -isEqual: on the tow objects and returns the result. This method can be overridden when a custom comparison is needed.
 */
+ (BOOL)value:(id)value isEqual:(id)other;

/*!
 @abstract KVC method overridden to allow access to the language variants.
 @discussion More precisely, extends the properties available to key-value-coding by the localization variants.
 */
- (id)valueForKey:(NSString *)key;

/*!
 @abstract KVC method overridden to allow access to the language variants.
 @discussion More precisely, extends the properties available to key-value-coding by the localization variants.
 */
- (void)setValue:(id)value forKey:(NSString *)key;

/*!
 @abstract Direct access to all localized variants in the form of a dictionary.
 @discussion The returned dictionary has the language identifiers as keys and holds the objects for the values. Depending on the class of objects attribute of the class, the objects may be NSStrings or NSAttributedStrings.
 */
@property (weak, readonly) NSDictionary *strings;

/*!
 @abstract A media file attached to the key for being presented to the user.
 @discussion Objects that are attached to multiple keys will only be persisted once.
 */
@property (strong) NSFileWrapper *attachedMedia;

@end
