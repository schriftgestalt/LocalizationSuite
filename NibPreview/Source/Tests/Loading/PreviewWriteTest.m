//
//  PreviewWriteTest.m
//  NibPreview
//
//  Created by max on 27.01.10.
//  Copyright 2010 The Soulmen. All rights reserved.
//

#import "PreviewWriteTest.h"

@implementation PreviewWriteTest

- (void)setUp {
	srcPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"complex-1" ofType:@"xib" inDirectory:@"Test Data/Builder/complex"];
	outPath = @"/tmp/export.xib";

	// Load strings
	fileObject = [BLFileObject fileObjectWithPath:srcPath];
	BLFileInterpreter *interpreter = [BLFileInterpreter interpreterForFileObject:fileObject];
	[interpreter activateOptions:BLFileInterpreterAllowChangesToKeyObjects];
	STAssertTrue([interpreter interpreteFile:srcPath intoObject:fileObject withLanguage:@"en" referenceLanguage:nil], @"Cannot import file!");

	// Load preview
	preview = [[NPPreview alloc] initWithNibAtPath:srcPath];
	[preview loadNib];
}

- (void)tearDown {
	[[NSFileManager defaultManager] removeItemAtPath:outPath error:NULL];
}

- (void)testWriteNothing {
	// No file should fail
	STAssertTrue([preview writeToNibAtPath:outPath actions:0], @"No existing file to be updated");

	// No change, and should not fail
	STAssertTrue([preview writeToNibAtPath:outPath actions:0], @"Write should not fail");
	STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:outPath], @"Nothing should change");

	// Associationg should still change nothing
	preview.associatedFileObject = fileObject;
	STAssertTrue([preview writeToNibAtPath:outPath actions:0], @"Write should not fail");
	STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:outPath], @"Nothing should change");
}

- (void)testWriteStringsFileChanges {
	// Write strings without strings
	STAssertTrue([preview writeToNibAtPath:outPath actions:NPPreviewWriteStrings], @"Write should not fail");
	STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:outPath], @"Nothing should change");

	// Associationg should still change nothing
	preview.associatedFileObject = fileObject;
	preview.displayLanguage = @"de";
	STAssertTrue([preview writeToNibAtPath:outPath actions:NPPreviewWriteStrings | NPPreviewUpdateFile], @"Write should not fail");
	STAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:outPath], @"Nothing should change");

	// Now it should change
	[[fileObject objectForKey:@"13.title"] setObject:@"Knopf" forLanguage:@"de"];
	STAssertTrue([preview writeToNibAtPath:outPath actions:NPPreviewWriteStrings], @"Write should not fail");
	STAssertFalse([[NSFileManager defaultManager] contentsEqualAtPath:srcPath andPath:outPath], @"Something should have changed");

	// Check contents
	BLFileObject *other = [BLFileObject fileObjectWithPath:outPath];
	BLFileInterpreter *interpreter = [BLFileInterpreter interpreterForFileObject:other];
	[interpreter activateOptions:BLFileInterpreterAllowChangesToKeyObjects];
	STAssertTrue([interpreter interpreteFile:outPath intoObject:other withLanguage:@"de" referenceLanguage:nil], @"Cannot import file!");

	for (BLKeyObject *key in other.objects) {
		BLKeyObject *orig = [fileObject objectForKey:key.key];
		STAssertNotNil(orig, @"Missing matching original key");

		if (![orig isEmptyForLanguage:@"de"])
			STAssertEqualObjects([orig objectForLanguage:@"de"], [key objectForLanguage:@"de"], @"Strings not matching");
		else
			STAssertEqualObjects([orig objectForLanguage:@"en"], [key objectForLanguage:@"de"], @"Strings not matching");
	}
}

- (void)testWriteFramesFileChanges {
	// Modify a frame
	NSButton *button = [[preview objectForNibObjectID:@"8"] original];

	NSRect frame = [button frame];
	frame.size.width += 50;
	[button setFrame:frame];

	// Modify another frame
	NSWindow *window = [[preview objectForNibObjectID:@"5"] original];

	frame = [window frame];
	frame.size.width += 50;
	[window setFrame:frame display:NO];

	// Write changes
	STAssertTrue([preview writeToNibAtPath:outPath actions:NPPreviewWriteFrames], @"Write should not fail");
	STAssertFalse([[NSFileManager defaultManager] contentsEqualAtPath:srcPath andPath:outPath], @"Something should have changed");

	// Load written preview
	NPPreview *preview2 = [[NPPreview alloc] initWithNibAtPath:outPath];
	[preview2 loadNib];

	// Check frames
	STAssertEquals([button frame], [[[preview2 objectForNibObjectID:@"8"] original] frame], @"Frame not written!");
	STAssertEquals([window frame], [[[preview2 objectForNibObjectID:@"5"] original] frame], @"Frame not written!");
}

@end
