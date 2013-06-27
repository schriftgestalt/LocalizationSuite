/*!
 @header
 BLFileManagerAdditions.h
 Created by Max on 29.11.04.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

/*!
 @abstract Constants to be passed to compressFileAtPath:usingCompression:keepOriginal: as file compression method.
 */
typedef enum {
	BLFileManagerNoCompression,
	
	BLFileManagerGzipCompression,
	BLFileManagerTarCompression,
	BLFileManagerTarGzipCompression,
	BLFileManagerTarBzip2Compression
} BLFileManagerCompression;


/*!
 @abstract Extensions to NSFileManager used by some parts of the Framework.
 */
@interface NSFileManager (BLFileManagerAdditions)

/*!
 @abstract Tries to determine the kind of compression applied to the file.
 */
- (BLFileManagerCompression)compressionOfFile:(NSString *)path;


/*!
 @abstract Returns the file name of the result of a compression.
 */
- (NSString *)pathOfFile:(NSString *)path compressedUsing:(BLFileManagerCompression)compression;

/*!
 @abstract Compresses a file at a gien path.
 @param	path			The path to the file or folder.
 @param	compression		A constant with the type of compression.
 @param keepOriginal	If YES, the original file will be kept.
 @return YES if successfull, NO otherwise.
 */
- (BOOL)compressFileAtPath:(NSString *)path usingCompression:(BLFileManagerCompression)compression keepOriginal:(BOOL)keepOriginal;


/*!
 @abstract Returns the file name of the result of a compression.
 */
- (NSString *)pathOfFile:(NSString *)path decompressedUsing:(BLFileManagerCompression)compression;

/*!
 @abstract Compresses a file at a gien path.
 @param	path			The path to the file or folder.
 @param	compression		A constant with the type of compression being used for compressing.
 @param keepOriginal	If YES, the original file will be kept.
 @return YES if successfull, NO otherwise.
 */
- (BOOL)decompressFileAtPath:(NSString *)path usedCompression:(BLFileManagerCompression *)compression resultPath:(NSString **)outResultPath keepOriginal:(BOOL)keepOriginal;

@end
