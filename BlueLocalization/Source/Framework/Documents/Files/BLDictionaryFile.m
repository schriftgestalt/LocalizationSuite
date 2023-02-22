/*!
 @header
 BLDictionaryFile.m
 Created by Max Seelemann on 31.07.06.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLDictionaryFile.h"
#import "BLFileInternal.h"
#import "BLStringKeyObject.h"
#import "CFPropertyListWriter_vintage.h"

NSString *BLDictionaryFilePathExtension = @"lod";

NSString *BLFilterSettingsPropertyName = @"filterSettings";

/*!
 @abstract Version History

 Version 1:		Initial version.
 Version 2:		Adds filtering support to file structure.
 */
#define BLDictionaryFileVersionNumber 2

@interface BLDictionaryFile (BLFileInternal)

+ (BOOL)updateDictionaryFile:(NSMutableDictionary *)dict;
+ (BOOL)updateDictionaryObjects:(NSMutableArray *)objects fromFile:(NSMutableDictionary *)dict;

@end

@implementation BLDictionaryFile

+ (NSString *)pathExtension {
	return BLDictionaryFilePathExtension;
}

+ (NSArray *)requiredProperties {
	return [NSArray arrayWithObjects:BLLanguagesPropertyName, BLFilterSettingsPropertyName, nil];
}

+ (NSFileWrapper *)createFileForObjects:(NSArray *)keys withOptions:(NSUInteger)options andProperties:(NSDictionary *)properties {
	BLLogBeginGroup(@"Generating Dictionary File");

	// Check input
	for (NSString *key in [self requiredProperties]) {
		if (![properties objectForKey:key])
			[NSException raise:NSInternalInconsistencyException format:@"Missing value for key %@", key];
	}

	// Archive all keys
	NSDictionary *attributes = @{
		BLActiveObjectsOnlySerializationKey: @((options & BLFileActiveObjectsOnlyOption) != 0),
		BLClearChangeInformationSerializationKey: @((options & BLFileClearChangedValuesOption) != 0),
		BLLanguagesSerializationKey: [properties objectForKey:BLLanguagesPropertyName]
	};

	NSArray *archivedKeys = [BLPropertyListSerializer serializeObject:keys withAttributes:attributes outWrappers:NULL];

	archivedKeys = [archivedKeys sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *_Nonnull obj1, NSDictionary *_Nonnull obj2) {
		NSString *key1 = obj1[@"localizations"][@"en"];
		NSString *key2 = obj2[@"localizations"][@"en"];
		NSComparisonResult result = [key1 compare:key2];
		if (result != NSOrderedSame) {
			return result;
		}
		NSLog(@"%@ == %@", obj1, obj2);
		return result;
	}];

	// Create Contents.plist
	NSMutableDictionary *contents = [NSMutableDictionary dictionary];
	[contents setObject:archivedKeys forKey:BLFileKeysKey];
	[contents secureSetObject:[properties objectForKey:BLLanguagesPropertyName] forKey:BLFileLanguagesKey];
	[contents setObject:[properties objectForKey:BLFilterSettingsPropertyName] forKey:BLFileFilterSettingsKey];
	[contents setObject:@(BLDictionaryFileVersionNumber) forKey:BLFileVersionKey];

	// Create file wrapper
	NSData *contentsData = dataWithPropertyList(contents);
	NSFileWrapper *wrapper = [[NSFileWrapper alloc] initRegularFileWithContents:contentsData];
	BLLogEndGroup();
	return wrapper;
}

+ (NSArray *)objectsFromFile:(NSFileWrapper *)wrapper readingProperties:(NSDictionary **)outProperties {
	BLLogBeginGroup(@"Reading Dictionary File");

	// Unarchive contents
	NSMutableDictionary *contents = [NSPropertyListSerialization propertyListWithData:[wrapper regularFileContents] options:NSPropertyListMutableContainersAndLeaves format:nil error:nil];
	if (![self updateDictionaryFile:contents]) {
		BLLogEndGroup();
		return nil;
	}

	// Deserialize bundles
	NSArray *inKeys = [contents objectForKey:BLFileKeysKey];
	inKeys = [BLPropertyListSerializer objectWithPropertyList:inKeys fileWrappers:nil];
	NSMutableArray *keys = [NSMutableArray arrayWithArray:inKeys];

	// Update keys
	if (![self updateDictionaryObjects:keys fromFile:contents]) {
		BLLogEndGroup();
		return nil;
	}

	// Generate properties
	if (outProperties != nil) {
		NSMutableDictionary *attrs = [NSMutableDictionary dictionary];

		[attrs secureSetObject:[contents objectForKey:BLFileLanguagesKey] forKey:BLLanguagesPropertyName];
		[attrs secureSetObject:[contents objectForKey:BLFileFilterSettingsKey] forKey:BLFilterSettingsPropertyName];

		if (outProperties)
			(*outProperties) = attrs;
	}

	BLLogEndGroup();
	return keys;
}

#pragma mark -

+ (BOOL)updateDictionaryFile:(NSMutableDictionary *)dict {
	NSUInteger version = [[dict objectForKey:BLFileVersionKey] intValue];

	if (version < 2) {
		[dict setObject:[NSDictionary dictionary] forKey:BLFileFilterSettingsKey];
	}

	return YES;
}

+ (BOOL)updateDictionaryObjects:(NSMutableArray *)objects fromFile:(NSMutableDictionary *)dict {
	// nothing to update yet
	return YES;
}

@end
