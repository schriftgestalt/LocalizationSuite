/*!
 @header
 BLStringsExporter.h
 Created by max on 27.02.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

/*!
 @abstract The file extension of a strings file.
  Namely "strings".
 */
extern NSString *kStringsPathExtension;

/*!
 @abstract The name of the strings file (excluding the extension) when writing to a single file but include others.
 @discussion Namely "Localizable".
 */
extern NSString *BLStringsExporterExportFileName;

/*!
 @abstract An exporter class that writes file objects to a hierarchy of strings and other files.
 */
@interface BLStringsExporter : NSObject {
	IBOutlet NSView *optionsView;

	NSDocument<BLDocumentProtocol> *_document;
	NSArray *_languages;
}

/*!
 @abstract The export method to call from a GUI application. Will show a question sheet.
 @discussion This works just like +exportStringsFromObjects:forLanguages:andReferenceLanguage:withOptions:toPath: but instead requests the additional infomation needed from the user or fetches it from the document.
 */
+ (void)exportStringsFromObjects:(NSArray *)objects forLanguages:(NSArray *)languages inDocument:(NSDocument<BLDocumentProtocol> *)document;

/*!
 @enum BLStringsExporterSettings
 @abstract The options that can be given to the exporter.

 @const BLStringsExporterIncludeComments	The resulting strings files will include all comments.
 @const BLStringsExporterMissingStringsOnly	The resulting strings files will contain only empty strings.

 @const BLStringsExporterSeparateFiles		The strings are not merged into a single big file but split up.
 @const BLStringsExporterIncludeOthers		Files that cannot be exported as strings (e.g. rtf) are exported as well.
 @const BLStringsExporterGroupByBundle		All exported files will be split by their containing bundle names.
 */
typedef enum {
	BLStringsExporterIncludeComments = 1 << 0,
	BLStringsExporterMissingStringsOnly = 1 << 4,

	BLStringsExporterSeparateFiles = 1 << 1,
	BLStringsExporterIncludeOthers = 1 << 2,
	BLStringsExporterGroupByBundle = 1 << 3
} BLStringsExporterSettings;

/*!
 @abstract The export method that does not require an interface.
 @discussion Writes all objects for the given language as strings files to disk. The resulting files map from the reference language to the the translated language, missing keys are left empty. The result at path will be either a file or a folder depending on the settings. In both cases it is extended by a space (" ") and the abbreviation of the language.

 The options value is an logical or ("|") of the BLStringsExporterSettings. For possible settings, please see @link BLStringsExporterSettings BLStringsExporterSettings @/link's documentation.

 Please note a few things: Ths method does NOT check for name duplicates. If you don't group files by bundle and have separate files activated then multiple Localizabale.strings file will be overwritten. It is not defined which one will be written to disk. This also goes for grouping by bundle: if two bundles have the same name, only one will be in the result!
 */
+ (void)exportStringsFromObjects:(NSArray *)objects forLanguage:(NSString *)language andReferenceLanguage:(NSString *)referenceLanguage withOptions:(NSUInteger)options toPath:(NSString *)path;

@end
