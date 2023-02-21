//
//  XcodeProjectParserTest.m
//  BlueLocalization
//
//  Created by max on 01.07.09.
//  Copyright 2009 Blue Technologies Group. All rights reserved.
//

#import "XcodeProjectParserTest.h"

#import "BLXcodeProjectInternal.h"

@implementation XcodeProjectParserTest

- (void)setUp {
	projectPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"project" ofType:@"xcodeproj" inDirectory:@"Test Data/Xcode/proj1"];
	parser = [BLXcodeProjectParser parserWithProjectFileAtPath:projectPath];
}

- (void)testProjectLoading {
	XCTAssertFalse([parser projectIsLoaded], @"The project should not yet be loaded");
	XCTAssertNil([parser mainGroup], @"No item root should exist created");

	[parser loadProject];

	XCTAssertTrue([parser projectIsLoaded], @"There was an error during loading the project");
	XCTAssertNotNil([parser mainGroup], @"No item root was created");

	XCTAssertEqualObjects([parser projectPath], [projectPath stringByDeletingLastPathComponent], @"Project path wrong");
	XCTAssertEqualObjects([parser projectName], [projectPath lastPathComponent], @"Project name wrong");
}

- (void)testMainGroup {
	BLXcodeProjectItem *item;

	[parser loadProject];
	item = [parser mainGroup];

	XCTAssertEqual([item itemType], BLXcodeItemTypeGroup, @"Root is no group");
	XCTAssertEqualObjects([item name], @"Testproject", @"Root has wrong name");
	XCTAssertEqual([[item children] count], (NSUInteger)2, @"Wrong child count for root");
}

- (void)testItemStructure {
	BLXcodeProjectItem *item, *subitem;

	[parser loadProject];
	item = [parser mainGroup];
	XCTAssertEqualObjects([item name], @"Testproject", @"Item has wrong name");
	XCTAssertEqualObjects([item path], nil, @"Item has wrong path");
	XCTAssertEqual([item itemType], BLXcodeItemTypeGroup, @"Item has wrong type");
	XCTAssertEqual([[item children] count], (NSUInteger)2, @"Too few children");

	item = [[item children] objectAtIndex:0];
	XCTAssertEqualObjects([item name], @"Resources", @"Item has wrong name");
	XCTAssertEqualObjects([item path], @"Resources", @"Item has wrong path");
	XCTAssertEqual([item itemType], BLXcodeItemTypeGroup, @"Item has wrong type");
	XCTAssertEqual([[item children] count], (NSUInteger)3, @"Too few children");

	NSArray *names = [NSArray arrayWithObjects:@"InfoPlist.strings", @"MainMenu.xib", @"Localizable.strings", nil];

	for (subitem in [item children]) {
		XCTAssertTrue([names containsObject:[subitem name]], @"Unknown subitem name");
		XCTAssertEqual([subitem parent], item, @"Wrong parentat relations");
		XCTAssertEqual([subitem itemType], BLXcodeItemTypeVariantGroup, @"Item has wrong type");

		BLXcodeProjectItem *subsubitem = [[subitem children] objectAtIndex:0];

		XCTAssertTrue([[subsubitem name] isEqual:@"English"], @"Subitem has no subitem named \"English\"");
		XCTAssertEqual([subsubitem itemType], BLXcodeItemTypeFile, @"Item has wrong type");
		XCTAssertEqual([subsubitem children], (NSArray *)nil, @"Files should return no children");
	}
}

- (void)testGroupPathGeneration {
	BLXcodeProjectItem *item;
	NSString *path;

	[parser loadProject];

	item = [parser mainGroup];
	path = [parser projectPath];
	XCTAssertEqualObjects([item fullPath], path, @"Wrong path for root group");

	item = [[item children] objectAtIndex:0];
	path = [path stringByAppendingPathComponent:@"Resources"];
	XCTAssertEqualObjects([item fullPath], path, @"Wrong path for group");

	item = [[item children] objectAtIndex:0];
	path = path;
	XCTAssertEqualObjects([item fullPath], path, @"Wrong path for group");

	item = [[item children] objectAtIndex:0];
	path = [path stringByAppendingPathComponent:@"English.lproj/InfoPlist.strings"];
	XCTAssertEqualObjects([item fullPath], path, @"Wrong path for file");
}

- (void)testOtherPathGeneration {
	BLXcodeProjectItem *item, *aItem;
	NSString *path;

	[parser loadProject];

	item = [parser mainGroup];
	path = [parser projectPath];
	XCTAssertEqualObjects([item fullPath], path, @"Wrong path for root group");

	item = [[item children] objectAtIndex:1];
	path = [path stringByAppendingPathComponent:@"Folder"];
	XCTAssertEqualObjects([item fullPath], path, @"Wrong path for group");

	aItem = [[item children] objectAtIndex:0];
	XCTAssertEqualObjects([aItem fullPath], [path stringByAppendingPathComponent:@"Localizable.strings"], @"Wrong path for file");
	aItem = [[item children] objectAtIndex:1];
	XCTAssertEqualObjects([aItem fullPath], [path stringByAppendingPathComponent:@"Localizable2.strings"], @"Wrong path for file");

	aItem = [[item children] objectAtIndex:2];
	XCTAssertNil([aItem fullPath], @"Unknow referencing type should not return any path...");
	aItem = [[item children] objectAtIndex:3];
	XCTAssertNil([aItem fullPath], @"Unknow referencing type should not return any path...");
	aItem = [[item children] objectAtIndex:4];
	XCTAssertNil([aItem fullPath], @"Unknow referencing type should not return any path...");
}

@end
