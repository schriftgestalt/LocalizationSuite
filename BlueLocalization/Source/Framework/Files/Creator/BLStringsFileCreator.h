/*!
 @header
 BLStringsFileCreator.h
 Created by Max on 29.11.04.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLFileCreator.h>

/*!
 @abstract A file creator implementation for strings files.
 */
@interface BLStringsFileCreator : BLFileCreator

/*!
 @discussion BLStringsFileCreator just forwards the standard method -_writeFileToPath:fromObject:withLanguage:referenceLanguage: to this one, passing NSUnicodeStringEncoding as encoding.
 */
- (BOOL)_writeFileToPath:(NSString *)path fromObject:(BLFileObject *)object withLanguage:(NSString *)language referenceLanguage:(NSString *)defaultLanguage usingEncoding:(NSStringEncoding)encoding;

@end
