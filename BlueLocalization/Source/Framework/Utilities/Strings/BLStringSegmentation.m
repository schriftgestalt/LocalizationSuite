/*!
 @header
 BLStringSegmentation.m
 Created by Max on 17.02.10.
 
 @copyright 2010 Localization Suite. All rights reserved.
 */

#import "BLStringSegmentation.h"

@implementation NSString (BLStringSegmentation)

- (NSArray *)segmentsForType:(BLSegmentationType)type delimiters:(NSArray **)delimis
{
	NSMutableArray *segments = [NSMutableArray array];
	NSMutableArray *delimiters = [NSMutableArray array];
	NSEnumerator *parts = [[self splitForType: type] objectEnumerator];
	
	// Leading delimiter
	[delimiters addObject: [parts nextObject]];
	
	// (Sequence.Delimiter)*
	NSString *segment;
	while ((segment = [parts nextObject])) {
		[segments addObject: segment];
		[delimiters addObject: [parts nextObject]];
	}
	
	// Finished
	if (delimis)
		*delimis = delimiters;
	return segments;
}

+ (NSString *)stringByJoiningSegments:(NSArray *)segments withDelimiters:(NSArray *)delimiters
{
	NSMutableString *string = [NSMutableString string];
	NSEnumerator *segEnum = [segments objectEnumerator];
	NSEnumerator *delEnum = [delimiters objectEnumerator];
	
	// Leading delimiter
	[string appendString: [delEnum nextObject]];
	
	// (Sequence.Delimiter)*
	NSString *segment;
	while ((segment = [segEnum nextObject])) {
		[string appendString: segment];
		[string appendString: [delEnum nextObject]];
	}
	
	// Finished
	return string;
}

- (NSArray *)splitForType:(BLSegmentationType)type
{
	// Empty strings have only a single delimiter
	if (![self length])
		return [NSArray arrayWithObject: @""];
		
	// Set the appropriate character classes for each type
	NSCharacterSet *splitter = nil;
	NSCharacterSet *spacer = nil;
	NSCharacterSet *delimiter = nil;
	
	switch (type) {
		case BLDetailedSegmentation:
			splitter = [NSCharacterSet punctuationCharacterSet];
			spacer = [NSCharacterSet whitespaceAndNewlineCharacterSet];
			break;
		case BLWordSegmentation:
			spacer = [NSCharacterSet whitespaceAndNewlineCharacterSet];
			break;
		case BLSentenceSegmentation:
			delimiter = [NSCharacterSet characterSetWithCharactersInString: @".:!?"];
			spacer = [NSCharacterSet whitespaceAndNewlineCharacterSet];
			break;
		case BLParagraphSegmentation:
			spacer = [NSCharacterSet newlineCharacterSet];
			break;
		default:
			return [NSArray arrayWithObjects: @"", self, @"", nil];
	}
	
	// The scanning state
	NSMutableArray *parts;	// the produced parts
	NSUInteger pos;			// the scanning position
	NSMutableString *scan;	// the currently scanned substring
	BOOL wasDelimiter;		// last character was a delimiter
	BOOL wasSpacer;			// last character was a spacer
	BOOL lastWasDelimiter;	// last non-spacer character was a delimiter
	
	// Init
	parts = [NSMutableArray array];
	scan = [NSMutableString string];
	pos = 0;
	
	wasSpacer = YES;
	wasDelimiter = NO;
	lastWasDelimiter = YES;
	
	/* The state is initialized in a waysuch that, if we start with a
	 sequence of spacers it will form the leading spacer sequence and
	 that othwerwise an empty string will be put instead (aka no spacer).
	 */
	
	// Scanning loop
	while (pos < [self length]) {
		unichar chr = [self characterAtIndex: pos];
		BOOL isSplitter = (splitter) && [splitter characterIsMember: chr];
		BOOL isDelimiter = (!delimiter) || [delimiter characterIsMember: chr];
		BOOL isSpacer = (!spacer) || [spacer characterIsMember: chr];
		BOOL emit = NO;
		
		// At the end of a delimiter sequence
		if (wasDelimiter && !isDelimiter && isSpacer)
			emit = YES;
		
		// Jump into a spacer -> split if the previous was a delimiter
		if (!wasSpacer && isSpacer && wasDelimiter)
			emit = YES;
		
		// Jump out of spacer -> split if char before spacer sequence was delimiter
		if (wasSpacer && !isSpacer && lastWasDelimiter)
			emit = YES;
		
		// Emit and append
		if (emit) {
			[parts addObject: scan];
			scan = [NSMutableString string];
		}
		// When finding a splitter
		if (isSplitter) {
			if (!emit) {
				[parts addObject: scan];
				[parts addObject: @""];
			}
			
			[parts addObject: [NSString stringWithFormat: @"%C", chr]];
			isSpacer = YES;
			
			scan = [NSMutableString string];
		}
		else {
			[scan appendFormat: @"%C", chr];
		}
		
		// Remember stuff
		wasDelimiter = isDelimiter;
		wasSpacer = isSpacer;
		if (!isSpacer)
			lastWasDelimiter = wasDelimiter;
		
		// Move
		pos++;
	}
	
	// Add the rest
	[parts addObject: scan];
	if (!wasSpacer || !lastWasDelimiter)
		[parts addObject: @""];
	
	return parts;
}

@end
