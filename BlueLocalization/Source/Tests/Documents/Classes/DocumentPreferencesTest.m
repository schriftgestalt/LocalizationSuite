//
//  DocumentPreferencesTest.m
//  BlueLocalization
//
//  Created by Max Seelemann on 29.10.10.
//  Copyright 2010 The Soulmen. All rights reserved.
//

#import "DocumentPreferencesTest.h"

@implementation DocumentPreferencesTest

- (void)setUpWithClass:(Class)documentClass {
	document = [[documentClass alloc] init];
	preferences = [document preferences];

	userPrefs = [document valueForKey:@"_userPreferences"];
	prefs = [document valueForKey:@"_preferences"];
}

- (void)testDocumentPreferences {
	[self setUpWithClass:[BLDatabaseDocument class]];

	XCTAssertTrue([[document preferences] isKindOfClass:[NSMutableDictionary class]], @"Prefs broken?");

	// Check user-dictionary has been created
	XCTAssertNotNil([userPrefs objectForKey:NSUserName()], @"User settings not created");

	// Check setting and deleting user-key
	[preferences setObject:@"yeah" forKey:@"myKey"];
	XCTAssertEqualObjects([preferences objectForKey:@"myKey"], @"yeah", @"Setting does not work");
	XCTAssertEqualObjects([prefs objectForKey:@"myKey"], @"yeah", @"Setting does not work");
	XCTAssertNil([[userPrefs objectForKey:NSUserName()] objectForKey:@"myKey"], @"Set in wrong dictionary");

	[preferences removeObjectForKey:@"myKey"];
	XCTAssertNil([preferences objectForKey:@"myKey"], @"Deleting does not work");

	// Check setting and deleting user-key
	[preferences setObject:@"yeah" forKey:BLDocumentOpenFolderKey];
	XCTAssertEqualObjects([preferences objectForKey:BLDocumentOpenFolderKey], @"yeah", @"Setting does not work");
	XCTAssertEqualObjects([[userPrefs objectForKey:NSUserName()] objectForKey:BLDocumentOpenFolderKey], @"yeah", @"Setting does not work");
	XCTAssertNil([prefs objectForKey:BLDocumentOpenFolderKey], @"Set in wrong dictionary");

	[preferences removeObjectForKey:BLDocumentOpenFolderKey];
	XCTAssertNil([preferences objectForKey:BLDocumentOpenFolderKey], @"Deleting does not work");

	// Check mixed set/get
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  @"123", BLDocumentOpenFolderKey,
						  @2, BLDatabaseDocumentBundleNamingStyleKey, nil];
	[preferences addEntriesFromDictionary:dict];
	XCTAssertEqualObjects([preferences objectForKey:BLDatabaseDocumentBundleNamingStyleKey], @2, @"Setting regular failed");
	XCTAssertEqualObjects([preferences objectForKey:BLDocumentOpenFolderKey], @"123", @"Setting user-pref feiled");
}

- (void)testDatabasePrefPersistence {
	[self setUpWithClass:[BLDatabaseDocument class]];

	XCTAssertNotNil([userPrefs objectForKey:NSUserName()], @"User settings not created");

	NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"NoUsers" withExtension:@"ldb" subdirectory:@"Test Data/Documents/"];
	XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[url path]], @"Missing file %@", [[url path] lastPathComponent]);
	[document readFromURL:url ofType:nil error:NULL];
	XCTAssertNotNil([userPrefs objectForKey:NSUserName()], @"User settings deleted!");

	url = [[NSBundle bundleForClass:[self class]] URLForResource:@"OtherUser" withExtension:@"ldb" subdirectory:@"Test Data/Documents/"];
	XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[url path]], @"Missing file %@", [[url path] lastPathComponent]);
	[document readFromURL:url ofType:nil error:NULL];
	XCTAssertNotNil([userPrefs objectForKey:NSUserName()], @"User settings deleted!");
	XCTAssertNotNil([userPrefs objectForKey:@"detlef"], @"User not loaded");
	XCTAssertEqualObjects([[userPrefs objectForKey:@"detlef"] objectForKey:@"setting"], @"12321", @"Settings not loaded");

	// Change and write
	[[document preferences] setObject:@"hello" forKey:BLDocumentOpenFolderKey];
	NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.ldb"];
	[document writeToURL:[NSURL fileURLWithPath:path] ofType:nil error:NULL];

	// Create a new one
	BLDatabaseDocument *newDocument = [[BLDatabaseDocument alloc] init];
	XCTAssertNil([[newDocument preferences] objectForKey:BLDocumentOpenFolderKey], @"New doc should have empty setting");
	[newDocument readFromURL:[NSURL fileURLWithPath:path] ofType:nil error:NULL];
	XCTAssertEqualObjects([[newDocument preferences] objectForKey:BLDocumentOpenFolderKey], @"hello", @"Loading doc should overwrite settings");

	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

- (void)testLocalizerPrefPersistence {
	[self setUpWithClass:[BLLocalizerDocument class]];

	XCTAssertNotNil([userPrefs objectForKey:NSUserName()], @"User settings not created");

	NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"NoUsers" withExtension:@"loc" subdirectory:@"Test Data/Documents/"];
	XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[url path]], @"Missing file %@", [[url path] lastPathComponent]);
	[document readFromURL:url ofType:nil error:NULL];
	XCTAssertNotNil([userPrefs objectForKey:NSUserName()], @"User settings deleted!");

	url = [[NSBundle bundleForClass:[self class]] URLForResource:@"OtherUser" withExtension:@"loc" subdirectory:@"Test Data/Documents/"];
	XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[url path]], @"Missing file %@", [[url path] lastPathComponent]);
	[document readFromURL:url ofType:nil error:NULL];
	XCTAssertNotNil([userPrefs objectForKey:NSUserName()], @"User settings deleted!");
	XCTAssertNotNil([userPrefs objectForKey:@"detlef"], @"User not loaded");
	XCTAssertEqualObjects([[userPrefs objectForKey:@"detlef"] objectForKey:@"setting"], @"12321", @"Settings not loaded");

	// Change and write
	[[document preferences] setObject:@"hello" forKey:BLDocumentOpenFolderKey];
	NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.loc"];
	[document writeToURL:[NSURL fileURLWithPath:path] ofType:nil error:NULL];

	// Create a new one
	BLLocalizerDocument *newDocument = [[BLLocalizerDocument alloc] init];
	XCTAssertNil([[newDocument preferences] objectForKey:BLDocumentOpenFolderKey], @"New doc should have empty setting");
	[newDocument readFromURL:[NSURL fileURLWithPath:path] ofType:nil error:NULL];
	XCTAssertEqualObjects([[newDocument preferences] objectForKey:BLDocumentOpenFolderKey], @"hello", @"Loading doc should overwrite settings");

	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

- (void)testDictionaryPrefPersistence {
	[self setUpWithClass:[BLDictionaryDocument class]];

	XCTAssertNotNil([userPrefs objectForKey:NSUserName()], @"User settings not created");

	NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"NoUsers" withExtension:@"lod" subdirectory:@"Test Data/Documents/"];
	XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[url path]], @"Missing file %@", [[url path] lastPathComponent]);
	[document readFromURL:url ofType:nil error:NULL];
	XCTAssertNotNil([userPrefs objectForKey:NSUserName()], @"User settings deleted!");

	url = [[NSBundle bundleForClass:[self class]] URLForResource:@"OtherUser" withExtension:@"lod" subdirectory:@"Test Data/Documents/"];
	XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[url path]], @"Missing file %@", [[url path] lastPathComponent]);
	[document readFromURL:url ofType:nil error:NULL];
	XCTAssertNotNil([userPrefs objectForKey:NSUserName()], @"User settings deleted!");
	//	XCTAssertNotNil([userPrefs objectForKey: @"detlef"], @"User not loaded");
	//	XCTAssertEqualObjects([[userPrefs objectForKey: @"detlef"] objectForKey: @"setting"], @"12321", @"Settings not loaded");

	// Change and write
	[[document preferences] setObject:@"hello" forKey:BLDocumentOpenFolderKey];
	NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.lod"];
	[document writeToURL:[NSURL fileURLWithPath:path] ofType:nil error:NULL];

	// Create a new one
	BLDictionaryDocument *newDocument = [[BLDictionaryDocument alloc] init];
	XCTAssertNil([[newDocument preferences] objectForKey:BLDocumentOpenFolderKey], @"New doc should have empty setting");
	[newDocument readFromURL:[NSURL fileURLWithPath:path] ofType:nil error:NULL];
	//	XCTAssertEqualObjects([[newDocument preferences] objectForKey: BLDocumentOpenFolderKey], @"hello", @"Loading doc should overwrite settings");

	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

@end
