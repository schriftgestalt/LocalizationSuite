/*!
 @header
 BLDatabaseFile.h
 Created by Max on 29.11.04.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLFile.h>

/*!
 @abstract A concrete implementation of the BLFile class, creating and reading Localizer files.
 */
@interface BLDatabaseFile : BLFile

/*!
 @abstract Concrete implementation of the abstract BLFile method.
 @discussion See superclass for details. For additional options defined by this class see BLDatabaseFileExportOptions. Also this class requires the additional properties BLReferenceLanguagePropertyName and - if the BLFileIncludePreviewOption is set - BLPathCreatorPropertyName.
 */
+ (NSFileWrapper *)createFileForObjects:(NSArray *)objects withOptions:(NSUInteger)options andProperties:(NSDictionary *)properties;

/*!
 @abstract Concrete implementation of the abstract BLFile method.
 @discussion See superclass for details. This class returnes both the additional properties BLReferenceLanguagePropertyName and BLIncludesPreviewPropertyName.
 */
+ (NSArray *)objectsFromFile:(NSFileWrapper *)wrapper readingProperties:(NSDictionary **)properties;

@end
