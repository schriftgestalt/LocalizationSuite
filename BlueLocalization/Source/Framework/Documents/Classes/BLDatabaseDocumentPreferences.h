/*!
 @header
 BLDatabaseDocumentPreferences.h
 Created by Max Seelemann on 28.10.2010.

 @copyright 2010 the Localization Suite Foundation. All rights reserved.
 */

/*!
 @abstract BLDatabaseDocument preference key: Include preview in Localizer files.
 @discussion NSNumber containing a BOOL. If YES, exported Localizer files will include a interface preview. This is done by copying all interface files into the package.
 */
extern NSString *BLDatabaseDocumentLocalizerFilesIncludePreviewKey;

/*!
 @abstract BLDatabaseDocument preference key: Embed dictionary in Localizer files.
 @discussion NSNumber containing a BOOL. If YES, exported Localizer files will include an embedded dictionary, created form the currently available keys in the BLDictionaryController. This dictionary will contain only matching keys.
 */
extern NSString *BLDatabaseDocumentLocalizerFilesEmbedDictionaryKey;

/*!
 @abstract BLDatabaseDocument preference key: Include guesses in the teilored dictionary embedded in a Localizer file.
 @discussion NSNumber containing a BOOL. If YES, the dictionary embedded in exported Localizer files will contain matching keys as well as keys that are used for guesses. Activating this option may considderably increase export durations.
 */
extern NSString *BLDatabaseDocumentLocalizerFilesEmbedDictionaryGuessesKey;

/*!
 @abstract BLDatabaseDocument preference key: Write in compressed format.
 @discussion NSNumber containing a BOOL. If YES, exported Localizer files will be written in the compressed file format.
 */
extern NSString *BLDatabaseDocumentLocalizerFilesCompressionKey;

/*!
 @abstract BLDatabaseDocument preference key: Localizer file write path.
 @discussion NSString. Per-user preference. A document-relative path to the folder where Localizer files should be exported.
 */
extern NSString *BLDatabaseDocumentLocalizerFilesPathKey;

/*!
 @abstract BLDatabaseDocument preference key: Save all languages in one file.
 @discussion NSNumber containing a BOOL. Per-user preference. If YES, exporting Localizer files will create a separate file for each language, otherwise just a single file is created.
 */
extern NSString *BLDatabaseDocumentLocalizerFilesSaveToOneFileKey;

/*!
 @abstract BLDatabaseDocument preference key: Default bundle naming style.
 @discussion NSNumber containing a BLNamingStyle. The default naming style for newly created bundle objects in the document.
 */
extern NSString *BLDatabaseDocumentBundleNamingStyleKey;

/*!
 @abstract BLDatabaseDocument preference key: Default bundle referencing style.
 @discussion NSNumber containing a BLReferencingStyle. The default referencing style for newly created bundle objects in the document.
 */
extern NSString *BLDatabaseDocumentBundleReferencingStyleKey;

/*!
 @abstract BLDatabaseDocument preference key: Import empty strings.
 @discussion NSNumber containing a BOOL. Whether the default interpreter options should contain BLFileInterpreterImportEmptyKeys or not.
 */
extern NSString *BLDatabaseDocumentImportEmptyStringsKey;

/*!
 @abstract BLDatabaseDocument preference key: Deactivate empty strings.
 @discussion NSNumber containing a BOOL. Whether the default interpreter options should contain BLFileInterpreterDeactivateEmptyKeys or not.
 */
extern NSString *BLDatabaseDocumentDeactivateEmptyStringsKey;

/*!
 @abstract BLDatabaseDocument preference key: Deactivate placeholder strings.
 @discussion NSNumber containing a BOOL. Whether the default interpreter options should contain BLFileInterpreterDeactivateIgnoredPlaceholders or not.
 */
extern NSString *BLDatabaseDocumentDeactivatePlaceholderStringsKey;

/*!
 @abstract BLDatabaseDocument preference key: The ignored placeholder strings.
 @discussion NSArray containing NSString objects. The strings that will be passed on as BLInterpretationStepIgnoredPlaceholderStringsKey to the interpreter parameters.
 */
extern NSString *BLDatabaseDocumentIgnoredPlaceholderStringsKey;

/*!
 @abstract BLDatabaseDocument preference key: Autotranslate new strings.
 @discussion NSNumber containing a BOOL. Whether the default interpreter options should contain BLFileInterpreterAutotranslateNewKeys or not.
 */
extern NSString *BLDatabaseDocumentAutotranslateNewStringsKey;

/*!
 @abstract BLDatabaseDocument preference key: Mark autotranslated as not changed.
 @discussion NSNumber containing a BOOL. Whether the default interpreter options should contain BLFileInterpreterTrackAutotranslationAsNoUpdate or not.
 */
extern NSString *BLDatabaseDocumentMarkAutotranslatedAsNotChangedKey;

/*!
 @abstract BLDatabaseDocument preference key: Value changes should reset strings.
 @discussion NSNumber containing a BOOL. Whether the default interpreter options should contain BLFileInterpreterValueChangesResetKeys or not.
 */
extern NSString *BLDatabaseDocumentValueChangesResetStringsKey;

/*!
 @abstract BLDatabaseDocument preference key: Automatically import Xcode projects when rescanning files.
 @discussion NSNumber containing a BOOL. Whether a BLXcodeImporterStep should be enqueued to every rescan.
 */
extern NSString *BLDatabaseDocumentRescanXcodeProjectsEnabledKey;

/*!
 @abstract BLDatabaseDocument preference key: Automatically update Xcode projects when writing files.
 @discussion NSNumber containing a BOOL. Whether a BLXcodeExporterStep should be enqueued to every synchronize.
 */
extern NSString *BLDatabaseDocumentUpdateXcodeProjectsEnabledKey;

/*!
 @abstract BLDatabaseDocument preference key: Add missing files when updating Xcode project.
 @discussion NSNumber containing a BOOL. Whether files missing from the project should be added during Xcode export.
 */
extern NSString *BLDatabaseDocumentUpdateXcodeAddMissingFilesKey;

/*!
 @abstract BLDatabaseDocument preference key: Remove not matching files when updating Xcode project.
 @discussion NSNumber containing a BOOL. Whether files not matching the filter criteria should be removed from the project during Xcode export.
 */
extern NSString *BLDatabaseDocumentUpdateXcodeRemoveNotMatchingFilesKey;

/*!
 @abstract BLDatabaseDocument preference key: Required minimum localization for including a language in a Xcode project.
 @discussion NSNumber containing BOOL. Whether the language limit given by BLDatabaseDocumentUpdateXcodeLanguageLimitKey should be applied or not.
 */
extern NSString *BLDatabaseDocumentUpdateXcodeHasLanguageLimitKey;

/*!
 @abstract BLDatabaseDocument preference key: Required minimum localization for including a language in a Xcode project.
 @discussion NSNumber containing a float between 0 and 100. The percentage of localization required for a language to be included.
 */
extern NSString *BLDatabaseDocumentUpdateXcodeLanguageLimitKey;

/*!
 @abstract BLDatabaseDocument preference key: Required minimum localization for including a file in a Xcode project.
 @discussion NSNumber containing BOOL. Whether the file limit given by BLDatabaseDocumentUpdateXcodeFileLimitKey should be applied or not.
 */
extern NSString *BLDatabaseDocumentUpdateXcodeHasFileLimitKey;

/*!
 @abstract BLDatabaseDocument preference key: Required minimum localization for including a file in a Xcode project.
 @discussion NSNumber containing a float between 0 and 100. The percentage of localization required for a file to be included.
 */
extern NSString *BLDatabaseDocumentUpdateXcodeFileLimitKey;
