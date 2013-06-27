//
//  DocumentPreferencesTest.m
//  BlueLocalization
//
//  Created by Max Seelemann on 29.10.10.
//  Copyright 2010 The Soulmen. All rights reserved.
//

#import "DocumentPreferencesTest.h"


@implementation DocumentPreferencesTest

- (void)setUpWithClass:(Class)documentClass
{	
	document = [[documentClass alloc] init];
	preferences = [document preferences];
	
	userPrefs = [document valueForKey: @"_userPreferences"];
	prefs = [document valueForKey: @"_preferences"];
}

- (void)testDocumentPreferences
{	
	[self setUpWithClass: [BLDatabaseDocument class]];
	
	STAssertTrue([[document preferences] isKindOfClass: [NSMutableDictionary class]], @"Prefs broken?");
	
	// Check user-dictionary has been created
	STAssertNotNil([userPrefs objectForKey: NSUserName()], @"User settings not created");
	
	// Check setting and deleting user-key
	[preferences setObject:@"yeah" forKey:@"myKey"];
	STAssertEqualObjects([preferences objectForKey: @"myKey"], @"yeah", @"Setting does not work");
	STAssertEqualObjects([prefs objectForKey: @"myKey"], @"yeah", @"Setting does not work");
	STAssertNil([[userPrefs objectForKey: NSUserName()] objectForKey: @"myKey"], @"Set in wrong dictionary");
	
	[preferences removeObjectForKey: @"myKey"];
	STAssertNil([preferences objectForKey: @"myKey"], @"Deleting does not work");

	// Check setting and deleting user-key
	[preferences setObject:@"yeah" forKey:BLDocumentOpenFolderKey];
	STAssertEqualObjects([preferences objectForKey: BLDocumentOpenFolderKey], @"yeah", @"Setting does not work");
	STAssertEqualObjects([[userPrefs objectForKey: NSUserName()] objectForKey: BLDocumentOpenFolderKey], @"yeah", @"Setting does not work");
	STAssertNil([prefs objectForKey: BLDocumentOpenFolderKey], @"Set in wrong dictionary");
	
	[preferences removeObjectForKey: BLDocumentOpenFolderKey];
	STAssertNil([preferences objectForKey: BLDocumentOpenFolderKey], @"Deleting does not work");
	
	// Check mixed set/get
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  @"123", BLDocumentOpenFolderKey,
						  [NSNumber numberWithInt: 2], BLDatabaseDocumentBundleNamingStyleKey, nil];
	[preferences addEntriesFromDictionary: dict];
	STAssertEqualObjects([preferences objectForKey: BLDatabaseDocumentBundleNamingStyleKey], [NSNumber numberWithInt: 2], @"Setting regular failed");
	STAssertEqualObjects([preferences objectForKey: BLDocumentOpenFolderKey], @"123", @"Setting user-pref feiled");
}

- (void)testDatabasePrefPersistence
{
	[self setUpWithClass: [BLDatabaseDocument class]];
	
	STAssertNotNil([userPrefs objectForKey: NSUserName()], @"User settings not created");
	
	NSURL *url = [[NSBundle bundleForClass: [self class]] URLForResource:@"NoUsers" withExtension:@"ldb" subdirectory:@"Test Data/Documents/"];
	STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath: [url path]], @"Missing file %@", [[url path] lastPathComponent]);
	[document readFromURL:url ofType:nil error:NULL];
	STAssertNotNil([userPrefs objectForKey: NSUserName()], @"User settings deleted!");
	
	url = [[NSBundle bundleForClass: [self class]] URLForResource:@"OtherUser" withExtension:@"ldb" subdirectory:@"Test Data/Documents/"];
	STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath: [url path]], @"Missing file %@", [[url path] lastPathComponent]);
	[document readFromURL:url ofType:nil error:NULL];
	STAssertNotNil([userPrefs objectForKey: NSUserName()], @"User settings deleted!");
	STAssertNotNil([userPrefs objectForKey: @"detlef"], @"User not loaded");
	STAssertEqualObjects([[userPrefs objectForKey: @"detlef"] objectForKey: @"setting"], @"12321", @"Settings not loaded");
	
	// Change and write
	[[document preferences] setObject:@"hello" forKey:BLDocumentOpenFolderKey];
	NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent: @"test.ldb"];
	[document writeToURL:[NSURL fileURLWithPath: path] ofType:nil error:NULL];
	
	// Create a new one
	BLDatabaseDocument *newDocument = [[BLDatabaseDocument alloc] init];
	STAssertNil([[newDocument preferences] objectForKey: BLDocumentOpenFolderKey], @"New doc should have empty setting");
	[newDocument readFromURL:[NSURL fileURLWithPath: path] ofType:nil error:NULL];
	STAssertEqualObjects([[newDocument preferences] objectForKey: BLDocumentOpenFolderKey], @"hello", @"Loading doc should overwrite settings");
	
	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

- (void)testLocalizerPrefPersistence
{
	[self setUpWithClass: [BLLocalizerDocument class]];
	
	STAssertNotNil([userPrefs objectForKey: NSUserName()], @"User settings not created");
	
	NSURL *url = [[NSBundle bundleForClass: [self class]] URLForResource:@"NoUsers" withExtension:@"loc" subdirectory:@"Test Data/Documents/"];
	STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath: [url path]], @"Missing file %@", [[url path] lastPathComponent]);
	[document readFromURL:url ofType:nil error:NULL];
	STAssertNotNil([userPrefs objectForKey: NSUserName()], @"User settings deleted!");
	
	url = [[NSBundle bundleForClass: [self class]] URLForResource:@"OtherUser" withExtension:@"loc" subdirectory:@"Test Data/Documents/"];
	STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath: [url path]], @"Missing file %@", [[url path] lastPathComponent]);
	[document readFromURL:url ofType:nil error:NULL];
	STAssertNotNil([userPrefs objectForKey: NSUserName()], @"User settings deleted!");
	STAssertNotNil([userPrefs objectForKey: @"detlef"], @"User not loaded");
	STAssertEqualObjects([[userPrefs objectForKey: @"detlef"] objectForKey: @"setting"], @"12321", @"Settings not loaded");
	
	// Change and write
	[[document preferences] setObject:@"hello" forKey:BLDocumentOpenFolderKey];
	NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent: @"test.loc"];
	[document writeToURL:[NSURL fileURLWithPath: path] ofType:nil error:NULL];
	
	// Create a new one
	BLLocalizerDocument *newDocument = [[BLLocalizerDocument alloc] init];
	STAssertNil([[newDocument preferences] objectForKey: BLDocumentOpenFolderKey], @"New doc should have empty setting");
	[newDocument readFromURL:[NSURL fileURLWithPath: path] ofType:nil error:NULL];
	STAssertEqualObjects([[newDocument preferences] objectForKey: BLDocumentOpenFolderKey], @"hello", @"Loading doc should overwrite settings");
	
	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

- (void)testDictionaryPrefPersistence
{
	[self setUpWithClass: [BLDictionaryDocument class]];
	
	STAssertNotNil([userPrefs objectForKey: NSUserName()], @"User settings not created");
	
	NSURL *url = [[NSBundle bundleForClass: [self class]] URLForResource:@"NoUsers" withExtension:@"lod" subdirectory:@"Test Data/Documents/"];
	STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath: [url path]], @"Missing file %@", [[url path] lastPathComponent]);
	[document readFromURL:url ofType:nil error:NULL];
	STAssertNotNil([userPrefs objectForKey: NSUserName()], @"User settings deleted!");
	
	url = [[NSBundle bundleForClass: [self class]] URLForResource:@"OtherUser" withExtension:@"lod" subdirectory:@"Test Data/Documents/"];
	STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath: [url path]], @"Missing file %@", [[url path] lastPathComponent]);
	[document readFromURL:url ofType:nil error:NULL];
	STAssertNotNil([userPrefs objectForKey: NSUserName()], @"User settings deleted!");
//	STAssertNotNil([userPrefs objectForKey: @"detlef"], @"User not loaded");
//	STAssertEqualObjects([[userPrefs objectForKey: @"detlef"] objectForKey: @"setting"], @"12321", @"Settings not loaded");
	
	// Change and write
	[[document preferences] setObject:@"hello" forKey:BLDocumentOpenFolderKey];
	NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent: @"test.lod"];
	[document writeToURL:[NSURL fileURLWithPath: path] ofType:nil error:NULL];
	
	// Create a new one
	BLDictionaryDocument *newDocument = [[BLDictionaryDocument alloc] init];
	STAssertNil([[newDocument preferences] objectForKey: BLDocumentOpenFolderKey], @"New doc should have empty setting");
	[newDocument readFromURL:[NSURL fileURLWithPath: path] ofType:nil error:NULL];
//	STAssertEqualObjects([[newDocument preferences] objectForKey: BLDocumentOpenFolderKey], @"hello", @"Loading doc should overwrite settings");
	
	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

@end
