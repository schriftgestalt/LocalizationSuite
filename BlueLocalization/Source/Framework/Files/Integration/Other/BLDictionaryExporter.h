/*!
 @header
 BLDictionaryExporter.h
 Created by max on 20.02.10.
 
 @copyright 2004-2010 the Localization Suite. All rights reserved.
 */


/*!
 @abstract Exports objects as a dictionary.
 */
@interface BLDictionaryExporter : NSObject
{
	IBOutlet NSView	*optionsView;
}

/*!
 @abstract The export method to call from a GUI application. Will show a question sheet.
 @discussion Presents the user a sheet with some options and a selection for the path, and then exports the given objects as a dictionary file. Depending on the user's options, The dictionary might be reduced to the passed or not. When updating is set to YES, not a new dictionary will be created but instead an existing one will be extended.
 */
+ (void)exportDictionaryFromObjects:(NSArray *)objects forLanguages:(NSArray *)languages inDocument:(NSDocument<BLDocumentProtocol> *)document updatingDictionary:(BOOL)updating;

@end
