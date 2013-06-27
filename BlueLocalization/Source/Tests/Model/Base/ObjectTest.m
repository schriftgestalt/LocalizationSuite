//
//  ObjectTest.m
//  BlueLocalization
//
//  Created by Max Seelemann on 25.11.08.
//  Copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
//

#import "ObjectTest.h"


@implementation ObjectTest

- (void)setUp
{
	bundle = [[BLObject alloc] init];
}

- (void)testBundle
{
	STAssertNotNil(bundle, @"Cannot create bundle");
}

- (void)testChangedValues
{
	[bundle setNothingDidChange];
	STAssertTrue([bundle didChange] == false, @"Wrong change state");
	STAssertTrue([[bundle changedValues] count] == 0, @"Wrong change number");
	
	NSString *string = @"test1";
	[bundle setValue:string didChange:YES];
	STAssertTrue([bundle didChange] == true, @"Wrong change state");
	STAssertTrue([[bundle changedValues] count] == 1, @"Change not tracked");
	
	[bundle setValue:string didChange:YES];
	STAssertTrue([[bundle changedValues] count] == 1, @"Second change should not track again");
	STAssertTrue([[bundle changedValues] containsObject: string], @"Chnaged value not contained");
	
	NSArray *array = [NSArray arrayWithObjects: @"abc", @"cde", @"def", nil];
	[bundle setChangedValues: array];
	STAssertEqualObjects([bundle changedValues], array, @"Error setting changed values");
	
	[bundle setValue:string didChange:YES];
	STAssertTrue([[bundle changedValues] containsObject: string], @"Set object not contained");
	
	[bundle setNothingDidChange];
	[bundle addChangedValues: array];
	STAssertEqualObjects([bundle changedValues], array, @"Error adding changed values");
	
	[bundle addChangedValues: array];
	STAssertEqualObjects([bundle changedValues], array, @"Error adding changed values");
	
	NSArray *array2 = [NSArray arrayWithObjects: @"ghf", @"sdf", @"asd", nil];
	[bundle addChangedValues: array2];
	STAssertFalse([[bundle changedValues] isEqualToArray: array], @"Error adding changed values");
	STAssertFalse([[bundle changedValues] isEqualToArray: array2], @"Error adding changed values");
	
	[bundle setNothingDidChange];
	STAssertTrue([bundle didChange] == false, @"Wrong change state");
	STAssertTrue([[bundle changedValues] count] == 0, @"Wrong change number");
}

@end
