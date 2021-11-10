/*!
 @header
 BLAppleGlotDocument.h
 Created by max on 24.01.10.

 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */

/*!
 @abstract A object representing an AppleGlot Dictionary document.
 @discussion This class supports only reading of existing files. Also, while AppleGlot document support a structure including files and projects, this importer reads only the keys from the file.
 */
@interface BLAppleGlotDocument : NSObject {
	NSXMLDocument *_document;
	NSMapTable *_keyObjectMap;
	NSMutableArray *_keyObjects;
	NSXMLElement *_project;
}

/*!
 @abstract The file endings supported by this document format.
 */
+ (NSArray *)pathExtensions;

/*!
 @abstract Convenience allocator. Tries to open an existing document.
 */
+ (id)documentWithFileAtPath:(NSString *)path;

/*!
 @abstract Designated Initializer. Tries to open a AppleGlot Dictionary file at the given path and converts it to an internal structure.
 */
- (id)initWithFileAtPath:(NSString *)path;

/*!
 @abstract The key object contained in the document.
 @discussion Represented by an NSArray of BLKeyObjects.
 */
@property (weak, readonly) NSArray *keyObjects;

@end
