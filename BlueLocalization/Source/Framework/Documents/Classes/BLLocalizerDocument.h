/*!
 @header
 BLLocalizerDocument.h
 Created by Max Seelemann on 28.05.09.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLDocument.h>
#import <BlueLocalization/BLDictionaryDocument.h>

/*!
 @abstract A basic localizer storage document that does all the data handling but has no interface support whatsoever.
 @discussion This document basically acts as read-only version. Which means, changes to data like localizations can be made, but no root properties (like bundles, languages, etc) should be changed. To add user interaction or other custom functionality, override this class.
 */
@interface BLLocalizerDocument : BLDocument
{
    NSArray				*_bundles;
	BLProcessManager	*_processManager;
	NSDictionary		*_properties;
}

/*!
 @abstract Returns the document's process manager.
 */
- (BLProcessManager *)processManager;

/*!
 @abstract The properties of the document.
 @discussion See BLLocalizerFile for details about possible keys and values.
 */
- (NSDictionary *)properties;

/*!
 @abstract The bundle objects of the document.
 */
- (NSArray *)bundles;

/*!
 @abstract The languages contained in the document.
 */
- (NSArray *)languages;

/*!
 @abstract The reference language of the document.
 */
- (NSString *)referenceLanguage;

/*!
 @abstract The dictionary shipped alongside the localizer document.
 */
- (BLDictionaryDocument *)embeddedDictionary;

@end
