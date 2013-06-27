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

- (void)setUp
{
	projectPath = [[NSBundle bundleForClass: [self class]] pathForResource:@"project" ofType:@"xcodeproj" inDirectory:@"Test Data/Xcode/proj1"];
	parser = [BLXcodeProjectParser parserWithProjectFileAtPath: projectPath];
}

- (void)testProjectLoading
{
	STAssertFalse([parser projectIsLoaded], @"The project should not yet be loaded");
	STAssertNil([parser mainGroup], @"No item root should exist created");
	
	[parser loadProject];
	
	STAssertTrue([parser projectIsLoaded], @"There was an error during loading the project");
	STAssertNotNil([parser mainGroup], @"No item root was created");
	
	STAssertEqualObjects([parser projectPath], [projectPath stringByDeletingLastPathComponent], @"Project path wrong");
	STAssertEqualObjects([parser projectName], [projectPath lastPathComponent], @"Project name wrong");
}

- (void)testMainGroup
{
	BLXcodeProjectItem *item;
	
	[parser loadProject];
	item = [parser mainGroup];
	
	STAssertEquals([item itemType], BLXcodeItemTypeGroup, @"Root is no group");
	STAssertEqualObjects([item name], @"Testproject", @"Root has wrong name");
	STAssertEquals([[item children] count], (NSUInteger)2, @"Wrong child count for root");
}

- (void)testItemStructure
{
	BLXcodeProjectItem *item, *subitem;
	
	[parser loadProject];
	item = [parser mainGroup];
	STAssertEqualObjects([item name], @"Testproject", @"Item has wrong name");
	STAssertEqualObjects([item path], nil, @"Item has wrong path");
	STAssertEquals([item itemType], BLXcodeItemTypeGroup, @"Item has wrong type");
	STAssertEquals([[item children] count], (NSUInteger)2, @"Too few children");
	
	item = [[item children] objectAtIndex: 0];
	STAssertEqualObjects([item name], @"Resources", @"Item has wrong name");
	STAssertEqualObjects([item path], @"Resources", @"Item has wrong path");
	STAssertEquals([item itemType], BLXcodeItemTypeGroup, @"Item has wrong type");
	STAssertEquals([[item children] count], (NSUInteger)3, @"Too few children");
	
	NSArray *names = [NSArray arrayWithObjects: @"InfoPlist.strings", @"MainMenu.xib", @"Localizable.strings", nil];
	
	for (subitem in [item children]) {
		STAssertTrue([names containsObject: [subitem name]], @"Unknown subitem name");
		STAssertEquals([subitem parent], item, @"Wrong parentat relations");
		STAssertEquals([subitem itemType], BLXcodeItemTypeVariantGroup, @"Item has wrong type");
		
		BLXcodeProjectItem *subsubitem = [[subitem children] objectAtIndex: 0];
		
		STAssertTrue([[subsubitem name] isEqual: @"English"], @"Subitem has no subitem named \"English\"");
		STAssertEquals([subsubitem itemType], BLXcodeItemTypeFile, @"Item has wrong type");
		STAssertEquals([subsubitem children], (NSArray *)nil, @"Files should return no children");
	}
}

- (void)testGroupPathGeneration
{
	BLXcodeProjectItem *item;
	NSString *path;
	
	[parser loadProject];
	
	item = [parser mainGroup];
	path = [parser projectPath];
	STAssertEqualObjects([item fullPath], path, @"Wrong path for root group");
	
	item = [[item children] objectAtIndex: 0];
	path = [path stringByAppendingPathComponent: @"Resources"];
	STAssertEqualObjects([item fullPath], path, @"Wrong path for group");
	
	item = [[item children] objectAtIndex: 0];
	path = path;
	STAssertEqualObjects([item fullPath], path, @"Wrong path for group");
	
	item = [[item children] objectAtIndex: 0];
	path = [path stringByAppendingPathComponent: @"English.lproj/InfoPlist.strings"];
	STAssertEqualObjects([item fullPath], path, @"Wrong path for file");
}

- (void)testOtherPathGeneration
{
	BLXcodeProjectItem *item, *aItem;
	NSString *path;
	
	[parser loadProject];
	
	item = [parser mainGroup];
	path = [parser projectPath];
	STAssertEqualObjects([item fullPath], path, @"Wrong path for root group");
	
	item = [[item children] objectAtIndex: 1];
	path = [path stringByAppendingPathComponent: @"Folder"];
	STAssertEqualObjects([item fullPath], path, @"Wrong path for group");
	
	aItem = [[item children] objectAtIndex: 0];
	STAssertEqualObjects([aItem fullPath], [path stringByAppendingPathComponent: @"Localizable.strings"], @"Wrong path for file");
	aItem = [[item children] objectAtIndex: 1];
	STAssertEqualObjects([aItem fullPath], [path stringByAppendingPathComponent: @"Localizable2.strings"], @"Wrong path for file");

	aItem = [[item children] objectAtIndex: 2];
	STAssertNil([aItem fullPath], @"Unknow referencing type should not return any path...");
	aItem = [[item children] objectAtIndex: 3];
	STAssertNil([aItem fullPath], @"Unknow referencing type should not return any path...");
	aItem = [[item children] objectAtIndex: 4];
	STAssertNil([aItem fullPath], @"Unknow referencing type should not return any path...");
}

@end
