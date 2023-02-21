//
//  XcodeProjectModificationTest.m
//  BlueLocalization
//
//  Created by max on 03.07.09.
//  Copyright 2009 Blue Technologies Group. All rights reserved.
//

#import "XcodeProjectModificationTest.h"

#import "BLXcodeProjectInternal.h"

@implementation XcodeProjectModificationTest

- (void)setUp:(NSString *)project folder:(NSString *)folder {
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:project ofType:@"xcodeproj" inDirectory:[@"Test Data/Xcode/" stringByAppendingPathComponent:folder]];

	parser = [BLXcodeProjectParser parserWithProjectFileAtPath:path];
	[parser loadProject];
	mainGroup = [parser mainGroup];

	objectsDict = [[parser valueForKey:@"_contents"] objectForKey:BLXcodeProjectObjectsKey];
}

- (void)testItemCreation {
	BLXcodeProjectItem *item;

	[self setUp:@"project" folder:@"proj1"];

	item = [BLXcodeProjectItem blankItemWithType:BLXcodeItemTypeGroup];
	XCTAssertEqual([item itemType], BLXcodeItemTypeGroup, @"Wrong item type");
	XCTAssertEqual([item pathType], BLXcodePathTypeGroup, @"Wring path type");
	XCTAssertNil([item path], @"Item should have no path");
	XCTAssertNil([item name], @"Item should have no name");
	XCTAssertNil([item parent], @"Item should have no parent");
	XCTAssertNotNil([item children], @"Item should have a childrens array");
	XCTAssertEqual([[item children] count], (NSUInteger)0, @"Item should have no children");
}

- (void)testUniqueIdentifiers {
	NSString *id1, *id2;

	[self setUp:@"project" folder:@"proj1"];

	id1 = [parser createUniqueIdentifier];
	id2 = [parser createUniqueIdentifier];

	XCTAssertFalse([id1 isEqual:id2], @"Two identifiers should not be the same");
	XCTAssertTrue([id1 length] == 24, @"Identifier is too short");
	XCTAssertEqualObjects([id1 uppercaseString], id1, @"Ifdentifier should be uppercas string");
	XCTAssertTrue([id1 rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].length == 0, @"Indentifiers must be numbers and characters only");
	XCTAssertNil([parser objectWithIdentifier:id1], @"Identifier is in use");
}

- (void)testAddRemoveItem {
	[self setUp:@"project" folder:@"proj1"];

	NSArray *allKeys = [objectsDict allKeys];
	XCTAssertEqual([objectsDict count], (NSUInteger)18, @"Wrong initial number of objects");

	NSMutableDictionary *someDict = [NSMutableDictionary dictionary];
	NSString *newKey = [parser addObject:someDict];
	XCTAssertEqual([objectsDict count], (NSUInteger)19, @"Object was not added");

	NSMutableArray *newKeys = [NSMutableArray arrayWithArray:[objectsDict allKeys]];
	[newKeys removeObjectsInArray:allKeys];
	XCTAssertEqual([newKeys count], (NSUInteger)1, @"One key should have been added");
	XCTAssertEqualObjects([newKeys lastObject], newKey, @"Returned key should be the same as in dict");
	XCTAssertEqual([objectsDict objectForKey:[newKeys lastObject]], someDict, @"New key should belong to new object");
	XCTAssertEqual([parser objectWithIdentifier:[newKeys lastObject]], someDict, @"Parser should return the same object");

	[parser removeObjectWithIdentifier:[newKeys lastObject]];
	XCTAssertEqual([objectsDict count], (NSUInteger)18, @"Item was not deleted");
	XCTAssertEqualObjects([objectsDict allKeys], allKeys, @"Keys should be like they were before");
}

- (void)testAddRemoveChild {
	[self setUp:@"project" folder:@"proj1"];

	BLXcodeProjectItem *newItem;
	NSArray *items;

	XCTAssertEqual([objectsDict count], (NSUInteger)18, @"Wrong initial number of objects");

	items = [NSArray arrayWithArray:[mainGroup children]];
	newItem = [BLXcodeProjectItem blankItemWithType:BLXcodeItemTypeFile];
	XCTAssertEqual([objectsDict count], (NSUInteger)18, @"Item should not yet be added to objects dictionary");

	XCTAssertThrows([newItem addChild:nil], @"Unassigned items must not allow childs to be added");

	[mainGroup addChild:newItem];
	XCTAssertEqualObjects([items arrayByAddingObject:newItem], [mainGroup children], @"New item should be in children array");
	XCTAssertEqual([objectsDict count], (NSUInteger)19, @"Item was not added to objects dictionary");

	NSDictionary *mainGroupDict = [objectsDict objectForKey:@"29B97314FDCFA39411CA2CEA"];
	XCTAssertNotNil(mainGroupDict, @"Main group id has changed");
	XCTAssertEqual([[mainGroupDict objectForKey:BLXcodeProjectItemChildrenKey] count], (NSUInteger)3, @"Item was not added to group");

	for (NSString *key in [mainGroupDict objectForKey:BLXcodeProjectItemChildrenKey])
		XCTAssertNotNil([objectsDict objectForKey:key], @"Child item does not exist");

	XCTAssertThrows([mainGroup removeChild:[[mainGroup children] objectAtIndex:0]], @"Items with children must not be removed");

	[mainGroup removeChild:newItem];
	XCTAssertEqualObjects(items, [mainGroup children], @"New item should no longer be in children array");
	XCTAssertEqual([objectsDict count], (NSUInteger)18, @"Item was not removed from objects dictionary");
	XCTAssertEqual([[mainGroupDict objectForKey:BLXcodeProjectItemChildrenKey] count], (NSUInteger)2, @"Item was not removed from group");
}

@end
