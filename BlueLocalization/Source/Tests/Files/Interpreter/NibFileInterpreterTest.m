//
//  NibFileInterpreterTest.m
//  BlueLocalization
//
//  Created by Max Seelemann on 27.04.09.
//  Copyright 2009 The Blue Technologies Group. All rights reserved.
//

#import "NibFileInterpreterTest.h"

NSString *TestLanguage = @"en";
NSString *Extension = @"xib";
NSString *OldExtension = @"nib";

@implementation NibFileInterpreterTest

- (void)setUp {
	interpreter = [BLFileInterpreter interpreterForFileType:Extension];
	[interpreter activateOptions:BLFileInterpreterAllowChangesToKeyObjects];
}

- (void)testDataImport {
	NSArray *paths;

	paths = [[NSBundle bundleForClass:[self class]] pathsForResourcesOfType:Extension inDirectory:@"Test Data/Interpreter/nib"];
	STAssertTrue([paths count] > 0, @"Found no test files");

	for (NSString *path in paths) {
		BLFileObject *fileObject;
		NSDictionary *data;

		fileObject = [BLFileObject fileObjectWithPathExtension:Extension];
		BOOL result = [interpreter interpreteFile:path intoObject:fileObject withLanguage:TestLanguage referenceLanguage:nil];
		STAssertTrue(result, @"Interpreter failed with no result for file %@", path);

		data = [NSDictionary dictionaryWithContentsOfFile:[[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"strings"]];
		STAssertNotNil(data, @"NSDictionary can't open file %@", path);

		for (NSString *key in [data allKeys]) {
			id orig, import;

			orig = [data objectForKey:key];
			import = [[fileObject objectForKey:key] stringForLanguage:TestLanguage];

			STAssertNotNil([fileObject objectForKey:key], @"Missing key object for key \"%@\" in file \"%@\"", key, [path lastPathComponent]);
			STAssertTrue((![orig length] || import), @"Missing value for key \"%@\" in file \"%@\"", key, [path lastPathComponent]);
			STAssertTrue((![orig length] && !import) || [orig isEqual:import], @"Values don't match for key \"%@\" in file \"%@\"", key, [path lastPathComponent]);
		}
	}
}

- (void)testForNoLeftTbzFiles {
	BLFileObject *fileObject;
	NSString *path;

	// Get path
	STAssertFalse([[[NSBundle bundleForClass:[self class]] pathsForResourcesOfType:OldExtension inDirectory:@"Test Data/Interpreter/nib"] count] == 0, @"no files found");
	path = [[[NSBundle bundleForClass:[self class]] pathsForResourcesOfType:OldExtension inDirectory:@"Test Data/Interpreter/nib"] lastObject];
	STAssertNotNil(path, @"No file found");

	// Interprete file
	fileObject = [BLFileObject fileObjectWithPathExtension:Extension];
	BOOL result = [interpreter interpreteFile:path intoObject:nil withLanguage:TestLanguage referenceLanguage:nil];
	STAssertTrue(result, @"Interpreter failed with no result for file %@", path);

	// Check for tbz files
	STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"tbz"]], @"no \"tbz\" file should have been created");
	STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingPathExtension:@"tbz"]], @"no \"%@.tbz\" file should have been created", [path lastPathComponent]);
}

- (void)testChangeState {
	BLFileObject *fileObject = [BLFileObject fileObjectWithPathExtension:Extension];

	// Interprete original
	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"example" ofType:Extension inDirectory:@"Test Data/Interpreter/nib"];
	[interpreter interpreteFile:path intoObject:fileObject withLanguage:TestLanguage referenceLanguage:TestLanguage];

	STAssertEqualObjects([fileObject changedValues], [NSArray arrayWithObject:BLObjectReferenceChangedKey], @"Reference should change");
	[fileObject setNothingDidChange];
	STAssertEqualObjects([fileObject changedValues], [NSArray array], @"Nothing should be changed");

	// Interprete again
	[interpreter interpreteFile:path intoObject:fileObject withLanguage:TestLanguage referenceLanguage:TestLanguage];
	STAssertEqualObjects([fileObject changedValues], [NSArray array], @"Nothing should be changed");

	// Interprete moved version
	path = [[NSBundle bundleForClass:[self class]] pathForResource:@"example-mv" ofType:Extension inDirectory:@"Test Data/Interpreter/nib"];
	[interpreter interpreteFile:path intoObject:fileObject withLanguage:TestLanguage referenceLanguage:TestLanguage];

	STAssertEqualObjects([fileObject changedValues], [NSArray arrayWithObject:BLObjectReferenceChangedKey], @"Reference should change");
	[fileObject setNothingDidChange];
	STAssertEqualObjects([fileObject changedValues], [NSArray array], @"Nothing should be changed");

	// Re-interprete original
	path = [[NSBundle bundleForClass:[self class]] pathForResource:@"example" ofType:Extension inDirectory:@"Test Data/Interpreter/nib"];
	[interpreter interpreteFile:path intoObject:fileObject withLanguage:TestLanguage referenceLanguage:TestLanguage];

	STAssertEqualObjects([fileObject changedValues], [NSArray arrayWithObject:BLObjectReferenceChangedKey], @"Reference should change");
	[fileObject setNothingDidChange];
	STAssertEqualObjects([fileObject changedValues], [NSArray array], @"Nothing should be changed");

	// Interprete version with added strings
	path = [[NSBundle bundleForClass:[self class]] pathForResource:@"example-ed" ofType:Extension inDirectory:@"Test Data/Interpreter/nib"];
	[interpreter interpreteFile:path intoObject:fileObject withLanguage:TestLanguage referenceLanguage:TestLanguage];

	STAssertEqualObjects([fileObject changedValues], [NSArray arrayWithObject:BLObjectReferenceChangedKey], @"Reference should change");
	[fileObject setNothingDidChange];
	STAssertEqualObjects([fileObject changedValues], [NSArray array], @"Nothing should be changed");
}

@end
