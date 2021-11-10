//
//  StringsFileCreatorTest.m
//  BlueLocalization
//
//  Created by max on 26.10.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StringsFileCreatorTest.h"

NSString *StringsFileCreatorTestLanguage = @"en";
NSString *StringsFileCreatorExtension = @"strings";

@implementation StringsFileCreatorTest

- (void)setUp {
	creator = [BLFileCreator creatorForFileType:StringsFileCreatorExtension];

	interpreter = [BLFileInterpreter interpreterForFileType:StringsFileCreatorExtension];
	[interpreter activateOptions:BLFileInterpreterAllowChangesToKeyObjects];

	tmpRootPath = @"/tmp/LocTests/";
	[[NSFileManager defaultManager] createDirectoryAtPath:tmpRootPath withIntermediateDirectories:NO attributes:nil error:NULL];
}

- (void)tearDown {
	[[NSFileManager defaultManager] removeItemAtPath:tmpRootPath error:NULL];
}

- (void)testWriteOut {
	NSArray *paths;

	paths = [[NSBundle bundleForClass:[self class]] pathsForResourcesOfType:StringsFileCreatorExtension inDirectory:@"Test Data/Strings/specific"];
	STAssertTrue([paths count] > 0, @"Found no test files");

	for (NSString *path in paths) {
		BLFileObject *fileObject, *secondFileObject;
		NSDictionary *data;

		fileObject = [BLFileObject fileObjectWithPathExtension:StringsFileCreatorExtension];
		secondFileObject = [BLFileObject fileObjectWithPathExtension:StringsFileCreatorExtension];

		// Read in
		BOOL result = [interpreter interpreteFile:path intoObject:fileObject withLanguage:StringsFileCreatorTestLanguage referenceLanguage:nil];
		STAssertTrue(result, @"Interpreter failed with no result for file %@", path);

		// Write out
		NSString *outPath = [tmpRootPath stringByAppendingPathComponent:[path lastPathComponent]];
		[creator writeFileToPath:outPath fromObject:fileObject withLanguage:StringsFileCreatorTestLanguage referenceLanguage:StringsFileCreatorTestLanguage];

		// Read in again
		data = [NSDictionary dictionaryWithContentsOfFile:outPath];
		STAssertTrue(data != nil || [fileObject numberOfKeys] == 0, @"NSDictionary can't open file %@", path);

		for (NSString *key in [data allKeys]) {
			id orig, import;
			BOOL empty;

			orig = [data objectForKey:key];
			import = [[fileObject objectForKey:key] stringForLanguage:StringsFileCreatorTestLanguage];

			empty = !orig || ![orig length] || [orig rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == [orig length];

			STAssertNotNil([fileObject objectForKey:key], @"Missing key object for key \"%@\" in file \"%@\"", key, [path lastPathComponent]);
			STAssertTrue((empty || import), @"Missing value for key \"%@\" in file \"%@\"", key, [path lastPathComponent]);
			STAssertTrue((empty && !import) || [orig isEqual:import], @"Values don't match for key \"%@\" in file \"%@\"", key, [path lastPathComponent]);
		}
	}
}

- (void)testEncodingMimicing {
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"utf8" ofType:StringsFileCreatorExtension inDirectory:@"Test Data/Strings/specific"];

	// Read in
	BLFileObject *fileObject = [BLFileObject fileObjectWithPathExtension:StringsFileCreatorExtension];
	BOOL result = [interpreter interpreteFile:path intoObject:fileObject withLanguage:StringsFileCreatorTestLanguage referenceLanguage:StringsFileCreatorTestLanguage];
	STAssertTrue(result, @"Interpreter failed with no result for file %@", path);

	// Write out
	NSString *outPath = [tmpRootPath stringByAppendingPathComponent:[path lastPathComponent]];
	[creator writeFileToPath:outPath fromObject:fileObject withLanguage:StringsFileCreatorTestLanguage referenceLanguage:StringsFileCreatorTestLanguage];

	// Compare encodings
	NSStringEncoding encoding;
	STAssertNotNil([NSString stringWithContentsOfFile:path usedEncoding:&encoding error:NULL], @"Reading failed");
	STAssertEquals(encoding, (NSStringEncoding)NSUTF8StringEncoding, @"Wrong input encoding");

	STAssertNotNil([NSString stringWithContentsOfFile:outPath usedEncoding:&encoding error:NULL], @"Reading failed");
	STAssertEquals(encoding, (NSStringEncoding)NSUTF8StringEncoding, @"Wrong output encoding");

	// REad utf-16
	path = [[NSBundle bundleForClass:[self class]] pathForResource:@"utf16" ofType:StringsFileCreatorExtension inDirectory:@"Test Data/Strings/specific"];

	// Read in
	fileObject = [BLFileObject fileObjectWithPathExtension:StringsFileCreatorExtension];
	result = [interpreter interpreteFile:path intoObject:fileObject withLanguage:StringsFileCreatorTestLanguage referenceLanguage:nil];
	STAssertTrue(result, @"Interpreter failed with no result for file %@", path);

	// Write out
	outPath = [tmpRootPath stringByAppendingPathComponent:[path lastPathComponent]];
	[creator writeFileToPath:outPath fromObject:fileObject withLanguage:StringsFileCreatorTestLanguage referenceLanguage:StringsFileCreatorTestLanguage];

	// Compare encodings
	STAssertNotNil([NSString stringWithContentsOfFile:path usedEncoding:&encoding error:NULL], @"Reading failed");
	STAssertEquals(encoding, (NSStringEncoding)NSUnicodeStringEncoding, @"Wrong input encoding");

	STAssertNotNil([NSString stringWithContentsOfFile:outPath usedEncoding:&encoding error:NULL], @"Reading failed");
	STAssertEquals(encoding, (NSStringEncoding)NSUnicodeStringEncoding, @"Wrong output encoding");
}

@end
