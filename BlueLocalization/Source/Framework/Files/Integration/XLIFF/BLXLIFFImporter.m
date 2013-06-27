/*!
 @header
 BLXLIFFImporter.m
 Created by max on 22.01.09.
 
 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */

#import "BLXLIFFImporter.h"

#import "BLXLIFFDocument.h"


@interface BLXLIFFImporter ()

+ (id)_sharedInstance;
- (void)importXLIFFToObjects:(NSArray *)objects inDocument:(NSDocument<BLDocumentProtocol> *)document;

@end


@implementation BLXLIFFImporter

id __sharedXLIFFImporter;

- (void)dealloc
{
	if (self == __sharedXLIFFImporter)
		__sharedXLIFFImporter = nil;
}

+ (id)_sharedInstance
{
    if (__sharedXLIFFImporter == nil)
        __sharedXLIFFImporter = [[self alloc] init];
    
    return __sharedXLIFFImporter;
}


#pragma mark - Public Access

+ (void)importXLIFFToObjects:(NSArray *)objects inDocument:(NSDocument<BLDocumentProtocol> *)document
{
	[[self _sharedInstance] importXLIFFToObjects:objects inDocument:document];
}


#pragma mark - Interface

- (void)importXLIFFToObjects:(NSArray *)objects inDocument:(NSDocument<BLDocumentProtocol> *)document
{
	// Open the open panel
    NSOpenPanel *panel = [NSOpenPanel openPanel];
	
	[panel setAllowsMultipleSelection: YES];
	[panel setAllowedFileTypes: [BLXLIFFDocument pathExtensions]];
	[[panel defaultButtonCell] setTitle: NSLocalizedStringFromTableInBundle(@"Import", @"Localizable", [NSBundle bundleForClass: [self class]], nil)];
	
	[panel beginSheetModalForWindow:[document windowForSheet] completionHandler: ^(NSInteger returnCode) {
		[panel close];
		
		// User aborted
		if (returnCode != NSFileHandlingPanelOKButton)
			return;
		
		// Enqueue process steps
		NSMutableArray *steps = [NSMutableArray array];
		for (NSURL *url in [panel URLs]) {
			BLGenericProcessStep *step = [BLGenericProcessStep genericStepWithBlock: ^{
				[[self class] importXLIFFFromFile:[url path] toObjects:objects];
			}];
			
			[step setAction: NSLocalizedStringFromTableInBundle(@"ImportingXLIFF", @"BLProcessStep", [NSBundle bundleForClass: [self class]], nil)];
			[step setDescription: [NSString stringWithFormat: NSLocalizedStringFromTableInBundle(@"ImportingXLIFFText", @"BLProcessStep", [NSBundle bundleForClass: [self class]], nil), [url lastPathComponent]]];
			
			[steps addObject: step];
		}
		
		// Run in process manager
		if ([document respondsToSelector: @selector(processManager)] && [document processManager]) {
			[[document processManager] enqueueStepGroup: steps];
			[[document processManager] startWithName: @"Importing XLIFF files…"];
		} else {
			[steps makeObjectsPerformSelector: @selector(perform)];
		}
		
		if ([steps count])
			[document updateChangeCount: NSChangeDone];
	}];
}


#pragma mark - Actions

+ (void)importXLIFFFromFile:(NSString *)path toObjects:(NSArray *)objects
{
	BLXLIFFDocument *document = [BLXLIFFDocument documentWithFileAtPath: path];
	NSString *language = document.targetLanguage;
	
	BLLogBeginGroup(@"Importing XLIFF file \"%@\"", path);
	
	for (BLFileObject *importFile in document.fileObjects) {
		// Split the name
		NSArray *importNameParts = [[importFile path] pathComponents];
		NSString *bundleName = [importNameParts objectAtIndex: 0];
		NSString *fileName = [[importFile path] substringFromIndex: [bundleName length]+1];
		
		// Find the bundle
		NSArray *bundles = [BLObject bundleObjectsWithName:bundleName inArray:objects];
		if ([bundles count] > 1)
			BLLog(BLLogWarning, @"Ambiguous bundle name \"%@\" - importing to multiple bundles...", bundleName);
		
		// Import to each matching bundle (hopefully exactly one)
		for (BLBundleObject *bundle in bundles) {
			BLFileObject *fileObject = [bundle fileWithName: fileName];
			if (!fileObject)
				continue;
			
			BLLog(BLLogInfo, @"Importing file object %@ into file object %@", importFile, fileObject);
			
			for (BLKeyObject *importKey in importFile.objects) {
				BLKeyObject *keyObject = [fileObject objectForKey: [importKey key]];
				id value = [importKey objectForLanguage: language];
				
				if (![[keyObject class] isEmptyValue: value])
					[keyObject setObject:value forLanguage:language];
			}
		}
	}
	
	BLLogEndGroup();
}

@end



