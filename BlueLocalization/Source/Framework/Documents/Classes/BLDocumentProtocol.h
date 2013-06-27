/*!
 @header
 BLDocumentProtocol.h
 Created by Max on 29.11.04.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

@class BLPathCreator, BLFileObject;

/*!
 @abstract The abstract protocol used by several classes for shared properties.
 */
@protocol BLDocumentProtocol

/*!
 @abstract Returns a path creator suited for this document.
 */
@property(readonly) BLPathCreator *pathCreator;

/*!
 @abstract The reference language of the document.
 @discussion Return nil, if there is no such language.
 */
@property(readonly) NSString *referenceLanguage;

/*!
 @abstract All languages occuring in the document.
 */
@property(readonly) NSArray *languages;


@optional
/*!
 @abstract Returns a process manager allowing assynchronous actions on the document.
 */
@property(readonly) BLProcessManager *processManager;

/*!
 @abstract Returns a file object with the given path.
 @discussion This method should create the file object if it is currently not present. Used to add file objects.
 */
- (BLFileObject *)fileObjectWithPath:(NSString *)path;

/*!
 @abstract Returns a file object with the given path, but only if is exists.
 @discussion Incontrast to fileObjectWithPath:, this method should NOT create a file object if it is currently not present. Used to find file objects.
 */
- (BLFileObject *)existingFileObjectWithPath:(NSString *)path;

/*!
 @abstract Notifies of a file object change.
 */
- (void)fileObjectChanged:(BLFileObject *)fileObject;

/*!
 @abstract Notifies of a language change.
 */
- (void)languageChanged:(NSString *)language;

@end
