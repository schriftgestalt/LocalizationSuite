/*!
 @header
 BLXcodeImportAssociationStep.h
 Created by max on 23.11.10.
 
 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLProcessStep.h>

/*!
 @abstract Internal class used by BLXcodeImporter to set the associated Xcode projects after importing the files.
 @discussion Do not use directly, use BLXcodeImporter instead!
 */
@interface BLXcodeImportAssociationStep : BLProcessStep
{
	BLDatabaseDocument	*_document;
	NSArray				*_files;
	NSString			*_path;
}

/*!
 @abstract Initializes a new step for updating associated xcode projects.
 */
- (id)initWithXcodeProjectAtPath:(NSString *)path document:(BLDatabaseDocument *)document andImportedFiles:(NSArray *)files;

@end
