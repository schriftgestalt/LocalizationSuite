/*!
 @header
 BLTMXDocument.h
 Created by max on 20.01.10.

 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */

/*!
 @abstract A object representing a TMX (Translation Memory eXchange) document.
 @discussion This class supports both reading of existing files and the creation of blank TMX file. Afterwards, a modified or initialized TMX file can be written out again.
 */
@interface BLTMXDocument : NSObject {
	NSXMLElement *_body;
	NSXMLDocument *_document;
	NSXMLElement *_header;
	NSMapTable *_keyObjectMap;
	NSMutableArray *_keyObjects;
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
 @abstract Designated Initializer. Creates a blank TMX document.
 */
- (id)initBlankDocument;

/*!
 @abstract Designated Initializer. Tries to open a TMX file at the given path and converts it to an internal structure.
 */
- (id)initWithFileAtPath:(NSString *)path;

/*!
 @abstract Writes the TMX file for the given set of key objects to disk.
 @discussion Returns YES uppon success, NO uppon failure. If an error occurs, error will contain it.
 */
- (BOOL)writeToPath:(NSString *)path error:(NSError **)error;

/*!
 @abstract The key object contained in the TMX document.
 @discussion Represented by an NSArray of BLKeyObjects.
 */
@property (strong) NSArray *keyObjects;

/*!
 @abstract Adds the given key objects to the key objects of the document.
 */
- (void)addKeyObjects:(NSArray *)newObjects;

@end

/*!
 @abstract Custom accessors methods used by BLTMXDocument for conversion.
 */
@interface BLKeyObject (BLTMXDocument)

/*!
 @abstract Takes the content of the XML node and set it for the given language.
 @discussion Conversion of content may be necessary.
 */
- (void)setObjectForLanguage:(NSString *)language fromNode:(NSXMLElement *)node;

/*!
 @abstract Takes the content of the XML node and set it for the given language.
 @discussion Conversion of content may be necessary.
 */
- (void)updateNode:(NSXMLElement *)node withObjectForLanguage:(NSString *)language;

@end
