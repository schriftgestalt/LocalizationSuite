//
//  StringSegmentationTest.m
//  BlueLocalization
//
//  Created by max on 17.02.10.
//  Copyright 2010 The Soulmen. All rights reserved.
//

#import "StringSegmentationTest.h"

@implementation StringSegmentationTest

- (void)testSplitting {
	NSString *string = @"\tThis is a. text\nwith\n\r\nseveral \t newlines... - Or what not?!? \n";

	// Paragraph
	NSArray *parts = [string splitForType:BLParagraphSegmentation];
	STAssertEqualObjects(string, [parts componentsJoinedByString:@""], @"Strings do not match");

	NSArray *goal = [NSArray arrayWithObjects:
								 @"",
								 @"\tThis is a. text", @"\n",
								 @"with", @"\n\r\n",
								 @"several \t newlines... - Or what not?!? ", @"\n",
								 nil];
	STAssertEquals([parts count], [goal count], @"Wrong number of paragraphs");
	STAssertEqualObjects(parts, goal, @"Parts do not match");

	// Sentence
	parts = [string splitForType:BLSentenceSegmentation];
	STAssertEqualObjects(string, [parts componentsJoinedByString:@""], @"Strings do not match");
	goal = [NSArray arrayWithObjects:
						@"\t",
						@"This is a.", @" ",
						@"text\nwith\n\r\nseveral \t newlines...", @" ",
						@"- Or what not?!?", @" \n",
						nil];
	STAssertEquals([parts count], [goal count], @"Wrong number of sentences");
	STAssertEqualObjects(parts, goal, @"Parts do not match");

	// Word
	parts = [string splitForType:BLWordSegmentation];
	STAssertEqualObjects(string, [parts componentsJoinedByString:@""], @"Strings do not match");
	goal = [NSArray arrayWithObjects:
						@"\t",
						@"This", @" ",
						@"is", @" ",
						@"a.", @" ",
						@"text", @"\n",
						@"with", @"\n\r\n",
						@"several", @" \t ",
						@"newlines...", @" ",
						@"-", @" ",
						@"Or", @" ",
						@"what", @" ",
						@"not?!?", @" \n",
						nil];
	STAssertEquals([parts count], [goal count], @"Wrong number of words");
	STAssertEqualObjects(parts, goal, @"Parts do not match");

	// Detailed
	parts = [string splitForType:BLDetailedSegmentation];
	STAssertEqualObjects(string, [parts componentsJoinedByString:@""], @"Strings do not match");
	goal = [NSArray arrayWithObjects:
						@"\t",
						@"This", @" ",
						@"is", @" ",
						@"a", @"",
						@".", @" ",
						@"text", @"\n",
						@"with", @"\n\r\n",
						@"several", @" \t ",
						@"newlines", @"",
						@".", @"",
						@".", @"",
						@".", @" ",
						@"-", @" ",
						@"Or", @" ",
						@"what", @" ",
						@"not", @"",
						@"?", @"",
						@"!", @"",
						@"?", @" \n",
						nil];
	STAssertEquals([parts count], [goal count], @"Wrong number of detailed segments");
	STAssertEqualObjects(parts, goal, @"Parts do not match");
}

- (void)testSegmentation {
	NSString *string = @"\tThis is a. text\nwith several \t newlines... ";

	// Paragraph
	NSArray *delimiters;
	NSArray *segments = [string segmentsForType:BLParagraphSegmentation delimiters:&delimiters];
	STAssertEqualObjects(string, [NSString stringByJoiningSegments:segments withDelimiters:delimiters], @"Strings do not match");

	NSArray *gSegs = [NSArray arrayWithObjects:
								  @"\tThis is a. text",
								  @"with several \t newlines... ",
								  nil];
	NSArray *gDels = [NSArray arrayWithObjects:
								  @"", @"\n", @"",
								  nil];
	STAssertEqualObjects(segments, gSegs, @"Segments don't match");
	STAssertEqualObjects(delimiters, gDels, @"Delimiters don't match");

	// Sentence
	segments = [string segmentsForType:BLSentenceSegmentation delimiters:&delimiters];
	STAssertEqualObjects(string, [NSString stringByJoiningSegments:segments withDelimiters:delimiters], @"Strings do not match");

	gSegs = [NSArray arrayWithObjects:
						 @"This is a.",
						 @"text\nwith several \t newlines...",
						 nil];
	gDels = [NSArray arrayWithObjects:
						 @"\t", @" ", @" ",
						 nil];
	STAssertEqualObjects(segments, gSegs, @"Segments don't match");
	STAssertEqualObjects(delimiters, gDels, @"Delimiters don't match");

	// Word
	segments = [string segmentsForType:BLWordSegmentation delimiters:&delimiters];
	STAssertEqualObjects(string, [NSString stringByJoiningSegments:segments withDelimiters:delimiters], @"Strings do not match");

	gSegs = [NSArray arrayWithObjects:
						 @"This",
						 @"is",
						 @"a.",
						 @"text",
						 @"with",
						 @"several",
						 @"newlines...",
						 nil];
	gDels = [NSArray arrayWithObjects:
						 @"\t",
						 @" ",
						 @" ",
						 @" ",
						 @"\n",
						 @" ",
						 @" \t ",
						 @" ",
						 nil];
	STAssertEqualObjects(segments, gSegs, @"Segments don't match");
	STAssertEqualObjects(delimiters, gDels, @"Delimiters don't match");

	// Detailed
	segments = [string segmentsForType:BLDetailedSegmentation delimiters:&delimiters];
	STAssertEqualObjects(string, [NSString stringByJoiningSegments:segments withDelimiters:delimiters], @"Strings do not match");

	gSegs = [NSArray arrayWithObjects:
						 @"This",
						 @"is",
						 @"a",
						 @".",
						 @"text",
						 @"with",
						 @"several",
						 @"newlines",
						 @".",
						 @".",
						 @".",
						 nil];
	gDels = [NSArray arrayWithObjects:
						 @"\t",
						 @" ",
						 @" ",
						 @"",
						 @" ",
						 @"\n",
						 @" ",
						 @" \t ",
						 @"",
						 @"",
						 @"",
						 @" ",
						 nil];
	STAssertEqualObjects(segments, gSegs, @"Segments don't match");
	STAssertEqualObjects(delimiters, gDels, @"Delimiters don't match");
}

- (void)testDetailled {
	STAssertEqualObjects([@"word" splitForType:BLDetailedSegmentation], ([NSArray arrayWithObjects:@"", @"word", @"", nil]), @"String split wrongly");
	STAssertEqualObjects([@" word " splitForType:BLDetailedSegmentation], ([NSArray arrayWithObjects:@" ", @"word", @" ", nil]), @"String split wrongly");
	STAssertEqualObjects([@" word s " splitForType:BLDetailedSegmentation], ([NSArray arrayWithObjects:@" ", @"word", @" ", @"s", @" ", nil]), @"String split wrongly");

	STAssertEqualObjects([@"a. text" splitForType:BLDetailedSegmentation], ([NSArray arrayWithObjects:@"", @"a", @"", @".", @" ", @"text", @"", nil]), @"String split wrongly");
	STAssertEqualObjects([@"(Hallo)" splitForType:BLDetailedSegmentation], ([NSArray arrayWithObjects:@"", @"(", @"", @"Hallo", @"", @")", @"", nil]), @"String split wrongly");
	STAssertEqualObjects([@"( Hallo?)" splitForType:BLDetailedSegmentation], ([NSArray arrayWithObjects:@"", @"(", @" ", @"Hallo", @"", @"?", @"", @")", @"", nil]), @"String split wrongly");
}

- (void)testSentences {
	STAssertEqualObjects([@" word s\n" splitForType:BLParagraphSegmentation], ([NSArray arrayWithObjects:@"", @" word s", @"\n", nil]), @"String split wrongly");
	STAssertEqualObjects([@" word s.\n" splitForType:BLSentenceSegmentation], ([NSArray arrayWithObjects:@" ", @"word s.", @"\n", nil]), @"String split wrongly");
	STAssertEqualObjects([@" word s\n" splitForType:BLSentenceSegmentation], ([NSArray arrayWithObjects:@" ", @"word s\n", @"", nil]), @"String split wrongly");
	STAssertEqualObjects([@"wtf.is" splitForType:BLSentenceSegmentation], ([NSArray arrayWithObjects:@"", @"wtf.is", @"", nil]), @"String split wrongly");
	STAssertEqualObjects([@"wtf. is" splitForType:BLSentenceSegmentation], ([NSArray arrayWithObjects:@"", @"wtf.", @" ", @"is", @"", nil]), @"String split wrongly");
}

- (void)testCornerCases {
	STAssertEqualObjects([@"" splitForType:BLDetailedSegmentation], [NSArray arrayWithObject:@""], @"Empty string split wrongly");
}

- (void)testUnicodeCompliance {
	STAssertEqualObjects([@"wählen" splitForType:BLDetailedSegmentation], ([NSArray arrayWithObjects:@"", @"wählen", @"", nil]), @"String split wrongly");
}

@end
