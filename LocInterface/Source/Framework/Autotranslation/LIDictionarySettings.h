/*!
 @header
 LIDictionarySettings.h
 Created by max on 28.06.09.

 @copyright 2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract Window controller hosting a interface for dictionary controller settings
 */
@interface LIDictionarySettings : NSWindowController {
	IBOutlet NSArrayController *dictsController;
}

/*!
 @abstract The shared dictionary settings.
 @discussion As most apps only need one dictionary settings window (which also would all show the same content), a single instance makes a lot of sense.
 */
+ (id)sharedInstance;

/*!
 @abstract Interface acessor leading to the single shared dictionary controller.
 */
- (BLDictionaryController *)controller;

/*!
 @abstract Begins adding a dicitionay by showing an open sheet.
 */
- (IBAction)addDictionary:(id)sender;

/*!
 @abstract Removes the currently selected dictionaries.
 */
- (IBAction)removeDictionaries:(id)sender;

@end
