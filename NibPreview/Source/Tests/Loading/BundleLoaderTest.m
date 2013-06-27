//
//  BundleLoaderTest.m
//  NibPreview
//
//  Created by max on 10.03.09.
//  Copyright 2009 Localization Suite. All rights reserved.
//

#import "BundleLoaderTest.h"

#import "NPBundleLoader.h"


@implementation BundleLoaderTest

- (void)testBundlePaths
{
	// The paths returned should be the paths actually stored in IB's preferences
	
	NSString *path = [NSHomeDirectory() stringByAppendingPathComponent: @"Library/Preferences/com.apple.InterfaceBuilder3.plist"];
	STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath: path], @"IB Preferences file does not exist");
	
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
	STAssertNotNil(dict, @"Can't load preferences file");
	
	NSString *pathsKey = [[[[dict keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
		return [key hasPrefix: @"IBKnownPluginPaths"];
	}] allObjects] sortedArrayUsingSelector: @selector(compare:)] lastObject];
	
	STAssertTrue([[NSSet setWithArray: [[dict objectForKey: pathsKey] allValues]] isEqualToSet: [NSSet setWithArray: [NPBundleLoader interfaceBuilderKnownPluginPaths]]], @"Loaded Bundle paths don't match");
}

- (void)testFrameworkPath
{
	NSString *path = [NPBundleLoader interfaceBuilderFrameworkPath];
	STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath: path], @"IB Framework does not exist at path: %@", path);
}

/*
 There should be exactly one shared instance
 */
- (void)testSharedInstance
{
	
	id instance1, instance2;
	
	instance1 = [NPBundleLoader sharedInstance];
	STAssertNotNil(instance1, @"No shared description loader");
	
	instance2 = [NPBundleLoader sharedInstance];
	STAssertTrue([instance1 isEqual: instance2], @"Amibigious shared instance");
}

/*
 Check exception throwing behaviour for non-existent paths
 */
- (void)testThrowOnNotFound
{
	NPBundleLoader *loader = [NPBundleLoader sharedInstance];
	NSString *path = @"some/arbitrary/path/that/does_not_exist";
	
	STAssertThrowsSpecificNamed([loader loadBundle: path], NSException, NSInvalidArgumentException, @"Does not throw on non-existent bundle");
	STAssertNoThrow([loader loadBundles: [NSArray arrayWithObject: path]], @"Should not throw on non-existent bundle!");
}

/*
 Check whether successfull bundle load actually loads classes
 */
- (void)testLoadedBundle
{
	STAssertNil(NSClassFromString(@"RBSplitView"), @"Class not loaded!");
	STAssertNil(NSClassFromString(@"RBSplitSubview"), @"Class not loaded!");
	
	// Find bundle
	NSString *path = [[NSBundle bundleForClass: [self class]] pathForResource:@"RBSplitView" ofType:@"ibplugin" inDirectory:@"Test Data/Loader"];
	STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath: path], @"Can't find example bundle to load");
	
	// Load the bundle
	[[NPBundleLoader sharedInstance] loadBundle: path];
	
	// Check for the classes
	STAssertNotNil(NSClassFromString(@"RBSplitView"), @"Class not loaded!");
	STAssertNotNil(NSClassFromString(@"RBSplitSubview"), @"Class not loaded!");
}

@end
