/*!
 @header
 BLTMXDocument.m
 Created by max on 20.01.10.

 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */

#import "BLTMXDocument.h"

#import "BLRTFDKeyObject.h"
#import "BLStringKeyObject.h"

NSString *BLTMXDocumentKnownVersion = @"1.4";

NSString *BLTMXDocumentPlainTextDatatype = @"plaintext";
NSString *BLTMXDocumentRTFDatatype = @"rtf";

/*!
 @abstract Internal methods of BLTMXDocument
 */
@interface BLTMXDocument (BLTMXDocumentInternal)

/*!
 @abstract The datatypes that are currently supported.
 */
+ (NSArray *)supportedDatatypes;

/*!
 @abstract Initializes a blank TMX document.
 */
- (void)createBlankDocument;

/*!
 @abstract Replaces the contents of the document with the ones at the given path.
 @discussion Returns YES uppon success, NO on failure.
 */
- (BOOL)readTMXFromPath:(NSString *)path;

/*!
 @abstract Creates a key object from a DOM node, representing a tranlation unit (tu).
 */
- (BLKeyObject *)keyObjectFromTranlationUnit:(NSXMLElement *)unit;

/*!
 @abstract Updates a DOM node, representing a tranlation unit (tu), using a key object.
 */
- (void)updateTranslationUnit:(NSXMLElement *)unit withKeyObject:(BLKeyObject *)keyObject;

@end

@implementation BLTMXDocument

+ (id)blankDocument {
	return [[self alloc] initBlankDocument];
}

+ (id)documentWithFileAtPath:(NSString *)path {
	return [[self alloc] initWithFileAtPath:path];
}

- (id)init {
	self = [super init];

	if (self != nil) {
		_body = nil;
		_document = nil;
		_header = nil;
		_keyObjectMap = nil;
		_keyObjects = nil;
	}

	return self;
}

- (id)initBlankDocument {
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
		BLLogBeginGroup(@"Opening TMX document at path \"%@\"", path);
		BOOL result = [self readTMXFromPath:path];
		BLLogEndGroup();

		if (!result)
			return nil;
	}

	return self;
}

#pragma mark - Global

+ (NSArray *)pathExtensions {
	return [NSArray arrayWithObject:@"tmx"];
}

+ (NSArray *)supportedDatatypes {
	return [NSArray arrayWithObjects:BLTMXDocumentPlainTextDatatype, BLTMXDocumentRTFDatatype, nil];
}

#pragma mark - Accessors

- (NSString *)valueOfHeaderAttribute:(NSString *)attribute {
	return [[_header attributeForName:attribute] stringValue];
}

- (NSArray *)keyObjects {
	return _keyObjects;
}

- (void)setKeyObjects:(NSArray *)newObjects {
	// Calculate removed keys
	NSMutableSet *removed = [NSMutableSet setWithArray:_keyObjects];
	[removed minusSet:[NSSet setWithArray:newObjects]];

	// Remove XML elements for the deleted key objects
	for (BLKeyObject *key in removed) {
		NSXMLElement *tu = [_keyObjectMap objectForKey:key];
		if (tu) {
			[_keyObjectMap removeObjectForKey:key];
			[_body removeChildAtIndex:[[_body children] indexOfObject:tu]];
		}
	}

	// Update keys
	[_keyObjects setArray:newObjects];
}

- (void)addKeyObjects:(NSArray *)newObjects {
	[_keyObjects addObjectsFromArray:newObjects];
}

#pragma mark - Persistence

- (void)createBlankDocument {
	// Document structure
	_document = [[NSXMLDocument alloc] init];

	NSXMLElement *tmx = [NSXMLElement elementWithName:@"tmx"];
	[tmx addAttribute:[NSXMLNode attributeWithName:@"version" stringValue:BLTMXDocumentKnownVersion]];
	[_document addChild:tmx];

	// Build the Header
	_header = [NSXMLElement elementWithName:@"header"];

	NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	[_header addAttribute:[NSXMLNode attributeWithName:@"creationtool" stringValue:appName]];
	[_header addAttribute:[NSXMLNode attributeWithName:@"creationtoolversion" stringValue:appVersion]];

	[_header addAttribute:[NSXMLNode attributeWithName:@"segtype" stringValue:@"block"]];
	[_header addAttribute:[NSXMLNode attributeWithName:@"o-tmf" stringValue:@"BlueLocalization"]];

	[_header addAttribute:[NSXMLNode attributeWithName:@"adminlang" stringValue:@"en"]];
	[_header addAttribute:[NSXMLNode attributeWithName:@"srclang" stringValue:@"en"]];
	[_header addAttribute:[NSXMLNode attributeWithName:@"datatype" stringValue:BLTMXDocumentPlainTextDatatype]];
	[tmx addChild:_header];

	// Create the body
	_body = [NSXMLElement elementWithName:@"body"];
	[tmx addChild:_body];

	_keyObjectMap = [NSMapTable weakToWeakObjectsMapTable];
	_keyObjects = [[NSMutableArray alloc] init];
}

- (BOOL)readTMXFromPath:(NSString *)path {
	NSError *error;

	// Open TMX document
	_document = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] options:0 error:&error];
	if (!_document) {
		BLLog(BLLogError, @"Unable to open TMX document, reason: %@", [error localizedDescription]);
		return NO;
	}

	// Find tmx element
	if (![_document childCount]) {
		BLLog(BLLogError, @"No tmx node found");
		return NO;
	}

	NSXMLElement *tmx = [_document rootElement];
	if (![[tmx name] isEqual:@"tmx"]) {
		BLLog(BLLogError, @"No tmx node found");
		return NO;
	}

	NSString *version = [[tmx attributeForName:@"version"] stringValue];
	if ([version compare:BLTMXDocumentKnownVersion] == NSOrderedDescending)
		BLLog(BLLogWarning, @"Unknown tmx version \"%@\", ignored.", version);

	// Find header & body element
	_header = [[tmx elementsForName:@"header"] lastObject];
	if (![[_header name] isEqual:@"header"]) {
		BLLog(BLLogError, @"No header node found");
		return NO;
	}

	_body = [[tmx elementsForName:@"body"] lastObject];
	if (![[_body name] isEqual:@"body"]) {
		BLLog(BLLogError, @"No body node found");
		return NO;
	}

	// Some integrity checks
	NSString *datatype = [self valueOfHeaderAttribute:@"datatype"];
	if (![[[self class] supportedDatatypes] containsObject:datatype]) {
		BLLog(BLLogError, @"Document has unknown datatype \"%@\"", datatype);
		return NO;
	}

	// Clear data structures

	_keyObjectMap = [NSMapTable weakToWeakObjectsMapTable];
	_keyObjects = [[NSMutableArray alloc] init];

	// Read the key objects
	for (NSXMLElement *tu in [_body children]) {
		if (![[tu name] isEqual:@"tu"])
			continue;

		// Create key object
		BLKeyObject *keyObject = [self keyObjectFromTranlationUnit:tu];
		if (!keyObject)
			continue;

		[_keyObjects addObject:keyObject];
		[_keyObjectMap setObject:tu forKey:keyObject];
	}

	return YES;
}

- (BOOL)writeToPath:(NSString *)path error:(NSError **)error {
	// First update all translation units
	for (BLKeyObject *keyObject in _keyObjects) {
		NSXMLElement *tu = [_keyObjectMap objectForKey:keyObject];

		// We need to create a node
		if (!tu) {
			tu = [NSXMLElement elementWithName:@"tu"];
			[_keyObjectMap setObject:tu forKey:keyObject];
			[_body addChild:tu];
		}

		// Update the element
		[self updateTranslationUnit:tu withKeyObject:keyObject];
	}

	// Then write the file
	return [[_document XMLDataWithOptions:NSXMLNodePreserveWhitespace] writeToFile:path options:NSAtomicWrite error:error];
}

#pragma mark - Conversion

- (BLKeyObject *)keyObjectFromTranlationUnit:(NSXMLElement *)unit {
	BLKeyObject *keyObject;
	NSString *datatype;

	// Find datatype
	datatype = [[unit attributeForName:@"datatype"] stringValue];
	if (!datatype)
		datatype = [self valueOfHeaderAttribute:@"datatype"];
	if (![[[self class] supportedDatatypes] containsObject:datatype]) {
		BLLog(BLLogWarning, @"Unsupported datatype \"%@\" for element %@", datatype, unit);
		return nil;
	}

	// Create key object
	if ([datatype isEqual:BLTMXDocumentPlainTextDatatype])
		keyObject = [BLStringKeyObject keyObjectWithKey:nil];
	else if ([datatype isEqual:BLTMXDocumentRTFDatatype])
		keyObject = [BLRTFDKeyObject keyObjectWithKey:nil];
	else
		return nil;

	// Find comments
	for (NSXMLElement *element in [unit elementsForName:@"note"]) {
		NSString *comment = [keyObject comment];

		if ([comment length])
			comment = [comment stringByAppendingString:@"\n"];
		comment = [comment stringByAppendingString:[element stringValue]];

		[keyObject setComment:comment];
	}

	// Find variants
	for (NSXMLElement *element in [unit elementsForName:@"tuv"]) {
		// Find the segment
		NSXMLElement *segment = nil;
		for (NSXMLElement *subElement in [element children]) {
			if ([[subElement name] isEqual:@"seg"]) {
				segment = subElement;
				break;
			}
		}
		if (!segment)
			continue;

		// Extract the language
		NSString *language = [[element attributeForName:@"xml:lang"] stringValue];
		if (!language)
			language = [[element attributeForName:@"lang"] stringValue];
		language = [BLLanguageTranslator languageIdentifierFromRFCLanguage:language];
		if (!language) {
			BLLog(BLLogWarning, @"Unable to recognize language \"%@\" -- please report!", [[element attributeForName:@"xml:lang"] stringValue]);
			continue;
		}

		// Set the value
		[keyObject setObjectForLanguage:language fromNode:segment];
	}

	return keyObject;
}

- (void)updateTranslationUnit:(NSXMLElement *)unit withKeyObject:(BLKeyObject *)keyObject {
	// Clean
	[unit removeAttributeForName:@"datatype"];
	[unit setChildren:nil];

	// Set datatype
	NSString *datatype = nil;
	if ([keyObject isKindOfClass:[BLStringKeyObject class]])
		datatype = BLTMXDocumentPlainTextDatatype;
	else if ([keyObject isKindOfClass:[BLRTFDKeyObject class]])
		datatype = BLTMXDocumentRTFDatatype;

	if (![[self valueOfHeaderAttribute:@"datatype"] isEqual:datatype])
		[unit addAttribute:[NSXMLNode attributeWithName:@"datatype" stringValue:datatype]];

	// Add comment
	if ([[keyObject comment] length]) {
		NSXMLElement *note = [NSXMLElement elementWithName:@"note"];
		[note setStringValue:[keyObject comment]];
		[unit addChild:note];
	}

	// Add localizations
	for (NSString *language in [keyObject languages]) {
		NSXMLElement *tuv = [NSXMLElement elementWithName:@"tuv"];
		NSXMLElement *seg = [NSXMLElement elementWithName:@"seg"];

		[tuv addAttribute:[NSXMLNode attributeWithName:@"xml:lang" stringValue:[BLLanguageTranslator RFCLanguageFromLanguageIdentifier:language]]];
		[tuv addChild:seg];
		[unit addChild:tuv];

		[keyObject updateNode:seg withObjectForLanguage:language];
	}
}

@end

#pragma mark -

@implementation BLStringKeyObject (BLTMXDocument)

- (void)setObjectForLanguage:(NSString *)language fromNode:(NSXMLElement *)node {
	NSString *value = [node stringValue];

	if (![[self class] isEmptyValue:value])
		[self setObject:value forLanguage:language];
}

- (void)updateNode:(NSXMLElement *)node withObjectForLanguage:(NSString *)language {
	// Set Content
	[node setStringValue:[self stringForLanguage:language]];

	// Preserve whitespace
	[node removeAttributeForName:@"xml:space"];
	[node addAttribute:[NSXMLNode attributeWithName:@"xml:space" stringValue:@"preserve"]];

	// XML language
	//[node removeAttributeForName: @"xml:lang"];
	//[node addAttribute: [NSXMLNode attributeWithName:@"xml:lang" stringValue:[BLLanguageTranslator RFCLanguageFromLanguageIdentifier: language]]];
}

@end

@implementation BLRTFDKeyObject (BLTMXDocument)

- (void)setObjectForLanguage:(NSString *)language fromNode:(NSXMLElement *)node {
	NSString *text = [node stringValue];

	// Check for missing rtf header
	if (![text hasPrefix:@"{\\rtf"])
		text = [NSString stringWithFormat:@"{\\rtf1\\ansi %@}", text];

	NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
	NSAttributedString *attrText = [[NSAttributedString alloc] initWithRTF:data documentAttributes:nil];

	if (![[self class] isEmptyValue:attrText])
		[self setObject:attrText forLanguage:language];
}

- (void)updateNode:(NSXMLElement *)node withObjectForLanguage:(NSString *)language {
	// Content
	NSAttributedString *attrString = [self objectForLanguage:language];

	NSData *data = [attrString RTFFromRange:NSMakeRange(0, [attrString length]) documentAttributes:nil];
	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

	// Split string escaping rtf sequences
	NSScanner *scanner = [NSScanner scannerWithString:string];
	[scanner setCharactersToBeSkipped:nil];
	NSCharacterSet *escapeSet = [NSCharacterSet characterSetWithCharactersInString:@"{\\}"];
	NSCharacterSet *whiteSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
	NSUInteger index = 0;

	while (![scanner isAtEnd]) {
		NSString *scan = nil;

		// Scan regular text
		[scanner scanUpToCharactersFromSet:escapeSet intoString:&scan];
		if (scan && [scan length]) {
			NSUInteger length = [scan rangeOfCharacterFromSet:[[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet]].length;

			if (!length) {
				// Encode whitespace-only strings
				NSXMLNode *last = [[node children] lastObject];
				[last setStringValue:[[last stringValue] stringByAppendingString:scan]];
			}
			else {
				// Normal strings
				[node addChild:[NSXMLNode textWithStringValue:scan]];
			}
		}
		if ([scanner isAtEnd])
			break;

		// Special cases
		if ([scanner scanString:@"\\{" intoString:&scan]) {
			[node addChild:[NSXMLNode textWithStringValue:scan]];
			continue;
		}
		if ([scanner scanString:@"\\}" intoString:&scan]) {
			[node addChild:[NSXMLNode textWithStringValue:scan]];
			continue;
		}
		if ([scanner scanString:@"\\'" intoString:&scan]) {
			scan = [scan stringByAppendingString:[string substringWithRange:NSMakeRange([scanner scanLocation], 2)]];
			[node addChild:[NSXMLNode textWithStringValue:scan]];

			[scanner setScanLocation:[scanner scanLocation] + 2];
			continue;
		}

		// Scan control sequence
		if (![scanner scanString:@"}" intoString:&scan]) {
			[scanner scanUpToCharactersFromSet:whiteSet intoString:&scan];
			if (![scanner isAtEnd]) {
				scan = [scan stringByAppendingFormat:@"%C", [string characterAtIndex:[scanner scanLocation]]];
				[scanner setScanLocation:[scanner scanLocation] + 1];
			}
		}

		NSXMLElement *ph = [NSXMLNode elementWithName:@"ph" stringValue:scan];
		[ph addAttribute:[NSXMLNode attributeWithName:@"id" stringValue:[NSString stringWithFormat:@"%lu", index++]]];
		[node addChild:ph];
	}

	// Preserve whitespace
	[node removeAttributeForName:@"xml:space"];
	[node addAttribute:[NSXMLNode attributeWithName:@"xml:space" stringValue:@"preserve"]];

	// XML language
	//[node removeAttributeForName: @"xml:lang"];
	//[node addAttribute: [NSXMLNode attributeWithName:@"xml:lang" stringValue:[BLLanguageTranslator RFCLanguageFromLanguageIdentifier: language]]];
}

@end
