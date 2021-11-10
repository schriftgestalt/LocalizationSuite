/*!
 @header
 BLAppleGlotDocument.m
 Created by max on 24.01.10.

 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */

#import "BLAppleGlotDocument.h"

#import "BLStringKeyObject.h"

/*!
 @abstract Internal methods of BLAppleGlotDocument
 */
@interface BLAppleGlotDocument (BLAppleGlotDocumentInternal)

/*!
 @abstract Replaces the contents of the document with the ones at the given path.
 @discussion Returns YES uppon success, NO on failure.
 */
- (BOOL)readAppleGlotFromPath:(NSString *)path;

/*!
 @abstract Creates a key object from a DOM node, representing a text item (TextItem).
 */
- (BLKeyObject *)keyObjectFromTextItem:(NSXMLElement *)item;

@end

@implementation BLAppleGlotDocument

+ (id)documentWithFileAtPath:(NSString *)path {
	return [[self alloc] initWithFileAtPath:path];
}

- (id)init {
	self = [super init];

	if (self != nil) {
		_document = nil;
		_keyObjectMap = nil;
		_keyObjects = nil;
		_project = nil;
	}

	return self;
}

- (id)initWithFileAtPath:(NSString *)path;
{
	self = [self init];

	if (self) {
		BLLogBeginGroup(@"Opening AppleGlot document at path \"%@\"", path);
		BOOL result = [self readAppleGlotFromPath:path];
		BLLogEndGroup();

		if (!result)
			return nil;
	}

	return self;
}

#pragma mark - Global

+ (NSArray *)pathExtensions {
	return [NSArray arrayWithObjects:@"lg", @"ad", nil];
}

#pragma mark - Accessors

- (NSArray *)keyObjects {
	return _keyObjects;
}

#pragma mark - Persistence

- (BOOL)readAppleGlotFromPath:(NSString *)path {
	NSError *error;

	// Open AppleGlot document
	_document = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] options:0 error:&error];
	if (!_document) {
		BLLog(BLLogError, @"Unable to open AppleGlot document, reason: %@", [error localizedDescription]);
		return NO;
	}

	// Find Proj element
	_project = [_document rootElement];
	if (![[_project name] isEqual:@"Proj"]) {
		BLLog(BLLogError, @"No Proj node found");
		return NO;
	}

	// Clear data structures

	_keyObjectMap = [NSMapTable mapTableWithWeakToWeakObjects];
	_keyObjects = [[NSMutableArray alloc] init];

	// Read the key objects
	for (NSXMLElement *file in [_project elementsForName:@"File"]) {
		for (NSXMLElement *item in [file elementsForName:@"TextItem"]) {
			// Create key object
			BLKeyObject *keyObject = [self keyObjectFromTextItem:item];
			if (!keyObject)
				continue;

			[_keyObjects addObject:keyObject];
			[_keyObjectMap setObject:item forKey:keyObject];
		}
	}

	return YES;
}

#pragma mark - Conversion

- (BLKeyObject *)keyObjectFromTextItem:(NSXMLElement *)item {
	// Create key object
	BLKeyObject *keyObject = [BLStringKeyObject keyObjectWithKey:nil];

	// Find comments
	for (NSXMLElement *desc in [item elementsForName:@"Description"]) {
		NSString *comment = [keyObject comment];

		if ([comment length])
			comment = [comment stringByAppendingString:@"\n"];
		comment = [comment stringByAppendingString:[desc stringValue]];

		[keyObject setComment:comment];
	}

	// Read localizations
	NSXMLElement *transSet = [[item elementsForName:@"TranslationSet"] lastObject];

	// Reference
	for (NSXMLElement *base in [transSet elementsForName:@"base"]) {
		[keyObject setObject:[base stringValue] forLanguage:[[base attributeForName:@"loc"] stringValue]];
	}

	// Translation
	for (NSXMLElement *tran in [transSet elementsForName:@"tran"]) {
		[keyObject setObject:[tran stringValue] forLanguage:[[tran attributeForName:@"loc"] stringValue]];
	}

	return keyObject;
}

@end
