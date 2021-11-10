//
//  BLXcodeImportUpdateStep.m
//  BlueLocalization
//
//  Created by Max Seelemann on 01.09.11.
//  Copyright (c) 2011 Localization Suite. All rights reserved.
//

#import "BLXcodeImportUpdateStep.h"

@interface BLXcodeImportUpdateStep () {
	NSArray *_bundles;
	BLDatabaseDocument *_document;
}

@end

@implementation BLXcodeImportUpdateStep

- (id)initWithXcodeProjectsOfBundles:(NSArray *)bundles inProject:(BLDatabaseDocument *)document {
	self = [super init];

	if (self) {
		_bundles = bundles;
		_document = document;
	}

	return self;
}

#pragma mark - Processing

- (void)updateDescription {
	self.action = NSLocalizedStringFromTableInBundle(@"UpdatingXcode", @"BLProcessStep", [NSBundle bundleForClass:[self class]], nil);
}

- (void)perform {
	// Find all affected projects
	NSMutableSet *projects = [NSMutableSet set];
	for (BLBundleObject *bundle in _bundles) {
		NSString *bundlePath = [[_document pathCreator] fullPathForBundle:bundle];

		for (NSString *path in bundle.associatedXcodeProjects)
			[projects addObject:[BLPathCreator fullPathWithRelativePath:path fromPath:bundlePath]];
	}

	// Import projects
	BLLogBeginGroup(@"Importing associated Xcode projects...");
	NSMutableArray *newFilePaths = [NSMutableArray array];

	for (NSString *path in projects) {
		self.description = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"UpdatingXcodeText", @"BLProcessStep", [NSBundle bundleForClass:[self class]], nil), path];

		BLLogBeginGroup(@"Project path: %@", path);
		[newFilePaths addObjectsFromArray:[BLXcodeImporter pathsToImportFromXcodeProjectAtPath:path toDatabaseDocument:_document withOptions:0]];
		BLLogEndGroup();
	}

	if ([newFilePaths count]) {
		BLLog(BLLogInfo, @"Adding %d files", [newFilePaths count]);
		[_document addFiles:newFilePaths];
	}
	else {
		BLLog(BLLogInfo, @"No new files");
	}

	BLLogEndGroup();
}

@end
