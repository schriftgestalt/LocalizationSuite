/*!
 @header
 BLStringsDictionary.h
 Created by Max on 10.08.05.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

/*!
 @abstract An extension to import and write strings files. This includes comments and is way less error prone manner than the default AppKit version.
 */
@interface NSDictionary (BLStringsDictionary)

/*!
 @abstract Scans the file at path as strings file and returns it as disctionary.
 @discussion This just calls -dictionaryWithStringsAtPath:scannedComments:scannedKeyOrder:, passing NULL as outComments and keyOrder. See there for more details.
 @return The scanned dictionary, or nil on failure.
 */
+ (NSDictionary *)dictionaryWithStringsAtPath:(NSString *)path;

/*!
 @abstract Scans the file at path as strings file and returns it as disctionary, also scanning comments and the key order.
 @discussion If outComments is not NULL, a Dictionary containing all found comments will be returned. If keyOrder is not NULL, a array containing the order of the scanned keys will be included.
 @return The scanned dictionary, or nil on failure.
 */
+ (NSDictionary *)dictionaryWithStringsAtPath:(NSString *)path scannedComments:(NSDictionary **)outComments scannedKeyOrder:(NSArray **)keyOrder;

/*!
 @abstract Writes the dictionary of strings to path.
 @discussion The dictionary should contain string values only. The resulting file is encoded using the given encosing. This method is just a forward to -writeAsStringsWithComments:toPath:usingEncoding:, which you will have to use anyways, if you want to include comments.
 @return YES on success, NO otherwise.
 */
- (BOOL)writeAsStringsToPath:(NSString *)path usingEncoding:(NSStringEncoding)encoding;

/*!
 @abstract Writes the dictionary of strings interspersed with comments to path.
 @discussion This just calls -writeKeysAsStrings:withComments:toPath:usingEncoding:, passing [self allKeys] alphabetically sorted as keys. See there for more details.
 @return YES on success, NO otherwise.
 */
- (BOOL)writeAsStringsWithComments:(NSDictionary *)comments toPath:(NSString *)path usingEncoding:(NSStringEncoding)encoding;

/*!
 @abstract Writes the keys from the dictionary of strings interspersed with comments to path.
 @discussion The dictionary should contain string values only. Only keys given in keys will be written, in the order of the keys. Duplicates will not be checked. However, this can be used to retain a speciffic key order via multiple scans and reads.
 Comments are written in the standard multiline format (/\* *\/) in front of each key. The comments dictionary must have the same keys as the value dictionary, in order to assing comments to the right string.
 Various characters in both keys and values will be escaped using BLStandardStringReplacements. See there for more details.
 BLStringsFileCreator uses these methods to write a dictionary as strings file. The difference between this implementation and the one of NSString is that this one doesn't convert UniCode characters to be a hex number prefixed by \U and that comments can be added.
 If path contains directories that do not yet exist, they will be created and the file will be written inside these folders.
 @return YES on success, NO otherwise.
 */
- (BOOL)writeKeysAsStrings:(NSArray *)keys withComments:(NSDictionary *)comments toPath:(NSString *)path usingEncoding:(NSStringEncoding)encoding;

/*!
 @abstract Writes the keys from the dictionary to a path, copying the structure of an existing file.
 @discussion This method is very similar to -writeKeysAsStrings:withComments:toPath:usingEncoding: in most respects. However, there two major differences: It tries to mimic the format of an existing strings file, leaving every structure intact and replacing the values of string-pairs only. It also preserves the string encoding of the original. This is also the reason why this method does not take any comments or key orders, since existing structure is used.
 Existing keys that have no match within the dictionary will be left as-is. The other way round, keys that exist in the dictionary but are not used in the file will not be written at all.
 @return NO failure or if the original does not exist, YES on success.
 */
- (BOOL)writeToPath:(NSString *)path mimicingFileAtPath:(NSString *)original;

@end

