/*!
 @header
 BLDictionaryFile.h
 Created by Max Seelemann on 31.07.06.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLFile.h>

/*!
 @abstract The filter settings of the BLDictionaryFile.
 @discussion (readwrite) This is a property key for a BLDictionaryFile, containing NSDictionary used by the BLDictionaryDocument class.
 */
extern NSString *BLFilterSettingsPropertyName;

/*!
 @abstract A concrete implementation of the BLFile class, creating and reading Dictionary files.
 */
@interface BLDictionaryFile : BLFile

/*!
 @abstract Concrete implementation of the abstract BLFile method.
 @discussion See superclass for details. For additional options defined by this class see BLDictionaryFileExportOptions. Also this class requires the additional property BLFilterSettingsPropertyName.
 */
+ (NSFileWrapper *)createFileForObjects:(NSArray *)objects withOptions:(NSUInteger)options andProperties:(NSDictionary *)properties;

/*!
 @abstract Concrete implementation of the abstract BLFile method.
 @discussion See superclass for details. This class returnes the additional property BLFilterSettingsPropertyName.
 */
+ (NSArray *)objectsFromFile:(NSFileWrapper *)wrapper readingProperties:(NSDictionary **)properties;

@end
