/*!
 @header
 BLPathCreator.m
 Created by Max on 14.11.04.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLPathCreator.h>

#import <BlueLocalization/BLDocumentProtocol.h>
#import <BlueLocalization/BLFileObject.h>

NSString *BLLanguageFolderPathExtension = @"lproj";

@implementation BLPathCreator

#pragma mark - BLDocument Dependent Path Creator

- (id)initWithDocument:(NSDocument<BLDocumentProtocol> *)document {
	self = [super init];

	_document = document;

	return self;
}

- (void)dealloc {
	_document = nil;
}

#pragma mark - INDEPENDENT PATH CREATOR METHODS

+ (NSString *)languageOfFileAtPath:(NSString *)path {
	return [BLLanguageTranslator identifierForLanguage:[self exactLanguageOfFileAtPath:path]];
}

+ (NSString *)exactLanguageOfFileAtPath:(NSString *)path {
	NSString *language;
	NSInteger i, loc;
	NSRange range;

	language = nil;

	range = [path rangeOfString:BLLanguageFolderPathExtension options:NSBackwardsSearch];

	if (range.location != NSNotFound && range.location > 0) {
		loc = range.location - 1; // -1 because we need to get rid of the dot

		for (i = loc; i >= 0; i--) {
			if ([path characterAtIndex:i] == '/')
				break;
		}

		language = [path substringWithRange:NSMakeRange(i + 1, loc - i - 1)];
	}

	return language;
}

+ (NSString *)languageNameForLanguage:(NSString *)language withNamingStyle:(BLNamingStyle)style {
	switch (style) {
		case BLIdentifiersNamingStyle:
			return [BLLanguageTranslator identifierForLanguage:language];
			break;
		case BLDescriptionsNamingStyle:
			return [BLLanguageTranslator descriptionForLanguage:language];
			break;
		case BLIdentifiersAndDescriptionsNamingStyle:
		default:
			if ([[BLLanguageTranslator identifierForLanguage:language] rangeOfString:@"_"].location != NSNotFound || [[BLLanguageTranslator descriptionForLanguage:language] rangeOfString:@" "].location != NSNotFound)
				return [BLLanguageTranslator identifierForLanguage:language];
			else
				return [BLLanguageTranslator descriptionForLanguage:language];
	}
}

+ (NSString *)languageNameForLanguage:(NSString *)language atBundlePath:(NSString *)path {
	NSFileManager *manager = [NSFileManager defaultManager];

	if ([manager fileExistsAtPath:path]) {
		NSString *tmpPath;

		// Original
		tmpPath = [path stringByAppendingPathComponent:language];
		tmpPath = [tmpPath stringByAppendingPathExtension:BLLanguageFolderPathExtension];
		if ([manager fileExistsAtPath:tmpPath])
			return language;

		// Identifier
		tmpPath = [path stringByAppendingPathComponent:[BLLanguageTranslator identifierForLanguage:language]];
		tmpPath = [tmpPath stringByAppendingPathExtension:BLLanguageFolderPathExtension];
		if ([manager fileExistsAtPath:tmpPath])
			return [BLLanguageTranslator identifierForLanguage:language];

		// Description
		tmpPath = [path stringByAppendingPathComponent:[BLLanguageTranslator descriptionForLanguage:language]];
		tmpPath = [tmpPath stringByAppendingPathExtension:BLLanguageFolderPathExtension];
		if ([manager fileExistsAtPath:tmpPath])
			return [BLLanguageTranslator descriptionForLanguage:language];
	}

	return nil;
}

+ (NSString *)replaceLanguage:(NSString *)oldLanguage inPath:(NSString *)path withLanguage:(NSString *)newLanguage bundle:(BLBundleObject *)bundle {
	NSString *language;
	NSRange range;

	range = [path rangeOfString:[NSString stringWithFormat:@"%@.%@", oldLanguage, BLLanguageFolderPathExtension] options:NSBackwardsSearch];

	if (range.location == NSNotFound)
		range = [path rangeOfString:[NSString stringWithFormat:@"%@.%@", [BLLanguageTranslator identifierForLanguage:oldLanguage], BLLanguageFolderPathExtension] options:NSBackwardsSearch];
	if (range.location == NSNotFound)
		range = [path rangeOfString:[NSString stringWithFormat:@"%@.%@", [BLLanguageTranslator descriptionForLanguage:oldLanguage], BLLanguageFolderPathExtension]];
	if (range.location == NSNotFound)
		return path;

	// Get the right replacement language
	language = [self languageNameForLanguage:newLanguage atBundlePath:[path substringToIndex:range.location]];
	if (!language) {
		if (bundle)
			language = [self languageNameForLanguage:newLanguage withNamingStyle:[bundle namingStyle]];
		else
			language = newLanguage;
	}
	range.length -= [BLLanguageFolderPathExtension length] + 1;

	return [NSString stringWithFormat:@"%@%@%@", [path substringToIndex:range.location], language, [path substringFromIndex:NSMaxRange(range)]];
}

+ (NSString *)bundlePartOfFilePath:(NSString *)filePath {
	NSUInteger i, loc;
	NSRange range;

	range = [filePath rangeOfString:BLLanguageFolderPathExtension options:NSBackwardsSearch];

	if (range.location != NSNotFound) {
		loc = range.location;

		for (i = loc; i > 0; i--) {
			if ([filePath characterAtIndex:i] == '/')
				break;
		}

		if (i > 0)
			return [filePath substringToIndex:i];
	}

	return nil;
}

+ (NSString *)relativePartOfFilePath:(NSString *)filePath {
	NSString *path;
	NSRange range;

	range = [filePath rangeOfString:BLLanguageFolderPathExtension options:NSBackwardsSearch];
	path = (range.location != NSNotFound && NSMaxRange(range) + 1 < [filePath length]) ? [filePath substringFromIndex:NSMaxRange(range) + 1] : filePath;

	return path;
}

+ (NSString *)relativePathFromPath:(NSString *)fromPath toPath:(NSString *)toPath {
	if (!fromPath || !toPath)
		return nil;

	NSArray *fromParts = [fromPath pathComponents];
	NSArray *toParts = [toPath pathComponents];

	NSString *relPath = @"";
	NSUInteger i = 0, j = 0;

	while (i < [fromParts count] && j < [toParts count] && [[fromParts objectAtIndex:i] isEqual:[toParts objectAtIndex:j]]) {
		i++;
		j++;
	}
	while (i < [fromParts count]) {
		relPath = [relPath stringByAppendingPathComponent:@".."];
		i++;
	}
	while (j < [toParts count]) {
		relPath = [relPath stringByAppendingPathComponent:[toParts objectAtIndex:j]];
		j++;
	}

	return relPath;
}

+ (NSString *)fullPathWithRelativePath:(NSString *)relPath fromPath:(NSString *)fromPath {
	while ([relPath hasPrefix:@"../"]) {
		fromPath = [fromPath stringByDeletingLastPathComponent];
		relPath = [relPath substringFromIndex:3];
	}

	return [fromPath stringByAppendingPathComponent:relPath];
}

#pragma mark - DOCUMENT PATH CREATOR METHODS

- (NSString *)fullPathForBundle:(BLBundleObject *)bundle {
	switch ([bundle referencingStyle]) {
		case BLAbsoluteReferencingStyle:
			return [bundle path];
		case BLRelativeReferencingStyle:
			return [self fullPathOfDocumentRelativePath:[bundle path]];
	}

	return nil;
}

- (NSString *)relativePathForBundle:(BLBundleObject *)bundle {
	switch ([bundle referencingStyle]) {
		case BLAbsoluteReferencingStyle:
			return [self documentRelativePathOfFullPath:[bundle path]];
		case BLRelativeReferencingStyle:
			return [bundle path];
	}

	return nil;
}

- (NSString *)fullPathOfDocumentRelativePath:(NSString *)path {
	NSString *documentPath;

	documentPath = [[_document fileURL] path];
	if (![documentPath length])
		return nil;

	documentPath = [documentPath stringByDeletingLastPathComponent];

	return [[self class] fullPathWithRelativePath:path fromPath:documentPath];
}

- (NSString *)documentRelativePathOfFullPath:(NSString *)fullPath {
	NSString *documentPath;

	documentPath = [[_document fileURL] path];
	if (![documentPath length] || !fullPath)
		return nil;

	documentPath = [documentPath stringByDeletingLastPathComponent];

	return [[self class] relativePathFromPath:documentPath toPath:fullPath];
}

#pragma mark -

- (NSString *)absolutePathForFile:(BLFileObject *)file andLanguage:(NSString *)language {
	NSString *base;

	if ([self realPathForFolderOfLanguage:language inBundle:[file bundleObject]])
		base = [self realPathForFolderOfLanguage:language inBundle:[file bundleObject]];
	else
		base = [self pathForFolderOfLanguage:language inBundle:[file bundleObject]];

	return [base stringByAppendingPathComponent:[file path]];
}

- (NSString *)pathForFolderOfLanguage:(NSString *)language inBundle:(BLBundleObject *)bundle {
	return [[[self fullPathForBundle:bundle] stringByAppendingPathComponent:[[self class] languageNameForLanguage:language withNamingStyle:[bundle namingStyle]]] stringByAppendingPathExtension:BLLanguageFolderPathExtension];
}

- (NSString *)realPathForFolderOfLanguage:(NSString *)language inBundle:(BLBundleObject *)bundle {
	NSString *bundlePath, *realLanguage;

	// Get and check bundle path
	bundlePath = [self fullPathForBundle:bundle];
	if (![[NSFileManager defaultManager] fileExistsAtPath:bundlePath])
		return nil;

	// Get real or computed language folder name
	realLanguage = [[self class] languageNameForLanguage:language atBundlePath:bundlePath];
	if (!realLanguage)
		realLanguage = [[self class] languageNameForLanguage:language withNamingStyle:[bundle namingStyle]];

	return [[[self fullPathForBundle:bundle] stringByAppendingPathComponent:realLanguage] stringByAppendingPathExtension:BLLanguageFolderPathExtension];
}

@end
