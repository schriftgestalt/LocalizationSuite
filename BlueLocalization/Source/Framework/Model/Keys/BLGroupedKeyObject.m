/*!
 @header
 BLGroupedKeyObject.m
 Created by Max on 27.02.08.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLGroupedKeyObject.h"

@implementation BLGroupedKeyObject

- (id)init {
	self = [super init];

	if (self) {
		_keyObjects = [[NSMutableArray alloc] init];
	}

	return self;
}

- (id)initWithKey:(NSString *)key {
	return [self init];
}

- (id)initWithKeyObjects:(NSArray *)objects {
	self = [self init];

	[self setKeyObjects:objects];

	return self;
}

+ (id)keyObjectWithKeyObjects:(NSArray *)objects {
	return [[self alloc] initWithKeyObjects:objects];
}

+ (Class)classOfObjects {
	return [NSString class];
}

- (NSDictionary *)propertyListWithAttributes:(NSDictionary *)attributes {
	[NSException raise:NSInternalInconsistencyException format:@"Grouped key objects cannot be archived!"];

	return nil;
}

#pragma mark - Accessors

- (NSArray *)keyObjects {
	return _keyObjects;
}

- (void)setKeyObjects:(NSArray *)keyObjects {
	[_keyObjects setArray:keyObjects];
}

#pragma mark - Forwards

- (NSString *)key {
	return [[_keyObjects lastObject] key];
}

- (void)setKey:(NSString *)key {
}

- (NSString *)comment {
	return [[_keyObjects lastObject] comment];
}

- (void)setComment:(NSString *)comment {
	[_keyObjects makeObjectsPerformSelector:@selector(setComment:) withObject:comment];
}

- (BLFileObject *)fileObject {
	return [[_keyObjects lastObject] fileObject];
}

- (void)setFileObject:(BLFileObject *)object {
}

- (BOOL)isEmpty {
	return [[_keyObjects lastObject] isEmpty];
}

- (id)valueForKey:(NSString *)key {
	return [[_keyObjects lastObject] valueForKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key {
	for (unsigned i = 0; i < [_keyObjects count]; i++)
		[[_keyObjects objectAtIndex:i] setValue:value forKey:key];
}

- (id)objectForLanguage:(NSString *)lang {
	return [[_keyObjects lastObject] objectForLanguage:lang];
}

- (NSString *)stringForLanguage:(NSString *)lang {
	return [[_keyObjects lastObject] stringForLanguage:lang];
}

- (void)setObject:(id)object forLanguage:(NSString *)lang {
	for (unsigned i = 0; i < [_keyObjects count]; i++)
		[[_keyObjects objectAtIndex:i] setObject:object forLanguage:lang];
}

- (BOOL)isEmptyForLanguage:(NSString *)lang {
	return [[_keyObjects lastObject] isEmptyForLanguage:lang];
}

- (NSArray *)languages {
	return [[_keyObjects lastObject] languages];
}

@end
