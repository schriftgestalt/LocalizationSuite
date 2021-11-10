//
//  LIPreferences.h
//  LocInterface
//
//  Created by Max Seelemann on 02.11.10.
//  Copyright 2010 Localization Suite. All rights reserved.
//

/*!
 @abstract Abstract base class that can be used directly to enable standard preference management.
 */
@interface LIPreferences : NSWindowController

/*!
 @abstract Override if you want the preferences to init with a window.
 */
- (NSString *)windowNibName;

/*!
 @abstract Returns the default preferences.
 */
+ (id)sharedInstance;

/*!
 @abstract Opens the preference window, if present.
 */
- (void)open;

/*!
 @abstract Closes the preference window, if present and open.
 */
- (void)close;

/*!
 @abstract An array that contains all currently open documents. Bindable.
 */
@property (strong, readonly) NSArray *openDocuments;

/*!
 @abstract Whether more than one document is currently open. Bindable.
 */
@property (readonly) BOOL multipleOpenDocuments;

/*!
 @abstract If any documents are open, the selected one. Bindable.
 */
@property (strong) BLDocument *selectedDocument;

/*!
 @abstract Copies default settings into the document.
 */
- (void)initDocument:(BLDocument *)document;

/*!
 @abstract Register a document when it has been opened.
 */
- (void)registerDocument:(BLDocument *)document;

/*!
 @abstract Unregister a document after closing. Will persist settings from the document for reuse on new documents.
 */
- (void)unregisterDocument:(BLDocument *)document;

/*!
 @abstract An array of all installed developer tools.
 @discussion Returns an array of dictionaries: "path" the path of the developer directory, "displayPath" the path to show, "version" the Developer tools version.
 Requesting the value of this property for the first time might retrun an empty array. However, a spotlight query is started, updating this value continuously as it finds new installs. It is thus wise to directly bind to this property instead of fetching it just once.
 */
@property (nonatomic, strong, readonly) NSArray *availableDeveloperTools;

@end
