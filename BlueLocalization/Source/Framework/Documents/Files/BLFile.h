/*!
 @header
 BLFile.h
 Created by Max Seelemann on 05.10.07.

 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */

/*!
 @abstract Options possible to be set during export of a Localizer or Dictionary file.
 @discussion Subclasses may define additional options, but these options must use only the bits above 15, namely 1<<16 and up!

 @const BLFileActiveObjectsOnlyOption	Only objects that respond to -isActive with YES will be exported.
 @const BLFileClearChangedValuesOption	The -changedValues property of all objects will be cleared during export.
 */
typedef enum {
	BLFileActiveObjectsOnlyOption = 1 << 0,
	BLFileClearChangedValuesOption = 1 << 1
} BLFileExportOptions;

/*!
 @abstract The languages contained in BLFile.
 @discussion (readwrite) This is a property key for a BLFile, representing a NSArray of languages in a file. Required for all file subclasses.
 */
extern NSString *BLLanguagesPropertyName;

/*!
 @abstract The reference language in a BLFile.
 @discussion (readwrite) This is a property key for a BLFile, representing a NSString of the reference language of the file. As this is not required/allowed in all file classes, this property cannot required by the BLFile class. See subclasses for details.
 */
extern NSString *BLReferenceLanguagePropertyName;

/*!
 @abstract The preferences of the file.
 @discussion (readwrite) Represented by a NSMutableDictionary, the user-defined behaviour changes when working with the file contents.
 */
extern NSString *BLPreferencesPropertyName;

/*!
 @abstract The per-user preferences of the file.
 @discussion (readwrite) A NSMutableDictionary, mapping from user name to a NSMutableDictionary of per-user settings, additional specific user-defined behaviour changes when working with this file.
 */
extern NSString *BLUserPreferencesPropertyName;

/*!
 @abstract This is an abstract class for all files formats owned by the BlueLocalization framework.
 @discussion Currently there are two subclasses - BLLocalizerFile and BLDictionaryFile - see those class descriptiosn for details.
 */
@interface BLFile : NSObject

/*!
 @abstract Returns the path extension for the file created by the class.
 */
+ (NSString *)pathExtension;

/*!
 @abstract The properties that must be set to the properties dictionary when creating a file.
 */
+ (NSArray *)requiredProperties;

/*!
 @abstract Creates a file wrapper containing the file.
 @discussion This is also the primary overridepoint for subclasses. For possible options see BLFileExportOptions. Subclasses may define additional options. Currently the only property supported by the abstract class is BLLanguagesPropertyName.
 */
+ (NSFileWrapper *)createFileForObjects:(NSArray *)objects withOptions:(NSUInteger)options andProperties:(NSDictionary *)properties;

/*!
 @abstract Reads a file wrapper containing the file.
 @discussion Primitive. Returns the objects contained in the file. This is also the primary overridepoint for subclasses. The only property returned by the abstract class is currently BLLanguagesPropertyName.
 */
+ (NSArray *)objectsFromFile:(NSFileWrapper *)wrapper readingProperties:(NSDictionary **)properties;

@end