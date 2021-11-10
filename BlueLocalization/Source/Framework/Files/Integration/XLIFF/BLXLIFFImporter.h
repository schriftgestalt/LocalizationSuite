/*!
 @header
 BLXLIFFImporter.h
 Created by max on 22.01.09.

 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */

/*!
 @abstract An importer class that reads XLIFF files into file objects.
 */
@interface BLXLIFFImporter : NSObject

/*!
 @abstract The import method to call from a GUI application. Will show a question sheet.
 @discussion This works just like +importStringsFromFiles:forReferenceLanguage:toObjects: but instead requests the additional infomation needed from the user or fetches it from the document.
 */
+ (void)importXLIFFToObjects:(NSArray *)objects inDocument:(NSDocument<BLDocumentProtocol> *)document;

/*!
 @abstract The import method that does not require an interface.
 @discussion Only the target language will be imported, the source language will be completely ignored!
 */
+ (void)importXLIFFFromFile:(NSString *)path toObjects:(NSArray *)objects;

@end
