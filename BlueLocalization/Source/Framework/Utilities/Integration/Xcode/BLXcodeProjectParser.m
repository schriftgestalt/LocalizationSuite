/*!
 @header
 BLXcodeProjectParser.m
 Created by max on 01.07.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLXcodeProjectParser.h"

#import "BLXcodeProjectInternal.h"
#import "BLXcodeProjectItem.h"

#define kBLXcodeProjectKnownArchiveVersion 1
#define kBLXcodeProjectKnownObjectVersion 46

NSString *BLXcodeProjectContentsFileName = @"project.pbxproj";

NSString *BLXcodeProjectArchiveVersionKey = @"archiveVersion";
NSString *BLXcodeProjectObjectVersionKey = @"objectVersion";
NSString *BLXcodeProjectRootObjectKeyKey = @"rootObject";
NSString *BLXcodeProjectObjectsKey = @"objects";

NSString *BLXcodeProjectItemMainGroupKey = @"mainGroup";
NSString *BLXcodeProjectItemTypeKey = @"isa";
NSString *BLXcodeProjectItemEncodingKey = @"fileEncoding";
NSString *BLXcodeProjectItemFileTypeKey = @"lastKnownFileType";
NSString *BLXcodeProjectItemChildrenKey = @"children";
NSString *BLXcodeProjectItemNameKey = @"name";
NSString *BLXcodeProjectItemPathKey = @"path";
NSString *BLXcodeProjectItemTreeTypeKey = @"sourceTree";

NSString *BLXcodeProjectItemTypeFile = @"PBXFileReference";
NSString *BLXcodeProjectItemTypeGroup = @"PBXGroup";
NSString *BLXcodeProjectItemTypeVariantGroup = @"PBXVariantGroup";

NSString *BLXcodeProjectTreeTypeAbsolute = @"<absolute>";
NSString *BLXcodeProjectTreeTypeGroup = @"<group>";
NSString *BLXcodeProjectTreeTypeProject = @"SOURCE_ROOT";

NSString *BLXcodeProjectFileTypeNib = @"wrapper.nib";
NSString *BLXcodeProjectFileTypeXib = @"file.xib";
NSString *BLXcodeProjectFileTypeStrings = @"text.plist.strings";
NSString *BLXcodeProjectFileTypeRTF = @"text.rtf";
NSString *BLXcodeProjectFileTypePlist = @"text.plist.xml";

@interface BLXcodeProjectParser () {
	BOOL _changed;
	NSMutableDictionary *_contents;
	BLXcodeProjectItem *_mainGroup;
	NSString *_path;
}

@end

@implementation BLXcodeProjectParser

+ (NSArray *)pathExtensions {
	return [NSArray arrayWithObject:@"xcodeproj"];
}

+ (id)parserWithProjectFileAtPath:(NSString *)path {
	return [[self alloc] initWithProjectFileAtPath:path];
}

- (id)initWithProjectFileAtPath:(NSString *)path {
	self = [super init];

	if (self) {
		_contents = nil;
		_path = path;
		_mainGroup = nil;
	}

	return self;
}

#pragma mark - Accessors

- (NSString *)projectPath {
	return [_path stringByDeletingLastPathComponent];
}

- (NSString *)projectName {
	return [_path lastPathComponent];
}

#pragma mark - Loading & Saving

- (void)loadProject {
	// Check the existence of the project
	NSString *path = [_path stringByAppendingPathComponent:BLXcodeProjectContentsFileName];
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		BLLog(BLLogError, @"No project found at path \"%@\"", path);
	}

	// Get the contents
	NSString *error;

	_contents = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:path] mutabilityOption:NSPropertyListMutableContainersAndLeaves format:NULL errorDescription:&error];
	if (!_contents) {
		BLLog(BLLogError, @"Unable to read Xcode project file at path \"%@\". Error: %@", _path, error);
		return;
	}

	// Check file versions
	NSUInteger version;

	version = [[_contents objectForKey:BLXcodeProjectArchiveVersionKey] intValue];
	if (version > kBLXcodeProjectKnownArchiveVersion)
		BLLog(BLLogWarning, @"Archive version of project (%d) higher than known (%d). This may cause problems. Project path:\"%@\"", version, kBLXcodeProjectKnownArchiveVersion, _path);

	version = [[_contents objectForKey:BLXcodeProjectObjectVersionKey] intValue];
	if (version > kBLXcodeProjectKnownObjectVersion)
		BLLog(BLLogWarning, @"Object version of project (%d) higher than known (%d). This may cause problems. Project path:\"%@\"", version, kBLXcodeProjectKnownObjectVersion, _path);

	// Create the object tree
	NSMutableDictionary *project, *itemRoot;

	project = [self objectWithIdentifier:[_contents objectForKey:BLXcodeProjectRootObjectKeyKey]];
	itemRoot = [self objectWithIdentifier:[project objectForKey:BLXcodeProjectItemMainGroupKey]];

	_mainGroup = [BLXcodeProjectItem itemFromDictionary:itemRoot withParent:nil andParser:self];
	_changed = NO;
}

- (BOOL)projectIsLoaded {
	return (_contents != nil);
}

- (BOOL)projectWasChanged {
	return _changed;
}

- (void)noteProjectWasChanged {
	_changed = YES;
}

- (BLXcodeProjectItem *)mainGroup {
	return _mainGroup;
}

- (BOOL)writeProject {
	// With no changes, we don't need to write anything
	if (!_changed)
		return YES;

	// Check the existence of the project
	NSString *path = [_path stringByAppendingPathComponent:BLXcodeProjectContentsFileName];
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		BLLog(BLLogError, @"No project found at path \"%@\"", path);
		return NO;
	}

	// Encode the contents
	NSString *error;
	NSData *data = [NSPropertyListSerialization dataFromPropertyList:_contents format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
	if (!data) {
		BLLog(BLLogError, @"Unable to encode Xcode project file. Error: %@", error);
		return NO;
	}

	// Write to disk
	if (![data writeToFile:path options:NSAtomicWrite error:nil]) {
		BLLog(BLLogError, @"Unable to write Xcode project file to path \"%@\".", path);
		return NO;
	}

	return YES;
}

#pragma mark - Object Management

- (NSMutableDictionary *)objectWithIdentifier:(NSString *)identifier {
	return [[_contents objectForKey:BLXcodeProjectObjectsKey] objectForKey:identifier];
}

- (NSString *)createUniqueIdentifier {
	NSDictionary *objects;
	NSString *hash;

	objects = [_contents objectForKey:BLXcodeProjectObjectsKey];

	do {
		hash = [NSString stringWithFormat:@"%08x%08x%08x", arc4random(), arc4random(), arc4random()];
		hash = [hash uppercaseString];
	} while ([objects objectForKey:hash]);

	return hash;
}

- (NSString *)addObject:(NSMutableDictionary *)dictionary {
	NSString *identifier = [self createUniqueIdentifier];

	NSMutableDictionary *objects = [_contents objectForKey:BLXcodeProjectObjectsKey];
	[objects setObject:dictionary forKey:identifier];

	[self noteProjectWasChanged];
	return identifier;
}

- (void)removeObjectWithIdentifier:(NSString *)identifier {
	[[_contents objectForKey:BLXcodeProjectObjectsKey] removeObjectForKey:identifier];
	[self noteProjectWasChanged];
}

@end
