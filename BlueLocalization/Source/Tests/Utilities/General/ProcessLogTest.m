//
//  BLLogTest.m
//  BlueLocalization
//
//  Created by max on 18.05.09.
//  Copyright 2009 Blue Technologies Group. All rights reserved.
//

#import "ProcessLogTest.h"

@implementation ProcessLogTest

- (void)setUp {
	_log = [BLProcessLog sharedLog];
	[_log clear];
}

- (void)testSharedInstance {
	XCTAssertNotNil(_log, @"No log present");
	XCTAssertEqual(_log, [BLProcessLog sharedLog], @"Only one log allowed");
	XCTAssertEqual(_log, [[BLProcessLog alloc] init], @"Only one log allowed");
}

- (void)testCreateAndClear {
	BLLog(BLLogError, @"test");
	[_log openRootGroup:@"test"];
	XCTAssertTrue([[_log items] count] == 2, @"No items were created");
	[_log clear];
	XCTAssertTrue([[_log items] count] == 0, @"Log was not cleared");
}

- (void)testRootGroups {
	XCTAssertTrue([[_log items] count] == 0, @"Log not empty");

	[_log openRootGroup:@"test"];
	XCTAssertTrue([[_log items] count] == 1, @"No group was created");
	XCTAssertThrows([_log openRootGroup:@"test"], @"No two root groups are allowed");

	[_log closeRootGroup];
	XCTAssertThrows([_log closeRootGroup], @"Should throw on closing when no root group open");

	[_log openRootGroup:@"test2"];
	XCTAssertTrue([[_log items] count] == 2, @"No group was created");

	BLLog(BLLogError, @"test");
	XCTAssertTrue([[_log items] count] == 2, @"Logging should not have gone to root");
	XCTAssertTrue([[[[_log items] objectAtIndex:1] items] count] == 1, @"Logging should have gone to group");

	[_log clear];
	XCTAssertTrue([[_log items] count] == 0, @"Log was not cleared");
	XCTAssertThrows([_log closeRootGroup], @"Clear log should remove current root group");
}

- (void)testBasicLogging {
	BLProcessLogItem *item;

	BLLog(BLLogInfo, @"you and %@", @"me");
	XCTAssertTrue([[_log items] count] == 1, @"No item was created");

	item = [[_log items] objectAtIndex:0];
	XCTAssertFalse([item isGroup], @"Item should be no group");
	XCTAssertEqualObjects([item message], @"you and me", @"Message faulty");
	XCTAssertEqual([item level], BLLogInfo, @"Level wrong");

	BLLog(BLLogError, @"you and %d or %1.2f", 17, 3.45);
	XCTAssertTrue([[_log items] count] == 2, @"No item was created");

	item = [[_log items] objectAtIndex:1];
	XCTAssertFalse([item isGroup], @"Item should be no group");
	XCTAssertEqualObjects([item message], @"you and 17 or 3.45", @"Message faulty");
	XCTAssertEqual([item level], BLLogError, @"Level wrong");
}

- (void)testGroupLogging {
	BLProcessLogItem *group;

	BLLogBeginGroup(@"Group %@", @"title");
	XCTAssertTrue([[_log items] count] == 1, @"No group was created");

	group = [[_log items] objectAtIndex:0];
	XCTAssertEqualObjects([group message], @"Group title", @"Message faulty");
	XCTAssertEqual([group level], BLLogInfo, @"Empty groups should be info");

	BLLog(BLLogWarning, @"Item %d", 1);
	XCTAssertTrue([group isGroup], @"Item should be a group");
	XCTAssertTrue([[group items] count] == 1, @"No item was created");
	XCTAssertTrue([[_log items] count] == 1, @"Root should be unchanged");
	XCTAssertEqual([group level], BLLogWarning, @"Groups level should be highest of items");

	BLLog(BLLogError, @"Item %d", 2);
	XCTAssertEqual([group level], BLLogError, @"Groups level should be highest of items");
	BLLog(BLLogWarning, @"Item %d", 3);
	XCTAssertEqual([group level], BLLogError, @"Groups level should be highest of items");

	BLLogEndGroup();
	BLLog(BLLogWarning, @"Anything");
	XCTAssertTrue([[_log items] count] == 2, @"Root should be target now");

	XCTAssertThrows(BLLogEndGroup(), @"No open group should throw on close");
}

- (void)testPipeLogging {
	BLProcessLogItem *item;
	NSPipe *pipe;

	pipe = BLLogOpenPipe(@"My title %d", 17);
	XCTAssertNotNil(pipe, @"No pipe opened");
	XCTAssertTrue([[_log items] count] == 1, @"No item was created");

	item = [[_log items] objectAtIndex:0];
	XCTAssertEqualObjects([item message], @"My title 17", @"Message should be non-empty");

	BLLog(BLLogInfo, @"messy");
	XCTAssertTrue([[_log items] count] == 2, @"Item should be created outside pipe item");

	NSTask *echo = [[NSTask alloc] init];
	[echo setLaunchPath:@"/bin/echo"];
	[echo setArguments:[NSArray arrayWithObject:@"hello eRRoR bye"]];
	[echo setStandardOutput:pipe];
	[echo launch];
	[echo waitUntilExit];

	// Wait till processing finished (?)
	NSUInteger count = 0;
	while ((![[item items] count]) && (++count < 100))
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
	if (count == 100) // We don't want to fail here...
		return;
	XCTAssertFalse(count == 100, @"Timed out");

	// Check
	XCTAssertEqual([[_log items] count], (NSUInteger)2, @"Closing and logging should add no items");
	XCTAssertTrue([[item items] count] >= 1, @"Message was not transfered correctly");
	XCTAssertEqualObjects([[[item items] objectAtIndex:0] message], @"hello eRRoR bye", @"Message was not transfered correctly");
	XCTAssertEqual([item level], BLLogError, @"Error string was not recognized");
}

- (void)testPlistPipeLogging {
	BLProcessLogItem *item;
	NSString *path;
	NSPipe *pipe;

	path = [[NSBundle bundleForClass:[self class]] pathForResource:@"ibtool-sample" ofType:@"out" inDirectory:@"Test Data/Utilities"];

	// Run regular setup
	pipe = BLLogOpenPipe(@"IBTool");

	NSTask *cat = [[NSTask alloc] init];
	[cat setLaunchPath:@"/bin/cat"];
	[cat setArguments:[NSArray arrayWithObject:path]];
	[cat setStandardOutput:pipe];
	[cat launch];
	[cat waitUntilExit];

	// Wait till processing finished (?)
	NSUInteger count = 0;
	while ((![[[_log items] objectAtIndex:0] isGroup]) && (++count < 100))
		[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
	if (count == 100) // We don't want to fail here...
		return;
	XCTAssertFalse(count == 100, @"Timed out");

	// Verify
	XCTAssertTrue([[_log items] count] == 1, @"No item was created");

	item = [[_log items] objectAtIndex:0];
	XCTAssertEqualObjects([item message], @"IBTool", @"Should have kept title");
	XCTAssertTrue([item isGroup], @"Item should now be a group");
	XCTAssertEqual([item level], BLLogError, @"Error was logged, groups hould have error");

	XCTAssertTrue([[item items] count] == 2, @"Two items should have been logged");
	XCTAssertEqualObjects([[[item items] objectAtIndex:0] message], @"Unable to do something.", @"Wrong message at index 0");
	XCTAssertEqualObjects([[[item items] objectAtIndex:1] message], @"A problem.", @"Wrong message at index 1");
}

@end
