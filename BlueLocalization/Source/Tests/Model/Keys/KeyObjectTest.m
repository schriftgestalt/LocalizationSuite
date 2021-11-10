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
	STAssertNoThrow([keyObject setObject:object forLanguage:@"en"], @"Setting failed with exception");
	STAssertEqualObjects([keyObject objectForLanguage:@"en"], object, @"Value was not set");

	object = [NSNull null];
	STAssertNoThrow([keyObject setObject:object forLanguage:@"en"], @"Setting failed with exception");
	STAssertEqualObjects([keyObject objectForLanguage:@"en"], nil, @"Null value not accepted");

	object = @"b";
	STAssertNoThrow([keyObject setObject:object forLanguage:@"en"], @"Setting failed with exception");
	STAssertEqualObjects([keyObject objectForLanguage:@"en"], object, @"Value was not set");

	object = [NSArray array];
	STAssertNoThrow([keyObject setObject:object forLanguage:@"en"], @"Setting failed with exception");
	STAssertEqualObjects([keyObject objectForLanguage:@"en"], nil, @"Invalid value should not be accepted");

	STAssertThrows([keyObject setObject:object forLanguage:nil], @"Setting failed with no exception");
	STAssertThrows([keyObject setObject:nil forLanguage:nil], @"Setting failed with no exception");
}

- (void)testRTFDSetObject {
	BLKeyObject *keyObject = [BLRTFDKeyObject keyObjectWithKey:@"a"];

	id object = [[NSAttributedString alloc] initWithString:@"a"];
	STAssertNoThrow([keyObject setObject:object forLanguage:@"en"], @"Setting failed with exception");
	STAssertEqualObjects([keyObject objectForLanguage:@"en"], object, @"Value was not set");

	object = [NSNull null];
	STAssertNoThrow([keyObject setObject:object forLanguage:@"en"], @"Setting failed with exception");
	STAssertEqualObjects([keyObject objectForLanguage:@"en"], nil, @"Null value not accepted");

	object = [[NSAttributedString alloc] initWithString:@"b"];
	STAssertNoThrow([keyObject setObject:object forLanguage:@"en"], @"Setting failed with exception");
	STAssertEqualObjects([keyObject objectForLanguage:@"en"], object, @"Value was not set");

	object = [NSArray array];
	STAssertNoThrow([keyObject setObject:object forLanguage:@"en"], @"Setting failed with exception");
	STAssertEqualObjects([keyObject objectForLanguage:@"en"], nil, @"Invalid value should not be accepted");

	STAssertThrows([keyObject setObject:object forLanguage:nil], @"Setting failed with no exception");
	STAssertThrows([keyObject setObject:nil forLanguage:nil], @"Setting failed with no exception");
}

- (void)testSnapshots {
	BLKeyObject *keyObject = [BLStringKeyObject keyObjectWithKey:@"a"];

	// No snapshot
	id object = @"a";
	STAssertNoThrow([keyObject setObject:object forLanguage:@"en"], @"Setting failed with exception");
	STAssertEqualObjects([keyObject objectForLanguage:@"en"], object, @"Value was not set");
	STAssertEqualObjects([keyObject snapshotForLanguage:@"en"], nil, @"Value was not set");

	// No hidden snapshot
	object = [NSNull null];
	STAssertNoThrow([keyObject setObject:object forLanguage:@"en"], @"Setting failed with exception");
	STAssertEqualObjects([keyObject objectForLanguage:@"en"], nil, @"Null value not accepted");
	STAssertEqualObjects([keyObject snapshotForLanguage:@"en"], nil, @"Value was not set");

	// Empty snapshot
	[keyObject snapshotLanguage:@"en"];
	id newObject = @"b";
	STAssertNoThrow([keyObject setObject:newObject forLanguage:@"en"], @"Setting failed with exception");
	STAssertEqualObjects([keyObject objectForLanguage:@"en"], newObject, @"Value was not set");
	STAssertEqualObjects([keyObject snapshotForLanguage:@"en"], nil, @"Value was not set");

	// Valid snapshot
	[keyObject snapshotLanguage:@"en"];
	object = nil;
	STAssertNoThrow([keyObject setObject:object forLanguage:@"en"], @"Setting failed with exception");
	STAssertEqualObjects([keyObject objectForLanguage:@"en"], nil, @"Invalid value should not be accepted");
	STAssertEqualObjects([keyObject snapshotForLanguage:@"en"], newObject, @"Value was not set");

	// Persistent snapshot
	object = @"a";
	STAssertNoThrow([keyObject setObject:object forLanguage:@"en"], @"Setting failed with exception");
	STAssertEqualObjects([keyObject objectForLanguage:@"en"], object, @"Value was not set");
	STAssertEqualObjects([keyObject snapshotForLanguage:@"en"], newObject, @"Value was not set");
}

@end
