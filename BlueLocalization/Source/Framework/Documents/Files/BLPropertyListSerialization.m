/*!
 @header
 BLPropertyListSerialization.h
 Created by Max Seelemann on 14.03.10.
 
 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */

#import "BLPropertyListSerialization.h"

#import "BLFileInternal.h"

NSString *BLActiveObjectsOnlySerializationKey		= @"activeOnly";
NSString *BLClearChangeInformationSerializationKey	= @"clearChanges";
NSString *BLClearAllBackupsSerializationKey			= @"noBackups";
NSString *BLLanguagesSerializationKey				= @"languages";


@implementation BLPropertyListSerializer

+ (id)serializeObject:(id)object withAttributes:(NSDictionary *)attributes outWrappers:(NSDictionary **)fileWrappers
{
	// Array
	if ([object isKindOfClass: [NSArray class]]) {
		NSMutableArray *array = [NSMutableArray array];
		
		// Convert contained objects
		for (id child in object)
			[array addObject: [self serializeObject:child withAttributes:attributes outWrappers:fileWrappers]];
		
		return array;
	}
	
	// Dictionary
	if ([object isKindOfClass: [NSDictionary class]]) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		
		// Convert contained objects
		for (id key in [object allKeys])
			[dict setObject:[self serializeObject:[object objectForKey: key] withAttributes:attributes outWrappers:fileWrappers] forKey:key];
		
		return dict;
	}
	
	// Wrapper handles
	if ([object isKindOfClass: [BLWrapperHandle class]]) {
		// Works only if wrappers should be retuned
		if (!fileWrappers)
			return nil;
		
		// Merge handler into tree
		NSFileWrapper *wrapper = nil;
		
		// Find/build path to folder
		for (NSString *part in [[object preferredPath] pathComponents]) {
			// Inside a wrapper
			if (wrapper) {
				NSFileWrapper *aWrapper = [[wrapper fileWrappers] objectForKey: part];
				if (aWrapper) {
					wrapper = aWrapper;
					continue;
				}
				
				// Add a new directory
				aWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers: nil];
				[aWrapper setPreferredFilename: part];
				[wrapper addFileWrapper: aWrapper];
				wrapper = aWrapper;
			}
			// Find a root wrapper
			else {
				if ((wrapper = [*fileWrappers objectForKey: part]))
					continue;
				
				// Add a new directory
				NSMutableDictionary *rootWrappers = [NSMutableDictionary dictionaryWithDictionary: *fileWrappers];
				
				wrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers: nil];
				[wrapper setPreferredFilename: part];
				[rootWrappers setObject:wrapper forKey:part];
				
				*fileWrappers = rootWrappers;
			}
		}
		
		// Add and rename the wrapper
		NSFileWrapper *file = [object wrapper];
		NSString *name = [wrapper keyForFileWrapper: file];
		if (!name) {
			// Find a unique name if needed
			name = [file preferredFilename];
			if ([[wrapper fileWrappers] objectForKey: name]) {
				NSString *base = [name stringByDeletingPathExtension];
				NSString *extension = [name pathExtension];
				NSUInteger i = 1;
				
				do {
					name = [NSString stringWithFormat: @"%@-%lu.%@", base, i, extension];
					i++;
				} while ([[wrapper fileWrappers] objectForKey: name]);
			}
			
			[file setPreferredFilename: name];
			[wrapper addFileWrapper: file];
		} else {
			[file setPreferredFilename: name];
		}
		
		// Encode object
		return [object propertyListWithAttributes: attributes];
	}
	
	// Archivable classes
	if ([object conformsToProtocol: @protocol(BLPropertyListSerialization)]) {
		NSDictionary *archivedObject = [object propertyListWithAttributes: attributes];
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		
		for (id key in [archivedObject allKeys]) {
			id obj = [archivedObject objectForKey: key];
			obj = [self serializeObject:obj withAttributes:attributes outWrappers:fileWrappers];
			
			if (obj)
				[dict setObject:obj forKey:key];
		}
		
		[dict setObject:NSStringFromClass([object class]) forKey:BLFileClassKey];
		
		return dict;
	}
	
	// Other types
	if (![object isKindOfClass: [NSString class]] && ![object isKindOfClass: [NSNumber class]] && ![object isKindOfClass: [NSDate class]])
		return [NSKeyedArchiver archivedDataWithRootObject: object];
	
	// Regular plist types...
	return object;
}

+ (id)objectWithPropertyList:(id)obj fileWrappers:(NSDictionary *)fileWrappers
{
	// An array plist
	if ([obj isKindOfClass: [NSArray class]]) {
		NSMutableArray *array = [NSMutableArray array];
		
		// Convert contained objects
		for (id object in obj)
			[array addObject: [self objectWithPropertyList:object fileWrappers:fileWrappers]];
		
		return array;
	}
	
	// A dictionary plist
	if ([obj isKindOfClass: [NSDictionary class]]) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		
		// Convert contained objects
		for (id key in [obj allKeys])
			[dict secureSetObject:[self objectWithPropertyList:[obj objectForKey: key] fileWrappers:fileWrappers] forKey:key];
		
		// Find the class
		Class class = NSClassFromString([obj objectForKey: BLFileClassKey]);
		if (class == Nil)
			return dict;
		
		// Create an instance if possible
		id object = [[class alloc] initWithPropertyList: dict];
		
		// Special treatment of wrappers
		if (class == [BLWrapperHandle class]) {
			NSFileWrapper *wrapper = nil;
			@try {
				for (NSString *part in [[object path] pathComponents]) {
					if (wrapper)
						wrapper = [[wrapper fileWrappers] objectForKey: part];
					else
						wrapper = [fileWrappers objectForKey: part];
				}
				[object setWrapper: wrapper];
			}
			@catch (NSException *e) {
				BLLog(BLLogError, @"Error finding file at path %@ - expected directory", [object path]);
			}
		}
		
		return object;
	}
	
	// Archived data
	if ([obj isKindOfClass: [NSData class]]) {
		@try {
			return [NSKeyedUnarchiver unarchiveObjectWithData: obj];
		}
		@catch (NSException *e) {
			return nil;
		}
	}
	
	// No special format
	return obj;
}

@end

@implementation BLWrapperHandle

+ (BLWrapperHandle *)handleWithWrapper:(NSFileWrapper *)wrapper forPreferredPath:(NSString *)path
{
	BLWrapperHandle *handle = [[self alloc] init];
	
	handle.wrapper = wrapper;
	handle.preferredPath = path;
	
	return handle;
}

@synthesize path=_path;
@synthesize preferredPath=_prefPath;
@synthesize wrapper=_wrapper;

- (id)initWithPropertyList:(NSDictionary *)plist
{
	self = [self init];
	
	if (self) {
		_path = [plist objectForKey: BLFileNameKey];
	}
	
	return self;
}

- (NSDictionary *)propertyListWithAttributes:(NSDictionary *)attributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys: NSStringFromClass([self class]), BLFileClassKey, [_prefPath stringByAppendingPathComponent: [_wrapper preferredFilename]], BLFileNameKey, nil];
}

@end