/*!
 @header
 BLLocalizerFile.h
 Created by Max on 29.11.04.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLFile.h>

/*!
 @abstract Additional options allowed for a BLLocalizerFile.
 
 @const BLFileIncludePreviewOption			The localizer file should be built to include a preview. This will copy all reference file into the bundle.
 */
typedef enum {
	BLFileIncludePreviewOption		= 1<<16
} BLLocalizerFileExportOptions;

/*!
 @abstract Indicator whether the Localizer file contains a preview or not.
 @discussion (readonly) Represents a NSNumber containing a BOOL, whether the file does include a interface preview or not.
 */
extern NSString *BLIncludesPreviewPropertyName;

/*!
 @abstract The embedded dictionary of the Localizer file.
 @discussion (readwrite) Represented by a BLDictionaryDocument, an embedded dictionary in the Localizer file.
 */
extern NSString *BLDictionaryPropertyName;


/*!
 @abstract A concrete implementation of the BLFile class, creating and reading Localizer files.
 */
@interface BLLocalizerFile : BLFile

/*!
 @abstract Concrete implementation of the abstract BLFile method.
 @discussion See superclass for details. For additional options defined by this class see BLLocalizerFileExportOptions. Also this class requires the additional properties BLReferenceLanguagePropertyName and - if the BLFileIncludePreviewOption is set - BLPathCreatorPropertyName.
 */
+ (NSFileWrapper *)createFileForObjects:(NSArray *)objects withOptions:(NSUInteger)options andProperties:(NSDictionary *)properties;

/*!
 @abstract Concrete implementation of the abstract BLFile method.
 @discussion See superclass for details. This class returnes both the additional properties BLReferenceLanguagePropertyName and BLIncludesPreviewPropertyName.
 */
+ (NSArray *)objectsFromFile:(NSFileWrapper *)wrapper readingProperties:(NSDictionary **)properties;

@end

