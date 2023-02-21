//
//  ObjectTest.m
//  BlueLocalization
//
//  Created by Max Seelemann on 25.11.08.
//  Copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
//

#import "ObjectTest.h"

@implementation ObjectTest

- (void)setUp {
	bundle = [[BLObject alloc] init];
}

- (void)testBundle {
	XCTAssertNotNil(bundle, @"Cannot create bundle");
}

- (void)testChangedValues {
	[bundle setNothingDidChange];
	XCTAssertTrue([bundle didChange] == false, @"Wrong change state");
	XCTAssertTrue([[bundle changedValues] count] == 0, @"Wrong change number");

	NSString *string = @"test1";
	[bundle setValue:string didChange:YES];
	XCTAssertTrue([bundle didChange] == true, @"Wrong change state");
	XCTAssertTrue([[bundle changedValues] count] == 1, @"Change not tracked");

	[bundle setValue:string didChange:YES];
	XCTAssertTrue([[bundle changedValues] count] == 1, @"Second change should not track again");
	XCTAssertTrue([[bundle changedValues] containsObject:string], @"Chnaged value not contained");

	NSArray *array = [NSArray arrayWithObjects:@"abc", @"cde", @"def", nil];
	[bundle setChangedValues:array];
	XCTAssertEqualObjects([bundle changedValues], array, @"Error setting changed values");

	[bundle setValue:string didChange:YES];
	XCTAssertTrue([[bundle changedValues] containsObject:string], @"Set object not contained");

	[bundle setNothingDidChange];
	[bundle addChangedValues:array];
	XCTAssertEqualObjects([bundle changedValues], array, @"Error adding changed values");

	[bundle addChangedValues:array];
	XCTAssertEqualObjects([bundle changedValues], array, @"Error adding changed values");

	NSArray *array2 = [NSArray arrayWithObjects:@"ghf", @"sdf", @"asd", nil];
	[bundle addChangedValues:array2];
	XCTAssertFalse([[bundle changedValues] isEqualToArray:array], @"Error adding changed values");
	XCTAssertFalse([[bundle changedValues] isEqualToArray:array2], @"Error adding changed values");

	[bundle setNothingDidChange];
	XCTAssertTrue([bundle didChange] == false, @"Wrong change state");
	XCTAssertTrue([[bundle changedValues] count] == 0, @"Wrong change number");
}

@end
