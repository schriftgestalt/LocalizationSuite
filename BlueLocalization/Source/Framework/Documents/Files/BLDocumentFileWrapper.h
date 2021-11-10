/*!
 @header
 BLDocumentFileWrapper.h
 Created by Max Seelemann on 07.05.10.

 @copyright 2010 the Localization Suite Foundation. All rights reserved.
 */

/*!
 @abstract Additional options over NSFileWrapper for BLDocumentFileWrapper.

 @const BLDocumentFileWrapperSaveCompressedOption	The resulting file should be compressed.
 */
enum {
	BLDocumentFileWrapperSaveCompressedOption = 1 << 10
};

/*!
 @abstract A custom file wrapper class used by the BLFile classes to less destructively write projects.
 */
@interface BLDocumentFileWrapper : NSFileWrapper

- (id)initWithFileWrapper:(NSFileWrapper *)fileWrapper;

@end
