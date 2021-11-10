//
//  PlistFileInterpreterTest.m
//  BlueLocalization
//
//  Created by Max Seelemann on 27.04.09.
//  Copyright 2009 The Blue Technologies Group. All rights reserved.
//

#import "PlistFileInterpreterTest.h"

NSString *PlistFileInterpreterTestLanguage = @"en";
NSString *PlistFileInterpreterExtension = @"plist";

@implementation PlistFileInterpreterTest

- (void)setUp {
	interpreter = [BLFileInterpreter interpreterForFileType:PlistFileInterpreterExtension];
	[interpreter activateOptions:BLFileInterpreterAllowChangesToKeyObjects];
}

- (void)testDataImport {
	NSArray *paths;

	paths = [[NSBundle bundleForClass:[self class]] pathsForResourcesOfType:PlistFileInterpreterExtension inDirectory:@"Test Data/Interpreter/plist"];
	STAssertTrue([paths count] > 0, @"Found no test files");

	for (NSString *path in paths) {
		BLFileObject *fileObject;
		NSDictionary *data;

		fileObject = [BLFileObject fileObjectWithPathExtension:PlistFileInterpreterExtension];
		BOOL result = [interpreter interpreteFile:path intoObject:fileObject withLanguage:PlistFileInterpreterTestLanguage referenceLanguage:nil];
		STAssertTrue(result, @"Interpreter failed with no result for file %@", path);

		data = [NSDictionary dictionaryWithContentsOfFile:[[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"strings"]];
		STAssertNotNil(data, @"NSDictionary can't open file %@", path);

		for (NSString *key in [data allKeys]) {
			id orig, import;

			orig = [data objectForKey:key];
			import = [[fileObject objectForKey:key] stringForLanguage:PlistFileInterpreterTestLanguage];

			STAssertNotNil([fileObject objectForKey:key], @"Missing key object for key \"%@\" in file \"%@\"", key, [path lastPathComponent]);
			STAssertTrue((![orig length] || import), @"Missing value for key \"%@\" in file \"%@\"", key, [path lastPathComponent]);
			STAssertTrue((![orig length] && !import) || [orig isEqual:import], @"Values don't match for key \"%@\" in file \"%@\"", key, [path lastPathComponent]);
		}
	}
}

@end
