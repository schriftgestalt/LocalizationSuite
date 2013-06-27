/*!
 @header
 BLFileObject.m
 Created by Max on 27.10.04.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLFileObject.h"

#import "BLKeyObject.h"
#import "BLFileInternal.h"


NSString *BLBackupAttachmentKey = @"backup";

// Globals
NSMutableDictionary *__fileObjectClasses = nil;


// Class Cluster Placeholder Object
@interface BLPlaceholderFileObject : BLFileObject
{
}
@end

@implementation BLFileObject

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey: key];
	
	if ([key isEqual: @"name"])
		keyPaths = [keyPaths setByAddingObject: @"path"];
	
	return keyPaths;
}


#pragma mark - Class Cluster

+ (id)alloc
{
    if ([self isEqual: [BLFileObject class]])
        return [BLPlaceholderFileObject alloc];
    else
        return [super alloc];
}

+ (id)allocWithZone:(NSZone *)zone
{
    if ([self isEqual: [BLFileObject class]])
        return [BLPlaceholderFileObject allocWithZone: zone];
    else
        return [super allocWithZone: zone];
}


#pragma mark - Initializers

- (id)init
{
    self = [super init];
    
	if (self) {
		_attachments = [[NSMutableDictionary alloc] init];
		_bundleObject = nil;
		_customType = nil;
		_hashValue = nil;
		_objects = [[NSMutableArray alloc] init];
		_oldObjects = [[NSMutableArray alloc] init];
		_path = [[NSString alloc] init];
		_snapshots = [[NSMutableDictionary alloc] init];
		_versions = [[NSMutableDictionary alloc] init];
	}
    
    return self;
}

- (id)initWithPath:(NSString *)path
{
	self = [self init];
	
    if (self) {
		// Get the relative path
		NSString *portion = [BLPathCreator relativePartOfFilePath: path];
		
		if (portion) {
			BLBundleObject *bundle;
			
			// Set the file's path
			[self setPath: portion];
			
			// Create the bundle
			portion = [BLPathCreator bundlePartOfFilePath: path];
			if (portion && [portion length]) {
				bundle = [BLBundleObject bundleObjectWithPath: portion];
				[bundle addFile: self];
			}
		} else {
			// No relative path found
			[self setPath: path];
		}
	}
    
    return self;
}

- (id)initWithPathExtension:(NSString *)extension
{
    return [self init];
}


#pragma mark - Convenience Allocators

+ (id)fileObjectWithPath:(NSString *)path
{
    return [[BLFileObject alloc] initWithPath: path];
}

+ (id)fileObjectWithPathExtension:(NSString *)extension
{
    return [[BLFileObject alloc] initWithPathExtension: extension];
}


#pragma mark - Class Methods

+ (Class)classOfStoredKeys
{
    return Nil;
}

+ (NSArray *)availablePathExtensions
{
    return [__fileObjectClasses allKeys];
}

+ (Class)classForPathExtension:(NSString *)ext
{
	return [__fileObjectClasses objectForKey: ext];
}

+ (void)registerClass:(Class)fileClass forPathExtension:(NSString *)extension
{
	if (!__fileObjectClasses)
		__fileObjectClasses = [[NSMutableDictionary alloc] init];
	
	[__fileObjectClasses setObject:fileClass forKey:extension];
}


#pragma mark - Serialization

- (id)initWithPropertyList:(NSDictionary *)plist
{
    self = [super initWithPropertyList: plist];
    
	if (self) {
		// Unpack wrappers
		NSDictionary *attachments = [plist objectForKey: BLFileAttachmentsKey];
		NSMutableDictionary *newAttachments = [NSMutableDictionary dictionary];
		
		for (NSString *key in attachments) {
			NSDictionary *dict = [attachments objectForKey: key];
			NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
			
			for (NSString *vers in dict) {
				id object = [dict objectForKey: vers];
				
				if ([object isKindOfClass: [BLWrapperHandle class]])
					object = [object wrapper];
				
				if (object)
					[newDict setObject:object forKey:vers];
			}
			
			[newAttachments setObject:newDict forKey:key];
		}
		
		// Set properties
		[self setObjects: [plist objectForKey: BLFileObjectsKey]];
		[self setOldObjects: [plist objectForKey: BLFileOldObjectsKey]];
		
		[self setCustomFileType: [plist objectForKey: BLFileCustomTypeKey]];
		[self setHashValue: [plist objectForKey: BLFileHashKey]];
		[self setPath: [plist objectForKey: BLFileNameKey]];
		
		_versions = [[plist objectForKey: BLFileVersionsKey] copy];
		_attachments = [newAttachments copy];
		_snapshots = [[plist objectForKey: BLFileSnapshotsKey] copy];
		
		[_changedValues setArray: [plist objectForKey: BLFileChangedValuesKey]];
	}
	
    return self;
}

- (NSDictionary *)propertyListWithAttributes:(NSDictionary *)attributes
{
	BOOL activeOnly = [[attributes objectForKey: BLActiveObjectsOnlySerializationKey] boolValue];
	BOOL clearChanges = [[attributes objectForKey: BLClearChangeInformationSerializationKey] boolValue];
	BOOL noBackups = [[attributes objectForKey: BLClearAllBackupsSerializationKey] boolValue];
	
    // Serialize objects
    NSMutableArray *archivedObjects = [NSMutableArray array];
    for (BLKeyObject *key in [self objects]) {
        if ([key isActive] || !activeOnly)
            [archivedObjects addObject: key];
    }
	
	// Prepare attachments
	NSMutableDictionary *attachments = [NSMutableDictionary dictionary];
	NSArray *allVersions = [_versions allValues];
	
	// Clearing change information - only export the newest version!
	if (clearChanges && [allVersions count])
		allVersions = [NSArray arrayWithObject: [NSString stringWithFormat: @"%lu", [self versionForLanguage: nil]]];
	
	for (NSString *key in _attachments) {
		NSDictionary *dict = [_attachments objectForKey: key];
		NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
		
		// Skip backups if requested
		if (noBackups && [key isEqual: BLBackupAttachmentKey])
			continue;
		
		// Encode each version
		for (NSString *vers in dict) {
			id object = [dict objectForKey: vers];
			
			// Skip no longer referenced attachments
			if (![allVersions containsObject: vers])
				continue;
			
			// Encapsultate file wrappers
			if ([object isKindOfClass: [NSFileWrapper class]]) {
				NSString *prefPath = [[self bundleObject] name];
				prefPath = [prefPath stringByAppendingPathComponent: [[self name] stringByDeletingPathExtension]];
				prefPath = [prefPath stringByAppendingPathComponent: vers];
				object = [BLWrapperHandle handleWithWrapper:object forPreferredPath:prefPath];
			}
			
			[newDict setObject:object forKey:vers];
		}
		
		[attachments setObject:newDict forKey:key];
	}
    
	// Create the dictionary
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setDictionary: [super propertyListWithAttributes: attributes]];
	
	[dict secureSetObject:[self hashValue] forKey:BLFileHashKey];
	[dict secureSetObject:[self path] forKey:BLFileNameKey];
	[dict secureSetObject:archivedObjects forKey:BLFileObjectsKey];
	
	if (!activeOnly)
		[dict secureSetObject:[self oldObjects] forKey:BLFileOldObjectsKey];
    if ([self customFileType])
        [dict setObject:[self customFileType] forKey:BLFileCustomTypeKey];
	
	[dict setObject:_versions forKey:BLFileVersionsKey];
	[dict setObject:attachments forKey:BLFileAttachmentsKey];
	
	if (!noBackups)
		[dict setObject:_snapshots forKey:BLFileSnapshotsKey];
    
    return dict;
}


#pragma mark - Simple Accessors

@synthesize bundleObject=_bundleObject;

- (NSString *)customFileType
{
	return _customType;
}

- (void)setCustomFileType:(NSString *)type
{
	
	if ([[self class] classForPathExtension: type])
        _customType = type;
	else
		_customType = nil;
}

- (NSString *)fileFormatInfo
{
    return nil;
}

- (NSString *)hashValue
{
    return (_hashValue) ? _hashValue : @"";
}

- (void)setHashValue:(NSString *)hashValue
{
	_hashValue = hashValue;
}

- (NSString *)name
{
	return _path;
}

@synthesize path=_path;

- (NSArray *)objects
{
	return _objects;
}

- (void)setObjects:(NSArray *)objects
{
    [objects makeObjectsPerformSelector:@selector(setFileObject:) withObject:self];
    _objects = [objects copy];
}

- (NSArray *)oldObjects
{
	return _oldObjects;
}

- (void)setOldObjects:(NSArray *)objects
{
    [objects makeObjectsPerformSelector:@selector(setFileObject:) withObject:self];
    _oldObjects = [objects copy];
}

- (NSString *)description
{
	return [NSString stringWithFormat: @"<%@: \"%@\", %lu key(s)>", NSStringFromClass([self class]), self.name, [self.objects count]];
}

- (BOOL)isEqual:(id)other
{
	if (![super isEqual: other])
		return NO;
	
	// Properties
	if (![[self path] isEqual: [other path]])
		return NO;
	
	if (!([self customFileType] == nil && [other customFileType] == nil) && ![[self customFileType] isEqual: [other customFileType]])
		return NO;
	if (!([self hashValue] == nil && [other hashValue] == nil) && ![[self hashValue] isEqual: [other hashValue]])
		return NO;
	
	// Objects
	return [[self objects] isEqual: [other objects]];
}

#pragma mark - Object Methods

- (void)addObject:(BLKeyObject *)object
{
	[[self mutableArrayValueForKey: @"objects"] addObject: object];
}

- (void)removeObject:(BLKeyObject *)object
{
	[[self mutableArrayValueForKey: @"oldObjects"] addObject: object];
	[[self mutableArrayValueForKey: @"objects"] removeObject: object];
}

- (id)parentObject
{
    return [self bundleObject];
}

- (id)objectForKey:(NSString *)key
{
	return [self objectForKey:key createIfNeeded:YES];
}

- (id)objectForKey:(NSString *)key createIfNeeded:(BOOL)create
{
    BLKeyObject *object;
    
    if (!key)
        return nil;
	
	// Try to find an existing key object
    object = nil;
    for (NSUInteger i=0; i<[_objects count]; i++) {
        if ([[[_objects objectAtIndex: i] key] isEqual: key]) {
            object = [_objects objectAtIndex: i];
            break;
        }
	}
    
	// If wished and no key object was found, we create one here
    if (object == nil && create) {
        object = [[[[self class] classOfStoredKeys] alloc] initWithKey: key];
        [self addObject: object];
    }
    
    return object;
}

- (NSUInteger)removeObjectsWithKeyInArray:(NSArray *)limitedKeys
{
	NSUInteger count = 0;
	
    for (NSUInteger i=0; i<[_objects count]; i++) {
        if ([limitedKeys containsObject: [[_objects objectAtIndex: i] key]]) {
            [self removeObject: [_objects objectAtIndex: i--]];
			count++;
		}
    }
	
	return count;
}

- (NSUInteger)removeObjectsWithKeyNotInArray:(NSArray *)limitedKeys
{
	NSUInteger count = 0;
	
    for (NSUInteger i=0; i<[_objects count]; i++) {
        if (![limitedKeys containsObject: [[_objects objectAtIndex: i] key]]) {
            [self removeObject: [_objects objectAtIndex: i--]];
			count++;
		}
    }
	
	return count;
}

- (void)snapshotLanguage:(NSString *)language
{
	NSMutableDictionary *mutableSnapshots = [_snapshots mutableCopy];
	[mutableSnapshots setObject:[_objects valueForKey: @"key"] forKey:language];
	_snapshots = [mutableSnapshots copy];
	
	for (BLKeyObject *object in _objects)
		[object snapshotLanguage: language];
}

- (NSArray *)snapshotForLanguage:(NSString *)language
{
	// No snapshot yet
	if (![_snapshots objectForKey: language])
		return _objects;
	
	// Find key objects
	NSMutableArray *keys = [NSMutableArray arrayWithArray: [_snapshots objectForKey: language]];
	NSMutableArray *snapshot = [NSMutableArray array];
	
	for (BLKeyObject *object in _objects) {
		if (![keys count])
			break;
		if ([keys containsObject: object.key]) {
			[snapshot addObject: object];
			[keys removeObject: object.key];
		}
	}
	
	// Not all objects found
	for (BLKeyObject *object in [_oldObjects reverseObjectEnumerator]) {
		if (![keys count])
			break;
		if ([keys containsObject: object.key]) {
			[snapshot addObject: object];
			[keys removeObject: object.key];
		}
	}
	
	return snapshot;
}



#pragma mark - Internals

- (id)files
{
    return nil;
}

#pragma mark - Attached objects

- (NSUInteger)versionForLanguage:(NSString *)language
{
	NSUInteger version;
	
	version = [[_versions objectForKey: language] integerValue];
	if (version > 0)
		return version;
	
	for (NSString *number in [_versions allValues]) {
		NSUInteger n = [number integerValue];
		version = (n > version) ? n : version;
	}
	
	return version;
}

- (void)setVersion:(NSUInteger)version forLanguage:(NSString *)language
{
	NSMutableDictionary *mutableVersions = [_versions mutableCopy];
	
	if (version > 0)
		[mutableVersions setObject:[NSString stringWithFormat: @"%lu", version] forKey:language];
	else
		[mutableVersions removeObjectForKey: language];
	
	_versions = [mutableVersions copy];
}

- (BOOL)offsetVersionForLanguageIfNeeded:(NSString *)language
{
	NSUInteger origVersion = [self versionForLanguage: language];
	NSUInteger maxVersion = 0;
	
	// Find the second-largest version
	for (NSString *aLanguage in [_versions allKeys]) {
		if ([aLanguage isEqual: language])
			continue;
		
		NSUInteger otherVersion = [self versionForLanguage: aLanguage];
		maxVersion = (otherVersion > maxVersion) ? otherVersion : maxVersion;
	}
	
	// Check wether increase is needed
	if (origVersion > maxVersion)
		return NO;
	
	// Calculte new version
	NSUInteger newVersion = maxVersion + 1;
	[self setVersion:newVersion forLanguage:language];
	
	// Re-Reference objects
	for (NSString *key in [_attachments allKeys])
		[self setAttachedObject:[self attachedObjectForKey:key version:origVersion] forKey:key version:newVersion];
	
	return YES;
}

- (id)attachedObjectForKey:(NSString *)key
{
	return [self attachedObjectForKey:key version:[self versionForLanguage: nil]];
}

- (id)attachedObjectForKey:(NSString *)key version:(NSUInteger)version
{
	return [[_attachments objectForKey: key] objectForKey: [NSString stringWithFormat: @"%lu", version]];
}

- (void)setAttachedObject:(id)object forKey:(NSString *)key version:(NSUInteger)version
{
	if (!object || !key)
		return;
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: [_attachments objectForKey: key]];
	[dict setObject:object forKey:[NSString stringWithFormat: @"%lu", version]];
	
	NSMutableDictionary *mutableAttachments = [_attachments mutableCopy];
	[mutableAttachments setObject:dict forKey:key];
	_attachments = [mutableAttachments copy];
}

@end

#pragma mark -

@implementation BLPlaceholderFileObject

- (id)initWithPath:(NSString *)path
{
    Class class;
    
    if ((class = [BLFileObject classForPathExtension: [path pathExtension]]))
        return [[class alloc] initWithPath: path];
    
    return nil;
}

- (id)initWithPathExtension:(NSString *)extension
{
    Class class;
    
    if ((class = [BLFileObject classForPathExtension: extension]))
        return [[class alloc] initWithPathExtension: extension];
    
    return nil;
}

- (id)initWithPropertyList:(NSDictionary *)plist
{
    Class class;
    
    if ((class = NSClassFromString([plist objectForKey: BLFileClassKey])))
		return [[class alloc] initWithPropertyList: plist];
    
	return nil;
}

@end
