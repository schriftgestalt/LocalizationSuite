//
//  BLDictionaryDocument.m
//  BlueLocalization
//
//  Created by max on 28.06.09.
//  Copyright 2009 Blue Technologies Group. All rights reserved.
//

#import "BLDictionaryDocument.h"

NSString *BLDictionaryLimitLanguagesFilterSetting = @"limitLanguages";
NSString *BLDictionaryNormalizeFilterSetting = @"normalize";
NSString *BLDictionaryNormLanguageFilterSetting = @"normLanguage";

@implementation BLDictionaryDocument

- (id)init {
	self = [super init];

	if (self) {
		_processManager = [[BLProcessManager alloc] initWithDocument:self];

		_filterSettings = [[NSMutableDictionary alloc] init];
		_languages = [[NSMutableArray alloc] init];
		_keyObjects = [[NSArray alloc] init];
		_keysLock = [[NSLock alloc] init];
	}

	return self;
}

#pragma mark - Persistence

- (NSFileWrapper *)fileWrapperOfType:(NSString *)typeName error:(NSError **)outError {
	NSMutableDictionary *properties = [NSMutableDictionary dictionary];
	[properties setObject:_filterSettings forKey:BLFilterSettingsPropertyName];
	[properties setObject:_languages forKey:BLLanguagesPropertyName];

	NSUInteger options = BLFileClearChangedValuesOption;

	return [BLDictionaryFile createFileForObjects:_keyObjects withOptions:options andProperties:properties];
}

- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError **)outError {
	NSDictionary *properties;

	NSArray *keyObjects = [BLDictionaryFile objectsFromFile:fileWrapper readingProperties:&properties];

	_keyObjects = keyObjects;
	[_filterSettings setDictionary:[properties objectForKey:BLFilterSettingsPropertyName]];
	[_languages setArray:[properties objectForKey:BLLanguagesPropertyName]];

	return YES;
}

#pragma mark - Accessors

- (BLProcessManager *)processManager {
	return _processManager;
}

- (NSArray *)keys {
	return _keyObjects;
}

@synthesize languages = _languages;
@synthesize filterSettings = _filterSettings;

@end
