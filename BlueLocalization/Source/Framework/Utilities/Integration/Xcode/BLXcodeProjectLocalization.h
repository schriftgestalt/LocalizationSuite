/*!
 @header
 BLXcodeProjectLocalization.h
 Created by max on 17.07.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLXcodeProjectItem.h>

/*!
 @abstract Additions BLXcodeProjectItem used to manage localizations.
 */
@interface BLXcodeProjectItem (BLXcodeProjectLocalization)

/*!
 @abstract Finds all localized variant groups in the item tree.
 @discussion Traverses the whole item tree looking for variant groups containing localizable files. Localizable files are understood as all file with extensions that BLFileInterpreter knows.
 */
- (NSArray *)localizedVariantGroups;

/*!
 @abstract The localizations contained in a variant group.
 @discussion The returned array holds the identifiers of the contained languages. The item must have a item type BLXcodeItemTypeVariantGroup, throws otherwise.
 */
- (NSArray *)localizations;

/*!
 @abstract The exact localizations contained in a variant group.
 @discussion The returned array holds the exact names of the languages folders for all the contained languages. The item must have a item type BLXcodeItemTypeVariantGroup, throws otherwise.
 */
- (NSArray *)exactLocalizations;

/*!
 @abstract Updates the real names of all localizations.
 @discussion When a language folder has been renamed, the item must also rename it's localization variant. This is checked and performed by this method. The item must have a item type BLXcodeItemTypeVariantGroup, throws otherwise.
 */
- (void)updateLocalizationNames;

/*!
 @abstract Adds localizations to a variant group.
 @discussion The passed language array must hold language identifiers only. This method then checks the real existent language folder name and uses existing paths where possible. The item must have a item type BLXcodeItemTypeVariantGroup, throws otherwise.
 */
- (void)addLocalizations:(NSArray *)languages;

/*!
 @abstract Removes localizations from a variant group.
 @discussion The passed language array must hold language identifiers only. The item must have a item type BLXcodeItemTypeVariantGroup, throws otherwise. Also, the callee must not be empty as in having children, throws otherwise as well.
 */
- (void)removeLocalizations:(NSArray *)languages;

/*!
 @abstract Updates a file item to reflect it's type and encoding according to the file on disk.
 @discussion Currently only works for xib and strings files. The item must have a item type BLXcodeItemTypeFile, throws otherwise.
 */
- (void)updateFileTypeAndEncoding;

@end
