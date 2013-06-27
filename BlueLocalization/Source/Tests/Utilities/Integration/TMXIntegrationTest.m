//
//  TMXIntegrationTest.m
//  BlueLocalization
//
//  Created by max on 20.01.10.
//  Copyright 2010 The Soulmen. All rights reserved.
//

#import "TMXIntegrationTest.h"

#import <BlueLocalization/BLRTFDKeyObject.h>
#import <BlueLocalization/BLTMXDocument.h>


@implementation TMXIntegrationTest

- (void)setUp
{
	tmpPath = @"/tmp/loc-export.tmx";
}

- (void)tearDown
{
	[[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
}

- (NSString *)path:(NSString *)filename
{
	return [[NSBundle bundleForClass: [self class]] pathForResource:[filename stringByDeletingPathExtension] ofType:[filename pathExtension] inDirectory:@"Test Data/TMX"];
}

- (NSString *)translateString:(NSString *)text withKeyObjects:(NSArray *)objects source:(NSString *)src target:(NSString *)tar
{
	NSArray *segments = [text componentsSeparatedByString: @"\r\n"];
	
	NSMutableArray *newSegments = [NSMutableArray arrayWithCapacity: [segments count]];
	for (NSString *line in segments) {
		BLKeyObject *match = nil;
		
		for (BLKeyObject *key in objects) {
			if ([[key stringForLanguage: src] isEqual: line] && ![key isEmptyForLanguage: tar]) {
				match = key;
				break;
			}
		}
		
		if (match)
			[newSegments addObject: [match stringForLanguage: tar]];
		else
			[newSegments addObject: line];
	}
	
	return [newSegments componentsJoinedByString: @"\r\n"];
}

- (void)runSimpleTest:(NSString *)name source:(NSString *)source target:(NSString *)target
{
	NSString *tmxPath = [self path: [NSString stringWithFormat: @"ImportTest%@.tmx", name]];
	BLTMXDocument *document = [[BLTMXDocument alloc] initWithFileAtPath: tmxPath];
	
	// Read a text
	NSString *txtPath = [self path: [NSString stringWithFormat: @"ImportTest%@.txt", name]];
	NSString *text = [NSString stringWithContentsOfFile:txtPath usedEncoding:NULL error:NULL];
	
	// Translate it
	text = [self translateString:text withKeyObjects:document.keyObjects source:source target:target];
	
	NSString *refTxtPath = [self path: [NSString stringWithFormat: @"ImportTest%@_%@.txt", name, [BLLanguageTranslator RFCLanguageFromLanguageIdentifier: target]]];
	NSString *refText = [NSString stringWithContentsOfFile:refTxtPath usedEncoding:NULL error:NULL];
	STAssertEqualObjects(text, refText, @"Translation failed!");
	
	// RTF test still missing
}

- (void)testSimpleImports
{
	[self runSimpleTest:@"1A" source:@"en_US" target:@"fr_CA"];
	[self runSimpleTest:@"1B" source:@"en_US" target:@"fr_CA"];
	[self runSimpleTest:@"1C" source:@"en_US" target:@"fr_CA"];
	[self runSimpleTest:@"1D" source:@"en_US" target:@"en_GB"];
	[self runSimpleTest:@"1E" source:@"en_US" target:@"en_GB"];
	[self runSimpleTest:@"1F" source:@"en_US" target:@"en_GB"];
	[self runSimpleTest:@"1G" source:@"en_US" target:@"en_GB"];
	[self runSimpleTest:@"1H" source:@"en_US" target:@"en_GB"];
	[self runSimpleTest:@"1I" source:@"en_US" target:@"ja_JP"];
}

- (void)testImport1J
{
	// Import a file
	NSString *tmxPath = [self path: @"ImportTest1J_many.tmx"];
	BLTMXDocument *document = [[BLTMXDocument alloc] initWithFileAtPath: tmxPath];
	STAssertEquals([document.keyObjects count], (NSUInteger)3, @"3 objects should be imported");
	
	// Remove a key
	NSMutableArray *objects = [NSMutableArray arrayWithArray: document.keyObjects];
	[objects removeLastObject];
	document.keyObjects = objects;
	
	// Write out
	STAssertTrue([document writeToPath:tmpPath error:NULL], @"Write should not fail");
	
	// Read in again
	BLTMXDocument *document2 = [[BLTMXDocument alloc] initWithFileAtPath: tmpPath];
	STAssertEqualObjects(document.keyObjects, document2.keyObjects, @"The key objects should be the same!");
	
	// Read in reference
	NSString *tmxPath2 = [self path: @"ImportTest1J.tmx"];
	BLTMXDocument *document3 = [[BLTMXDocument alloc] initWithFileAtPath: tmxPath2];
	STAssertEqualObjects(document3.keyObjects, document2.keyObjects, @"The key objects should be the same!");
}

- (void)testImport1K
{
	NSString *tmxPath = [self path: @"ImportTest1K.tmx"];
	BLTMXDocument *document = [[BLTMXDocument alloc] initWithFileAtPath: tmxPath];
	STAssertEquals([document.keyObjects count], (NSUInteger)2, @"2 objects should be imported");
}

- (void)testImport1L
{
	// Import a file
	NSString *tmxPath = [self path: @"ImportTest1L.tmx"];
	BLTMXDocument *document = [[BLTMXDocument alloc] initWithFileAtPath: tmxPath];
	STAssertEquals([document.keyObjects count], (NSUInteger)1, @"1 object should be imported");
	
	// Write out
	STAssertTrue([document writeToPath:tmpPath error:NULL], @"Write should not fail");
	
	// Read in again
	BLTMXDocument *document2 = [[BLTMXDocument alloc] initWithFileAtPath: tmpPath];
	STAssertEqualObjects(document.keyObjects, document2.keyObjects, @"The key objects should be the same!");
}

- (void)testCreation
{
	// Import a file
	NSString *tmxPath = [self path: @"ImportTest1J_many.tmx"];
	BLTMXDocument *document = [[BLTMXDocument alloc] initWithFileAtPath: tmxPath];
	STAssertEquals([document.keyObjects count], (NSUInteger)3, @"3 objects should be imported");
	
	// Create a new
	BLTMXDocument *newDocument = [[BLTMXDocument alloc] initBlankDocument];
	newDocument.keyObjects = document.keyObjects;
	STAssertTrue([newDocument writeToPath:tmpPath error:NULL], @"Write should not fail");
	
	// Read in again
	BLTMXDocument *document2 = [[BLTMXDocument alloc] initWithFileAtPath: tmpPath];
	STAssertEqualObjects(document.keyObjects, document2.keyObjects, @"The key objects should be the same!");
}

- (void)testImportLegacy
{
	// Import a file
	NSString *tmxPath = [self path: @"Legacy.tmx"];
	BLTMXDocument *document = [[BLTMXDocument alloc] initWithFileAtPath: tmxPath];
	STAssertEquals([document.keyObjects count], (NSUInteger)3, @"3 objects should be imported");
	
	for (BLKeyObject *keyObject in document.keyObjects) {
		STAssertTrue([keyObject isKindOfClass: [BLRTFDKeyObject class]], @"Wrong class of keys");
		STAssertTrue([[keyObject stringForLanguage: @"en_GB"] length] > 0, @"No english string found");
		STAssertTrue([[keyObject stringForLanguage: @"de_DE"] length] > 0, @"No german string found");
	}
}

- (void)testRTFSupport
{
	// Create a RTF key object
	BLRTFDKeyObject *keyObject = [BLRTFDKeyObject keyObjectWithKey: nil];
	[keyObject setObject:[[NSAttributedString alloc] initWithPath:[self path: @"ImportTest2B.rtf"] documentAttributes:NULL] forLanguage:@"en"];
	[keyObject setObject:[[NSAttributedString alloc] initWithPath:[self path: @"ImportTest2B_fr-ca.rtf"] documentAttributes:NULL] forLanguage:@"fr_CA"];
	
	// Create a document and write it
	BLTMXDocument *document = [[BLTMXDocument alloc] initBlankDocument];
	document.keyObjects = [NSArray arrayWithObject: keyObject];
	STAssertTrue([document writeToPath:tmpPath error:NULL], @"Write should not fail");
	
	// Read in again
	BLTMXDocument *document2 = [[BLTMXDocument alloc] initWithFileAtPath: tmpPath];
	STAssertEqualObjects(document.keyObjects, document2.keyObjects, @"The key objects should be the same!");
}


@end


