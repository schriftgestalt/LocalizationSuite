/*!
 @header
 BLXcodeImportAssociationStep.m
 Created by max on 23.11.10.

 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */

#import "BLXcodeImportAssociationStep.h"

@implementation BLXcodeImportAssociationStep

- (id)initWithXcodeProjectAtPath:(NSString *)path document:(BLDatabaseDocument *)document andImportedFiles:(NSArray *)files {
	self = [super init];

	if (self) {
		_document = document;
		_files = files;
		_path = path;
	}

	return self;
}

#pragma mark - Processing

- (void)perform {
	// Collect all bundles
	NSMutableSet *bundles = [NSMutableSet set];
	for (NSString *path in _files) {
		BLFileObject *file = [_document existingFileObjectWithPath:path];
		if (file)
			[bundles addObject:file.bundleObject];
	}

	// Add Project to bundles
	BLPathCreator *pathCreator = [_document pathCreator];

	for (BLBundleObject *bundle in bundles) {
		NSString *bundlePath = [pathCreator fullPathForBundle:bundle];
		[bundle addAssociatedXcodeProject:[BLPathCreator relativePathFromPath:bundlePath toPath:_path]];
	}
}

- (NSString *)action {
	return NSLocalizedStringFromTableInBundle(@"Importing", @"BLProcessStep", [NSBundle bundleForClass:[self class]], nil);
}

@end
