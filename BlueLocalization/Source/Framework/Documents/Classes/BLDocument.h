/*!
 @header
 BLDocument.h
 Created by Max Seelemann on 07.05.10.

 @copyright 2010 the Localization Suite Foundation. All rights reserved.
 */

#import <Cocoa/Cocoa.h>
#import <BlueLocalization/BLDocumentProtocol.h>

/*!
 @abstract BLDocument preference key: Database should be saved compressed.
 @discussion NSNumber containing a BOOL. Whether the database should be written in a compressed fashion or not.
 */
extern NSString *BLDocumentSaveCompressedKey;

/*!
 @abstract BLDocument preference key: The path where the document has been last saved.
 @discussion NSString. Per-user preference. When saving a document, this preference key will be filled with the path. A app can then check this for changes after re-opening.
 */
extern NSString *BLDocumentLastSavePathKey;

/*!
 @abstract BLDatabaseDocument preference key: Last folder in an open panel.
 @discussion NSString. Per-user preference. The most recently used folder chosen by the user for opening or exporting files.
 */
extern NSString *BLDocumentOpenFolderKey;

@class BLDocumentPreferences;

/*!
 @abstract Abstract base class for all concrete document classes in BlueLocalization framework.
 @discussion Features a abstract dummy implementation of BLDocumentProtocol and customizes the way the documents are written to disk.
 */
@interface BLDocument : NSDocument <BLDocumentProtocol> {
	NSMutableDictionary *_preferences;
	NSMutableDictionary *_userPreferences;

	BLDocumentPreferences *_preferencesProxy;
}

/*!
 @abstract Settings of the user that affect the working of some methods.
 @discussion This will actually return a proxy object that automatically splits between project and user settings.
 */
@property (weak, readonly) NSMutableDictionary *preferences;

/*!
 @abstract The default settings when creating a new document.
 */
+ (NSDictionary *)defaultPreferences;

/*!
 @abstract The keys of the preferences that should be stored per-user instead of per-project.
 */
+ (NSArray *)userPreferenceKeys;

@end
