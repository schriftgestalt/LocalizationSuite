//
//  XcodeProjectLocalizationTest.m
//  BlueLocalization
//
//  Created by max on 17.07.09.
//  Copyright 2009 Blue Technologies Group. All rights reserved.
//

#import "XcodeProjectLocalizationTest.h"

@implementation XcodeProjectLocalizationTest

- (void)setUp:(NSString *)project folder:(NSString *)folder {
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:project ofType:@"xcodeproj" inDirectory:[@"Test Data/Xcode/" stringByAppendingPathComponent:folder]];

	parser = [BLXcodeProjectParser parserWithProjectFileAtPath:path];
	[parser loadProject];
	mainGroup = [parser mainGroup];
}

- (void)testVariantGroups {
	NSArray *variantGroups;

	[self setUp:@"project" folder:@"proj1"];

	variantGroups = [mainGroup localizedVariantGroups];
	STAssertNotNil(variantGroups, @"Nothing returned!");
	STAssertEquals([variantGroups count], (NSUInteger)3, @"Found wrong number of variant groups");

	for (BLXcodeProjectItem *item in variantGroups) {
		STAssertEqualObjects([item localizations], [NSArray arrayWithObject:@"en"], @"Item should be only english");
	}
}

- (void)testLocalizationEditing {
	[self setUp:@"project" folder:@"proj1"];

	NSArray *variantGroups = [mainGroup localizedVariantGroups];
	BLXcodeProjectItem *item = [variantGroups objectAtIndex:0];

	// Test initial state
	STAssertEqualObjects([item localizations], [NSArray arrayWithObject:@"en"], @"Item should be only english");
	STAssertEquals([[item children] count], (NSUInteger)1, @"Item should have only one single child");

	// Test added item and verify path
	[item addLocalizations:[NSArray arrayWithObject:@"de"]];
	STAssertEquals([[item children] count], (NSUInteger)2, @"No item was added");
	STAssertEqualObjects([item localizations], ([NSArray arrayWithObjects:@"en", @"de", nil]), @"Item should now be english and german");
	STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[[[item children] objectAtIndex:1] fullPath]], @"Wrong item path");

	// Test removal
	[item removeLocalizations:[NSArray arrayWithObject:@"en"]];
	STAssertEquals([[item children] count], (NSUInteger)1, @"Item was not deleted");
	STAssertEqualObjects([item localizations], [NSArray arrayWithObject:@"de"], @"Item should now be german only");

	// Test other names (just because it works)
	[item addLocalizations:[NSArray arrayWithObject:@"English"]];
	STAssertEqualObjects([item localizations], ([NSArray arrayWithObjects:@"de", @"en", nil]), @"Item should now be english and german");

	// Test multiple add
	[item addLocalizations:[NSArray arrayWithObjects:@"pt", @"fr", nil]];
	STAssertEqualObjects([item localizations], ([NSArray arrayWithObjects:@"de", @"en", @"pt", @"fr", nil]), @"Item should now be english and german");

	// Test multiple removal
	[item removeLocalizations:[NSArray arrayWithObjects:@"pt", @"en", nil]];
	STAssertEqualObjects([item localizations], ([NSArray arrayWithObjects:@"de", @"fr", nil]), @"Item should now be english and german");

	// Border cases
	[item removeLocalizations:[item localizations]];
	STAssertEqualObjects([item localizations], [NSArray array], @"No localizations should be left");
	STAssertThrows([item addLocalizations:[NSArray arrayWithObject:@"de"]], @"Empty groups should accept no new locs.");
}

- (void)testLocalizationNameUpdate {
	[self setUp:@"project" folder:@"proj1"];

	// Create a copy, modify parser
	NSString *tmpPath = @"/tmp/loc-xcode";
	STAssertTrue([[NSFileManager defaultManager] copyItemAtPath:[parser projectPath] toPath:tmpPath error:NULL], @"Copy failed");
	[parser setValue:[tmpPath stringByAppendingPathComponent:[parser projectName]] forKey:@"_path"];

	// Find file
	BLXcodeProjectItem *file = nil;
	for (BLXcodeProjectItem *item in [mainGroup localizedVariantGroups]) {
		if ([[item name] isEqual:@"Localizable.strings"])
			file = item;
	}
	STAssertNotNil(file, @"No file found!");

	// Add to project
	[[NSFileManager defaultManager] copyItemAtPath:[tmpPath stringByAppendingPathComponent:@"Resources/German.lproj"]
											toPath:[tmpPath stringByAppendingPathComponent:@"Resources/no.lproj"]
											 error:NULL];
	[file addLocalizations:[NSArray arrayWithObjects:@"no", nil]];
	STAssertTrue([[file exactLocalizations] containsObject:@"no"], @"Language not added.");

	// Move files
	[[NSFileManager defaultManager] moveItemAtPath:[tmpPath stringByAppendingPathComponent:@"Resources/no.lproj"]
											toPath:[tmpPath stringByAppendingPathComponent:@"Resources/nb.lproj"]
											 error:NULL];
	[file updateLocalizationNames];
	STAssertFalse([[file exactLocalizations] containsObject:@"no"], @"Language not renamed.");
	STAssertTrue([[file exactLocalizations] containsObject:@"nb"], @"Language not renamed.");

	// Clean up
	[[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
}

- (void)testOtherPathTypes {
	[self setUp:@"project2" folder:@"proj1"];

	NSArray *variantGroups = [mainGroup localizedVariantGroups];
	BLXcodeProjectItem *item = [variantGroups objectAtIndex:0];

	// Test initial state
	STAssertEqualObjects([item localizations], [NSArray arrayWithObject:@"en"], @"Item should be only english");
	STAssertEquals([[item children] count], (NSUInteger)1, @"Item should have only one single child");

	// Test added item and verify path
	[item addLocalizations:[NSArray arrayWithObject:@"de"]];
	STAssertEquals([[item children] count], (NSUInteger)2, @"No item was added");
	STAssertEqualObjects([item localizations], ([NSArray arrayWithObjects:@"en", @"de", nil]), @"Item should now be english and german");
	STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[[[item children] objectAtIndex:1] fullPath]], @"Wrong item path");
}

@end
