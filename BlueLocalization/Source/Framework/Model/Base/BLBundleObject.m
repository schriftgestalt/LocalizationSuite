/*!
 @header
 BLBundleObject.m
 Created by Max Seelemann on 24.07.06.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLBundleObject.h"

#import "BLFileInternal.h"
#import "BLFileObject.h"

@implementation BLBundleObject

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqual:@"changeDescription"])
		keyPaths = [keyPaths setByAddingObject:@"files"];
	if ([key isEqual:@"objects"])
		keyPaths = [keyPaths setByAddingObject:@"files"];
	if ([key isEqual:@"name"])
		keyPaths = [keyPaths setByAddingObject:@"path"];

	return keyPaths;
}

#pragma mark - Initializers

- (id)init {
	self = [super init];

	if (self) {
		_files = [[NSMutableArray alloc] init];
		_name = nil;
		_namingStyle = BLIdentifiersAndDescriptionsNamingStyle;
		_path = [[NSString alloc] init];
		_referencingStyle = BLAbsoluteReferencingStyle;
		_xcodeProjects = [[NSArray alloc] init];
	}

	return self;
}

- (id)initWithPath:(NSString *)path {
	self = [self init];

	if (self) {
		[self setPath:path];
		[self setName:[path lastPathComponent]];
	}

	return self;
}

#pragma mark - Convenience Allocators

+ (id)bundleObject {
	return [[BLBundleObject alloc] init];
}

+ (id)bundleObjectWithPath:(NSString *)path {
	return [[BLBundleObject alloc] initWithPath:path];
}

#pragma mark - Serialization

- (id)initWithPropertyList:(NSDictionary *)plist {
	self = [super initWithPropertyList:plist];

	if (self) {
		[self setFiles:[plist objectForKey:BLFileFilesKey]];

		[self setName:[plist objectForKey:BLFileUserNameKey]];
		[self setNamingStyle:[[plist objectForKey:BLFileNamingStyleKey] intValue]];
		[self setPath:[plist objectForKey:BLFileNameKey]];
		[self setReferencingStyle:[[plist objectForKey:BLFileReferencingStyleKey] intValue]];
		[self setAssociatedXcodeProjects:[plist objectForKey:BLFileXcodeProjectsKey]];

		[_changedValues setArray:[plist objectForKey:BLFileChangedValuesKey]];
	}

	return self;
}

- (NSDictionary *)propertyListWithAttributes:(NSDictionary *)attributes {
	NSMutableArray *archivedObjects = [NSMutableArray array];
	for (BLFileObject *file in [self files]) {
		if ([file isActive] || ![[attributes objectForKey:BLActiveObjectsOnlySerializationKey] boolValue])
			[archivedObjects addObject:file];
	}

	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setDictionary:[super propertyListWithAttributes:attributes]];

	[dict secureSetObject:[self path] forKey:BLFileNameKey];
	[dict secureSetObject:[self name] forKey:BLFileUserNameKey];
	[dict secureSetObject:[NSNumber numberWithInt:[self namingStyle]] forKey:BLFileNamingStyleKey];
	[dict secureSetObject:[NSNumber numberWithInt:[self referencingStyle]] forKey:BLFileReferencingStyleKey];
	[dict secureSetObject:archivedObjects forKey:BLFileFilesKey];
	[dict secureSetObject:[self associatedXcodeProjects] forKey:BLFileXcodeProjectsKey];

	return dict;
}

#pragma mark - Simple Accessors

- (NSString *)path {
	return _path;
}

- (void)setPath:(NSString *)path {
	_path = [path copy];
}

- (NSString *)name {
	if (_name)
		return _name;
	else
		return [_path lastPathComponent];
}

- (void)setName:(NSString *)name {
	_name = [name copy];
}

- (NSArray *)files {
	return _files;
}

- (void)setFiles:(NSArray *)files {
	[files makeObjectsPerformSelector:@selector(setBundleObject:) withObject:self];
	_files = [files copy];
}

- (BLFileObject *)fileWithName:(NSString *)name {
	for (BLFileObject *file in _files) {
		if ([[file name] isEqual:name])
			return file;
	}

	return nil;
}

- (BLNamingStyle)namingStyle {
	return _namingStyle;
}

- (void)setNamingStyle:(BLNamingStyle)namingStyle {
	_namingStyle = namingStyle;
}

- (BLReferencingStyle)referencingStyle {
	return _referencingStyle;
}

- (void)setReferencingStyle:(BLReferencingStyle)referencingStyle {
	_referencingStyle = referencingStyle;
}

- (NSArray *)associatedXcodeProjects {
	return _xcodeProjects;
}

- (void)setAssociatedXcodeProjects:(NSArray *)projects {
	if (projects)
		_xcodeProjects = projects;
	else
		_xcodeProjects = [[NSArray alloc] init];
}

- (void)addAssociatedXcodeProject:(NSString *)relativePath {
	if (!self.associatedXcodeProjects)
		self.associatedXcodeProjects = [NSArray arrayWithObject:relativePath];
	else if (![self.associatedXcodeProjects containsObject:relativePath])
		self.associatedXcodeProjects = [self.associatedXcodeProjects arrayByAddingObject:relativePath];
}

#pragma mark - Further Methods

- (void)addFile:(BLFileObject *)object {
	[[self mutableArrayValueForKey:@"files"] addObject:object];
}

- (void)removeFile:(BLFileObject *)object {
	[[self mutableArrayValueForKey:@"files"] removeObject:object];
}

- (NSArray *)objects {
	return [self files];
}

- (id)parentObject {
	return nil;
}

- (NSString *)changeDescription {
	NSUInteger i, changes, errors;

	errors = 0;
	changes = 0;

	for (i = 0; i < [_files count]; i++) {
		changes += ([[[_files objectAtIndex:i] changedValues] count] > 0);
		errors += ([[[_files objectAtIndex:i] errors] count] > 0);
	}

	if (errors > 0)
		return [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"BLBundleObjectErrorDescription", @"Localizable", [NSBundle bundleForClass:[self class]], nil), errors];
	else if (changes == 1)
		return NSLocalizedStringFromTableInBundle(@"BLBundleObjectChangeDescription1", @"Localizable", [NSBundle bundleForClass:[self class]], nil);
	else if (changes)
		return [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"BLBundleObjectChangeDescription", @"Localizable", [NSBundle bundleForClass:[self class]], nil), changes];
	else
		return nil;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: \"%@\", %ld file(s)>", NSStringFromClass([self class]), self.name, [self.files count]];
}

- (BOOL)isEqual:(id)other {
	if (![super isEqual:other])
		return NO;

	// Properties
	if (![[self name] isEqual:[other name]])
		return NO;
	if (![[self path] isEqual:[other path]])
		return NO;

	// Flags
	if ([self namingStyle] != [other namingStyle])
		return NO;
	if ([self referencingStyle] != [other referencingStyle])
		return NO;

	// Files
	return [[self files] isEqual:[other files]];
}

@end
