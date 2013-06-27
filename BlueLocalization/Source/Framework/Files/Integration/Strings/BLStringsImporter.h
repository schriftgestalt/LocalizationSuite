/*!
 @header
 BLStringsImporter.h
 Created by max on 27.02.09.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

/*!
 @abstract An importer class that reads files mapping one language to another into file objects.
 @discussion Basically this is the inverse operation of BLStringsExporter.
 */
@interface BLStringsImporter : NSObject
{
	NSDocument<BLDocumentProtocol>	*_document;
}

/*!
 @abstract The import method to call from a GUI application. Will show a question sheet.
 @discussion This works just like +importStringsFromFiles:forReferenceLanguage:toObjects: but instead requests the additional infomation needed from the user or fetches it from the document.
 */
+ (void)importStringsToObjects:(NSArray *)objects inDocument:(NSDocument<BLDocumentProtocol> *)document;

/*!
 @abstract The import method that does not require an interface.
 */
+ (void)importStringsFromFiles:(NSArray *)paths forReferenceLanguage:(NSString *)referenceLanguage toObjects:(NSArray *)objects;

@end
