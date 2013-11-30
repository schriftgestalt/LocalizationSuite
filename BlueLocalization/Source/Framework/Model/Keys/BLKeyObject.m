/*!
 @header
 BLKeyObject.m
 Created by Max on 13.11.04.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLKeyObject.h"

#import "BLFileInternal.h"
#import "BLFileInterpreter.h"
#import "BLFileObject.h"
#import "BLLocalizerFile.h"
#import "BLPropertyListSerialization.h"

@implementation BLKeyObject

#pragma mark - Initializers

- (id)init
{
    self = [super init];
    
	_attachedMedia = nil;
    _comment = nil;
    _key = nil;
    _objects = [[NSMutableDictionary alloc] init];
	_snapshot = [[NSMutableDictionary alloc] init];
	_oldObjects = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (id)initWithKey:(NSString *)key
{
    self = [self init];
    
	if (self) {
		[self setKey: key];
	}
    
    return self;
}

- (id)initWithPropertyList:(NSDictionary *)plist
{
    self = [super initWithPropertyList: plist];
    
	if (self) {
		// values first
		[self setComment: [plist objectForKey: BLFileCommentKey]];
		[self setKey: [plist objectForKey: BLFileKeyKey]];
		[self setAttachedMedia: [[plist objectForKey: BLFileAttachmentsKey] wrapper]];
		
		// strings
		[_objects setDictionary: [plist objectForKey: BLFileLocalizationsKey]];
		[_snapshot setDictionary: [plist objectForKey: BLFileSnapshotsKey]];

		if ([plist objectForKey:BLFilePreviousLocalizationsKey])
		{
			[_oldObjects setDictionary:[plist objectForKey:BLFilePreviousLocalizationsKey]];
		}
		
		// changes
		[_changedValues setArray: [plist objectForKey: BLFileChangedValuesKey]];
	}
    
    return self;
}

#pragma mark - Serialization

- (NSDictionary *)propertyListWithAttributes:(NSDictionary *)attributes
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setDictionary: [super propertyListWithAttributes: attributes]];
	
	// General Properties
	if ([self key])
		[dict setObject:[self key] forKey:BLFileKeyKey];
	if ([self comment])
		[dict setObject:[self comment] forKey:BLFileCommentKey];
	if ([self attachedMedia])
		[dict setObject:[BLWrapperHandle handleWithWrapper:[self attachedMedia] forPreferredPath:@"Media"] forKey:BLFileAttachmentsKey];
    
	// Exported strings
	NSMutableDictionary *exportedStrings = [NSMutableDictionary dictionaryWithDictionary: self.strings];
	NSMutableDictionary *snapshotStrings = [NSMutableDictionary dictionaryWithDictionary: _snapshot];
	NSMutableDictionary *previousStrings = [NSMutableDictionary dictionaryWithDictionary: _oldObjects];
	
	// Filter languages
	if ([attributes objectForKey: BLLanguagesSerializationKey]) {
		NSMutableSet *remove = [NSMutableSet setWithArray: [exportedStrings allKeys]];
		[remove minusSet: [NSSet setWithArray: [attributes objectForKey: BLLanguagesSerializationKey]]];
		
		[exportedStrings removeObjectsForKeys: [remove allObjects]];
		[_snapshot removeObjectsForKeys: [remove allObjects]];
		[previousStrings removeObjectForKey:[remove allObjects]];
	}
	
	// Store strings
	[dict setObject:exportedStrings forKey:BLFileLocalizationsKey];

	if (previousStrings.count > 0)
		[dict setObject:previousStrings forKey:BLFilePreviousLocalizationsKey];

	if (![[attributes objectForKey: BLClearAllBackupsSerializationKey] boolValue])
		[dict setObject:snapshotStrings forKey:BLFileSnapshotsKey];
	
    return dict;
}


#pragma mark - Simple Accessors

- (NSString *)name
{
    return _key;
}

@synthesize key=_key;

- (NSString *)comment
{
	return _comment;
}

- (void)setComment:(NSString *)comment
{
	
	if (comment && [comment length])
		_comment = comment;
	else
		_comment = nil;
}

- (NSFileWrapper *)attachedMedia
{
	return _attachedMedia;
}

- (void)setAttachedMedia:(NSFileWrapper *)attachedMedia
{
	_attachedMedia = attachedMedia;
}


#pragma mark - Additional Accessors

- (BLFileObject *)fileObject
{
    return _fileObject;
}

- (void)setFileObject:(BLFileObject *)object
{
    _fileObject = object;
}

- (id)parentObject
{
    return [self fileObject];
}

- (BOOL)isEmpty
{
	for (NSString *language in [self languages]) {
		if (![self isEmptyForLanguage: language])
			return NO;
	}
	
	return YES;
}

- (BOOL)isEmptyForLanguage:(NSString *)lang
{
    return [[self class] isEmptyValue: [self objectForLanguage: lang]];
}

- (BOOL)isEqual:(id)other
{
	if (![super isEqual: other])
		return NO;
	
	// Compare keys
	if (!([self key] == nil && [other key] == nil) && ![[self key] isEqual: [other key]])
		return NO;
	if (!([self comment] == nil && [other comment] == nil) && ![[self comment] isEqual: [other comment]])
		return NO;
	
	// Compare number of languages
	if ([[self languages] count] != [[other languages] count])
		return NO;
	
	// Compare all objects
	for (NSString *language in [self languages]) {
		if (![[self class] value:[self objectForLanguage: language] isEqual:[other objectForLanguage: language]])
			return NO;
	}
	
	return YES;
}

+ (BOOL)isEmptyValue:(id)value
{
	return (value == nil);
}

+ (BOOL)value:(id)value isEqual:(id)other
{
	return [value isEqual: other];
}

- (void)removeObjectForLanguage:(NSString *)language
{
	[self setObject:nil forLanguage:language];
}

#pragma mark - KVC Overrides

- (id)valueForKey:(NSString *)key
{
    if ([key isEqual: @"comment"])
        return [self comment];
    if ([key isEqual: @"didChange"])
        return [NSNumber numberWithBool: [self didChange]];
    if ([key isEqual: @"key"])
        return [self key];
    if ([[self languages] containsObject: key])
        return [self objectForLanguage: key];

    return [super valueForKey: key];
}

- (id)valueForUndefinedKey:(NSString *)key
{
    return [self objectForLanguage: key];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqual: @"comment"]) {
        [self setComment: value];
        return;
    }
    if ([key isEqual: @"didChange"]) {
        if (![value boolValue])
            [self setNothingDidChange];
        return;
    }
    if ([key isEqual: @"key"]) {
        [self setKey: value];
        return;
    }
    if ([[self languages] indexOfObject: key] != NSNotFound) {
        [self setObject:value forLanguage:key];
        return;
    }
    
    [super setValue:value forKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    [self setObject:value forLanguage:key];
}


#pragma mark - String Accessors

- (id)objectForLanguage:(NSString *)lang
{
    return [_objects objectForKey: lang];
}

- (NSString *)stringForLanguage:(NSString *)lang
{
	if ([[self class] classOfObjects] == [NSString class])
		return [self objectForLanguage: lang];
	else {
		[NSException raise:NSInternalInconsistencyException format:@"Superclass cannot convert object to string!"];
		return nil;
	}
}

- (void)setObject:(id)object forLanguage:(NSString *)lang
{
	if (!lang)
		[NSException raise:NSInvalidArgumentException format:@"Language may not be nil for setting value %@ to key object %@", object, self];
	
	if (object && [[self class] isEmptyValue: object])
		object = nil;
	id oldObject = [self objectForLanguage: lang];
	
    if ((object != oldObject) && ![object isEqual: oldObject]) {
		[self willChangeValueForKey: lang];
		
		// Overwrite or delete
		if (object)
            [_objects setObject:object forKey:lang];
        else
            [_objects removeObjectForKey: lang];
        
		[self didChangeValueForKey: lang];
		[self setValue:lang didChange:YES];
	}
}

- (NSArray *)languages
{
    return [_objects allKeys];
}

- (NSDictionary *)strings
{
    return _objects;
}

- (NSString *)description
{
    return [[super description] stringByAppendingFormat: @" %@", _objects];
}

- (void)snapshotLanguage:(NSString *)language
{
	id object = [_objects objectForKey: language];
	
	if (object)
		[_snapshot setObject:object forKey:language];
	else
		[_snapshot removeObjectForKey: language];
}

- (id)snapshotForLanguage:(NSString *)language
{
	return [_snapshot objectForKey: language];
}

- (void)setOldObject:(id)object forLanguage:(NSString *)language
{
	[_oldObjects setObject:object forKey:language];
}

#pragma mark - Empty Accessors

+ (Class)classOfObjects
{
    return nil;
}

@end
