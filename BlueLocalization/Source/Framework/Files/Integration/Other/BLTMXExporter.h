/*!
 @header
 BLTMXExporter.h
 Created by max on 22.01.10.
 
 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */


/*!
 @abstract Exports file objects to a TMX (XML Localization Interchange File Format) files.
 */
@interface BLTMXExporter : NSObject
{
	IBOutlet NSView					*optionsView;
}

/*!
 @abstract The export method to call from a GUI application. Will show a question sheet.
 @discussion This works just like +exportTMXFromObjects:forLanguages:andReferenceLanguage:withOptions:toPath: but instead requests the additional infomation needed from the user or fetches it from the document.
 */
+ (void)exportTMXFromObjects:(NSArray *)objects inDocument:(NSDocument<BLDocumentProtocol> *)document;


/*!
 @enum BLTMXExporterSettings
 @abstract The options that can be given to the TMX exporter.
 
 @const BLTMXExporterAllowRichText	RichText (RTF) contents will be included in the exported files.
 */
typedef enum {
	BLTMXExporterAllowRichText	= 1<<0
} BLTMXExporterSettings;

/*!
 @abstract The export method that does not require an interface.
 @discussion Writes all objects for the given language as tmx to disk. The options value is an logical or ("|") of the BLTMXExporterSettings. For possible settings, please see @link BLTMXExporterSettings BLTMXExporterSettings @/link's documentation.
 */
+ (void)exportTMXFromObjects:(NSArray *)objects withOptions:(NSUInteger)options toPath:(NSString *)path;

@end
