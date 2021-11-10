//
//  DocumentCompressionTest.m
//  BlueLocalization
//
//  Created by Max Seelemann on 02.11.10.
//  Copyright 2010 The Soulmen. All rights reserved.
//

#import "DocumentCompressionTest.h"

@implementation DocumentCompressionTest

- (void)testDatabaseCompression {
	BLDatabaseDocument *document1 = [[BLDatabaseDocument alloc] init];

	NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"OtherUser" withExtension:@"ldb" subdirectory:@"Test Data/Documents/"];
	STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[url path]], @"Missing file %@", [[url path] lastPathComponent]);
	[document1 readFromURL:url ofType:nil error:NULL];

	// Check file
	STAssertTrue([document1.bundles count] > 0, @"No bundles");
	STAssertTrue([document1.languages count] > 0, @"No languages");

	// Tmp path
	NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.ldb"];

	// Enable compression, save
	[document1.preferences setObject:[NSNumber numberWithBool:YES] forKey:BLDocumentSaveCompressedKey];
	STAssertTrue([document1 writeToURL:[NSURL fileURLWithPath:path] ofType:nil error:NULL], @"Writing failed");

	BOOL directory = NO;
	STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory], @"Missing file");
	STAssertFalse(directory, @"Should NOT be a directory");

	// Read in
	BLDatabaseDocument *document2 = [[BLDatabaseDocument alloc] init];
	[document2 readFromURL:[NSURL fileURLWithPath:path] ofType:nil error:NULL];
	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];

	// Check file
	STAssertEqualObjects(document1.bundles, document2.bundles, @"Lost data");
	STAssertEqualObjects(document1.languages, document2.languages, @"Lost data");

	// Disable encryption, save
	[document2.preferences setObject:[NSNumber numberWithBool:NO] forKey:BLDocumentSaveCompressedKey];
	STAssertTrue([document2 writeToURL:[NSURL fileURLWithPath:path] ofType:nil error:NULL], @"Writing failed");

	STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory], @"Missing file");
	STAssertTrue(directory, @"Should be a directory");

	// Read in
	BLDatabaseDocument *document3 = [[BLDatabaseDocument alloc] init];
	[document3 readFromURL:[NSURL fileURLWithPath:path] ofType:nil error:NULL];
	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];

	// Check file
	STAssertEqualObjects(document1.bundles, document3.bundles, @"Lost data");
	STAssertEqualObjects(document1.languages, document3.languages, @"Lost data");

	// Enable compression, save
	[document3.preferences setObject:[NSNumber numberWithBool:YES] forKey:BLDocumentSaveCompressedKey];
	STAssertTrue([document3 writeToURL:[NSURL fileURLWithPath:path] ofType:nil error:NULL], @"Writing failed");

	STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory], @"Missing file");
	STAssertFalse(directory, @"Should NOT be a directory");

	// Read in
	BLDatabaseDocument *document4 = [[BLDatabaseDocument alloc] init];
	[document4 readFromURL:[NSURL fileURLWithPath:path] ofType:nil error:NULL];
	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];

	// Check file
	STAssertEqualObjects(document1.bundles, document4.bundles, @"Lost data");
	STAssertEqualObjects(document1.languages, document4.languages, @"Lost data");
}

- (void)testLocalizerCompression {
	BLLocalizerDocument *document1 = [[BLLocalizerDocument alloc] init];

	NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"OtherUser" withExtension:@"ldb" subdirectory:@"Test Data/Documents/"];
	STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[url path]], @"Missing file %@", [[url path] lastPathComponent]);
	[document1 readFromURL:url ofType:nil error:NULL];

	// Check file
	STAssertTrue([document1.bundles count] > 0, @"No bundles");
	STAssertTrue([document1.languages count] > 0, @"No languages");

	// Tmp path
	NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.ldb"];

	// Enable compression, save
	[document1.preferences setObject:[NSNumber numberWithBool:YES] forKey:BLDocumentSaveCompressedKey];
	STAssertTrue([document1 writeToURL:[NSURL fileURLWithPath:path] ofType:nil error:NULL], @"Writing failed");

	BOOL directory = NO;
	STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory], @"Missing file");
	STAssertFalse(directory, @"Should NOT be a directory");

	// Read in
	BLLocalizerDocument *document2 = [[BLLocalizerDocument alloc] init];
	[document2 readFromURL:[NSURL fileURLWithPath:path] ofType:nil error:NULL];
	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];

	// Check file
	STAssertEqualObjects(document1.bundles, document2.bundles, @"Lost data");
	STAssertEqualObjects(document1.languages, document2.languages, @"Lost data");

	// Disable encryption, save
	[document2.preferences setObject:[NSNumber numberWithBool:NO] forKey:BLDocumentSaveCompressedKey];
	STAssertTrue([document2 writeToURL:[NSURL fileURLWithPath:path] ofType:nil error:NULL], @"Writing failed");

	STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory], @"Missing file");
	STAssertTrue(directory, @"Should be a directory");

	// Read in
	BLLocalizerDocument *document3 = [[BLLocalizerDocument alloc] init];
	[document3 readFromURL:[NSURL fileURLWithPath:path] ofType:nil error:NULL];
	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];

	// Check file
	STAssertEqualObjects(document1.bundles, document3.bundles, @"Lost data");
	STAssertEqualObjects(document1.languages, document3.languages, @"Lost data");

	// Enable compression, save
	[document3.preferences setObject:[NSNumber numberWithBool:YES] forKey:BLDocumentSaveCompressedKey];
	STAssertTrue([document3 writeToURL:[NSURL fileURLWithPath:path] ofType:nil error:NULL], @"Writing failed");

	STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory], @"Missing file");
	STAssertFalse(directory, @"Should NOT be a directory");

	// Read in
	BLLocalizerDocument *document4 = [[BLLocalizerDocument alloc] init];
	[document4 readFromURL:[NSURL fileURLWithPath:path] ofType:nil error:NULL];
	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];

	// Check file
	STAssertEqualObjects(document1.bundles, document4.bundles, @"Lost data");
	STAssertEqualObjects(document1.languages, document4.languages, @"Lost data");
}

@end
