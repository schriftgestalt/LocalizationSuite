/*!
 @header
 BLXLIFFDocument.h
 Created by max on 21.01.10.

 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */

/*!
 @abstract A object representing a XLIFF (XML Localization Interchange File Format) document.
 @discussion This class supports both reading of existing files and the creation of blank XLIFF file. Afterwards, a modified or initialized XLIFF file can be written out again. In contrast to a TMX file, XLIFF documents only contain two languages (which of both might be the same) and are structured in means of files of keys instead of of keys only.
 */
@interface BLXLIFFDocument : NSObject {
	NSXMLDocument *_document;
	NSMapTable *_fileObjectMap;
	NSMutableArray *_fileObjects;
	BOOL _includeComments;
	NSString *_sourceLanguage;
	NSString *_targetLanguage;
	NSXMLElement *_xliff;
}

/*!
 @abstract The file endings supported by this document format.
 */
+ (NSArray *)pathExtensions;

/*!
 @abstract Convenience allocator. Creates a new, blank document.
 */
+ (id)blankDocument;

/*!
 @abstract Convenience allocator. Tries to open an existing document.
 */
+ (id)documentWithFileAtPath:(NSString *)path;

/*!
 @abstract Designated Initializer. Creates a blank XLIFF document.
 */
- (id)initBlankDocument;

/*!
 @abstract Designated Initializer. Tries to open a XLIFF file at the given path and converts it to an internal structure.
 */
- (id)initWithFileAtPath:(NSString *)path;

/*!
 @abstract Writes the XLIFF file for the given set of file objects to disk.
 @discussion Returns YES uppon success, NO uppon failure. If an error occurs, error will contain it.
 */
- (BOOL)writeToPath:(NSString *)path error:(NSError **)error;

/*!
 @abstract The source language in this document.
 @discussion Returns the source language of the first file in this document. Setting this property overwrites all source languages and might lead to loss of data when writing back to disk.
 */
@property (strong) NSString *sourceLanguage;

/*!
 @abstract The target language in this document.
 @discussion Returns the target language of the first file in this document. Setting this property overwrites all target languages and might lead to loss of data when writing back to disk.
 */
@property (strong) NSString *targetLanguage;

/*!
 @abstract When writing the document, include comments of key objects.
 @discussion Defaults to YES.
 */
@property (assign) BOOL includeComments;

/*!
 @abstract The file object contained in the XLIFF document.
 @discussion Represented by an NSArray of BLFileObjects. Imported file objects will have their path set as stored in the file. Exported file objects, however, write their path as the name of their bundle object plus their file name. As such, a file object that was re-imported from a exported file object will have a path that has the form: "<bundle-name>/<file-path>". You need to be aware of this fact to be able to reimport exported key objects.
 */
@property (strong) NSArray *fileObjects;

/*!
 @abstract Adds the given file objects to the file objects of the document.
 */
- (void)addFileObjects:(NSArray *)newObjects;

@end
