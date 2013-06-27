/*!
 @header
 BLXLIFFDocument.m
 Created by max on 21.01.10.
 
 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */

#import "BLXLIFFDocument.h"

#import "BLTMXDocument.h"
#import "BLStringKeyObject.h"
#import "BLStringsFileObject.h"
#import "BLRTFDKeyObject.h"
#import "BLRTFFileObject.h"


NSString *BLXLIFFDocumentKnownVersion		= @"1.2";

NSString *BLXLIFFDocumentPlainTextDatatype	= @"plaintext";
NSString *BLXLIFFDocumentRTFDatatype		= @"rtf";

/*!
 @abstract Internal methods of BLXLIFFDocument
 */
@interface BLXLIFFDocument (BLXLIFFDocumentInternal)

/*!
 @abstract The datatypes that are currently supported.
 */
+ (NSArray *)supportedDatatypes;

/*!
 @abstract Initializes a blank XLIFF document.
 */
- (void)createBlankDocument;

/*!
 @abstract Replaces the contents of the document with the ones at the given path.
 @discussion Returns YES uppon success, NO on failure.
 */
- (BOOL)readXLIFFFromPath:(NSString *)path;

/*!
 @abstract Creates a key object from a DOM node, representing a tranlation unit (tu).
 */
- (BLFileObject *)fileObjectFromFileNode:(NSXMLElement *)fileNode;

/*!
 @abstract Updates a DOM node, representing a tranlation unit (tu), using a key object.
 */
- (void)updateFileNode:(NSXMLElement *)fileNode withFileObject:(BLFileObject *)fileObject;

@end


@implementation BLXLIFFDocument

+ (id)blankDocument
{
	return [[self alloc] initBlankDocument];
}

+ (id)documentWithFileAtPath:(NSString *)path
{
	return [[self alloc] initWithFileAtPath: path];
}

- (id)init
{
	self = [super init];
	
	if (self != nil) {
		_document = nil;
		_fileObjectMap = nil;
		_fileObjects = nil;
		_includeComments = YES;
		_sourceLanguage = nil;
		_targetLanguage = nil;
		_xliff = nil;
	}
	
	return self;
}

- (id)initBlankDocument
{
	self = [self init];
	
	if (self) {
		[self createBlankDocument];
	}
	
	return self;
}

- (id)initWithFileAtPath:(NSString *)path;
{
	self = [self init];
	
	if (self) {
		BLLogBeginGroup(@"Opening XLIFF document at path \"%@\"", path);
		BOOL result = [self readXLIFFFromPath: path];
		BLLogEndGroup();
		
		if (!result)
			return nil;
	}
	
	return self;
}




#pragma mark - Global

+ (NSArray *)pathExtensions
{
	return [NSArray arrayWithObjects: @"xlf", @"xliff", nil];
}

+ (NSArray *)supportedDatatypes
{
	return [NSArray arrayWithObjects: BLXLIFFDocumentPlainTextDatatype, BLXLIFFDocumentRTFDatatype, nil];
}


#pragma mark - Accessors

- (NSArray *)fileObjects
{
	return _fileObjects;
}

- (void)setFileObjects:(NSArray *)newObjects
{
	// Calculate removed files
	NSMutableSet *removed = [NSMutableSet setWithArray: _fileObjects];
	[removed minusSet: [NSSet setWithArray: newObjects]];
	
	// Remove XML elements for the deleted key objects
	for (BLFileObject *file in removed) {
		NSXMLElement *fileNode = [_fileObjectMap objectForKey: file];
		if (fileNode) {
			[_fileObjectMap removeObjectForKey: file];
			[_xliff removeChildAtIndex: [[_xliff children] indexOfObject: fileNode]];
		}
	}
	
	// Update keys
	[_fileObjects setArray: newObjects];
}

- (void)addFileObjects:(NSArray *)newObjects
{
	[_fileObjects addObjectsFromArray: newObjects];
}

@synthesize sourceLanguage=_sourceLanguage;
@synthesize targetLanguage=_targetLanguage;
@synthesize includeComments=_includeComments;


#pragma mark - Persistence

- (void)createBlankDocument
{
	// Document structure
	_document = [[NSXMLDocument alloc] init];
	
	_xliff = [NSXMLElement elementWithName: @"xliff"];
	[_xliff addAttribute: [NSXMLNode attributeWithName:@"version" stringValue:BLXLIFFDocumentKnownVersion]];
	[_xliff addAttribute: [NSXMLNode attributeWithName:@"xmlns" stringValue:@"urn:oasis:names:tc:xliff:document:1.2"]];
	[_xliff addAttribute: [NSXMLNode attributeWithName:@"xmlns:xsi" stringValue:@"http://www.w3.org/2001/XMLSchema-instance"]];
	[_xliff addAttribute: [NSXMLNode attributeWithName:@"xsi:schemaLocation" stringValue:@"urn:oasis:names:tc:xliff:document:1.2 http://docs.oasis-open.org/xliff/v1.2/cs02/xliff-core-1.2-strict.xsd"]];
	[_document addChild: _xliff];
	
	// Create the content
	_fileObjectMap = [NSMapTable mapTableWithWeakToWeakObjects];
	_fileObjects = [[NSMutableArray alloc] init];
}

- (BOOL)readXLIFFFromPath:(NSString *)path
{
	NSError *error;
	
	// Open XLIFF document
	_document = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath: path] options:0 error:&error];
	if (!_document) {
		BLLog(BLLogError, @"Unable to open XLIFF document, reason: %@", [error localizedDescription]);
		return NO;
	}
	
	// Find tmx element
	if (![_document childCount]) {
		BLLog(BLLogError, @"No xliff node found");
		return NO;
	}
	
	_xliff = [_document rootElement];
	if (![[_xliff name] isEqual: @"xliff"]) {
		BLLog(BLLogError, @"No tmx node found");
		return NO;
	}
	
	NSString *version = [[_xliff attributeForName: @"version"] stringValue];
	if ([version compare: BLXLIFFDocumentKnownVersion] == NSOrderedDescending)
		BLLog(BLLogWarning, @"Unknown xliff version \"%@\", ignored.", version);
	
	// Clear data structures
	
	_fileObjectMap = [NSMapTable mapTableWithWeakToWeakObjects];
	_fileObjects = [[NSMutableArray alloc] init];
	
	// Read the file objects
	for (NSXMLElement *fileNode in [_xliff elementsForName: @"file"]) {
		BLFileObject *fileObject = [self fileObjectFromFileNode: fileNode];
		if (!fileObject)
			continue;
		
		[_fileObjects addObject: fileObject];
		[_fileObjectMap setObject:fileNode forKey:fileObject];
	}
	
	return YES;
}

- (BOOL)writeToPath:(NSString *)path error:(NSError **)error
{
	if (!self.sourceLanguage)
		[NSException raise:NSGenericException format:@"Document does not have a source language!"];
	if (!self.targetLanguage)
		[NSException raise:NSGenericException format:@"Document does not have a target language!"];
	
	// First update all file nodes
	for (BLFileObject *fileObject in _fileObjects) {
		// Get the file node
		NSXMLElement *fileNode = [_fileObjectMap objectForKey: fileObject];
		
		// Inactive objects will not be exported
		if (![fileObject isActive]) {
			if (fileNode) {
				[_fileObjectMap removeObjectForKey: fileObject];
				[_xliff removeChildAtIndex: [[_xliff children] indexOfObject: fileNode]];
			}
			
			continue;
		}
		
		// We need to create a node
		if (!fileNode) {
			fileNode = [NSXMLElement elementWithName: @"file"];
			[_fileObjectMap setObject:fileNode forKey:fileObject];
			[_xliff addChild: fileNode];
		}
		
		// Update the element
		[self updateFileNode:fileNode withFileObject:fileObject];
	}
	
	// Then write the file
	return [[_document XMLData] writeToFile:path options:NSAtomicWrite error:error];
}


#pragma mark - Conversion

- (BLFileObject *)fileObjectFromFileNode:(NSXMLElement *)fileNode
{
	// Find datatype and storage class
	NSString *datatype = [[fileNode attributeForName: @"datatype"] stringValue];
	if (![[[self class] supportedDatatypes] containsObject: datatype]) {
		BLLog(BLLogWarning, @"Unsupported datatype \"%@\" for element %@", datatype, fileNode);
		return nil;
	}
	
	
	// Source language
	NSString *sourceLang = [[fileNode attributeForName: @"source-language"] stringValue];
	sourceLang = [BLLanguageTranslator languageIdentifierFromRFCLanguage: sourceLang];
	if (!self.sourceLanguage)
		self.sourceLanguage = sourceLang;
	
	// Target language
	NSString *targetLang = [[fileNode attributeForName: @"target-language"] stringValue];
	targetLang = [BLLanguageTranslator languageIdentifierFromRFCLanguage: targetLang];
	if (!self.targetLanguage)
		self.targetLanguage = targetLang;
	
	
	// Create file object
	NSString *path = [[fileNode attributeForName: @"original"] stringValue];
	
	BLFileObject *fileObject = nil;
	if ([BLFileObject classForPathExtension: [path pathExtension]]) {
		fileObject = [BLFileObject fileObjectWithPath: path];
	}
	else if ([datatype isEqual: BLXLIFFDocumentPlainTextDatatype]) {
		fileObject = [BLFileObject fileObjectWithPathExtension: @"strings"];
		fileObject.path = path;
	}
	else if ([datatype isEqual: BLXLIFFDocumentRTFDatatype]) {
		fileObject = [BLFileObject fileObjectWithPathExtension: @"rtf"];
		fileObject.path = path;
	}
	
	if (!fileObject)
		return nil;
	
	
	// Find all translation units
	NSXMLElement *body = [[fileNode elementsForName: @"body"] lastObject];
	
	NSMutableArray *groups = [NSMutableArray arrayWithArray: [body elementsForName: @"group"]];
	NSMutableArray *transUnits = [NSMutableArray arrayWithArray: [body elementsForName: @"trans-unit"]];
	
	while ([groups count]) {
		NSXMLElement *group = [groups objectAtIndex: 0];
		[groups removeObjectAtIndex: 0];
		
		[groups addObjectsFromArray: [group elementsForName: @"group"]];
		[transUnits addObjectsFromArray: [group elementsForName: @"trans-unit"]];
	}
	
	
	// Import translation units
	for (NSXMLElement *unit in transUnits) {
		// Unit datatype has to match
		NSString *unitDatatype = [[unit attributeForName: @"datatype"] stringValue];
		if (unitDatatype && ![datatype isEqual: unitDatatype]) {
			BLLog(BLLogWarning, @"Cannot mix multiple datatypes (%@, %@)in one file %@, skipping.", datatype, unitDatatype, fileNode);
			continue;
		}
		
		// Create the key object
		NSString *key = [[unit attributeForName: @"id"] stringValue];
		BLKeyObject *keyObject = [fileObject objectForKey:key createIfNeeded:YES];
		
		// Import source and target
		NSXMLElement *source = [[unit elementsForName: @"source"] lastObject];
		[keyObject setObjectForLanguage:sourceLang fromNode:source];
		
		NSXMLElement *target = [[unit elementsForName: @"target"] lastObject];
		[keyObject setObjectForLanguage:targetLang fromNode:target];
		
		// Find comments
		for (NSXMLElement *element in [unit elementsForName: @"note"]) {
			NSString *comment = [keyObject comment];
			
			if ([comment length])
				comment = [comment stringByAppendingString: @"\n"];
			comment = [comment stringByAppendingString: [element stringValue]];
			
			[keyObject setComment: comment];
		}
	}
	
	return fileObject;
}

- (void)updateFileNode:(NSXMLElement *)fileNode withFileObject:(BLFileObject *)fileObject
{
	// Clean
	[fileNode setAttributesAsDictionary: nil];
	[fileNode setChildren: nil];
	
	// Set path
	NSString *path = [fileObject path];
	if (fileObject.bundleObject)
		path = [NSString stringWithFormat: @"%@/%@", [fileObject.bundleObject name], path];
	[fileNode addAttribute: [NSXMLNode attributeWithName:@"original" stringValue:path]];
	
	// Set languages
	[fileNode addAttribute: [NSXMLNode attributeWithName:@"source-language" stringValue:[BLLanguageTranslator RFCLanguageFromLanguageIdentifier:self.sourceLanguage]]];
	[fileNode addAttribute: [NSXMLNode attributeWithName:@"target-language" stringValue:[BLLanguageTranslator RFCLanguageFromLanguageIdentifier:self.targetLanguage]]];
	
	// Set datatype
	NSString *datatype = nil;
	Class keyClass = [[fileObject class] classOfStoredKeys];
	if (keyClass == [BLStringKeyObject class])
		datatype = BLXLIFFDocumentPlainTextDatatype;
	else if (keyClass == [BLRTFDKeyObject class])
		datatype = BLXLIFFDocumentRTFDatatype;
	else
		[NSException raise:NSInternalInconsistencyException format:@"Unknown datatype for file object %@", fileObject];
	[fileNode addAttribute: [NSXMLNode attributeWithName:@"datatype" stringValue:datatype]];
	
	// Add translation units
	NSXMLElement *body = [NSXMLElement elementWithName: @"body"];
	[fileNode addChild: body];
	
	for (BLKeyObject *keyObject in fileObject.objects) {
		// Skip inactive objects
		if (![keyObject isActive])
			continue;
		
		// Create the structure
		NSXMLElement *unit = [NSXMLElement elementWithName: @"trans-unit"];
		[unit addAttribute: [NSXMLNode attributeWithName:@"id" stringValue:[keyObject key]]];
		[body addChild: unit];
		
		// Source and Target localization
		NSXMLElement *source = [NSXMLElement elementWithName: @"source"];
		[keyObject updateNode:source withObjectForLanguage:self.sourceLanguage];
		[unit addChild: source];
		
		NSXMLElement *target = [NSXMLElement elementWithName: @"target"];
		[keyObject updateNode:target withObjectForLanguage:self.targetLanguage];
		[unit addChild: target];
		
		// Comments
		if (_includeComments && [keyObject.comment length]) {
			NSXMLElement *note = [NSXMLElement elementWithName: @"note"];
			[note setStringValue: keyObject.comment];
			[unit addChild: note];
		}
	}
}

@end
