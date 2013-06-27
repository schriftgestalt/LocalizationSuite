/*!
 @header
 BLXLIFFExporter.h
 Created by max on 22.01.10.
 
 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */


/*!
 @abstract Exports file objects to a XLIFF (XML Localization Interchange File Format) files.
 */
@interface BLXLIFFExporter : NSObject
{
	IBOutlet NSView					*optionsView;
	
	NSDocument<BLDocumentProtocol>	*_document;
	NSArray							*_languages;
}

/*!
 @abstract The export method to call from a GUI application. Will show a question sheet.
 @discussion This works just like +exportXLIFFFromObjects:forLanguages:andReferenceLanguage:withOptions:toPath: but instead requests the additional infomation needed from the user or fetches it from the document.
 */
+ (void)exportXLIFFFromObjects:(NSArray *)objects forLanguages:(NSArray *)languages inDocument:(NSDocument<BLDocumentProtocol> *)document;


/*!
 @enum BLXLIFFExporterSettings
 @abstract The options that can be given to the XLIFF exporter.
 
 @const BLXLIFFExporterIncludeComments	Include comments of the exported object in the xliff file as a note.
 @const BLXLIFFExporterAllowRichText	RichText (RTF) contents will be included in the exported files.
 */
typedef enum {
	BLXLIFFExporterIncludeComments	= 1<<0,
	BLXLIFFExporterAllowRichText	= 1<<1
} BLXLIFFExporterSettings;

/*!
 @abstract The export method that does not require an interface.
 @discussion Writes all objects for the given language as tmx to disk. The resulting files map from the reference language to the the translated language, missing keys are left empty. For each language, one XLIFF file is created, extended by a space (" ") and the abbreviation of the language.
 
 The options value is an logical or ("|") of the BLXLIFFExporterSettings. For possible settings, please see @link BLXLIFFExporterSettings BLXLIFFExporterSettings @/link's documentation.
 */
+ (void)exportXLIFFFromObjects:(NSArray *)objects forLanguage:(NSString *)language andReferenceLanguage:(NSString *)referenceLanguage withOptions:(NSUInteger)options toPath:(NSString *)path;

@end
