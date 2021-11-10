//
//  BLTMXExporter.m
//  BlueLocalization
//
//  Created by max on 22.01.10.
//  Copyright 2010 The Soulmen. All rights reserved.
//

#import "BLTMXExporter.h"

#import "BLRTFDKeyObject.h"
#import "BLTMXDocument.h"

NSString *BLTMXExporterNibName = @"BLTMXExporter";

NSString *BLTMXExporterAllowRichTextKeyPath = @"tmxExporter.allowRichText";

@interface BLTMXExporter ()

+ (id)_sharedInstance;
- (void)exportTMXFromObjects:(NSArray *)objects inDocument:(NSDocument<BLDocumentProtocol> *)document;

@end

@implementation BLTMXExporter

id __sharedTMXExporter;

- (void)dealloc {
	__sharedTMXExporter = nil;
}

+ (id)_sharedInstance {
	if (__sharedTMXExporter == nil)
		__sharedTMXExporter = [[self alloc] init];

	return __sharedTMXExporter;
}

#pragma mark - Public Access

+ (void)exportTMXFromObjects:(NSArray *)objects inDocument:(NSDocument<BLDocumentProtocol> *)document {
	[[self _sharedInstance] exportTMXFromObjects:objects inDocument:document];
}

#pragma mark - User Interaction

- (void)exportTMXFromObjects:(NSArray *)objects inDocument:(NSDocument<BLDocumentProtocol> *)document {
	// Set some defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (![defaults objectForKey:BLTMXExporterAllowRichTextKeyPath])
		[defaults setBool:YES forKey:BLTMXExporterAllowRichTextKeyPath];

	// Open the save panel
	NSSavePanel *panel = [NSSavePanel savePanel];

	if (!optionsView)
		[NSBundle loadNibNamed:BLTMXExporterNibName owner:self];

	[panel setCanCreateDirectories:YES];
	[panel setAllowedFileTypes:[BLTMXDocument pathExtensions]];
	[panel setAccessoryView:optionsView];
	[[panel defaultButtonCell] setTitle:NSLocalizedStringFromTableInBundle(@"Export", @"Localizable", [NSBundle bundleForClass:[self class]], nil)];

	[panel beginSheetModalForWindow:[document windowForSheet]
				  completionHandler:^(NSInteger returnCode) {
					  [panel close];

					  // User aborted
					  if (returnCode != NSFileHandlingPanelOKButton)
						  return;

					  // Create options
					  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
					  NSUInteger options = 0;

					  if ([defaults boolForKey:BLTMXExporterAllowRichTextKeyPath])
						  options |= BLTMXExporterAllowRichText;

					  // Create Step
					  BLGenericProcessStep *step = [BLGenericProcessStep genericStepWithBlock:^{
						  [[self class] exportTMXFromObjects:objects withOptions:options toPath:[[panel URL] path]];
					  }];

					  [step setAction:NSLocalizedStringFromTableInBundle(@"ExportingTMX", @"BLProcessStep", [NSBundle bundleForClass:[self class]], nil)];
					  [step setDescription:NSLocalizedStringFromTableInBundle(@"ExportingTMXText", @"BLProcessStep", [NSBundle bundleForClass:[self class]], nil)];

					  // Schedule or execute
					  if ([document respondsToSelector:@selector(processManager)] && [document processManager]) {
						  [[document processManager] enqueueStep:step];
						  [[document processManager] startWithName:@"Exporting TMX files…"];
					  }
					  else {
						  [step perform];
					  }
				  }];
}

#pragma mark - Export

+ (void)exportTMXFromObjects:(NSArray *)objects withOptions:(NSUInteger)options toPath:(NSString *)path {
	// Get all file objects
	objects = [BLObject keyObjectsFromArray:objects];

	// Filter RTF objects
	if (!(options & BLTMXExporterAllowRichText)) {
		NSMutableArray *newObjects = [NSMutableArray arrayWithCapacity:[objects count]];

		for (BLFileObject *file in objects) {
			if ([[file class] classOfStoredKeys] != [BLRTFDKeyObject class])
				[newObjects addObject:file];
		}

		objects = newObjects;
	}

	// Create document
	BLTMXDocument *document = [BLTMXDocument blankDocument];
	document.keyObjects = objects;

	// Write document
	NSError *error;
	if (![document writeToPath:path error:&error]) {
		BLLog(BLLogError, @"Failed writing TMX file to path %@", path);
	}
	else {
		BLLog(BLLogInfo, @"Wrote TMX file to path %@", path);
	}
}

@end
