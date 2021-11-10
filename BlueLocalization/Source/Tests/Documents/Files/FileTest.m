//
//  FileTest.m
//  BlueLocalization
//
//  Created by max on 15.03.10.
//  Copyright 2010 The Soulmen. All rights reserved.
//

#import "FileTest.h"

@implementation FileTest

- (void)setUp {
	path = [[NSBundle bundleForClass:[self class]] pathForResource:@"MainMenu" ofType:@"strings" inDirectory:@"Test Data/Documents/English.lproj"];
	file = [BLFileObject fileObjectWithPath:path];
	bundle = [file bundleObject];

	BLFileInterpreter *interpreter = [BLFileInterpreter interpreterForFileObject:file];
	[interpreter activateOptions:BLFileInterpreterAllowChangesToKeyObjects];
	[interpreter interpreteFile:path intoObject:file withLanguage:@"en" referenceLanguage:nil];

	tmpPath = @"/tmp/loc.test";
}

- (void)tearDown {
	[[NSFileManager defaultManager] removeItemAtPath:tmpPath error:NULL];
}

- (void)testSetUp {
	STAssertNotNil(file, @"No file");
	STAssertNotNil(bundle, @"No bundle");
	STAssertTrue([[file objects] count] > 0, @"Empty file");
}

- (void)testErrorHandling {
	STAssertThrows([BLDatabaseFile createFileForObjects:nil withOptions:0 andProperties:nil], @"Missing properties should throw!");
	STAssertThrows([BLLocalizerFile createFileForObjects:nil withOptions:0 andProperties:nil], @"Missing properties should throw!");
	STAssertThrows([BLDictionaryFile createFileForObjects:nil withOptions:0 andProperties:nil], @"Missing properties should throw!");
}

- (void)testDatabaseFile {
	// Write out
	NSArray *inObjects = [NSArray arrayWithObject:bundle];
	NSDictionary *inProperties = [NSDictionary dictionaryWithObjectsAndKeys:
												   @"en", BLReferenceLanguagePropertyName,
												   [NSArray arrayWithObject:@"en"], BLLanguagesPropertyName,
												   [NSDictionary dictionary], BLPreferencesPropertyName,
												   [NSDictionary dictionary], BLUserPreferencesPropertyName,
												   nil];
	NSFileWrapper *outWrapper = [BLDatabaseFile createFileForObjects:inObjects withOptions:0 andProperties:inProperties];

	STAssertNotNil(outWrapper, @"No wrapper created!");
	STAssertTrue([outWrapper writeToFile:tmpPath atomically:YES updateFilenames:NO], @"Writing failed");

	// Read in
	NSFileWrapper *inWrapper = [[NSFileWrapper alloc] initWithPath:tmpPath];
	NSDictionary *outProperties = nil;
	NSArray *outObjects = [BLDatabaseFile objectsFromFile:inWrapper readingProperties:&outProperties];

	// Check equality
	STAssertEqualObjects(outProperties, inProperties, @"Properties do not match");
	STAssertEqualObjects(outObjects, inObjects, @"Objects do not match");
}

- (void)testLegacyDatabaseFile {
	NSString *aPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"Legacy" ofType:@"ldb" inDirectory:@"Test Data/Documents/"];

	// Read in
	NSFileWrapper *wrapper1 = [[NSFileWrapper alloc] initWithPath:aPath];
	NSDictionary *properties1 = nil;
	NSArray *objects1 = [BLDatabaseFile objectsFromFile:wrapper1 readingProperties:&properties1];

	// Check bundles and files
	STAssertTrue([objects1 count] == 1, @"Wrong number of bundles");
	BLBundleObject *aBundle = [objects1 objectAtIndex:0];
	STAssertTrue([[aBundle files] count] == 7, @"Wrong number of files");
	for (BLFileObject *aFile in aBundle.files)
		STAssertTrue([[aFile objects] count] > 0, @"Wrong number of keys");

	// Check properties
	STAssertEqualObjects([properties1 objectForKey:BLReferenceLanguagePropertyName], @"en", @"Wrong reference language");
	STAssertEqualObjects([properties1 objectForKey:BLLanguagesPropertyName], ([NSArray arrayWithObjects:@"en", @"fr", @"de", nil]), @"Wrong reference language");
	STAssertNotNil([properties1 objectForKey:BLPreferencesPropertyName], @"Missing preferences");

	// Write and read in
	NSFileWrapper *outWrapper = [BLDatabaseFile createFileForObjects:objects1 withOptions:0 andProperties:properties1];
	STAssertTrue([outWrapper writeToFile:tmpPath atomically:YES updateFilenames:NO], @"Writing failed");

	NSFileWrapper *wrapper2 = [[NSFileWrapper alloc] initWithPath:tmpPath];
	NSDictionary *properties2 = nil;
	NSArray *objects2 = [BLDatabaseFile objectsFromFile:wrapper2 readingProperties:&properties2];

	// Compare
	STAssertEqualObjects(properties1, properties2, @"Properties do not match");
	STAssertEqualObjects(objects1, objects2, @"Objects do not match");
}

- (void)testLocalizerFile {
	// Write out
	NSArray *inObjects = [NSArray arrayWithObject:bundle];
	NSDictionary *inProperties = [NSDictionary dictionaryWithObjectsAndKeys:
												   @"en", BLReferenceLanguagePropertyName,
												   [NSArray arrayWithObject:@"en"], BLLanguagesPropertyName,
												   [NSDictionary dictionary], BLPreferencesPropertyName,
												   nil];
	NSFileWrapper *outWrapper = [BLLocalizerFile createFileForObjects:inObjects withOptions:0 andProperties:inProperties];

	STAssertNotNil(outWrapper, @"No wrapper created!");
	STAssertTrue([outWrapper writeToFile:tmpPath atomically:YES updateFilenames:NO], @"Writing failed");

	// Read in
	NSFileWrapper *inWrapper = [[NSFileWrapper alloc] initWithPath:tmpPath];
	NSDictionary *outProperties = nil;
	NSArray *outObjects = [BLLocalizerFile objectsFromFile:inWrapper readingProperties:&outProperties];

	// Check equality
	for (NSString *key in inProperties)
		STAssertEqualObjects([outProperties objectForKey:key], [inProperties objectForKey:key], @"Properties do not match");
	STAssertEqualObjects(outObjects, inObjects, @"Objects do not match");
}

- (void)testDictionaryFile {
	// Write out
	NSArray *inObjects = [file objects];
	NSDictionary *inProperties = [NSDictionary dictionaryWithObjectsAndKeys:
												   [NSArray arrayWithObjects:@"en", @"de", @"fr", nil], BLLanguagesPropertyName,
												   [NSDictionary dictionary], BLFilterSettingsPropertyName,
												   nil];
	NSFileWrapper *outWrapper = [BLDictionaryFile createFileForObjects:inObjects withOptions:0 andProperties:inProperties];

	STAssertNotNil(outWrapper, @"No wrapper created!");
	STAssertTrue([outWrapper writeToFile:tmpPath atomically:YES updateFilenames:NO], @"Writing failed");

	// Read in
	NSFileWrapper *inWrapper = [[NSFileWrapper alloc] initWithPath:tmpPath];
	NSDictionary *outProperties = nil;
	NSArray *outObjects = [BLDictionaryFile objectsFromFile:inWrapper readingProperties:&outProperties];

	// Check equality
	STAssertEqualObjects(outProperties, inProperties, @"Properties do not match");

	NSComparator comp = ^(BLKeyObject *obj1, BLKeyObject *obj2) { return [obj1.key compare:obj2.key]; };
	inObjects = [inObjects sortedArrayUsingComparator:comp];
	outObjects = [outObjects sortedArrayUsingComparator:comp];
	STAssertEqualObjects(outObjects, inObjects, @"Objects do not match");
}

- (void)testAttachments {
	NSFileWrapper *wrapper = [[NSFileWrapper alloc] initWithPath:path];
	NSString *string = @"Hello World!";

	// Attachments
	[file setAttachedObject:wrapper forKey:@"test1" version:2];
	[file setAttachedObject:string forKey:@"test2" version:1];
	[file setVersion:1 forLanguage:@"fr"];
	[file setVersion:2 forLanguage:@"cz"];

	// Write
	NSDictionary *properties = [NSDictionary dictionaryWithObjectsAndKeys:
												 @"en", BLReferenceLanguagePropertyName,
												 [NSArray arrayWithObjects:@"en", @"fr", @"cz", nil], BLLanguagesPropertyName,
												 [NSDictionary dictionary], BLPreferencesPropertyName,
												 nil];
	NSFileWrapper *outWrapper = [BLLocalizerFile createFileForObjects:[NSArray arrayWithObject:bundle] withOptions:0 andProperties:properties];
	STAssertTrue([outWrapper writeToFile:tmpPath atomically:YES updateFilenames:NO], @"Writing failed");

	// Read
	NSFileWrapper *inWrapper = [[NSFileWrapper alloc] initWithPath:tmpPath];
	NSArray *outObjects = [BLLocalizerFile objectsFromFile:inWrapper readingProperties:NULL];
	BLFileObject *outFile = [[[outObjects lastObject] files] lastObject];

	// Check attachments
	STAssertEquals([file versionForLanguage:@"fr"], [outFile versionForLanguage:@"fr"], @"Versions differ");
	STAssertEquals([file versionForLanguage:@"cz"], [outFile versionForLanguage:@"cz"], @"Versions differ");
	STAssertEqualObjects([file attachedObjectForKey:@"test2" version:1], [outFile attachedObjectForKey:@"test2" version:1], @"attachments differ");
	STAssertEqualObjects([[file attachedObjectForKey:@"test1" version:2] regularFileContents], [[outFile attachedObjectForKey:@"test1" version:2] regularFileContents], @"attachments differ");
}

@end
