//
//  StringsDictionaryTest.m
//  BlueLocalization
//
//  Created by Max Seelemann on 07.04.09.
//  Copyright 2009 The Blue Technologies Group. All rights reserved.
//

#import "StringsDictionaryTest.h"

@implementation StringsDictionaryTest

- (void)runDataImportTestForSubdirectory:(NSString *)subdir {
	NSArray *paths;

	paths = [[NSBundle bundleForClass:[self class]] pathsForResourcesOfType:@"strings" inDirectory:[NSString stringWithFormat:@"Test Data/Strings/%@", subdir]];
	STAssertTrue([paths count] > 0, @"Found no test files");

	for (NSString *path in paths) {
		NSDictionary *data, *dict;

		dict = [NSDictionary dictionaryWithStringsAtPath:path];
		STAssertNotNil(dict, @"Interpreter failed with no result for file %@", path);

		data = [NSDictionary dictionaryWithContentsOfFile:path];
		STAssertTrue((data != nil) || [dict count] == 0, @"NSDictionary can't open file %@", path);

		for (NSString *key in [data allKeys]) {
			id orig, import;

			orig = [data objectForKey:key];
			import = [dict objectForKey:key];

			STAssertNotNil(import, @"Missing key object for key \"%@\" in file \"%@\"", key, [path lastPathComponent]);
			STAssertEqualObjects(orig, import, @"Values don't match for key \"%@\" in file \"%@\"", key, [path lastPathComponent]);
		}
	}
}

- (void)testDataImport {
	[self runDataImportTestForSubdirectory:@"specific"];
	[self runDataImportTestForSubdirectory:@"arbitrary"];
}

- (void)runCommentImportTestForSubdirectory:(NSString *)subdir {
	NSArray *paths;

	paths = [[NSBundle bundleForClass:[self class]] pathsForResourcesOfType:@"strings" inDirectory:[NSString stringWithFormat:@"Test Data/Strings/%@", subdir]];
	STAssertTrue([paths count] > 0, @"Found no test files");

	for (NSString *path in paths) {
		NSDictionary *data, *dict, *comments;

		comments = nil;
		dict = [NSDictionary dictionaryWithStringsAtPath:path scannedComments:&comments scannedKeyOrder:NULL];
		STAssertNotNil(dict, @"Interpreter failed with no result for file %@", path);
		STAssertNotNil(comments, @"Interpreter failed with no comments for file %@", path);

		NSString *commentsPath;
		commentsPath = [[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"comments"];
		data = [NSDictionary dictionaryWithContentsOfFile:commentsPath];
		STAssertNotNil(data, @"NSDictionary can't open comments file %@", path);

		for (NSString *key in [data allKeys]) {
			id orig, import;

			orig = [data objectForKey:key];
			import = [comments objectForKey:key];

			STAssertNotNil([dict objectForKey:key], @"Missing key object for key \"%@\" in file \"%@\"", key, [path lastPathComponent]);
			STAssertTrue([orig isEqual:import], @"Comment values don't match for key \"%@\" in file \"%@\"", key, [path lastPathComponent]);
		}
	}
}

- (void)testCommentImport {
	[self runCommentImportTestForSubdirectory:@"comment"];
}

- (void)runFileCreationMimickryTestForSubdirectory:(NSString *)subdir {
	NSArray *paths;

	paths = [[NSBundle bundleForClass:[self class]] pathsForResourcesOfType:@"strings" inDirectory:[NSString stringWithFormat:@"Test Data/Strings/%@", subdir]];
	STAssertTrue([paths count] > 0, @"Found no test files");

	for (NSString *path in paths) {
		NSDictionary *data, *dict;

		// Write unchanged
		data = [NSDictionary dictionaryWithContentsOfFile:path];
		STAssertNotNil(data, @"Interpreter failed with no result for file %@", path);

		NSString *tmpPath = [@"/tmp/" stringByAppendingPathComponent:[path lastPathComponent]];
		STAssertTrue([data writeToPath:tmpPath mimicingFileAtPath:path], @"Writing failed at path %@", tmpPath);

		// Compare files
		NSString *writePath = [[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"write"];
		if (![[NSFileManager defaultManager] fileExistsAtPath:writePath])
			writePath = path;

		NSString *old = [NSString stringWithContentsOfFile:writePath usedEncoding:NULL error:NULL];
		NSString *new = [NSString stringWithContentsOfFile : tmpPath usedEncoding : NULL error : NULL];

		STAssertEqualObjects(old, new, @"Unchanged dict should create same file");

		// Write changes
		NSString *deltaPath = [[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"replace"];
		dict = [NSDictionary dictionaryWithContentsOfFile:deltaPath];
		STAssertNotNil(dict, @"Interpreter failed with no result for file %@", deltaPath);

		STAssertTrue([dict writeToPath:tmpPath mimicingFileAtPath:path], @"Writing failed at path %@", tmpPath);

		NSString *resultPath = [[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"result"];
		old = [NSString stringWithContentsOfFile:resultPath usedEncoding:NULL error:NULL];
		new = [NSString stringWithContentsOfFile : tmpPath usedEncoding : NULL error : NULL];

		STAssertEqualObjects(old, new, @"Changed dict should create result file");

		// Clean up
		STAssertTrue([[NSFileManager defaultManager] removeItemAtPath:tmpPath error:NULL], @"Cannot remove tmp file");
	}
}

- (void)testFileCreationMimickry {
	[self runFileCreationMimickryTestForSubdirectory:@"write"];
}

@end
