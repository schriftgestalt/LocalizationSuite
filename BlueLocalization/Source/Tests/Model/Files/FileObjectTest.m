//
//  FileObjectTest.m
//  BlueLocalization
//
//  Created by Max on 26.03.10.
//  Copyright 2010 The Soulmen. All rights reserved.
//

#import "FileObjectTest.h"

@implementation FileObjectTest

- (void)testSnapshots {
	BLFileObject *file = [BLFileObject fileObjectWithPathExtension:@"strings"];

	// Create some keys
	[file objectForKey:@"a"];
	[file objectForKey:@"c"];
	[file objectForKey:@"b"];
	[file objectForKey:@"d"];

	// No snapshot
	NSArray *keys = [NSArray arrayWithObjects:@"a", @"c", @"b", @"d", nil];
	STAssertEqualObjects([[file objects] valueForKey:@"key"], keys, @"wrong keys");
	STAssertEqualObjects([[file snapshotForLanguage:@"en"] valueForKey:@"key"], keys, @"wrong snapshot keys");

	// Equal snapshot
	[file snapshotLanguage:@"en"];
	STAssertEqualObjects([[file objects] valueForKey:@"key"], keys, @"wrong keys");
	STAssertEqualObjects([[file snapshotForLanguage:@"en"] valueForKey:@"key"], keys, @"wrong snapshot keys");

	// Do some changes
	[file objectForKey:@"k"];
	[file removeObject:[file objectForKey:@"c"]];

	keys = [NSArray arrayWithObjects:@"a", @"b", @"d", @"k", nil];
	NSArray *snap = [NSArray arrayWithObjects:@"a", @"b", @"d", @"c", nil];
	STAssertEqualObjects([[file objects] valueForKey:@"key"], keys, @"wrong keys");
	STAssertEqualObjects([[file snapshotForLanguage:@"en"] valueForKey:@"key"], snap, @"wrong snapshot keys");

	// Snapshot
	[file snapshotLanguage:@"en"];
	STAssertEqualObjects([[file objects] valueForKey:@"key"], keys, @"wrong keys");
	STAssertEqualObjects([[file snapshotForLanguage:@"en"] valueForKey:@"key"], keys, @"wrong snapshot keys");

	// Hard change
	[file setObjects:@[]];
	keys = @[];
	snap = [NSArray arrayWithObjects:@"a", @"b", @"d", @"k", nil];
	STAssertEqualObjects([[file objects] valueForKey:@"key"], keys, @"wrong keys");
	STAssertEqualObjects([[file snapshotForLanguage:@"en"] valueForKey:@"key"], keys, @"wrong snapshot keys");
}

@end
