/*!
 @header
 BLPathCreator.h
 Created by Max on 14.11.04.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

@class BLFileObject;
@protocol BLDocumentProtocol;

/*!
 @abstract Global constant holding the path extension of a language folder, namely "lproj".
 */
extern NSString *BLLanguageFolderPathExtension;

/*!
 @abstract An object that transfroms paths, but mainly creates the paths needed to access the files referenced by a document.
 @discussion Here will follow several definitions that will be used in the following method descriptions.

 <b>Language Name</b>: Depending on the namingStyle property of a bundle, the name of a language is the name of the language's ".lproj" folder in the given bundle. Example: Given the brazilian portuguese langauge, in the short naming style the name would be "pt_BR". In the long naming style it would be "Brazilian Portuguese". However, these long names are not only discouraged but also more unspecific. Therefore, in the mixed naming style, long names which contain either spaces (" ") or underscores ("_") are abbreviated to identifiers. In the case of brazillian portuguese, the short identifier would be used.

 <b>File Path</b>: A file path basically consists of three parts: the bundle portion, the language folder and the file portion. The bundle path is just the path to the folder which contains the .lproj folders, the relative file path is the path of the file inside this .lproj folder (and therefor most of the time just a single path component). Note that the language folder name is not contained in both paths. This is because when giving a language, the folder name can be generated.

 <b>Bundle Path</b>: The bundle path is the bundle portion of a file path. All objects in BlueLocalization are organized with a bundle as root, it is the major splitting of projects. However, when not contained in a file path, the bundle path can come in two flavours. Either it is relative or absolute. The latter one is always the case woth file paths. The first one is a standard relative path as seen from the document it belongs to.
 */
@interface BLPathCreator : NSObject {
	NSDocument<BLDocumentProtocol> *_document;
}

/*!
 @abstract Designated initializer.
 @discussion Use this method if you want to return a path creator for a BLDocumentProtocol object.
 */
- (id)initWithDocument:(NSDocument<BLDocumentProtocol> *)document;

/*!
 @abstract Returns the language of a path.
 @discussion Scans a given path for an .lproj folder and returns the language identifier by using it's name as description. Returns nil if no language is found. See class description for details about paths.
 */
+ (NSString *)languageOfFileAtPath:(NSString *)path;

/*!
 @abstract Scans a given path for an .lproj folder and returns it's name.
 @discussion See class description for details about paths.
 */
+ (NSString *)exactLanguageOfFileAtPath:(NSString *)path;

/*!
 @abstract Returns the proposed name of a language for a given naming style.
 @discussion This takes into account the setting of the bundle - to either use identifiers, long names or both. When the bundles naming style is BLIdentifiersAndDescriptionsNamingStyle, the long name is returned if the description does not contain any spaces (" ") or underscores ("_"), otherwise the identifier is used. See class description for details about paths.
 */
+ (NSString *)languageNameForLanguage:(NSString *)language withNamingStyle:(BLNamingStyle)style;

/*!
 @abstract Returns the real name of the language folder at a given bundle path.
 @discussion This takes into account the real existing language folder, if it exists. Returns the input language otherwise. See class description for details about paths.
 */
+ (NSString *)languageNameForLanguage:(NSString *)language atBundlePath:(NSString *)path;

/*!
 @abstract Replaces the occurence of a language in a path with another language.
 @discussion This method tries to find an occurrence of the given old language, using both its identifier and description. If one is found, it is replaced with the new languages name as set in the bundle settings. See languageNameForLanguage:inBundle: for more details. See class description for details about paths.
 */
+ (NSString *)replaceLanguage:(NSString *)oldLanguage inPath:(NSString *)path withLanguage:(NSString *)newLanguage bundle:(BLBundleObject *)bundle;

/*!
 @abstract Returns the bundle file path portion of a full path.
 @discussion See class description for details about paths.
 */
+ (NSString *)bundlePartOfFilePath:(NSString *)filePath;

/*!
 @abstract Returns the relative file path portion of a full path.
 @discussion See class description for details about paths.
 */
+ (NSString *)relativePartOfFilePath:(NSString *)filePath;

/*!
 @abstract Computes the relative path between two paths.
 @discussion Returns the relative path that has to be traversed to get from "fromPath" to "toPath".
 */
+ (NSString *)relativePathFromPath:(NSString *)fromPath toPath:(NSString *)toPath;

/*!
 @abstract Computes the absolute path from a relative path and a full path.
 @discussion Returns the full path that would result if the relative path "relPath" was traversed originating at "fromPath".
 */
+ (NSString *)fullPathWithRelativePath:(NSString *)relPath fromPath:(NSString *)fromPath;

/*!
 @abstract Returns the absolute path of a bundle.
 @discussion See class description for details about paths.
 */
- (NSString *)fullPathForBundle:(BLBundleObject *)bundle;

/*!
 @abstract Returns the relative path of a bundle as seen from the document.
 @discussion See class description for details about paths.
 */
- (NSString *)relativePathForBundle:(BLBundleObject *)bundle;

/*!
 @abstract Converts a relative bundle path into an absolute path.
 @discussion See class description for details about paths.
 */
- (NSString *)fullPathOfDocumentRelativePath:(NSString *)path;

/*!
 @abstract Converts an absolute bundle path into a relative path.
 @discussion See class description for details about paths.
 */
- (NSString *)documentRelativePathOfFullPath:(NSString *)path;

/*!
 @abstract Calculates the full path of a file in a specific language.
 @discussion This method does nothing else than checking for the real path of the containing bundle and returns the real path of the language folder plus the file path. If the bundle path does not exist, the path where the file should be found is returned. This can be used to create written copies of bundles in the database. See class description for details about paths.
 */
- (NSString *)absolutePathForFile:(BLFileObject *)file andLanguage:(NSString *)language;

/*!
 @abstract Returns the ideal path for a language folder in a bundle.
 @discussion The returned path does not have to be a real path, it can be the real path of a bundle plus the language folder named by the naming style of the containing bundle. This method also returns a path if the bundle does not exist at that location. See class description for details about paths.
 */
- (NSString *)pathForFolderOfLanguage:(NSString *)language inBundle:(BLBundleObject *)bundle;

/*!
 @abstract Returns the actual real path for a language folder in a bundle, if it exists.
 @discussion The returned path is always a real path that can be used. In contrast to pathForFolderOfLanguage:inBundle:, the returned path might have a different naming style that the bundle. When working on files, this method should be used to ensure that user-specific namings are reflected. If the bundle path given by bundle does not exist, nil is returned. See class description for details about paths.
 */
- (NSString *)realPathForFolderOfLanguage:(NSString *)language inBundle:(BLBundleObject *)bundle;

@end
