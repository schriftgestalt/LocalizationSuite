//
//  XLIFFIntegrationTest.m
//  BlueLocalization
//
//  Created by max on 22.01.10.
//  Copyright 2010 The Soulmen. All rights reserved.
//

#import "XLIFFIntegrationTest.h"

#import <BlueLocalization/BLXLIFFDocument.h>

@implementation XLIFFIntegrationTest

- (void)setUp {
	tmpPath = @"/tmp/loc-export.xlf";
}

- (void)tearDown {
	[[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
}

- (NSString *)path:(NSString *)filename {
	return [[NSBundle bundleForClass:[self class]] pathForResource:[filename stringByDeletingPathExtension] ofType:[filename pathExtension] inDirectory:@"Test Data/XLIFF"];
}

- (void)testExampleImport1 {
	BLXLIFFDocument *document = [BLXLIFFDocument documentWithFileAtPath:[self path:@"strict.xlf"]];
	XCTAssertEqual([document.fileObjects count], (NSUInteger)2, @"Wrong number of file objects");

	BLFileObject *file = [document.fileObjects objectAtIndex:0];
	XCTAssertEqual([file.objects count], (NSUInteger)4, @"Wrong number of keys in first file");
	for (BLKeyObject *key in file.objects)
		XCTAssertTrue([[key stringForLanguage:@"en_US"] length] > 0, @"Strings missing");

	file = [document.fileObjects objectAtIndex:1];
	XCTAssertEqual([file.objects count], (NSUInteger)7, @"Wrong number of keys in first file");
	for (BLKeyObject *key in file.objects)
		XCTAssertTrue([[key stringForLanguage:@"en_US"] length] > 0, @"Strings missing");
}

- (void)testExampleImport2 {
	BLXLIFFDocument *document = [BLXLIFFDocument documentWithFileAtPath:[self path:@"transitional.xlf"]];
	XCTAssertEqual([document.fileObjects count], (NSUInteger)2, @"Wrong number of file objects");

	BLFileObject *file = [document.fileObjects objectAtIndex:0];
	XCTAssertEqual([file.objects count], (NSUInteger)5, @"Wrong number of keys in first file");
	for (BLKeyObject *key in file.objects)
		XCTAssertTrue([[key stringForLanguage:@"en_US"] length] > 0, @"Strings missing");

	file = [document.fileObjects objectAtIndex:1];
	XCTAssertEqual([file.objects count], (NSUInteger)7, @"Wrong number of keys in first file");
	for (BLKeyObject *key in file.objects)
		XCTAssertTrue([[key stringForLanguage:@"en_US"] length] > 0, @"Strings missing");
}

- (void)testReimport {
	BLXLIFFDocument *document = [BLXLIFFDocument documentWithFileAtPath:[self path:@"example.xlf"]];

	XCTAssertTrue([document writeToPath:tmpPath error:NULL], @"Write should not fail");

	BLXLIFFDocument *document2 = [BLXLIFFDocument documentWithFileAtPath:tmpPath];
	XCTAssertEqualObjects(document.fileObjects, document2.fileObjects, @"Files should be the same!");
}

- (void)testCreateNew {
	// Read old document
	BLXLIFFDocument *document = [BLXLIFFDocument documentWithFileAtPath:[self path:@"example.xlf"]];
	XCTAssertNotNil(document.sourceLanguage, @"Missing source language");
	XCTAssertNotNil(document.targetLanguage, @"Missing target language");

	// Create new document
	BLXLIFFDocument *newDocument = [BLXLIFFDocument blankDocument];
	newDocument.fileObjects = document.fileObjects;

	// Missing source language
	XCTAssertThrows([newDocument writeToPath:tmpPath error:NULL], @"Write should fail");

	// Missing target language
	newDocument.sourceLanguage = document.sourceLanguage;
	XCTAssertThrows([newDocument writeToPath:tmpPath error:NULL], @"Write should fail");

	// Write should succeed
	newDocument.targetLanguage = document.targetLanguage;
	XCTAssertTrue([newDocument writeToPath:tmpPath error:NULL], @"Write should not fail");

	// Read in again and compare
	BLXLIFFDocument *document2 = [BLXLIFFDocument documentWithFileAtPath:tmpPath];
	XCTAssertEqualObjects(document.fileObjects, document2.fileObjects, @"Files should be the same!");
}

- (void)testBundlePaths {
	// Create some dummy files
	NSMutableArray *fileObjects = [NSMutableArray array];
	[fileObjects addObject:[BLFileObject fileObjectWithPath:@"bundle1/en.lproj/file.strings"]];
	[fileObjects addObject:[BLFileObject fileObjectWithPath:@"bundle1/en.lproj/file2.strings"]];
	[fileObjects addObject:[BLFileObject fileObjectWithPath:@"bundle2/de.lproj/my/test/path.rtf"]];
	[fileObjects addObject:[BLFileObject fileObjectWithPath:@"some_pack/fr.lproj/interface.nib"]];

	// Create a file
	BLXLIFFDocument *document = [BLXLIFFDocument blankDocument];
	document.fileObjects = fileObjects;
	document.sourceLanguage = @"en";
	document.targetLanguage = @"de";

	// Write the file
	XCTAssertTrue([document writeToPath:tmpPath error:NULL], @"Write should not fail");

	// Read in again
	BLXLIFFDocument *document2 = [BLXLIFFDocument documentWithFileAtPath:tmpPath];

	// Check file names
	XCTAssertEqual([document.fileObjects count], [document2.fileObjects count], @"Count of files should be the same");
	XCTAssertFalse([document.fileObjects isEqual:document2.fileObjects], @"But files should not be the same!");

	for (NSUInteger i = 0; i < [document.fileObjects count]; i++) {
		BLFileObject *f1 = [document.fileObjects objectAtIndex:i];
		BLFileObject *f2 = [document2.fileObjects objectAtIndex:i];

		XCTAssertEqualObjects(f2.path, [f1.bundleObject.name stringByAppendingPathComponent:f1.path], @"Invalid names!");
	}
}

- (void)testRTFSupport {
	// Read basic document
	BLXLIFFDocument *document = [BLXLIFFDocument documentWithFileAtPath:[self path:@"rtf.xlf"]];

	XCTAssertTrue([document writeToPath:tmpPath error:NULL], @"Write should not fail");

	BLXLIFFDocument *document2 = [BLXLIFFDocument documentWithFileAtPath:tmpPath];
	XCTAssertEqualObjects(document.fileObjects, document2.fileObjects, @"Files should be the same!");

	// Import rtf document
	NSAttributedString *string = [[NSAttributedString alloc] initWithPath:[self path:@"rtf2.rtf"] documentAttributes:nil];

	// Read, write advanced document
	document = [BLXLIFFDocument documentWithFileAtPath:[self path:@"rtf2.xlf"]];
	XCTAssertEqualObjects([string string], [[[[[document.fileObjects objectAtIndex:0] objects] objectAtIndex:0] objectForLanguage:@"en"] string], @"Wrong string");

	XCTAssertTrue([document writeToPath:tmpPath error:NULL], @"Write should not fail");

	document2 = [BLXLIFFDocument documentWithFileAtPath:tmpPath];
	XCTAssertEqualObjects(document.fileObjects, document2.fileObjects, @"Files should be the same!");
	XCTAssertEqualObjects([string string], [[[[[document2.fileObjects objectAtIndex:0] objects] objectAtIndex:0] objectForLanguage:@"en"] string], @"Wrong string");

	// Create advanced document
	BLXLIFFDocument *document3 = [BLXLIFFDocument blankDocument];
	document3.sourceLanguage = document.sourceLanguage;
	document3.targetLanguage = document.targetLanguage;
	document3.fileObjects = document.fileObjects;

	XCTAssertTrue([document3 writeToPath:tmpPath error:NULL], @"Write should not fail");

	document2 = [BLXLIFFDocument documentWithFileAtPath:tmpPath];
	XCTAssertEqualObjects(document.fileObjects, document2.fileObjects, @"Files should be the same!");
	XCTAssertEqualObjects(document.fileObjects, document3.fileObjects, @"Files should be the same!");
	XCTAssertEqualObjects([string string], [[[[[document2.fileObjects objectAtIndex:0] objects] objectAtIndex:0] objectForLanguage:@"en"] string], @"Wrong string");
}

@end
