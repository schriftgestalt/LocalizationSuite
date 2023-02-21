//
//  StringsImporterTest.m
//  BlueLocalization
//
//  Created by max on 09.12.09.
//  Copyright 2009 The Soulmen. All rights reserved.
//

#import "StringsImporterTest.h"

NSString *StringsImporterTestExtension = @"strings";

@implementation StringsImporterTest

- (void)testUnicodeImport {
	// Find the file
	NSString *enPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"unicode_en" ofType:StringsImporterTestExtension inDirectory:@"Test Data/Importer"];
	NSString *dePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"unicode_de" ofType:StringsImporterTestExtension inDirectory:@"Test Data/Importer"];
	NSString *frPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"unicode fr" ofType:StringsImporterTestExtension inDirectory:@"Test Data/Importer"];
	XCTAssertNotNil(enPath, @"Found no test file");
	XCTAssertNotNil(dePath, @"Found no test file");
	XCTAssertNotNil(frPath, @"Found no test file");

	// Create file and interpreter
	BLFileObject *fileObject = [BLFileObject fileObjectWithPathExtension:StringsImporterTestExtension];
	BLFileInterpreter *interpreter = [BLFileInterpreter interpreterForFileType:StringsImporterTestExtension];
	[interpreter activateOptions:BLFileInterpreterAllowChangesToKeyObjects];

	// Import english
	BOOL result = [interpreter interpreteFile:enPath intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	XCTAssertTrue(result, @"Interpreter failed with no result for file %@", enPath);
	result = [interpreter interpreteFile:dePath intoObject:fileObject withLanguage:@"de" referenceLanguage:nil];
	XCTAssertTrue(result, @"Interpreter failed with no result for file %@", dePath);
	XCTAssertTrue([[fileObject objects] count] > 0, @"Nothing imported");

	// Import german
	[BLStringsImporter importStringsFromFiles:[NSArray arrayWithObject:frPath] forReferenceLanguage:@"en" toObjects:[NSArray arrayWithObject:fileObject]];

	// Both languages should now be the same
	for (BLKeyObject *keyObject in [fileObject objects])
		XCTAssertEqualObjects([keyObject objectForLanguage:@"de"], [keyObject objectForLanguage:@"fr"], @"Values do not match!");
}

@end
