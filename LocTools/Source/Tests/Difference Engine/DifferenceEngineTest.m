//
//  DifferenceEngineTest.m
//  LocTools
//
//  Created by max on 07.06.09.
//  Copyright 2009 Blue Technologies Group. All rights reserved.
//

#import "DifferenceEngineTest.h"

@implementation DifferenceEngineTest

- (void)setUp {
	engine = [LTDifferenceEngine new];
	[engine setSegmentation:BLDetailedSegmentation];
}

- (void)testMatchValue {
	[engine setOldString:@"Hello"];
	[engine setNewString:@"Hello"];
	[engine computeMatchValueOnly];
	XCTAssertEqual([engine matchValue], 1.0f, @"Match value should be 1 for equal strings");

	[engine setOldString:@"Hello"];
	[engine setNewString:@"Hallo"];
	[engine computeMatchValueOnly];
	XCTAssertEqual([engine matchValue], 0.0f, @"Match value should be 0 for different strings");

	[engine setOldString:@"Hello me"];
	[engine setNewString:@"Hello you"];
	[engine computeMatchValueOnly];
	XCTAssertEqual([engine matchValue], 0.5f, @"Match value should be 0.5");

	[engine setOldString:@"Hello"];
	[engine setNewString:@"Hello you"];
	[engine computeMatchValueOnly];
	XCTAssertEqualsWithAccuracy([engine matchValue], 0.666f, 0.001f, @"Match value should be about 0.666");

	[engine setOldString:@"Hello!"];
	[engine setNewString:@"Hello you!"];
	[engine computeMatchValueOnly];
	XCTAssertEqualsWithAccuracy([engine matchValue], 0.8f, 0.001f, @"Match value should be about 0.8");

	[engine setOldString:@"Hello?"];
	[engine setNewString:@"Hello you!"];
	[engine computeMatchValueOnly];
	XCTAssertEqualsWithAccuracy([engine matchValue], 0.4f, 0.001f, @"Match value should be about 0.4");

	[engine setOldString:@"(Hello)"];
	[engine setNewString:@"(Hallo)"];
	[engine computeMatchValueOnly];
	XCTAssertEqualsWithAccuracy([engine matchValue], 0.666f, 0.001f, @"Match value should be about 0.666");

	[engine setOldString:@"(Hello you)"];
	[engine setNewString:@"(Hallo you)"];
	[engine computeMatchValueOnly];
	XCTAssertEqualsWithAccuracy([engine matchValue], 0.75f, 0.001f, @"Match value should be about 0.666");

	[engine setOldString:@"Hello"];
	[engine setNewString:@": Hello :"];
	[engine computeMatchValueOnly];
	XCTAssertEqualsWithAccuracy([engine matchValue], 0.5f, 0.001f, @"Match value should be about 0.5");
}

- (void)testDifferences {
	LTDifference *diff;

	[engine setOldString:@"Hello this is a phrase!!"];
	[engine setNewString:@"Hello is no phrase, is it!?"];
	[engine computeDifferences];

	XCTAssertEqual([[engine differences] count], (NSUInteger)8, @"Number of differneces wrong");

	diff = [[engine differences] objectAtIndex:0];
	XCTAssertEqual([diff type], LTDifferenceCopy, @"Wrong type");
	XCTAssertEqualObjects([diff oldValue], @"Hello", @"Wrong old value");
	XCTAssertEqualObjects([diff newValue], @"Hello", @"Wrong new value");

	diff = [[engine differences] objectAtIndex:1];
	XCTAssertEqual([diff type], LTDifferenceDelete, @"Wrong type");
	XCTAssertEqualObjects([diff oldValue], @"this", @"Wrong old value");
	XCTAssertEqualObjects([diff newValue], @"", @"Wrong new value");

	diff = [[engine differences] objectAtIndex:2];
	XCTAssertEqual([diff type], LTDifferenceCopy, @"Wrong type");
	XCTAssertEqualObjects([diff oldValue], @"is", @"Wrong old value");
	XCTAssertEqualObjects([diff newValue], @"is", @"Wrong new value");

	diff = [[engine differences] objectAtIndex:3];
	XCTAssertEqual([diff type], LTDifferenceChange, @"Wrong type");
	XCTAssertEqualObjects([diff oldValue], @"a", @"Wrong old value");
	XCTAssertEqualObjects([diff newValue], @"no", @"Wrong new value");

	diff = [[engine differences] objectAtIndex:4];
	XCTAssertEqual([diff type], LTDifferenceCopy, @"Wrong type");
	XCTAssertEqualObjects([diff oldValue], @"phrase", @"Wrong old value");
	XCTAssertEqualObjects([diff newValue], @"phrase", @"Wrong new value");

	diff = [[engine differences] objectAtIndex:5];
	XCTAssertEqual([diff type], LTDifferenceAdd, @"Wrong type");
	XCTAssertEqualObjects([diff oldValue], @"", @"Wrong old value");
	XCTAssertEqualObjects([diff newValue], @", is it", @"Wrong new value");

	diff = [[engine differences] objectAtIndex:6];
	XCTAssertEqual([diff type], LTDifferenceCopy, @"Wrong type");
	XCTAssertEqualObjects([diff oldValue], @"!", @"Wrong old value");
	XCTAssertEqualObjects([diff newValue], @"!", @"Wrong new value");

	diff = [[engine differences] objectAtIndex:7];
	XCTAssertEqual([diff type], LTDifferenceChange, @"Wrong type");
	XCTAssertEqualObjects([diff oldValue], @"!", @"Wrong old value");
	XCTAssertEqualObjects([diff newValue], @"?", @"Wrong new value");
}

- (void)testPunctiuation {
	LTDifference *diff;

	[engine setOldString:@"Hello du da"];
	[engine setNewString:@": Hello ?du? da :"];
	[engine computeDifferences];

	XCTAssertEqual([[engine differences] count], (NSUInteger)7, @"Number of differneces wrong");

	diff = [[engine differences] objectAtIndex:0];
	XCTAssertEqual([diff type], LTDifferenceAdd, @"Wrong type");
	XCTAssertEqualObjects([diff oldValue], @"", @"Wrong old value");
	XCTAssertEqualObjects([diff newValue], @":", @"Wrong new value");

	diff = [[engine differences] objectAtIndex:1];
	XCTAssertEqual([diff type], LTDifferenceCopy, @"Wrong type");
	XCTAssertEqualObjects([diff oldValue], @"Hello", @"Wrong old value");
	XCTAssertEqualObjects([diff newValue], @"Hello", @"Wrong new value");

	diff = [[engine differences] objectAtIndex:2];
	XCTAssertEqual([diff type], LTDifferenceAdd, @"Wrong type");
	XCTAssertEqualObjects([diff oldValue], @"", @"Wrong old value");
	XCTAssertEqualObjects([diff newValue], @"?", @"Wrong new value");

	diff = [[engine differences] objectAtIndex:3];
	XCTAssertEqual([diff type], LTDifferenceCopy, @"Wrong type");
	XCTAssertEqualObjects([diff oldValue], @"du", @"Wrong old value");
	XCTAssertEqualObjects([diff newValue], @"du", @"Wrong new value");

	diff = [[engine differences] objectAtIndex:4];
	XCTAssertEqual([diff type], LTDifferenceAdd, @"Wrong type");
	XCTAssertEqualObjects([diff oldValue], @"", @"Wrong old value");
	XCTAssertEqualObjects([diff newValue], @"?", @"Wrong new value");

	diff = [[engine differences] objectAtIndex:5];
	XCTAssertEqual([diff type], LTDifferenceCopy, @"Wrong type");
	XCTAssertEqualObjects([diff oldValue], @"da", @"Wrong old value");
	XCTAssertEqualObjects([diff newValue], @"da", @"Wrong new value");

	diff = [[engine differences] objectAtIndex:6];
	XCTAssertEqual([diff type], LTDifferenceAdd, @"Wrong type");
	XCTAssertEqualObjects([diff oldValue], @"", @"Wrong old value");
	XCTAssertEqualObjects([diff newValue], @":", @"Wrong new value");
}

@end
