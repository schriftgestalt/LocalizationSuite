/*!
 @header
 BLLocalizerDocument.m
 Created by Max Seelemann on 28.05.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLLocalizerDocument.h"

@implementation BLLocalizerDocument

- (id)init {
	self = [super init];

	if (self) {
		_processManager = [[BLProcessManager alloc] initWithDocument:self];

		_properties = nil;
		_bundles = nil;
	}

	return self;
}

#pragma mark - Persistence

- (NSFileWrapper *)fileWrapperOfType:(NSString *)typeName error:(NSError **)outError {
	NSMutableDictionary *properties = [NSMutableDictionary dictionaryWithDictionary:_properties];

	// Persistent properties
	[properties setObject:_preferences forKey:BLPreferencesPropertyName];
	[properties setObject:_userPreferences forKey:BLUserPreferencesPropertyName];

	// Options
	NSUInteger options = 0;
	if ([[_properties objectForKey:BLIncludesPreviewPropertyName] boolValue])
		options |= BLFileIncludePreviewOption;

	return [BLLocalizerFile createFileForObjects:_bundles withOptions:options andProperties:properties];
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError **)outError {
	NSDictionary *properties;
	NSArray *bundles = [BLLocalizerFile objectsFromFile:fileWrapper readingProperties:&properties];

	_bundles = bundles;
	_properties = properties;

	[_userPreferences addEntriesFromDictionary:[properties objectForKey:BLUserPreferencesPropertyName]];
	[_preferences addEntriesFromDictionary:[properties objectForKey:BLPreferencesPropertyName]];

	return YES;
}

#pragma mark - Accessors

- (BLPathCreator *)pathCreator {
	return nil;
}

- (BLProcessManager *)processManager {
	return _processManager;
}

- (NSDictionary *)properties {
	return _properties;
}

- (NSArray *)bundles {
	return _bundles;
}

- (NSArray *)languages {
	return [_properties objectForKey:BLLanguagesPropertyName];
}

- (NSString *)referenceLanguage {
	return [_properties objectForKey:BLReferenceLanguagePropertyName];
}

- (BLDictionaryDocument *)embeddedDictionary {
	return [_properties objectForKey:BLDictionaryPropertyName];
}

@end

@implementation BLLocalizerDocument (BLLocalizerDocumentDeprecated)

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
	return [self readFromFileWrapper:[[NSFileWrapper alloc] initRegularFileWithContents:data] ofType:typeName error:outError];
}

@end
