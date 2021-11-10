/*!
 @header
 BLDictionaryDocumentActions.m
 Created by Max Seelemann on 24.01.10.

 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */

#import "BLDictionaryDocumentActions.h"

#import "BLDictionaryFileImportStep.h"
#import "BLStringKeyObject.h"

@implementation BLDictionaryDocument (BLDictionaryDocumentActions)

#pragma mark - Filtering

- (NSArray *)filterKeys:(NSArray *)someKeys {
	// Read settings
	BOOL filterLanguages = [[self.filterSettings objectForKey:BLDictionaryLimitLanguagesFilterSetting] boolValue];
	NSSet *filteredLanguages = [NSSet setWithArray:self.languages];

	// Apply filter
	NSMutableArray *filteredKeys = [NSMutableArray arrayWithCapacity:[someKeys count]];

	for (__strong BLKeyObject *key in someKeys) {
		// Indicate a object has been copied to not do work twice
		BOOL copied = NO;

		// Only a set of languages is allowed
		if (filterLanguages) {
			NSMutableSet *remove = [NSMutableSet setWithArray:[key languages]];
			[remove minusSet:filteredLanguages];

			// Only copy if modification is needed
			if ([remove count]) {
				if (!copied) {
					key = [key copy];
					// copied = YES;
				}

				for (NSString *lang in remove)
					[key removeObjectForLanguage:lang];
			}
		}

		// Key needs at least two language values
		if ([key.languages count] < 2)
			continue;

		[filteredKeys addObject:key];
	}

	return filteredKeys;
}

- (NSArray *)normalizeKeys:(NSArray *)someKeys {
	// Read settings
	BOOL normalize = [[self.filterSettings objectForKey:BLDictionaryNormalizeFilterSetting] boolValue];
	NSString *normLanguage = [self.filterSettings objectForKey:BLDictionaryNormLanguageFilterSetting];

	if (!normalize || !normLanguage)
		return someKeys;

	// Merge using dictionary
	NSMutableDictionary *mergeDict = [NSMutableDictionary dictionaryWithCapacity:[someKeys count]];
	NSMutableArray *outKeys = [NSMutableArray arrayWithCapacity:[someKeys count]];
	NSMutableArray *rest = [NSMutableArray array];

	for (BLKeyObject *key in someKeys) {
		NSString *normValue = [key stringForLanguage:normLanguage];

		// Skip keys with empty norm values
		if (![normValue length]) {
			[rest addObject:key];
			continue;
		}

		// Find a bucket
		NSMutableArray *bucket = [mergeDict objectForKey:normValue];
		if (!bucket) {
			bucket = [NSMutableArray array];
			[mergeDict setObject:bucket forKey:normValue];
		}

		// Merge all localizations into the bucket
		NSMutableArray *mergedLanguages = [NSMutableArray array];

		for (NSString *language in [key languages]) {
			NSString *value = [key stringForLanguage:language];

			// Skip norm language
			if ([language isEqual:normLanguage])
				continue;

			// Skip empty languages
			if (![value length]) {
				[mergedLanguages addObject:language];
				continue;
			}

			// Check elements in bucket
			for (BLStringKeyObject *other in bucket) {
				// Value not yet present and free space
				if ([other isEmptyForLanguage:language]) {
					[other setObject:value forLanguage:language];
					[mergedLanguages addObject:language];
					break;
				}
				// Value already present
				if ([[other stringForLanguage:language] isEqual:value]) {
					[mergedLanguages addObject:language];
					break;
				}
			}
		}

		// No values were merged, just add key to bucket
		if ([mergedLanguages count] == 0) {
			[bucket addObject:key];
			[outKeys addObject:key];
		}
		// Some values weren't merged, create new bucket element
		// We need to add 1 here, because the norm language (which always merges) will never be in mergedLanguages
		else if ([mergedLanguages count] + 1 < [[key languages] count]) {
			BLStringKeyObject *newKey = [BLStringKeyObject keyObjectWithKey:nil];

			for (NSString *language in [key languages]) {
				if (![mergedLanguages containsObject:language])
					[newKey setObject:[key stringForLanguage:language] forLanguage:language];
			}

			[bucket addObject:newKey];
			[outKeys addObject:newKey];
		}
	}

	// Append unmatched keys
	return [outKeys arrayByAddingObjectsFromArray:rest];
}

#pragma mark - Accessors

- (void)setKeys:(NSArray *)newKeys {
	// First apply filters
	newKeys = [self filterKeys:newKeys];

	// Add objects
	[_keysLock lock];
	[self performSelectorOnMainThread:@selector(willChangeValueForKey:) withObject:@"keys" waitUntilDone:YES];

	newKeys = [self normalizeKeys:newKeys];

	_keyObjects = newKeys;

	[self performSelectorOnMainThread:@selector(didChangeValueForKey:) withObject:@"keys" waitUntilDone:NO];
	[_keysLock unlock];
}

- (void)addKeys:(NSArray *)someKeys {
	// First apply filters & pre-normalize
	someKeys = [self filterKeys:someKeys];
	someKeys = [self normalizeKeys:someKeys];

	// Add objects
	[_keysLock lock];
	[self performSelectorOnMainThread:@selector(willChangeValueForKey:) withObject:@"keys" waitUntilDone:YES];

	someKeys = [_keyObjects arrayByAddingObjectsFromArray:someKeys];
	someKeys = [self normalizeKeys:someKeys];

	_keyObjects = someKeys;

	[self performSelectorOnMainThread:@selector(didChangeValueForKey:) withObject:@"keys" waitUntilDone:NO];
	[_keysLock unlock];
}

- (void)addLanguages:(NSArray *)someLanguages ignoreFilter:(BOOL)ignore {
	// Do not add languages if we are filtering
	BOOL filterLanguages = [[self.filterSettings objectForKey:BLDictionaryLimitLanguagesFilterSetting] boolValue];
	if (filterLanguages && !ignore)
		return;

	// Compute new languages
	NSMutableSet *newLanguages = [NSMutableSet setWithArray:someLanguages];
	[newLanguages minusSet:[NSSet setWithArray:_languages]];

	// New languages are to be added
	if ([newLanguages count]) {
		[self willChangeValueForKey:@"languages"];
		[_languages addObjectsFromArray:[newLanguages allObjects]];
		[self didChangeValueForKey:@"languages"];
	}
}

- (void)removeLanguages:(NSArray *)someLanguages applyFilter:(BOOL)filter {
	[self willChangeValueForKey:@"languages"];
	[_languages removeObjectsInArray:someLanguages];
	[self didChangeValueForKey:@"languages"];

	// Filter objects
	if (filter) {
		[self willChangeValueForKey:@"keys"];
		[self setKeys:_keyObjects];
		[self didChangeValueForKey:@"keys"];
	}
}

#pragma mark -  Import

+ (NSArray *)pathExtensionsForImport {
	return [BLDictionaryFileImportStep availablePathExtensions];
}

- (void)importFiles:(NSArray *)files {
	NSArray *group = [BLDictionaryFileImportStep stepGroupForImportingFiles:files];

	[[self processManager] enqueueStepGroup:group];
	[[self processManager] startWithName:@"Importing files…"];
}

@end
