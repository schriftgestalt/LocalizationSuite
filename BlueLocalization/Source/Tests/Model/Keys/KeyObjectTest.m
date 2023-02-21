//
//  KeyObjectTest.m
//  BlueLocalization
//
//  Created by max on 10.12.09.
//  Copyright 2009 The Soulmen. All rights reserved.
//

#import "KeyObjectTest.h"

#import <BlueLocalization/BLRTFDKeyObject.h>
#import <BlueLocalization/BLStringKeyObject.h>

@implementation KeyObjectTest

- (void)testStringSetObject {
	BLKeyObject *keyObject = [BLStringKeyObject keyObjectWithKey:@"a"];

	id object = @"a";
	XCTAssertNoThrow([keyObject setObject:object forLanguage:@"en"], @"Setting failed with exception");
	XCTAssertEqualObjects([keyObject objectForLanguage:@"en"], object, @"Value was not set");

	object = [NSNull null];
	XCTAssertNoThrow([keyObject setObject:object forLanguage:@"en"], @"Setting failed with exception");
	XCTAssertEqualObjects([keyObject objectForLanguage:@"en"], nil, @"Null value not accepted");

	object = @"b";
	XCTAssertNoThrow([keyObject setObject:object forLanguage:@"en"], @"Setting failed with exception");
	XCTAssertEqualObjects([keyObject objectForLanguage:@"en"], object, @"Value was not set");

	object = [NSArray array];
	XCTAssertNoThrow([keyObject setObject:object forLanguage:@"en"], @"Setting failed with exception");
	XCTAssertEqualObjects([keyObject objectForLanguage:@"en"], nil, @"Invalid value should not be accepted");

	XCTAssertThrows([keyObject setObject:object forLanguage:nil], @"Setting failed with no exception");
	XCTAssertThrows([keyObject setObject:nil forLanguage:nil], @"Setting failed with no exception");
}

- (void)testRTFDSetObject {
	BLKeyObject *keyObject = [BLRTFDKeyObject keyObjectWithKey:@"a"];

	id object = [[NSAttributedString alloc] initWithString:@"a"];
	XCTAssertNoThrow([keyObject setObject:object forLanguage:@"en"], @"Setting failed with exception");
	XCTAssertEqualObjects([keyObject objectForLanguage:@"en"], object, @"Value was not set");

	object = [NSNull null];
	XCTAssertNoThrow([keyObject setObject:object forLanguage:@"en"], @"Setting failed with exception");
	XCTAssertEqualObjects([keyObject objectForLanguage:@"en"], nil, @"Null value not accepted");

	object = [[NSAttributedString alloc] initWithString:@"b"];
	XCTAssertNoThrow([keyObject setObject:object forLanguage:@"en"], @"Setting failed with exception");
	XCTAssertEqualObjects([keyObject objectForLanguage:@"en"], object, @"Value was not set");

	object = [NSArray array];
	XCTAssertNoThrow([keyObject setObject:object forLanguage:@"en"], @"Setting failed with exception");
	XCTAssertEqualObjects([keyObject objectForLanguage:@"en"], nil, @"Invalid value should not be accepted");

	XCTAssertThrows([keyObject setObject:object forLanguage:nil], @"Setting failed with no exception");
	XCTAssertThrows([keyObject setObject:nil forLanguage:nil], @"Setting failed with no exception");
}

- (void)testSnapshots {
	BLKeyObject *keyObject = [BLStringKeyObject keyObjectWithKey:@"a"];

	// No snapshot
	id object = @"a";
	XCTAssertNoThrow([keyObject setObject:object forLanguage:@"en"], @"Setting failed with exception");
	XCTAssertEqualObjects([keyObject objectForLanguage:@"en"], object, @"Value was not set");
	XCTAssertEqualObjects([keyObject snapshotForLanguage:@"en"], nil, @"Value was not set");

	// No hidden snapshot
	object = [NSNull null];
	XCTAssertNoThrow([keyObject setObject:object forLanguage:@"en"], @"Setting failed with exception");
	XCTAssertEqualObjects([keyObject objectForLanguage:@"en"], nil, @"Null value not accepted");
	XCTAssertEqualObjects([keyObject snapshotForLanguage:@"en"], nil, @"Value was not set");

	// Empty snapshot
	[keyObject snapshotLanguage:@"en"];
	id newObject = @"b";
	XCTAssertNoThrow([keyObject setObject:newObject forLanguage:@"en"], @"Setting failed with exception");
	XCTAssertEqualObjects([keyObject objectForLanguage:@"en"], newObject, @"Value was not set");
	XCTAssertEqualObjects([keyObject snapshotForLanguage:@"en"], nil, @"Value was not set");

	// Valid snapshot
	[keyObject snapshotLanguage:@"en"];
	object = nil;
	XCTAssertNoThrow([keyObject setObject:object forLanguage:@"en"], @"Setting failed with exception");
	XCTAssertEqualObjects([keyObject objectForLanguage:@"en"], nil, @"Invalid value should not be accepted");
	XCTAssertEqualObjects([keyObject snapshotForLanguage:@"en"], newObject, @"Value was not set");

	// Persistent snapshot
	object = @"a";
	XCTAssertNoThrow([keyObject setObject:object forLanguage:@"en"], @"Setting failed with exception");
	XCTAssertEqualObjects([keyObject objectForLanguage:@"en"], object, @"Value was not set");
	XCTAssertEqualObjects([keyObject snapshotForLanguage:@"en"], newObject, @"Value was not set");
}

@end
