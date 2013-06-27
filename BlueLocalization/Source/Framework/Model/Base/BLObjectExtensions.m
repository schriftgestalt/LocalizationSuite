/*!
 @header
 BLObjectExtensions.m
 Created by max on 27.02.09.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLObjectExtensions.h"


@implementation BLObject (BLObjectExtensions)

+ (NSArray *)bundleObjectsFromArray:(NSArray *)array
{
	NSMutableArray *bundleObjects = [NSMutableArray array];
	
	for (BLObject *object in array) {
		if ([object isKindOfClass: [BLBundleObject class]])
			[bundleObjects addObject: object];
	}
	
	return bundleObjects;
}

+ (NSArray *)containingBundleObjectsFromArray:(NSArray *)array
{
	NSMutableSet *bundleObjects = [NSMutableSet set];
	
	for (BLObject *object in array) {
		if ([object isKindOfClass: [BLBundleObject class]])
			[bundleObjects addObject: object];
		if ([object isKindOfClass: [BLFileObject class]])
			[bundleObjects addObject: [(BLFileObject *)object bundleObject]];
		if ([object isKindOfClass: [BLKeyObject class]])
			[bundleObjects addObject: [[(BLKeyObject *)object fileObject] bundleObject]];
	}
	
	return [bundleObjects allObjects];
}

+ (NSArray *)fileObjectsFromArray:(NSArray *)array
{
	NSMutableSet *fileObjects = [NSMutableSet set];
	
	for (BLObject *object in array) {
		if ([object isKindOfClass: [BLBundleObject class]])
			[fileObjects addObjectsFromArray: [(BLBundleObject *)object files]];
		if ([object isKindOfClass: [BLFileObject class]])
			[fileObjects addObject: object];
	}
	
	return [fileObjects allObjects];
}

+ (NSArray *)keyObjectsFromArray:(NSArray *)array
{
	NSMutableSet *keyObjects = [NSMutableSet set];
	NSArray *files;
	
	// Bundles and files
	files = [self fileObjectsFromArray: array];
	for (BLFileObject *file in files)
		[keyObjects addObjectsFromArray: [file objects]];
	
	// Key objects
	for (BLObject *object in array) {
		if ([object isKindOfClass: [BLKeyObject class]])
			[keyObjects addObject: object];
	}
	
	return [keyObjects allObjects];
}

+ (NSArray *)bundleObjectsWithName:(NSString *)name inArray:(NSArray *)array
{
	NSMutableArray *objects = [NSMutableArray array];
	
	for (BLObject *object in array) {
		if ([object isKindOfClass: [BLBundleObject class]] && [[(BLBundleObject *)object name] isEqual: name])
			[objects addObject: object];
	}
	
	return objects;
}

+ (NSArray *)fileObjectsWithName:(NSString *)name inArray:(NSArray *)array
{
	NSMutableArray *objects = [NSMutableArray array];
	
	for (BLObject *object in array) {
		if ([object isKindOfClass: [BLFileObject class]] && [[(BLFileObject *)object name] isEqual: name])
			[objects addObject: object];
	}
	
	return objects;
}

+ (NSArray *)proxiesForObjects:(NSArray *)array
{
	NSMutableArray *proxies = [NSMutableArray array];
	
	for (BLObject *object in array)
		[proxies addObject: [BLObjectProxy proxyWithObject: object]];
	
	return proxies;
}

@end


@implementation BLObject (BLObjectKeyNumbers)

+ (NSUInteger)numberOfKeysInObjects:(NSArray *)array
{
	NSUInteger count = 0;
	for (BLObject *object in array) {
		if (object.isActive)
			count += [object numberOfKeys];
	}
	
	return count;
}

+ (NSUInteger)numberOfKeysMissingForLanguage:(NSString *)language inObjects:(NSArray *)array
{
	NSUInteger count = 0;
	for (BLObject *object in array) {
		if (object.isActive)
			count += [object numberOfMissingKeysForLanguage: language];
	}
	return count;
}

- (NSUInteger)numberOfKeys
{
	return [self.class numberOfKeysInObjects: [self objects]];
}

- (NSUInteger)numberOfMissingKeysForLanguage:(NSString *)language
{
	if (!self.isActive)
		return 0;
	return [self.class numberOfKeysMissingForLanguage:language inObjects:[self objects]];
}

@end

@implementation BLFileObject (BLObjectKeyNumbers)

- (NSUInteger)numberOfKeys
{
	return [[self.objects indexesOfObjectsPassingTest:^BOOL(BLKeyObject *key, NSUInteger idx, BOOL *stop) {
		return key.isActive && !key.isEmpty;
	}] count];
}

@end

@implementation BLKeyObject (BLObjectKeyNumbers)

- (NSUInteger)numberOfMissingKeysForLanguage:(NSString *)language
{
	// Inactive and empty items are not missing for any language
	if (!self.isActive || self.isEmpty)
		return 0;
	
	// 1, if key object is empty in this language
	if ([self isEmptyForLanguage: language])
		return 1;
	else
		return 0;
}

- (NSUInteger)numberOfKeys
{
	return (self.isActive && !self.isEmpty) ? 1 : 0;
}

@end

@implementation BLObject (BLObjectStatistics)

+ (NSUInteger)countForStatistic:(BLObjectStatisticsType)type forLanguage:(NSString *)language inObjects:(NSArray *)objects
{
	NSUInteger count = 0;
	for (BLObject *object in objects) {
		if ([object isActive])
			count += [object countForStatistic:type forLanguage:language];
	}
	return count;
}

- (NSUInteger)countForStatistic:(BLObjectStatisticsType)type forLanguage:(NSString *)language
{
	return [self.class countForStatistic:type forLanguage:language inObjects:[self objects]];
}

@end

@implementation BLKeyObject (BLObjectStatistics)

- (NSUInteger)countForStatistic:(BLObjectStatisticsType)type forLanguage:(NSString *)language
{
	NSString *value = [self stringForLanguage: language];
	
	switch (type) {
		case BLObjectStatisticsSentences:
			return [[value segmentsForType:BLSentenceSegmentation delimiters:NULL] count];
		case BLObjectStatisticsWords:
			return [[value segmentsForType:BLWordSegmentation delimiters:NULL] count];
		case BLObjectStatisticsCharacters:
			return [value length];
	}
	
	return 0;
}

@end


