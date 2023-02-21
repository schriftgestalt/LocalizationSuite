//
//  BLXLIFFExporter.m
//  BlueLocalization
//
//  Created by max on 22.01.10.
//  Copyright 2010 The Soulmen. All rights reserved.
//

#import "BLXLIFFExporter.h"

#import "BLRTFDKeyObject.h"
#import "BLXLIFFDocument.h"

NSString *BLXLIFFExporterNibName = @"BLXLIFFExporter";

NSString *BLXLIFFExporterAllowRichTextKeyPath = @"xliffExporter.allowRichText";
NSString *BLXLIFFExporterIncludeCommentsKeyPath = @"xliffExporter.includeComments";
NSString *BLXLIFFExporterExportAllFilesKeyPath = @"xliffExporter.exportAllFiles";
NSString *BLXLIFFExporterExportReferenceKeyPath = @"xliffExporter.exportReference";

@interface BLXLIFFExporter (BLXLIFFExporterInternal)

+ (id)_sharedInstance;
+ (void)initUserDefaults;

- (void)exportXLIFFFromObjects:(NSArray *)objects forLanguages:(NSArray *)languages inDocument:(NSDocument<BLDocumentProtocol> *)document;
- (void)exportXLIFFSheetDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;

@end

@implementation BLXLIFFExporter

id __sharedXLIFFExporter;

- (void)dealloc {
	__sharedXLIFFExporter = nil;
}

+ (id)_sharedInstance {
	if (__sharedXLIFFExporter == nil) {
		__sharedXLIFFExporter = [[self alloc] init];
		[self initUserDefaults];
	}

	return __sharedXLIFFExporter;
}

#pragma mark - Public Access

+ (void)exportXLIFFFromObjects:(NSArray *)objects forLanguages:(NSArray *)languages inDocument:(NSDocument<BLDocumentProtocol> *)document {
	[[self _sharedInstance] exportXLIFFFromObjects:objects forLanguages:languages inDocument:document];
}

#pragma mark - User Interaction

+ (void)initUserDefaults {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if (![defaults objectForKey:BLXLIFFExporterAllowRichTextKeyPath])
		[defaults setBool:YES forKey:BLXLIFFExporterAllowRichTextKeyPath];
	if (![defaults objectForKey:BLXLIFFExporterIncludeCommentsKeyPath])
		[defaults setBool:YES forKey:BLXLIFFExporterIncludeCommentsKeyPath];
	if (![defaults objectForKey:BLXLIFFExporterExportAllFilesKeyPath])
		[defaults setBool:YES forKey:BLXLIFFExporterExportAllFilesKeyPath];
	if (![defaults objectForKey:BLXLIFFExporterExportReferenceKeyPath])
		[defaults setBool:NO forKey:BLXLIFFExporterExportReferenceKeyPath];
}

- (void)exportXLIFFFromObjects:(NSArray *)objects forLanguages:(NSArray *)languages inDocument:(NSDocument<BLDocumentProtocol> *)document {
	// Remember the objects
	[self willChangeValueForKey:@"languages"];
	_languages = languages;
	_document = document;
	[self didChangeValueForKey:@"languages"];

	// Open the save panel
	NSSavePanel *panel = [NSSavePanel savePanel];

	if (!optionsView)
		[NSBundle loadNibNamed:BLXLIFFExporterNibName owner:self];

	[panel setCanCreateDirectories:YES];
	[panel setAccessoryView:optionsView];
	[[panel defaultButtonCell] setTitle:NSLocalizedStringFromTableInBundle(@"Export", @"Localizable", [NSBundle bundleForClass:[self class]], nil)];
	
	[panel beginSheetModalForWindow:[document windowForSheet]
				  completionHandler:^(NSInteger returnCode) {
		[panel close];
		
		// User aborted
		if (returnCode != NSModalResponseOK)
			return;
		
		// Read options
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSUInteger options = 0;
		
		if ([defaults boolForKey:BLXLIFFExporterAllowRichTextKeyPath])
			options |= BLXLIFFExporterAllowRichText;
		if ([defaults boolForKey:BLXLIFFExporterIncludeCommentsKeyPath])
			options |= BLXLIFFExporterIncludeComments;
		
		BOOL exportReference = [defaults boolForKey:BLXLIFFExporterExportReferenceKeyPath];
		BOOL exportAllFiles = [defaults boolForKey:BLXLIFFExporterExportAllFilesKeyPath];
		
		// Preprocess arguments
		NSArray *exportObjects = objects;
		
		if (exportAllFiles) {
			if ([document respondsToSelector:@selector(bundles)])
				exportObjects = [(id)document bundles];
		}
		
		// Enqueue process steps
		NSMutableArray *steps = [NSMutableArray array];
		NSString *reference = [document referenceLanguage];
		NSString *path = [[panel URL] path];
		
		for (NSString *language in languages) {
			if ([language isEqual:reference] && !exportReference)
				continue;
			
			// Create Step
			BLGenericProcessStep *step = [BLGenericProcessStep genericStepWithBlock:^{
				[[self class] exportXLIFFFromObjects:exportObjects forLanguage:language andReferenceLanguage:reference withOptions:options toPath:path];
			}];
			
			[step setAction:NSLocalizedStringFromTableInBundle(@"ExportingXLIFF", @"BLProcessStep", [NSBundle bundleForClass:[self class]], nil)];
			[step setDescription:[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"ExportingXLIFFText", @"BLProcessStep", [NSBundle bundleForClass:[self class]], nil), [BLLanguageTranslator descriptionForLanguage:language]]];
			
			[steps addObject:step];
		}
		
		// Enqueue or execute
		if ([document respondsToSelector:@selector(processManager)] && [document processManager]) {
			[[document processManager] enqueueStepGroup:steps];
			[[document processManager] startWithName:@"Exporting XLIFF files…"];
		}
		else {
			[steps makeObjectsPerformSelector:@selector(perform)];
		}
	}];
}

- (BOOL)includesReferenceLanguage {
	return [_languages containsObject:[_document referenceLanguage]];
}

+ (NSSet *)keyPathsForValuesAffectingIncludesReferenceLanguage {
	return [NSSet setWithObjects:@"languages", nil];
}

#pragma mark - Export

+ (void)exportXLIFFFromObjects:(NSArray *)objects forLanguage:(NSString *)language andReferenceLanguage:(NSString *)referenceLanguage withOptions:(NSUInteger)options toPath:(NSString *)path {
	// Get all file objects
	objects = [BLObject fileObjectsFromArray:objects];

	// Filter RTF objects
	if (!(options & BLXLIFFExporterAllowRichText)) {
		NSMutableArray *newObjects = [NSMutableArray arrayWithCapacity:[objects count]];

		for (BLFileObject *file in objects) {
			if ([[file class] classOfStoredKeys] != [BLRTFDKeyObject class])
				[newObjects addObject:file];
		}

		objects = newObjects;
	}

	// Create document
	BLXLIFFDocument *document = [BLXLIFFDocument blankDocument];
	document.sourceLanguage = referenceLanguage;
	document.targetLanguage = language;
	document.fileObjects = objects;
	document.includeComments = (options & BLXLIFFExporterIncludeComments);

	// Create path
	if ([[BLXLIFFDocument pathExtensions] containsObject:[path pathExtension]])
		path = [path stringByDeletingPathExtension];
	path = [path stringByAppendingFormat:@" %@", [BLLanguageTranslator identifierForLanguage:language]];
	path = [path stringByAppendingPathExtension:[[BLXLIFFDocument pathExtensions] objectAtIndex:0]];

	// Write document
	NSError *error;
	if (![document writeToPath:path error:&error]) {
		BLLog(BLLogError, @"Failed writing XLIFF file for languages (%@, %@) to path %@", referenceLanguage, language, path);
	}
	else {
		BLLog(BLLogInfo, @"Wrote XLIFF file for language %@ to path %@", language, path);
	}
}

@end
