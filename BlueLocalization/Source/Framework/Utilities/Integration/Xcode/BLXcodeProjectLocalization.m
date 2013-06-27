/*!
 @header
 BLXcodeProjectLocalization.h
 Created by max on 17.07.09.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLXcodeProjectLocalization.h"
#import "BLXcodeProjectInternal.h"


@implementation BLXcodeProjectItem (BLXcodeProjectLocalization)

- (NSArray *)localizedVariantGroups
{
	// This is a variant group
	if ([self itemType] == BLXcodeItemTypeVariantGroup) {
		// Check for localizations
		for (BLXcodeProjectItem *child in [self children]) {
			NSString *path;
			
			path = [child fullPath];
			if ([BLPathCreator languageOfFileAtPath: path])
				return [NSArray arrayWithObject: self];
		}
		
		return [NSArray array];
	}
	
	// This is a regular group
	if ([self itemType] == BLXcodeItemTypeGroup) {
		NSMutableArray *items = [NSMutableArray array];
		
		for (BLXcodeProjectItem *child in [self children])
			[items addObjectsFromArray: [child localizedVariantGroups]];
		
		return items;
	}
	
	// Other items are not localized from our definition
	return [NSArray array];
}

- (NSArray *)localizations
{
	return [[self exactLocalizations] valueForKey: @"languageIdentifier"];
}

- (NSArray *)exactLocalizations
{
	if ([self itemType] != BLXcodeItemTypeVariantGroup)
		[NSException raise:NSInvalidArgumentException format:@"Only variant groups have localizations!"];
	
	NSMutableArray *languages = [NSMutableArray arrayWithCapacity: [[self children] count]];
	
	for (BLXcodeProjectItem *child in [self children]) {
		NSString *language = [BLPathCreator exactLanguageOfFileAtPath: [child fullPath]];
		if (language)
			[languages addObject: language];
	}
	
	return languages;
}

- (void)updateLocalizationNames
{
	if ([self itemType] != BLXcodeItemTypeVariantGroup)
		[NSException raise:NSInvalidArgumentException format:@"Only variant groups have localizations!"];
	
	NSString *bundlePath = [BLPathCreator bundlePartOfFilePath: [[[self children] objectAtIndex: 0] fullPath]];
	
	// Find the current language and the real language and replace it
	for (BLXcodeProjectItem *child in [self children]) {
		NSString *oldLanguage = [BLPathCreator exactLanguageOfFileAtPath: [child fullPath]];
		NSString *languageName = [BLPathCreator languageNameForLanguage:oldLanguage atBundlePath:bundlePath];
		
		// Only for existing files and only for changed names
		if (!languageName || [oldLanguage isEqual: languageName])
			continue;
		
		NSString *path = [child path];
		path = [BLPathCreator replaceLanguage:oldLanguage inPath:path withLanguage:languageName bundle:nil];
		[child setPath: path];
		[child setName: languageName];
	}
}

- (void)addLocalizations:(NSArray *)languages
{
	if ([self itemType] != BLXcodeItemTypeVariantGroup)
		[NSException raise:NSInvalidArgumentException format:@"Only variant groups have localizations!"];
	NSAssert([[self children] count] > 0, @"Cannot add localization to empty variant group!");
	
	NSString *bundlePath = [BLPathCreator bundlePartOfFilePath: [[[self children] objectAtIndex: 0] fullPath]];
	NSString *fileBundlePath = [BLPathCreator bundlePartOfFilePath: [[[self children] objectAtIndex: 0] path]];
	NSString *filePath = [BLPathCreator relativePartOfFilePath: [[[self children] objectAtIndex: 0] path]];
	
	for (NSString *language in languages) {
		NSString *languageName, *path;
		BLXcodeProjectItem *item;
		
		// Get the right name
		languageName = [BLPathCreator languageNameForLanguage:language atBundlePath:bundlePath];
		if (!languageName)
			languageName = language;
		
		// Build the path
		path = [languageName stringByAppendingPathExtension: BLLanguageFolderPathExtension];
		if ([fileBundlePath length])
			path = [fileBundlePath stringByAppendingPathComponent: path];
		path = [path stringByAppendingPathComponent:filePath];
		
		// Create the item
		item = [BLXcodeProjectItem blankItemWithType: BLXcodeItemTypeFile];
		[item setName: languageName];
		[item setPath: path];
		
		// Add item to the tree
		[self addChild: item];
		
		// Set type and encoding
		[item updateFileTypeAndEncoding];
	}
}

- (void)removeLocalizations:(NSArray *)languages
{
	if ([self itemType] != BLXcodeItemTypeVariantGroup)
		[NSException raise:NSInvalidArgumentException format:@"Only variant groups have localizations!"];
	
	for (BLXcodeProjectItem *child in [self children]) {
		NSString *language = [BLPathCreator languageOfFileAtPath: [child fullPath]];
		if ([languages containsObject: language])
			[self removeChild: child];
	}
}

- (void)updateFileTypeAndEncoding
{
	if ([self itemType] != BLXcodeItemTypeFile)
		[NSException raise:NSInvalidArgumentException format:@"Only files can have file types!"];
	
	NSString *extension = [self.path pathExtension];
	
	if ([extension isEqual: @"strings"]) {
		self.fileType = BLXcodeProjectFileTypeStrings;
		
		// Read in encoding
		NSStringEncoding usedEncoding;
		(void)[[NSString alloc] initWithContentsOfFile:self.fullPath usedEncoding:&usedEncoding error:NULL];
		self.encoding = usedEncoding;
	} else if ([extension isEqual: @"nib"]) {
		self.fileType = BLXcodeProjectFileTypeNib;
	} else if ([extension isEqual: @"xib"]) {
		self.fileType = BLXcodeProjectFileTypeXib;
	} else if ([extension isEqual: @"rtf"]) {
		self.fileType = BLXcodeProjectFileTypeRTF;
	} else if ([extension isEqual: @"plist"]) {
		self.fileType = BLXcodeProjectFileTypePlist;
	} else {
		self.fileType = nil;
		BLLog(BLLogWarning, @"File type cannot be updated for unsupported file extension: %@\nFile:%@", extension, self.fullPath);
	}
}

@end



