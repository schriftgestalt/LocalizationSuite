/*!
 @header
 BLDatabaseDocumentActions.h
 Created by Max Seelemann on 28.04.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLDatabaseDocument.h>

/*!
 @abstract Common actions performed on a database document.
 */
@interface BLDatabaseDocument (BLDatabaseDocumentActions)

/*!
 @abstract The interpreter options determined by the file's preferences.
 @discussion The returned value is a set of flags that can be passed as options to a BLFileInterpreter. They are generated according to the user's settings and should be used for all file interpretations.
 */
- (NSUInteger)defaultInterpreterOptions;

/*!
 @abstract The default placeholder strings to be deactivated upon file import.
 @discussion Will be read from the resource file BLDefaultPlaceholders.plist.
 */
+ (NSArray *)defaultIgnoredPlaceholderStrings;

/*!
 @abstract Returns a file object with the given path, adding it if none with that path exists.
 @discussion The given path must be a full path. Forwards to -fileObjectWithPath:create: with create YES.
 */
- (BLFileObject *)fileObjectWithPath:(NSString *)path;

/*!
 @abstract Returns a file object with the given path if it exists.
 @discussion The given path must be a full path. Forwards to -fileObjectWithPath:create: with create NO.
 */
- (BLFileObject *)existingFileObjectWithPath:(NSString *)path;

/*!
 @abstract Looks for a file object, creating it if wished.
 @param path A full path to the file.
 @param create If YES, the file will be created if it does not exists.
 */
- (BLFileObject *)fileObjectWithPath:(NSString *)path create:(BOOL)create;

/*!
 @abstract Returns a bundle object with the given path, adding it if none with that path exists.
 @discussion The given path must be a full path. Forwards to -bundleObjectWithPath:create: with create YES.
 */
- (BLBundleObject *)bundleObjectWithPath:(NSString *)path;

/*!
 @abstract Looks for a file object, creating it if wished.
 @param path A full path to the bundle.
 @param create If YES, the bundle will be created if it does not exists.
 */
- (BLBundleObject *)bundleObjectWithPath:(NSString *)path create:(BOOL)create;

/*!
 @abstract Creates a new bundle object according to the document preferences.
 @discussion The returned object is only created and set up, no adding to internal structures are performed.
 */
- (BLBundleObject *)createBundleObjectWithPath:(NSString *)path;

/*!
 @abstract Creates a new file object according to the document preferences.
 @discussion The returned object is only created and set up, no adding to internal structures are performed.
 */
- (BLFileObject *)createFileObjectWithPath:(NSString *)path;

/*!
 @abstract Rescan the reference language and import any changes.
 @discussion This will spawn a new action to the process manager, first evaluating the amount of work to do and then importing any changed files.
 @param force If YES, all files will be imported, regardles if they changed or not.
 */
- (void)rescan:(BOOL)force;

/*!
 @abstract Rescans a set of files in the reference language and import any changes.
 @discussion This will spawn a new action to the process manager, first evaluating the amount of work to do and then importing any changed files.
 @param force If YES, all files will be imported, regardles if they changed or not.
 */
- (void)rescanObjects:(NSArray *)objects force:(BOOL)force;

/*!
 @abstract Add the given files to the database.
 @discussion This will spawn a new action to the process manager: first all reference language files will be imported, adding files and bundles as neccessary. Second all other languages will be imported, adding localization values only.

 Developer note: This action is safe to be used inside other actions. It enqueues the actions for immediate execution before every other enqueued step.
 */
- (void)addFiles:(NSArray *)filenames;

/*!
 @abstract Runs a import over the passed localized files in the given languages.
 @discussion The reference language is excluded. Will spawn a new action to the process manager.
 */
- (void)reimportFiles:(NSArray *)files forLanguages:(NSArray *)languages;

/*!
 @abstract Writes all changes in objects to disk.
 @discussion Only the given objects will only be affected in only the given languages. If reinject is YES, all files in scope (even the not changed) will be deleted and written out. Will spawn a new action to the process manager.
 */
- (void)synchronizeObjects:(NSArray *)objects forLanguages:(NSArray *)languages reinject:(BOOL)reinject;

/*!
 @abstract Exports localizer files for a given set of languages.
 @discussion The document's preferences will be used some options. However, additional options (logically or-ed) can be specifyed. See BLLocalizerExportStep options for possible values. Will spawn a new action to the process manager.
 */
- (void)exportLocalizerFilesForLanguages:(NSArray *)languages withAdditionalOptions:(NSUInteger)options;

/*!
 @abstract Returns the full path where the Localizer file of the given language will be written to.
 */
- (NSString *)pathForLocalizerFileOfLanguage:(NSString *)language;

/*!
 @abstract Imports localizer files for a set of files.
 @discussion See BLLocalizerExportStep options for possible option values. Will spawn a new action to the process manager.
 */
- (void)importLocalizerFiles:(NSArray *)files withOptions:(NSUInteger)options;

@end
