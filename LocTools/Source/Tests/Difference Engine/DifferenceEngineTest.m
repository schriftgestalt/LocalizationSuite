//
//  DifferenceEngineTest.m
//  LocTools
//
//  Created by max on 07.06.09.
//  Copyright 2009 Blue Technologies Group. All rights reserved.
//

#import "DifferenceEngineTest.h"


@implementation DifferenceEngineTest

- (void)setUp
{
	engine = [LTDifferenceEngine new];
	[engine setSegmentation: BLDetailedSegmentation];
}

- (void)testMatchValue
{
	[engine setOldString: @"Hello"];
	[engine setNewString: @"Hello"];
	[engine computeMatchValueOnly];
	STAssertEquals([engine matchValue], 1.0f, @"Match value should be 1 for equal strings");
	
	[engine setOldString: @"Hello"];
	[engine setNewString: @"Hallo"];
	[engine computeMatchValueOnly];
	STAssertEquals([engine matchValue], 0.0f, @"Match value should be 0 for different strings");
	
	[engine setOldString: @"Hello me"];
	[engine setNewString: @"Hello you"];
	[engine computeMatchValueOnly];
	STAssertEquals([engine matchValue], 0.5f, @"Match value should be 0.5");
	
	[engine setOldString: @"Hello"];
	[engine setNewString: @"Hello you"];
	[engine computeMatchValueOnly];
	STAssertEqualsWithAccuracy([engine matchValue], 0.666f, 0.001f, @"Match value should be about 0.666");
	
	[engine setOldString: @"Hello!"];
	[engine setNewString: @"Hello you!"];
	[engine computeMatchValueOnly];
	STAssertEqualsWithAccuracy([engine matchValue], 0.8f, 0.001f, @"Match value should be about 0.8");
	
	[engine setOldString: @"Hello?"];
	[engine setNewString: @"Hello you!"];
	[engine computeMatchValueOnly];
	STAssertEqualsWithAccuracy([engine matchValue], 0.4f, 0.001f, @"Match value should be about 0.4");
	
	[engine setOldString: @"(Hello)"];
	[engine setNewString: @"(Hallo)"];
	[engine computeMatchValueOnly];
	STAssertEqualsWithAccuracy([engine matchValue], 0.666f, 0.001f, @"Match value should be about 0.666");
	
	[engine setOldString: @"(Hello you)"];
	[engine setNewString: @"(Hallo you)"];
	[engine computeMatchValueOnly];
	STAssertEqualsWithAccuracy([engine matchValue], 0.75f, 0.001f, @"Match value should be about 0.666");
	
	[engine setOldString: @"Hello"];
	[engine setNewString: @": Hello :"];
	[engine computeMatchValueOnly];
	STAssertEqualsWithAccuracy([engine matchValue], 0.5f, 0.001f, @"Match value should be about 0.5");
}

- (void)testDifferences
{
	LTDifference *diff;
	
	[engine setOldString: @"Hello this is a phrase!!"];
	[engine setNewString: @"Hello is no phrase, is it!?"];
	[engine computeDifferences];
	
	STAssertEquals([[engine differences] count], (NSUInteger)8, @"Number of differneces wrong");
	
	diff = [[engine differences] objectAtIndex: 0];
	STAssertEquals([diff type], LTDifferenceCopy, @"Wrong type");
	STAssertEqualObjects([diff oldValue], @"Hello", @"Wrong old value");
	STAssertEqualObjects([diff newValue], @"Hello", @"Wrong new value");
	
	diff = [[engine differences] objectAtIndex: 1];
	STAssertEquals([diff type], LTDifferenceDelete, @"Wrong type");
	STAssertEqualObjects([diff oldValue], @"this", @"Wrong old value");
	STAssertEqualObjects([diff newValue], @"", @"Wrong new value");
	
	diff = [[engine differences] objectAtIndex: 2];
	STAssertEquals([diff type], LTDifferenceCopy, @"Wrong type");
	STAssertEqualObjects([diff oldValue], @"is", @"Wrong old value");
	STAssertEqualObjects([diff newValue], @"is", @"Wrong new value");
	
	diff = [[engine differences] objectAtIndex: 3];
	STAssertEquals([diff type], LTDifferenceChange, @"Wrong type");
	STAssertEqualObjects([diff oldValue], @"a", @"Wrong old value");
	STAssertEqualObjects([diff newValue], @"no", @"Wrong new value");
	
	diff = [[engine differences] objectAtIndex: 4];
	STAssertEquals([diff type], LTDifferenceCopy, @"Wrong type");
	STAssertEqualObjects([diff oldValue], @"phrase", @"Wrong old value");
	STAssertEqualObjects([diff newValue], @"phrase", @"Wrong new value");
	
	diff = [[engine differences] objectAtIndex: 5];
	STAssertEquals([diff type], LTDifferenceAdd, @"Wrong type");
	STAssertEqualObjects([diff oldValue], @"", @"Wrong old value");
	STAssertEqualObjects([diff newValue], @", is it", @"Wrong new value");
	
	diff = [[engine differences] objectAtIndex: 6];
	STAssertEquals([diff type], LTDifferenceCopy, @"Wrong type");
	STAssertEqualObjects([diff oldValue], @"!", @"Wrong old value");
	STAssertEqualObjects([diff newValue], @"!", @"Wrong new value");
	
	diff = [[engine differences] objectAtIndex: 7];
	STAssertEquals([diff type], LTDifferenceChange, @"Wrong type");
	STAssertEqualObjects([diff oldValue], @"!", @"Wrong old value");
	STAssertEqualObjects([diff newValue], @"?", @"Wrong new value");
}

- (void)testPunctiuation
{
	LTDifference *diff;
	
	[engine setOldString: @"Hello du da"];
	[engine setNewString: @": Hello ?du? da :"];
	[engine computeDifferences];
	
	STAssertEquals([[engine differences] count], (NSUInteger)7, @"Number of differneces wrong");
	
	diff = [[engine differences] objectAtIndex: 0];
	STAssertEquals([diff type], LTDifferenceAdd, @"Wrong type");
	STAssertEqualObjects([diff oldValue], @"", @"Wrong old value");
	STAssertEqualObjects([diff newValue], @":", @"Wrong new value");
	
	diff = [[engine differences] objectAtIndex: 1];
	STAssertEquals([diff type], LTDifferenceCopy, @"Wrong type");
	STAssertEqualObjects([diff oldValue], @"Hello", @"Wrong old value");
	STAssertEqualObjects([diff newValue], @"Hello", @"Wrong new value");
	
	diff = [[engine differences] objectAtIndex: 2];
	STAssertEquals([diff type], LTDifferenceAdd, @"Wrong type");
	STAssertEqualObjects([diff oldValue], @"", @"Wrong old value");
	STAssertEqualObjects([diff newValue], @"?", @"Wrong new value");
	
	diff = [[engine differences] objectAtIndex: 3];
	STAssertEquals([diff type], LTDifferenceCopy, @"Wrong type");
	STAssertEqualObjects([diff oldValue], @"du", @"Wrong old value");
	STAssertEqualObjects([diff newValue], @"du", @"Wrong new value");
	
	diff = [[engine differences] objectAtIndex: 4];
	STAssertEquals([diff type], LTDifferenceAdd, @"Wrong type");
	STAssertEqualObjects([diff oldValue], @"", @"Wrong old value");
	STAssertEqualObjects([diff newValue], @"?", @"Wrong new value");
	
	diff = [[engine differences] objectAtIndex: 5];
	STAssertEquals([diff type], LTDifferenceCopy, @"Wrong type");
	STAssertEqualObjects([diff oldValue], @"da", @"Wrong old value");
	STAssertEqualObjects([diff newValue], @"da", @"Wrong new value");
	
	diff = [[engine differences] objectAtIndex: 6];
	STAssertEquals([diff type], LTDifferenceAdd, @"Wrong type");
	STAssertEqualObjects([diff oldValue], @"", @"Wrong old value");
	STAssertEqualObjects([diff newValue], @":", @"Wrong new value");
	
}

@end
