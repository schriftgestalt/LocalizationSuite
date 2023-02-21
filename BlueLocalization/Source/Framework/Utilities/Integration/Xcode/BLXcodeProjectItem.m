/*!
 @header
 BLXcodeProjectItem.m
 Created by max on 02.07.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLXcodeProjectItem.h"

#import "BLXcodeProjectInternal.h"
#import "BLXcodeProjectParser.h"

@interface BLXcodeProjectItem () {
	NSMutableDictionary *_children;
	NSMutableDictionary *_dictionary;
	BLXcodeProjectItem *_parent;
	BLXcodeProjectParser *_parser;
}

@end

@implementation BLXcodeProjectItem

+ (BLXcodeProjectItem *)blankItemWithType:(BLXcodeItemType)type {
	return [[self alloc] initBlankItemWithType:type];
}

- (id)initBlankItemWithType:(BLXcodeItemType)type {
	self = [super init];

	if (self) {
		_children = nil;
		_dictionary = [[NSMutableDictionary alloc] init];
		_parent = nil;
		_parser = nil;

		[self setItemType:type];
		[self setPathType:BLXcodePathTypeGroup];
	}

	return self;
}

+ (BLXcodeProjectItem *)itemFromDictionary:(NSMutableDictionary *)dictionary withParent:(BLXcodeProjectItem *)parent andParser:(BLXcodeProjectParser *)parser {
	return [[self alloc] initFromDictionary:dictionary withParent:parent andParser:parser];
}

- (id)initFromDictionary:(NSMutableDictionary *)dictionary withParent:(BLXcodeProjectItem *)parent andParser:(BLXcodeProjectParser *)parser {
	self = [super init];

	if (self) {
		_children = nil;
		_dictionary = dictionary;
		_parent = parent;
		_parser = parser;
	}

	return self;
}

#pragma mark - General attributes

- (BLXcodeItemType)itemType {
	NSString *typeName = [_dictionary objectForKey:BLXcodeProjectItemTypeKey];

	if ([typeName isEqual:BLXcodeProjectItemTypeFile])
		return BLXcodeItemTypeFile;
	if ([typeName isEqual:BLXcodeProjectItemTypeGroup])
		return BLXcodeItemTypeGroup;
	if ([typeName isEqual:BLXcodeProjectItemTypeVariantGroup])
		return BLXcodeItemTypeVariantGroup;

	return BLXcodeItemTypeUnknown;
}

- (void)setItemType:(BLXcodeItemType)newType {
	if (newType != self.itemType)
		[_parser noteProjectWasChanged];

	switch (newType) {
		case BLXcodeItemTypeFile:
			[_dictionary setObject:BLXcodeProjectItemTypeFile forKey:BLXcodeProjectItemTypeKey];
			break;
		case BLXcodeItemTypeGroup:
			[_dictionary setObject:BLXcodeProjectItemTypeGroup forKey:BLXcodeProjectItemTypeKey];
			break;
		case BLXcodeItemTypeVariantGroup:
			[_dictionary setObject:BLXcodeProjectItemTypeVariantGroup forKey:BLXcodeProjectItemTypeKey];
			break;
		default:
			[NSException raise:NSInvalidArgumentException format:@"No valid type given"];
			break;
	}
}

- (NSString *)name {
	NSString *name = [_dictionary objectForKey:BLXcodeProjectItemNameKey];
	return (name) ? name : [self path];
}

- (void)setName:(NSString *)newName {
	if (![newName isEqualToString:self.name])
		[_parser noteProjectWasChanged];

	[_dictionary setObject:newName forKey:BLXcodeProjectItemNameKey];
}

- (NSString *)fileType {
	return [_dictionary objectForKey:BLXcodeProjectItemFileTypeKey];
}

- (void)setFileType:(NSString *)newType {
	if (![newType isEqualToString:self.fileType])
		[_parser noteProjectWasChanged];

	if (newType)
		[_dictionary setObject:newType forKey:BLXcodeProjectItemFileTypeKey];
	else
		[_dictionary removeObjectForKey:BLXcodeProjectItemFileTypeKey];
}

- (NSStringEncoding)encoding {
	NSNumber *encoding = [_dictionary objectForKey:BLXcodeProjectItemEncodingKey];
	return (encoding) ? [encoding intValue] : 0;
}

- (void)setEncoding:(NSStringEncoding)encoding {
	if (encoding != self.encoding)
		[_parser noteProjectWasChanged];

	if (encoding > 0)
		[_dictionary setObject:@(encoding) forKey:BLXcodeProjectItemEncodingKey];
	else
		[_dictionary removeObjectForKey:BLXcodeProjectItemEncodingKey];
}

- (NSMutableDictionary *)dictionary {
	return _dictionary;
}

- (void)setParser:(BLXcodeProjectParser *)aParser {
	_parser = aParser;
}

#pragma mark - Item hierarchy

- (NSArray *)children {
	NSArray *childKeys;

	if ([self itemType] == BLXcodeItemTypeFile)
		return nil;
	childKeys = [_dictionary objectForKey:BLXcodeProjectItemChildrenKey];

	// Build child array
	if (!_children) {
		_children = [[NSMutableDictionary alloc] initWithCapacity:[childKeys count]];

		for (NSString *key in childKeys) {
			BLXcodeProjectItem *item = [BLXcodeProjectItem itemFromDictionary:[_parser objectWithIdentifier:key] withParent:self andParser:_parser];
			[_children setObject:item forKey:key];
		}
	}

	// We need to retain the order though we use a dictionary
	return [_children objectsForKeys:childKeys notFoundMarker:[NSNull null]];
}

- (void)addChild:(BLXcodeProjectItem *)item {
	NSString *identifier;

	if (!_parser)
		[NSException raise:NSInternalInconsistencyException format:@"Items must be added to items that belong to a parser"];

	identifier = [_parser addObject:[item dictionary]];
	[(NSMutableArray *)[_dictionary objectForKey:BLXcodeProjectItemChildrenKey] addObject:identifier];

	[item setParent:self];
	[item setParser:_parser];
	[_children setObject:item forKey:identifier];
}

- (void)removeChild:(BLXcodeProjectItem *)item {
	NSString *identifier;

	if ([[_children allKeysForObject:item] count] == 0)
		[NSException raise:NSInvalidArgumentException format:@"Item not in childrens array"];
	if ([[item children] count] > 0)
		[NSException raise:NSInvalidArgumentException format:@"Items to remove may not have children"];

	identifier = [[_children allKeysForObject:item] lastObject];
	[_parser removeObjectWithIdentifier:identifier];
	[(NSMutableArray *)[_dictionary objectForKey:BLXcodeProjectItemChildrenKey] removeObject:identifier];

	[item setParent:nil];
	[item setParser:nil];
	[_children removeObjectForKey:identifier];
}

- (BLXcodeProjectItem *)parent {
	return _parent;
}

- (void)setParent:(BLXcodeProjectItem *)newParent {
	_parent = newParent;
}

#pragma mark - Paths

- (NSString *)path {
	return [_dictionary objectForKey:BLXcodeProjectItemPathKey];
}

- (void)setPath:(NSString *)newPath {
	if (![newPath isEqualToString:self.path])
		[_parser noteProjectWasChanged];

	[_dictionary setObject:newPath forKey:BLXcodeProjectItemPathKey];
}

- (BLXcodePathType)pathType {
	NSString *treeType = [_dictionary objectForKey:BLXcodeProjectItemTreeTypeKey];

	if ([treeType isEqual:BLXcodeProjectTreeTypeAbsolute])
		return BLXcodePathTypeAbsolute;
	if ([treeType isEqual:BLXcodeProjectTreeTypeGroup])
		return BLXcodePathTypeGroup;
	if ([treeType isEqual:BLXcodeProjectTreeTypeProject])
		return BLXcodePathTypeProject;

	return BLXcodePathTypeUnknown;
}

- (void)setPathType:(BLXcodePathType)newType {
	if (!(newType != self.pathType))
		[_parser noteProjectWasChanged];

	switch (newType) {
		case BLXcodePathTypeGroup:
			[_dictionary setObject:BLXcodeProjectTreeTypeGroup forKey:BLXcodeProjectItemTreeTypeKey];
			break;
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Path type cannot be changed!"];
	}
}

- (NSString *)fullPath {
	NSString *path;

	switch ([self pathType]) {
		case BLXcodePathTypeAbsolute: {
			path = [self path];
			break;
		}
		case BLXcodePathTypeGroup: {
			NSString *basePath = (_parent) ? [_parent fullPath] : [_parser projectPath];
			path = (![self path]) ? basePath : [basePath stringByAppendingPathComponent:[self path]];
			break;
		}
		case BLXcodePathTypeProject: {
			NSString *basePath = [_parser projectPath];
			path = (![self path]) ? basePath : [basePath stringByAppendingPathComponent:[self path]];
			break;
		}
		default: {
			// Fail on unknown tree types
			BLLog(BLLogInfo, @"Unsupported tree type \"%@\", returning nil path...", [_dictionary objectForKey:BLXcodeProjectItemTreeTypeKey]);
			return nil;
		}
	}

	return [path stringByStandardizingPath];
}

@end
