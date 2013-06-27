/*!
 @header
 BLXcodeExportUpdateStep.m
 Created by max on 24.11.10.
 
 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */

#import "BLXcodeExportUpdateStep.h"

@interface BLXcodeExportUpdateStep () {
	NSArray				*_bundles;
	BLDatabaseDocument	*_document;
	float				_fileLimit;
	float				_languageLimit;
	NSUInteger			_options;
}

@end

@implementation BLXcodeExportUpdateStep

- (id)initWithXcodeProjectsOfBundles:(NSArray *)bundles inProject:(BLDatabaseDocument *)document withOptions:(NSUInteger)options languageLimit:(float)languageLimit fileLimit:(float)fileLimit
{
	self = [super init];
	
	if (self) {
		_bundles = bundles;
		_document = document;
		_fileLimit = fileLimit;
		_languageLimit = languageLimit;
		_options = options;
	}
	
	return self;
}


#pragma mark - Processing

- (void)updateDescription
{
	self.action = NSLocalizedStringFromTableInBundle(@"UpdatingXcode", @"BLProcessStep", [NSBundle bundleForClass: [self class]], nil);
}

- (void)perform
{
	// Find all affected projects
	NSMutableSet *projects = [NSMutableSet set];
	for (BLBundleObject *bundle in _bundles) {
		NSString *bundlePath = [[_document pathCreator] fullPathForBundle: bundle];
		
		for (NSString *path in bundle.associatedXcodeProjects)
			[projects addObject: [BLPathCreator fullPathWithRelativePath:path fromPath:bundlePath]];
	}
	
	// Update projects
	BLLogBeginGroup(@"Updating associated Xcode projects...");
	
	for (NSString *path in projects) {
		self.description = [NSString stringWithFormat: NSLocalizedStringFromTableInBundle(@"UpdatingXcodeText", @"BLProcessStep", [NSBundle bundleForClass: [self class]], nil), path];
		
		[BLXcodeExporter exportToXcodeProjectAtPath:path fromDatabaseDocument:_document withOptions:_options languageLimit:_languageLimit fileLimit:_fileLimit];
	}
	
	BLLogEndGroup();
}

@end
