/*!
 @header
 NPPreviewBuilder.m
 Created by max on 02.03.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

#import <NibPreview/NPPreviewBuilder.h>

#import "NPColorAdditions.h"
#import "NPLazyStringValue.h"
#import "NPObjectPropertyExtensions.h"
#import "NPObject.h"


NSString *IBToolClassesKey			= @"com.apple.ibtool.document.classes";
NSString *IBToolHierarchyKey		= @"com.apple.ibtool.document.hierarchy";
NSString *IBToolObjectsKey			= @"com.apple.ibtool.document.objects";

NSString *IBToolClassClassKey		= @"class";
NSString *IBToolObjectClassNameKey	= @"className";
NSString *IBToolClassSuperclassKey	= @"superclass";
NSString *IBToolClassCustomClassKey	= @"custom-class";

NSString *IBToolObjectClassKey		= @"class";

NSString *IBToolHierarchyChildsKey	= @"children";
NSString *IBToolHierarchyIDKey		= @"object-id";
NSString *IBToolHierarchyLabelKey	= @"label";


/*!
 @abstract Internal methods used by NPPreviewBuilder
 */
@interface NPPreviewBuilder ()

/*!
 @abstract Creates the class map from the given description.
 @discussion Non-existent classes will be mapped to their superclasses.
 */
- (void)buildClassMapFromDescription:(NSDictionary *)classesDict;

/*!
 @abstract Builds the objects dictionary for the given description.
 @discussion For all objects specified by objectsDict, it will be tried to create and instanciated version. Thereby, unknown classes will (if possible) be replaced by superclasses from the classes dictionary. All given properties will be tried to be set, and caught if the atempt fails, printing an error to the console. Like in setValue:forKey:, values will be set using setMappedValue:forKey: as specified by NPObjectPropertyExtensions. After the method as finished, all created objects will be contained in the objects property.
 */
- (void)buildObjectsFromDescription:(NSDictionary *)objectsDict;

/*!
 @abstract Preprocesses and maybe alters an object description.
 @discussion Object descriptions have several attributes that must be mapped to other data structures or are not needed / not usable, which is done by this method. In detail:
 1. Class and AppleScript keys are removed
 2. Values that are not printable by ibtool are removed
 3. Color Strings are converted into a color using colorFromIBToolString:
 4. String values starting with a curly bracket ("{") will be converted to a lazily evaluating value (NPLazyStringValue) that might be converted to either NSPoint, NSRect, NSSize, NSRange or NSString.
 */
- (NSDictionary *)preprocessObjectDescription:(NSDictionary *)dictionary;

/*!
 @abstract Creates a description 
 */
- (NSDictionary *)descriptionOfObject:(id)object forProperties:(NSUInteger)properties;

/*!
 @abstract Builds the whole hierarchy description.
 @discussion From the given array of hierarchies, all objects with a positive object id will be put into a hierarchy and returned accordingly. The hierarchy will be built using previewObjectFromHierarchyDescription:. After the method has finished, all root preview objects will be contained in the rootObjects property.
 */
- (void)buildHierarchyFromDescriptions:(NSArray *)hierarchyDescriptions;

/*!
 @abstract Creates a preview object from a hierarchy description.
 @discussion Recursively builds a hierarchy of preview objects (NPObject) and their instantiated originals from the given description. Each preview object will then have the id of the nib object and will have the original property set to a instantiated original. Both hierarchies will match, meaning that the childs of a preview object will map to the childs of the original. NSWindows will be skipped.
 */
- (NPObject *)previewObjectFromHierarchyDescription:(NSDictionary *)itemDict;

@end


@implementation NPPreviewBuilder

- (id)init
{
	self = [super init];
	
	if (self) {
		_classes = nil;
		_objects = nil;
		_previewObjects = [[NSMutableDictionary alloc] init];
		_rootObjects = nil;
	}
	
	return self;
}



#pragma mark - Public Access

- (BOOL)previewWasBuilt
{
	return (_classes != nil) && (_objects != nil) && (_rootObjects != nil);
}

@synthesize classes=_classes;
@synthesize objects=_objects;
@synthesize previewObjects=_previewObjects;

- (NSArray *)rootObjects
{
	return [_rootObjects allValues];
}

- (void)buildPreviewFromDescription:(NSDictionary *)dictionary
{	
	[self buildClassMapFromDescription: [dictionary objectForKey: IBToolClassesKey]];
	BLLog(BLLogInfo, @"Created class map with %d entries.", [_classes count]);
	
	[self buildObjectsFromDescription: [dictionary objectForKey: IBToolObjectsKey]];
	BLLog(BLLogInfo, @"Created %d interface object(s).", [_objects count]);
	
	[self buildHierarchyFromDescriptions: [dictionary objectForKey: IBToolHierarchyKey]];
	BLLog(BLLogInfo, @"Created hierarchy: %d root object(s).", [_rootObjects count]);
}

- (NSDictionary *)descriptionForObjectProperties:(NSUInteger)properties
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	for (NPObject *object in [_previewObjects allValues]) {
		NSDictionary *objectDict = [self descriptionOfObject:object.original forProperties:properties];
		if (objectDict)
			[dict setObject:objectDict forKey:object.nibObjectID];
	}
	
	return dict;
}


#pragma mark - Classes

- (void)buildClassMapFromDescription:(NSDictionary *)classesDict
{
	NSMutableDictionary *classTranslation;
	NSArray *classDescriptions;
	
	NSAssert(classesDict != nil, @"no class dict");
	
	// Scan the classes dictionary
	classDescriptions = [classesDict allValues];
	classTranslation = [[NSMutableDictionary alloc] initWithCapacity: [classDescriptions count]];
	
	for (__strong NSDictionary *classDescription in classDescriptions) {
		NSString *className, *origClassName;
		Class class;
		
		origClassName = [classDescription objectForKey: IBToolClassClassKey];
		
		do {
			className = [classDescription objectForKey: IBToolClassClassKey];
			class = NSClassFromString(className);
		} while (class == nil
				 && (classDescription = [classesDict objectForKey: [classDescription objectForKey: IBToolClassSuperclassKey]]));
		
		if (class != nil)
			[classTranslation setObject:class forKey:origClassName];
	}
	
	// Custom mappings
	[classTranslation setObject:[NSWindow class] forKey:@"NSWindowTemplate"];
	
	// Done
	_classes = classTranslation;
}


#pragma mark - Objects

- (void)buildObjectsFromDescription:(NSDictionary *)objectsDict
{
	NSMutableDictionary *objectTranslation;
	NSArray *objectIDs;
	
	NSAssert(_classes != nil, @"no classes");
	NSAssert(objectsDict != nil, @"no objects dict");
	
	BLLogBeginGroup(@"Initializing objects, errors likely...");
	
	objectIDs = [objectsDict allKeys];
	objectTranslation = [[NSMutableDictionary alloc] initWithCapacity: [objectIDs count]];
	
	for (NSString *objectID in objectIDs) {
		// Get description
		NSDictionary *description = [objectsDict objectForKey: objectID];
		
		if ([objectID intValue] <= 0)
			continue;
		
		// Get class and create object
		Class class = [_classes objectForKey: [description objectForKey: IBToolClassCustomClassKey]];
		if (class == Nil)
			class = [_classes objectForKey: [description objectForKey: IBToolObjectClassNameKey]];
		if (class == Nil)
			class = [_classes objectForKey: [description objectForKey: IBToolObjectClassKey]];
		if (class == Nil)
			continue;
		
		// Try to create object
		__block id object;
		
		@try {
			object = [[class alloc] init];
		}
		@catch (NSException *e) {
			// Some objects want to be initialized on main thread...
			dispatch_sync(dispatch_get_main_queue(), ^{
				@try {
					object = [[class alloc] init];
				}
				@catch (NSException *e) {
					BLLog(BLLogWarning, @"Failed creating object of class %@. Reason: %@", NSStringFromClass(class), [e description]);
					object = nil;
				}
			});
		}
		
		// Check whether object was actually created
		if (object == nil)
			continue;
		
		// Send initialize message
		@try {
			[object initialize];
		}
		@catch (NSException *e) {
			BLLog(BLLogInfo, @"Error during initialization of object of class %@.", NSStringFromClass(class));
		}
		
		// Set all properties
		description = [self preprocessObjectDescription: description];
		
		NSArray *keys = [description allKeys];
		for (NSString *key in keys) {
			id value;
			
			value = [description objectForKey: key];
			
			// General things
			@try {
				[object setMappedValue:value forKey:key];
			}
			@catch (NSException *e) {
				BLLog(BLLogInfo, @"Failed setting %@ to object of class %@. Reason: %@", key, NSStringFromClass(class), [e description]);
			}
		}
		
		[objectTranslation setObject:object forKey:objectID];
	}
	
	BLLogEndGroup();
	
	_objects = objectTranslation;
}

- (NSDictionary *)preprocessObjectDescription:(NSDictionary *)dictionary
{
	NSMutableDictionary *newDict;
	NSArray *keys;
	
	newDict = [NSMutableDictionary dictionaryWithCapacity: [dictionary count]];
	keys = [dictionary allKeys];
	
	for (NSString *key in keys) {
		id value;
		
		value = [dictionary objectForKey: key];
		
		// Skip some special fields / values
		if (   [key isEqual: IBToolObjectClassKey]
			|| [key isEqual: IBToolObjectClassNameKey]
			|| [key isEqual: IBToolClassCustomClassKey]
			|| [key hasPrefix: @"appleScript"]
			|| ([value isKindOfClass: [NSString class]]
				&& [value hasPrefix: @"[This value is not printable by ibtool"])
			)
			continue;
		
		// Detect color strings and convert to colors
		if ([value isKindOfClass: [NSString class]] && [value rangeOfString: @"ColorSpace"].location != NSNotFound) {
			NSColor *color;
			
			color = [NSColor colorFromIBToolString: value];
			if (color)
				value = color;
		}
		
		// Detect size / range / point / rect strings and convert to lazy value
		if ([value isKindOfClass: [NSString class]] && [value hasPrefix: @"{"])
			value = [NPLazyStringValue valueWithString: value];
		
		[newDict setObject:value forKey:key];
	}
	
	return newDict;
}

- (NSDictionary *)descriptionOfObject:(id)object forProperties:(NSUInteger)properties
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	// Frames
	if (properties & NPPreviewBuilderFrameObjectProperty) {
		// Views
		if ([object isKindOfClass: [NSView class]]) {
			NSRect frame = [object frame];
			
			[dict setObject:NSStringFromSize(frame.size) forKey:@"frameSize"];
			[dict setObject:NSStringFromPoint(frame.origin) forKey:@"frameOrigin"];
		}
		
		// Windows
		if ([object isKindOfClass: [NSWindow class]]) {
			NSRect rect = [object contentRectForFrameRect: [object frame]];
			
			[dict setObject:NSStringFromSize(rect.size) forKey:@"contentRectSize"];
			[dict setObject:NSStringFromPoint(rect.origin) forKey:@"contentRectOrigin"];
		}
	}
	
	return ([dict count]) ? dict : nil;
}


#pragma mark - Hierarchy

- (void)buildHierarchyFromDescriptions:(NSArray *)hierarchyDescriptions
{
	NSMutableDictionary *rootObjects;
	
	rootObjects = [[NSMutableDictionary alloc] initWithCapacity: [hierarchyDescriptions count]];
	
	for (NSDictionary *item in hierarchyDescriptions)
	{
		NSString *identifier;
		NPObject *preview;
		
		id objectId = [item objectForKey: IBToolHierarchyIDKey];
		identifier = [objectId isKindOfClass: [NSString class]] ? objectId : [objectId stringValue];
		
		// Do not take the default items
		if ([identifier intValue] <= 0)
			continue;
		
		preview = [self previewObjectFromHierarchyDescription: item];
		
		if (preview)
			[rootObjects setObject:preview forKey:identifier];
	}
	
	_rootObjects = rootObjects;
}

- (NPObject *)previewObjectFromHierarchyDescription:(NSDictionary *)itemDict
{
	NSMutableArray *children, *childPreviewObjects;
	NSArray *childDescriptions;
	NPObject *previewObject;
	NSString *identifier;
	id original;
	
	// Init
	id objectId = [itemDict objectForKey: IBToolHierarchyIDKey];
	identifier = [objectId isKindOfClass: [NSString class]] ? objectId : [objectId stringValue];
	childDescriptions = [itemDict objectForKey: IBToolHierarchyChildsKey];
	
	original = [_objects objectForKey: identifier];
	
	// Create preview object
	previewObject = [NPObject previewObjectWithOriginal:original andID:identifier];
	[previewObject setLabel: [itemDict objectForKey: IBToolHierarchyLabelKey]];
	
	// Get all children
	children = [NSMutableArray arrayWithCapacity: [childDescriptions count]];
	childPreviewObjects = [NSMutableArray arrayWithCapacity: [childDescriptions count]];
	
	for (NSDictionary *childDesc in childDescriptions) {
		NPObject *childPreview;
		
		childPreview = [self previewObjectFromHierarchyDescription: childDesc];
		
		if (!childPreview || ![childPreview original])
			continue;
		
		[children addObject: [childPreview original]];
		[childPreviewObjects addObject: childPreview];
	}
	
	// Build object hierarchy
	@try {
		[original setChildren: children];
	}
	@catch (NSException * e) {}
	
	[previewObject setChildren: childPreviewObjects];
	[_previewObjects setObject:previewObject forKey:identifier];
	
	// Notify all objects that we're finsihed
	[children makeObjectsPerformSelector: @selector(finished)];
	
	return previewObject;
}

@end

