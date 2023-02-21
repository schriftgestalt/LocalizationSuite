//
//  TXTFileCreatorTest.m
//  BlueLocalization
//
//  Created by Max Seelemann on 25.08.11.
//  Copyright (c) 2011 Localization Suite. All rights reserved.
//

#import "TXTFileCreatorTest.h"

NSString *TXTFileCreatorTestLanguage = @"en";
NSString *TXTFileCreatorExtension = @"txt";

@implementation TXTFileCreatorTest

- (void)setUp {
	creator = [BLFileCreator creatorForFileType:TXTFileCreatorExtension];

	interpreter = [BLFileInterpreter interpreterForFileType:TXTFileCreatorExtension];
	[interpreter activateOptions:BLFileInterpreterAllowChangesToKeyObjects];

	tmpRootPath = @"/tmp/LocTests/";
	[[NSFileManager defaultManager] createDirectoryAtPath:tmpRootPath withIntermediateDirectories:NO attributes:nil error:NULL];
}

- (void)tearDown {
	[[NSFileManager defaultManager] removeItemAtPath:tmpRootPath error:NULL];
}

- (void)testEncodingMimicing {
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"utf8" ofType:TXTFileCreatorExtension inDirectory:@"Test Data/Text"];

	// Read in
	BLFileObject *fileObject = [BLFileObject fileObjectWithPathExtension:TXTFileCreatorExtension];
	BOOL result = [interpreter interpreteFile:path intoObject:fileObject withLanguage:TXTFileCreatorTestLanguage referenceLanguage:TXTFileCreatorTestLanguage];
	XCTAssertTrue(result, @"Interpreter failed with no result for file %@", path);

	// Write out
	NSString *outPath = [tmpRootPath stringByAppendingPathComponent:[path lastPathComponent]];
	[creator writeFileToPath:outPath fromObject:fileObject withLanguage:TXTFileCreatorTestLanguage referenceLanguage:TXTFileCreatorTestLanguage];

	// Compare encodings
	NSStringEncoding encoding;
	XCTAssertNotNil([NSString stringWithContentsOfFile:path usedEncoding:&encoding error:NULL], @"Reading failed");
	XCTAssertEqual(encoding, (NSStringEncoding)NSUTF8StringEncoding, @"Wrong input encoding");

	XCTAssertNotNil([NSString stringWithContentsOfFile:outPath usedEncoding:&encoding error:NULL], @"Reading failed");
	XCTAssertEqual(encoding, (NSStringEncoding)NSUTF8StringEncoding, @"Wrong output encoding");

	// Read utf-16
	path = [[NSBundle bundleForClass:[self class]] pathForResource:@"utf16" ofType:TXTFileCreatorExtension inDirectory:@"Test Data/Text"];

	// Read in
	fileObject = [BLFileObject fileObjectWithPathExtension:TXTFileCreatorExtension];
	result = [interpreter interpreteFile:path intoObject:fileObject withLanguage:TXTFileCreatorTestLanguage referenceLanguage:TXTFileCreatorTestLanguage];
	XCTAssertTrue(result, @"Interpreter failed with no result for file %@", path);

	// Write out
	outPath = [tmpRootPath stringByAppendingPathComponent:[path lastPathComponent]];
	[creator writeFileToPath:outPath fromObject:fileObject withLanguage:TXTFileCreatorTestLanguage referenceLanguage:TXTFileCreatorTestLanguage];

	// Compare encodings
	XCTAssertNotNil([NSString stringWithContentsOfFile:path usedEncoding:&encoding error:NULL], @"Reading failed");
	XCTAssertEqual(encoding, (NSStringEncoding)NSUnicodeStringEncoding, @"Wrong input encoding");

	XCTAssertNotNil([NSString stringWithContentsOfFile:outPath usedEncoding:&encoding error:NULL], @"Reading failed");
	XCTAssertEqual(encoding, (NSStringEncoding)NSUnicodeStringEncoding, @"Wrong output encoding");
}

@end
