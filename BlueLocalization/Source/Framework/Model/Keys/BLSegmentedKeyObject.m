/*!
 @header
 BLSegmentedKeyObject.m
 Created by Max on 17.02.10.

 @copyright 2010 the Localization Suite Foundation. All rights reserved.
 */

#import "BLSegmentedKeyObject.h"

#import "BLStringKeyObject.h"

/*!
 @abstract Internal forwarder key object of BLSegmentedKeyObject.
 */
@interface BLKeyObjectSegment : BLKeyObject {
	NSUInteger _index;
	BLSegmentedKeyObject *_host;
}

/*!
 @abstract The parent key objects.
 */
@property (strong) BLSegmentedKeyObject *host;

/*!
 @abstract The number of the segment.
 */
@property (assign) NSUInteger index;

@end

/*!
 @abstract Internal methods of BLSegmentedKeyObject.
 */
@interface BLSegmentedKeyObject (BLSegmentedKeyObjectInternal)

/*!
 @abstract Designated Initializer.
 */
- (id)initWithOriginal:(BLKeyObject *)original andType:(BLSegmentationType)type;

/*!
 @abstract The key objects for each segment.
 */
@property (readonly) NSArray *segmentObjects;

/*!
 @abstract Similar to -objectForLanguage: but requires the index for the segments.
 */
- (id)objectAtIndex:(NSUInteger)index forLanguage:(NSString *)lang;

/*!
 @abstract Similar to -setObject: forLanguage: but requires the index for the segments.
 */
- (void)setObject:(id)object atIndex:(NSUInteger)index forLanguage:(NSString *)lang;

@end

@implementation BLSegmentedKeyObject

+ (NSArray *)segmentKeyObject:(BLKeyObject *)original byType:(BLSegmentationType)type {
	BLSegmentedKeyObject *segmentedObject = [[self alloc] initWithOriginal:original andType:type];

	if (!segmentedObject)
		return [NSArray arrayWithObject:original];
	else
		return segmentedObject.segmentObjects;
}

- (id)initWithOriginal:(BLKeyObject *)original andType:(BLSegmentationType)type {
	self = [super init];

	if (self) {
		_delimiters = nil;
		_languages = nil;
		_keyObjects = nil;
		_original = nil;

		// Check storage class
		if ([[original class] classOfObjects] != [NSString class])
			goto bail;

		_original = original;
		_languages = [[NSMutableDictionary alloc] init];

		// Split
		for (NSString *lang in [_original languages]) {
			NSArray *delimiters, *segments;
			segments = [[_original stringForLanguage:lang] segmentsForType:type delimiters:&delimiters];

			// Check segment count
			if ([segments count] == 1)
				goto bail;

			// Check delimiters
			if (!_delimiters)
				_delimiters = delimiters;
			else if (![_delimiters isEqual:delimiters])
				goto bail;

			[_languages setObject:[NSMutableArray arrayWithArray:segments] forKey:lang];
		}

		// Create objects
		NSMutableArray *objects = [NSMutableArray array];
		for (NSUInteger i = 0; i < [_delimiters count] - 1; i++) {
			BLKeyObjectSegment *segment = [[BLKeyObjectSegment alloc] init];
			segment.host = self;
			segment.index = i;
			[objects addObject:segment];
		}

		_keyObjects = objects;
	}

	return self;

	// When the object cannot be constructed for some reason.
bail:;
	return nil;
}

+ (Class)classOfObjects {
	return [NSString class];
}

- (NSDictionary *)propertyListWithAttributes:(NSDictionary *)attributes {
	[NSException raise:NSInternalInconsistencyException format:@"Segmented key objects cannot be archived!"];

	return nil;
}

#pragma mark - Accessors

- (NSString *)key {
	return [_original key];
}

- (NSString *)comment {
	return [_original comment];
}

- (BLFileObject *)fileObject {
	return [_original fileObject];
}

- (NSArray *)segmentObjects {
	return _keyObjects;
}

- (id)objectAtIndex:(NSUInteger)index forLanguage:(NSString *)lang {
	if ([_languages objectForKey:lang])
		return [[_languages objectForKey:lang] objectAtIndex:index];
	else
		return @"";
}

- (void)setObject:(id)object atIndex:(NSUInteger)index forLanguage:(NSString *)lang {
	// Get the strings
	NSMutableArray *strings = [_languages objectForKey:lang];

	// Create and set strings array if needed
	if (!strings) {
		strings = [NSMutableArray array];
		for (NSUInteger i = 1; i < [_delimiters count]; i++)
			[strings addObject:@""];
		[_languages setObject:strings forKey:lang];
	}

	// Set string
	[strings replaceObjectAtIndex:index withObject:object];

	// Update original
	[_original setObject:[NSString stringByJoiningSegments:strings withDelimiters:_delimiters] forLanguage:lang];
}

+ (BOOL)isEmptyValue:(id)value {
	return [BLStringKeyObject isEmptyValue:value];
}

- (NSArray *)languages {
	return [_original languages];
}

@end

@implementation BLKeyObjectSegment

@synthesize index = _index;
@synthesize host = _host;

- (NSString *)key {
	return [_host key];
}

- (NSString *)comment {
	return [_host comment];
}

- (BLFileObject *)fileObject {
	return [_host fileObject];
}

+ (Class)classOfObjects {
	return [NSString class];
}

- (id)objectForLanguage:(NSString *)lang {
	return [_host objectAtIndex:_index forLanguage:lang];
}

- (NSString *)stringForLanguage:(NSString *)lang {
	return [_host objectAtIndex:_index forLanguage:lang];
}

- (void)setObject:(id)object forLanguage:(NSString *)lang {
	[_host setObject:object atIndex:_index forLanguage:lang];
}

+ (BOOL)isEmptyValue:(id)value {
	return [BLStringKeyObject isEmptyValue:value];
}

- (NSArray *)languages {
	return [_host languages];
}

@end
