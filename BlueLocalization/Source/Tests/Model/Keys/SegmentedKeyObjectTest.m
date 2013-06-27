//
//  SegmentedKeyObjectTest.m
//  BlueLocalization
//
//  Created by max on 17.02.10.
//  Copyright 2010 The Soulmen. All rights reserved.
//

#import "SegmentedKeyObjectTest.h"

#import <BlueLocalization/BLStringKeyObject.h>


@implementation SegmentedKeyObjectTest

- (void)testCreation
{
	BLStringKeyObject *stringObject = [BLStringKeyObject keyObjectWithKey: @"test"];
	
	// Too few segments
	[stringObject setObject:@"Hello" forLanguage:@"en"];
	STAssertEqualObjects([NSArray arrayWithObject: stringObject], [BLSegmentedKeyObject segmentKeyObject:stringObject byType:BLSentenceSegmentation], @"Should not create a object");
	
	// Still too few segments
	[stringObject setObject:@"Hallo" forLanguage:@"de"];
	STAssertEqualObjects([NSArray arrayWithObject: stringObject], [BLSegmentedKeyObject segmentKeyObject:stringObject byType:BLSentenceSegmentation], @"Should not create a object");
	
	// Different segment counts
	[stringObject setObject:@"Hello. You." forLanguage:@"en"];
	STAssertEqualObjects([NSArray arrayWithObject: stringObject], [BLSegmentedKeyObject segmentKeyObject:stringObject byType:BLSentenceSegmentation], @"Should not create a object");
	
	// Shoudl create object
	[stringObject setObject:@"Hallo. Du." forLanguage:@"de"];
	STAssertEquals([[BLSegmentedKeyObject segmentKeyObject:stringObject byType:BLSentenceSegmentation] count], (NSUInteger)2, @"Wrong number of objects");
}

- (void)testGettingAndSetting
{
	BLStringKeyObject *original = [BLStringKeyObject keyObjectWithKey: @"test"];
	[original setObject:@"Hello. You!\n" forLanguage:@"en"];
	[original setObject:@"Hallo. Du?\n" forLanguage:@"de"];
	
	NSArray *segments = [BLSegmentedKeyObject segmentKeyObject:original byType:BLSentenceSegmentation];
	
	// Read strings
	BLKeyObject *seg = [segments objectAtIndex: 0];
	STAssertEqualObjects([seg objectForLanguage: @"en"], @"Hello.", @"Wrong string read");
	STAssertEqualObjects([seg objectForLanguage: @"de"], @"Hallo.", @"Wrong string read");
	
	seg = [segments objectAtIndex: 1];
	STAssertEqualObjects([seg objectForLanguage: @"en"], @"You!", @"Wrong string read");
	STAssertEqualObjects([seg objectForLanguage: @"de"], @"Du?", @"Wrong string read");
	
	// Try changing a string
	seg = [segments objectAtIndex: 1];
	[seg setObject:@"Ich!" forLanguage:@"de"];
	
	STAssertEqualObjects([seg objectForLanguage: @"de"], @"Ich!", @"String was not set.");
	STAssertEqualObjects([original objectForLanguage: @"de"], @"Hallo. Ich!\n", @"String was not set correctly.");
}

@end
