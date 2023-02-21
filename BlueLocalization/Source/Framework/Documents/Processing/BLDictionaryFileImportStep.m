//
//  BLDictionaryFileImportStep.m
//  BlueLocalization
//
//  Created by max on 24.01.10.
//  Copyright 2010 The Soulmen. All rights reserved.
//

#import "BLDictionaryFileImportStep.h"

#import "BLAppleGlotDocument.h"
#import "BLTMXDocument.h"
#import "BLXLIFFDocument.h"

@interface BLDictionaryFileImportStep (BLDictionaryFileImportStepInternal)

- (id)initWithPath:(NSString *)path;

@property (readonly) BLDictionaryDocument *document;

- (void)importAppleGlotFile;
- (void)importDatabaseFile;
- (void)importDictionaryFile;
- (void)importLocalizerFile;
- (void)importTMXFile;
- (void)importXLIFFFile;

@end

@implementation BLDictionaryFileImportStep

+ (NSArray *)availablePathExtensions {
	NSMutableArray *extensions = [NSMutableArray array];

	[extensions addObject:[BLLocalizerFile pathExtension]];
	[extensions addObject:[BLDictionaryFile pathExtension]];
	[extensions addObject:@"ldb"];
	[extensions addObjectsFromArray:[BLTMXDocument pathExtensions]];
	[extensions addObjectsFromArray:[BLXLIFFDocument pathExtensions]];
	[extensions addObjectsFromArray:[BLAppleGlotDocument pathExtensions]];

	return extensions;
}

+ (NSArray *)stepGroupForImportingFiles:(NSArray *)files {
	NSMutableArray *steps = [NSMutableArray array];

	for (NSString *file in files)
		[steps addObject:[[self alloc] initWithPath:file]];

	return steps;
}

#pragma mark -

- (id)initWithPath:(NSString *)path {
	self = [super init];

	if (self != nil) {
		_path = path;
	}

	return self;
}

#pragma mark - Actions

- (void)perform {
	NSString *extension = [_path pathExtension];

	if ([extension isEqual:[BLLocalizerFile pathExtension]])
		[self importLocalizerFile];
	else if ([extension isEqual:[BLDictionaryFile pathExtension]])
		[self importDictionaryFile];
	else if ([extension isEqual:@"ldb"])
		[self importDatabaseFile];
	else if ([[BLTMXDocument pathExtensions] containsObject:extension])
		[self importTMXFile];
	else if ([[BLXLIFFDocument pathExtensions] containsObject:extension])
		[self importXLIFFFile];
	else if ([[BLAppleGlotDocument pathExtensions] containsObject:extension])
		[self importAppleGlotFile];
	else
		BLLog(BLLogError, @"Unknown path extension \"%@\", cannot import!", extension);
}

- (BLDictionaryDocument *)document {
	return (BLDictionaryDocument *)[[self manager] document];
}

#pragma mark -

- (void)importAppleGlotFile {
	BLAppleGlotDocument *file = [BLAppleGlotDocument documentWithFileAtPath:_path];

	// Collect languages
	NSMutableSet *languages = [NSMutableSet set];
	for (BLKeyObject *keyObject in file.keyObjects)
		[languages addObjectsFromArray:keyObject.languages];

	// Update document
	[self.document addLanguages:[languages allObjects] ignoreFilter:NO];
	[self.document addKeys:file.keyObjects];
}

- (void)importDatabaseFile {
	BLDatabaseDocument *file = [[BLDatabaseDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:_path] ofType:@"org.loc-suite.database" error:NULL];

	[self.document addLanguages:[file languages] ignoreFilter:NO];
	[self.document addKeys:[BLObject keyObjectsFromArray:[file bundles]]];
}

- (void)importDictionaryFile {
	NSDictionary *properties = nil;

	// Open file
	NSFileWrapper *wrapper = [[NSFileWrapper alloc] initWithURL:[NSURL fileURLWithPath:_path] options:0 error:nil];
	NSArray *keyObjects = [BLDictionaryFile objectsFromFile:wrapper readingProperties:&properties];

	// Update document
	if (keyObjects) {
		[self.document addLanguages:[properties objectForKey:BLLanguagesPropertyName] ignoreFilter:NO];
		[self.document addKeys:keyObjects];
	}
}

- (void)importLocalizerFile {
	NSDictionary *properties = nil;

	// Open file
	NSFileWrapper *wrapper = [[NSFileWrapper alloc] initWithURL:[NSURL fileURLWithPath:_path] options:0 error:nil];
	NSArray *fileObjects = [BLLocalizerFile objectsFromFile:wrapper readingProperties:&properties];

	// Update document
	if (fileObjects) {
		[self.document addLanguages:[properties objectForKey:BLLanguagesPropertyName] ignoreFilter:NO];
		[self.document addKeys:[BLObject keyObjectsFromArray:fileObjects]];
	}
}

- (void)importTMXFile {
	BLTMXDocument *file = [BLTMXDocument documentWithFileAtPath:_path];

	// Collect languages
	NSMutableSet *languages = [NSMutableSet set];
	for (BLKeyObject *keyObject in file.keyObjects)
		[languages addObjectsFromArray:keyObject.languages];

	// Update document
	[self.document addLanguages:[languages allObjects] ignoreFilter:NO];
	[self.document addKeys:file.keyObjects];
}

- (void)importXLIFFFile {
	BLXLIFFDocument *file = [BLXLIFFDocument documentWithFileAtPath:_path];

	// Update document
	[self.document addLanguages:[NSArray arrayWithObjects:file.sourceLanguage, file.targetLanguage, nil] ignoreFilter:NO];
	[self.document addKeys:[BLObject keyObjectsFromArray:file.fileObjects]];
}

#pragma mark - Interface

- (NSString *)action {
	return NSLocalizedStringFromTableInBundle(@"Importing", @"BLProcessStep", [NSBundle bundleForClass:[self class]], nil);
}

- (NSString *)description {
	return [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"ImportingText", @"BLProcessStep", [NSBundle bundleForClass:[self class]], nil), [_path lastPathComponent]];
}

@end
