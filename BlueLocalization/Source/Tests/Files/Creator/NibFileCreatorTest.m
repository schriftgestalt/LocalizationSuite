//
//  NibFileCreatorTest.m
//  BlueLocalization
//
//  Created by max on 17.03.10.
//  Copyright 2010 The Soulmen. All rights reserved.
//

#import "NibFileCreatorTest.h"

@implementation NibFileCreatorTest

- (void)setUp {
	NSString *folderPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"nib" ofType:nil inDirectory:@"Test Data/Creator"];
	tmpPath = @"/tmp/loc.test";

	[[NSFileManager defaultManager] copyItemAtPath:folderPath toPath:tmpPath error:NULL];
}

- (void)tearDown {
	[[NSFileManager defaultManager] removeItemAtPath:tmpPath error:NULL];
}

- (void)testIncrementalLocalization {
	NSString *path = [tmpPath stringByAppendingPathComponent:@"en.lproj/previous.xib"];

	BLFileObject *fileObject = [BLFileObject fileObjectWithPath:path];
	BLFileInterpreter *interpreter = [BLFileInterpreter interpreterForFileObject:fileObject];

	// Old reference
	[interpreter activateOptions:BLFileInterpreterAllowChangesToKeyObjects];
	[interpreter interpreteFile:path intoObject:fileObject withLanguage:@"en" referenceLanguage:@"en"];

	// Old translated
	path = [tmpPath stringByAppendingPathComponent:@"de.lproj/incremental.xib"];
	[interpreter deactivateOptions:BLFileInterpreterAllowChangesToKeyObjects];
	[interpreter interpreteFile:path intoObject:fileObject withLanguage:@"de" referenceLanguage:nil];
	[fileObject setVersion:1 forLanguage:@"de"];

	// New reference
	path = [tmpPath stringByAppendingPathComponent:@"en.lproj/reference.xib"];
	[interpreter activateOptions:BLFileInterpreterAllowChangesToKeyObjects];
	[interpreter interpreteFile:path intoObject:fileObject withLanguage:@"en" referenceLanguage:@"en"];

	// Write out
	BLFileCreator *creator = [BLFileCreator creatorForFileObject:fileObject];
	NSString *outPath = [tmpPath stringByAppendingPathComponent:@"de.lproj/incremental.xib"];

	[creator writeFileToPath:outPath fromObject:fileObject withLanguage:@"de" referenceLanguage:@"en"];

	// Compare files
	path = [tmpPath stringByAppendingPathComponent:@"de.lproj/output.xib"];
	XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:outPath], @"Missing outfile");
	XCTAssertTrue([[NSFileManager defaultManager] contentsEqualAtPath:path andPath:outPath], @"Incremental localization failed!");

	// Check versions
	XCTAssertTrue([fileObject versionForLanguage:@"de"] == 2, @"Version should be upgraded");
}

@end
