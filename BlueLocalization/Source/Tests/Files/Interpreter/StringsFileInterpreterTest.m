//
//  StringsFileInterpreterTest.m
//  BlueLocalization
//
//  Created by Max Seelemann on 25.11.08.
//  Copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
//

#import "StringsFileInterpreterTest.h"

NSString *StringsFileInterpreterTestLanguage = @"en";
NSString *StringsFileInterpreterExtension = @"strings";

@implementation StringsFileInterpreterTest

- (void)setUp {
	interpreter = [BLFileInterpreter interpreterForFileType:StringsFileInterpreterExtension];
	[interpreter activateOptions:BLFileInterpreterAllowChangesToKeyObjects];
}

- (void)testDataImport {
	NSArray *paths;

	paths = [[NSBundle bundleForClass:[self class]] pathsForResourcesOfType:StringsFileInterpreterExtension inDirectory:@"Test Data/Strings/specific"];
	XCTAssertTrue([paths count] > 0, @"Found no test files");

	for (NSString *path in paths) {
		BLFileObject *fileObject;
		NSDictionary *data;

		fileObject = [BLFileObject fileObjectWithPathExtension:StringsFileInterpreterExtension];
		BOOL result = [interpreter interpreteFile:path intoObject:fileObject withLanguage:StringsFileInterpreterTestLanguage referenceLanguage:nil];
		XCTAssertTrue(result, @"Interpreter failed with no result for file %@", path);

		data = [NSDictionary dictionaryWithContentsOfFile:path];
		XCTAssertTrue(data != nil || [fileObject numberOfKeys] == 0, @"NSDictionary can't open file %@", path);

		for (NSString *key in [data allKeys]) {
			id orig, import;
			BOOL empty;

			orig = [data objectForKey:key];
			import = [[fileObject objectForKey:key] stringForLanguage:StringsFileInterpreterTestLanguage];

			empty = !orig || ![orig length] || [orig rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == [orig length];

			XCTAssertNotNil([fileObject objectForKey:key], @"Missing key object for key \"%@\" in file \"%@\"", key, [path lastPathComponent]);
			XCTAssertTrue((empty || import), @"Missing value for key \"%@\" in file \"%@\"", key, [path lastPathComponent]);
			XCTAssertTrue((empty && !import) || [orig isEqual:import], @"Values don't match for key \"%@\" in file \"%@\"", key, [path lastPathComponent]);
		}
	}
}

- (void)testCommentImport {
	NSArray *paths;

	paths = [[NSBundle bundleForClass:[self class]] pathsForResourcesOfType:StringsFileInterpreterExtension inDirectory:@"Test Data/Strings/comment"];
	XCTAssertTrue([paths count] > 0, @"Found no test files");

	for (NSString *path in paths) {
		BLFileObject *fileObject;
		NSDictionary *data;

		fileObject = [BLFileObject fileObjectWithPathExtension:StringsFileInterpreterExtension];
		BOOL result = [interpreter interpreteFile:path intoObject:fileObject withLanguage:StringsFileInterpreterTestLanguage referenceLanguage:nil];
		XCTAssertTrue(result, @"Interpreter failed with no result for file %@", path);

		NSString *commentsPath;
		commentsPath = [[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"comments"];
		data = [NSDictionary dictionaryWithContentsOfFile:commentsPath];
		XCTAssertNotNil(data, @"NSDictionary can't open comments file %@", path);

		for (NSString *key in [data allKeys]) {
			id orig, import;

			orig = [data objectForKey:key];
			import = [[fileObject objectForKey:key] comment];

			XCTAssertNotNil([fileObject objectForKey:key], @"Missing key object for key \"%@\" in file \"%@\"", key, [path lastPathComponent]);
			XCTAssertTrue((![orig length] || import), @"Missing comment for key \"%@\" in file \"%@\"", key, [path lastPathComponent]);
			XCTAssertTrue([orig isEqual:import], @"Comment values don't match for key \"%@\" in file \"%@\"", key, [path lastPathComponent]);
		}
	}
}

- (void)testImportErrors {
	NSArray *paths;

	paths = [[NSBundle bundleForClass:[self class]] pathsForResourcesOfType:StringsFileInterpreterExtension inDirectory:@"Test Data/Strings/error"];
	XCTAssertTrue([paths count] > 0, @"Found no test files");

	for (NSString *path in paths) {
		BLFileObject *fileObject;

		fileObject = [BLFileObject fileObjectWithPathExtension:StringsFileInterpreterExtension];
		BOOL result = [interpreter interpreteFile:path intoObject:fileObject withLanguage:StringsFileInterpreterTestLanguage referenceLanguage:nil];
		XCTAssertFalse(result, @"Interpreter should fail with no result for file %@", path);
	}
}

- (void)testIgnoredPlaceholders {
	XCTAssertNotNil([BLDatabaseDocument defaultIgnoredPlaceholderStrings], @"No default placeholders!");
	XCTAssertTrue([[BLDatabaseDocument defaultIgnoredPlaceholderStrings] count] > 3, @"Not enough default placeholders!");

	NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"placeholders" ofType:StringsFileInterpreterExtension inDirectory:@"Test Data/Strings/specific"];
	XCTAssertNotNil(path, @"File not found");

	// Test without placeholders being set
	BLFileObject *fileObject1 = [BLFileObject fileObjectWithPathExtension:StringsFileInterpreterExtension];
	XCTAssertTrue([interpreter interpreteFile:path intoObject:fileObject1 withLanguage:StringsFileInterpreterTestLanguage referenceLanguage:StringsFileInterpreterTestLanguage], @"Interpretation failed");

	XCTAssertEqual([[fileObject1 objects] count], (NSUInteger)5, @"Wrong number of imported keys");
	XCTAssertEqual([fileObject1 numberOfKeys], (NSUInteger)5, @"Wrong number of active keys");

	// Test with placeholders being set
	[interpreter activateOptions:BLFileInterpreterDeactivatePlaceholderStrings];
	interpreter.ignoredPlaceholderStrings = [NSArray arrayWithObjects:@"value2", @"<do not localize>", nil];

	BLFileObject *fileObject2 = [BLFileObject fileObjectWithPathExtension:StringsFileInterpreterExtension];
	XCTAssertTrue([interpreter interpreteFile:path intoObject:fileObject2 withLanguage:StringsFileInterpreterTestLanguage referenceLanguage:StringsFileInterpreterTestLanguage], @"Interpretation failed");

	XCTAssertEqual([[fileObject2 objects] count], (NSUInteger)5, @"Wrong number of imported keys");
	XCTAssertEqual([fileObject2 numberOfKeys], (NSUInteger)3, @"Wrong number of active keys");

	// Deactivate option
	[interpreter deactivateOptions:BLFileInterpreterDeactivatePlaceholderStrings];

	BLFileObject *fileObject3 = [BLFileObject fileObjectWithPathExtension:StringsFileInterpreterExtension];
	XCTAssertTrue([interpreter interpreteFile:path intoObject:fileObject3 withLanguage:StringsFileInterpreterTestLanguage referenceLanguage:StringsFileInterpreterTestLanguage], @"Interpretation failed");

	XCTAssertEqual([[fileObject3 objects] count], (NSUInteger)5, @"Wrong number of imported keys");
	XCTAssertEqual([fileObject3 numberOfKeys], (NSUInteger)5, @"Wrong number of active keys");
}

@end
