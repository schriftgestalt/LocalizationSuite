/*!
 @header
 BLXcodeExporter.h
 Created by max on 01.07.09.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLDatabaseDocument.h>

/*!
 @abstract An interface to updating file-paths in Xcode projects.
 */
@interface BLXcodeExporter : NSObject <NSOpenSavePanelDelegate>
{
	IBOutlet NSView		*optionsView;
}

/*!
 @abstract Exports to (updates an) an user-selected Xcode project from a database document.
 @discussion This method will first open a sheet to allow th user to select a project and choose some options, and will then call importXcodeProjectAtPath:toDatabaseDocument:withOptions:.
 */
+ (void)exportDatabaseDocument:(BLDatabaseDocument *)document;

/*!
 @enum BLXcodeExporterSettings
 @abstract The options that can be given to a Xcode exporter.
 
 @const BLXcodeExporterAddMissingFiles	Files that are localized but not in the project will be added.
 @const BLXcodeExporterRemoveOldFiles	Files that are in the project but not localized accordingly will be removed.
 */
typedef enum {
	BLXcodeExporterAddMissingFiles	= 1<<0,
	BLXcodeExporterRemoveOldFiles	= 1<<1
} BLXcodeExporterSettings;

/*!
 @abstract The value to be passed when there should be no language limit.
 */
#define BLXcodeExporterNoLanguageLimit	-1.f

/*!
 @abstract The value to be passed when there should be no file limit.
 */
#define BLXcodeExporterNoFileLimit		-1.f

/*!
 @abstract Imports all localizable files in the Xcode project to the database document.
 @discussion This will open and parse the passes Xcode project using BLXcodeProjectParser, from the result extract all localizable files and then add them to the database document. See BLXcodeImporterSettings for possible values for options.
 */
+ (void)exportToXcodeProjectAtPath:(NSString *)path fromDatabaseDocument:(BLDatabaseDocument *)document withOptions:(NSUInteger)options languageLimit:(float)languageLimit fileLimit:(float)fileLimit;

@end
