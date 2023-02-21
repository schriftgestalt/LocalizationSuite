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
	XCTAssertNotNil(file, @"No file");
	XCTAssertNotNil(bundle, @"No bundle");
	XCTAssertTrue([[file objects] count] > 0, @"Empty file");
}

- (void)testErrorHandling {
	XCTAssertThrows([BLDatabaseFile createFileForObjects:nil withOptions:0 andProperties:nil], @"Missing properties should throw!");
	XCTAssertThrows([BLLocalizerFile createFileForObjects:nil withOptions:0 andProperties:nil], @"Missing properties should throw!");
	XCTAssertThrows([BLDictionaryFile createFileForObjects:nil withOptions:0 andProperties:nil], @"Missing properties should throw!");
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

	XCTAssertNotNil(outWrapper, @"No wrapper created!");
	XCTAssertTrue([outWrapper writeToURL:[NSURL fileURLWithPath:tmpPath] options:NSFileWrapperWritingAtomic originalContentsURL:nil error:nil], @"Writing failed");

	// Read in
	NSFileWrapper *inWrapper = [[NSFileWrapper alloc] initWithPath:tmpPath];
	NSDictionary *outProperties = nil;
	NSArray *outObjects = [BLDatabaseFile objectsFromFile:inWrapper readingProperties:&outProperties];

	// Check equality
	XCTAssertEqualObjects(outProperties, inProperties, @"Properties do not match");
	XCTAssertEqualObjects(outObjects, inObjects, @"Objects do not match");
}

- (void)testLegacyDatabaseFile {
	NSString *aPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"Legacy" ofType:@"ldb" inDirectory:@"Test Data/Documents/"];

	// Read in
	NSFileWrapper *wrapper1 = [[NSFileWrapper alloc] initWithPath:aPath];
	NSDictionary *properties1 = nil;
	NSArray *objects1 = [BLDatabaseFile objectsFromFile:wrapper1 readingProperties:&properties1];

	// Check bundles and files
	XCTAssertTrue([objects1 count] == 1, @"Wrong number of bundles");
	BLBundleObject *aBundle = [objects1 objectAtIndex:0];
	XCTAssertTrue([[aBundle files] count] == 7, @"Wrong number of files");
	for (BLFileObject *aFile in aBundle.files)
		XCTAssertTrue([[aFile objects] count] > 0, @"Wrong number of keys");

	// Check properties
	XCTAssertEqualObjects([properties1 objectForKey:BLReferenceLanguagePropertyName], @"en", @"Wrong reference language");
	XCTAssertEqualObjects([properties1 objectForKey:BLLanguagesPropertyName], ([NSArray arrayWithObjects:@"en", @"fr", @"de", nil]), @"Wrong reference language");
	XCTAssertNotNil([properties1 objectForKey:BLPreferencesPropertyName], @"Missing preferences");

	// Write and read in
	NSFileWrapper *outWrapper = [BLDatabaseFile createFileForObjects:objects1 withOptions:0 andProperties:properties1];
	XCTAssertTrue([outWrapper writeToURL:[NSURL fileURLWithPath:tmpPath] options:NSFileWrapperWritingAtomic originalContentsURL:nil error:nil], @"Writing failed");

	NSFileWrapper *wrapper2 = [[NSFileWrapper alloc] initWithPath:tmpPath];
	NSDictionary *properties2 = nil;
	NSArray *objects2 = [BLDatabaseFile objectsFromFile:wrapper2 readingProperties:&properties2];

	// Compare
	XCTAssertEqualObjects(properties1, properties2, @"Properties do not match");
	XCTAssertEqualObjects(objects1, objects2, @"Objects do not match");
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

	XCTAssertNotNil(outWrapper, @"No wrapper created!");
	XCTAssertTrue([outWrapper writeToURL:[NSURL fileURLWithPath:tmpPathoptions:NSFileWrapperWritingAtomic originalContentsURL:nil error:nil], @"Writing failed");

	// Read in
	NSFileWrapper *inWrapper = [[NSFileWrapper alloc] initWithPath:tmpPath];
	NSDictionary *outProperties = nil;
	NSArray *outObjects = [BLLocalizerFile objectsFromFile:inWrapper readingProperties:&outProperties];

	// Check equality
	for (NSString *key in inProperties)
		XCTAssertEqualObjects([outProperties objectForKey:key], [inProperties objectForKey:key], @"Properties do not match");
	XCTAssertEqualObjects(outObjects, inObjects, @"Objects do not match");
}

- (void)testDictionaryFile {
	// Write out
	NSArray *inObjects = [file objects];
	NSDictionary *inProperties = [NSDictionary dictionaryWithObjectsAndKeys:
												   [NSArray arrayWithObjects:@"en", @"de", @"fr", nil], BLLanguagesPropertyName,
												   [NSDictionary dictionary], BLFilterSettingsPropertyName,
												   nil];
	NSFileWrapper *outWrapper = [BLDictionaryFile createFileForObjects:inObjects withOptions:0 andProperties:inProperties];

	XCTAssertNotNil(outWrapper, @"No wrapper created!");
	XCTAssertTrue([outWrapper writeToURL:[NSURL fileURLWithPath:tmpPathoptions:NSFileWrapperWritingAtomic originalContentsURL:nil error:nil], @"Writing failed");

	// Read in
	NSFileWrapper *inWrapper = [[NSFileWrapper alloc] initWithURL:[NSURL fileURLWithPath:tmpPath] options:0 error:nil];
	NSDictionary *outProperties = nil;
	NSArray *outObjects = [BLDictionaryFile objectsFromFile:inWrapper readingProperties:&outProperties];

	// Check equality
	XCTAssertEqualObjects(outProperties, inProperties, @"Properties do not match");

	NSComparator comp = ^(BLKeyObject *obj1, BLKeyObject *obj2) { return [obj1.key compare:obj2.key]; };
	inObjects = [inObjects sortedArrayUsingComparator:comp];
	outObjects = [outObjects sortedArrayUsingComparator:comp];
	XCTAssertEqualObjects(outObjects, inObjects, @"Objects do not match");
}

- (void)testAttachments {
	NSFileWrapper *wrapper = [[NSFileWrapper alloc] initWithURL:[NSURL fileURLWithPath:path] options:0 error:nil];
	NSString *string = @"Hello World!";
	XCTAssertTrue(NO); // The tested API is not available. Why?
#if 0
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
	XCTAssertTrue([outWrapper writeToURL:[NSURL fileURLWithPath:tmpPathoptions:NSFileWrapperWritingAtomic originalContentsURL:nil error:nil], @"Writing failed");
	
	// Read
	NSFileWrapper *inWrapper = [[NSFileWrapper alloc] initWithPath:tmpPath];
	NSArray *outObjects = [BLLocalizerFile objectsFromFile:inWrapper readingProperties:NULL];
	BLFileObject *outFile = [[[outObjects lastObject] files] lastObject];

	// Check attachments
	XCTAssertEqual([file versionForLanguage:@"fr"], [outFile versionForLanguage:@"fr"], @"Versions differ");
	XCTAssertEqual([file versionForLanguage:@"cz"], [outFile versionForLanguage:@"cz"], @"Versions differ");
	XCTAssertEqualObjects([file attachedObjectForKey:@"test2" version:1], [outFile attachedObjectForKey:@"test2" version:1], @"attachments differ");
	XCTAssertEqualObjects([[file attachedObjectForKey:@"test1" version:2] regularFileContents], [[outFile attachedObjectForKey:@"test1" version:2] regularFileContents], @"attachments differ");
#endif
}

@end
