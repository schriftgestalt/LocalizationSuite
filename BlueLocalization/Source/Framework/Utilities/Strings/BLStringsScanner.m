/*!
 @header
 BLStringsScanner.h
 Created by Max Seelemann on 07.04.09.
 
 @copyright 2009 The Blue Technologies Group. All rights reserved.
 */

#import "BLStringsScanner.h"

/*!
 @abstract Internal methods of BLStringsScanner used to scan various parts of a strings file.
 */
@interface BLStringsScanner ()

/*!
 @abstract Internal scan method, scnas AND updates at the same time.
 */
+ (BOOL)_processScanString:(NSString *)string result:(NSString **)outString targetDictionary:(NSMutableDictionary *)strings withComments:(NSMutableDictionary *)comments andKeyOrder:(NSMutableArray *)keys replacements:(NSDictionary *)replacements;

/*!
 @abstract Scanns comments using the given scanner.
 @return A string containg the comment or nil if no comment was found at the current location.
 */
+ (NSString *)_scannerScanComments:(NSScanner *)scanner;

/*!
 @abstract Scanns a string using the given scanner.
 @return The scanned string or nil if no key was found at the current location.
 */
+ (NSString *)_scannerScanString:(NSScanner *)scanner;

/*!
 @abstract Post-processes a scanned string.
 @discussion Applies standard and unicode replacements on a string after reading it from a file. "string" must be non-nil or an exception will be thrown.
 */
+ (NSString *)_processString:(NSString *)string;

/*!
 @abstract Post-processes a previously scanned comment.
 @discussion This will apply the standard replacements and unicode replacements as in _processString. In addition, it will be trimmed and formatted as appropriate. "comment" must be non-nil or an exception will be thrown.
 */
+ (NSString *)_processComment:(NSString *)comment;

/*!
 @abstract Pre-processes a string for writing.
 @discussion Applies standard and unicode replacements on a string before writing it to a file. "string" must be non-nil or an exception will be thrown.
 */
+ (NSString *)_prepareString:(NSString *)string;


@end

@implementation BLStringsScanner

+ (BOOL)scanString:(NSString *)string toDictionary:(NSMutableDictionary *)strings withComments:(NSMutableDictionary *)comments andKeyOrder:(NSMutableArray *)keys
{
	return [self _processScanString:string result:NULL targetDictionary:strings withComments:comments andKeyOrder:keys replacements:nil];
}

+ (NSString *)scanAndUpdateString:(NSString *)string withReplacementDictionary:(NSDictionary *)strings
{
	NSString *result = nil;
	if ([self _processScanString:string result:&result targetDictionary:nil withComments:nil andKeyOrder:nil replacements:strings])
		return result;
	else
		return nil;
}

#pragma mark - Scanning

+ (BOOL)_processScanString:(NSString *)string result:(NSString **)outString targetDictionary:(NSMutableDictionary *)strings withComments:(NSMutableDictionary *)comments andKeyOrder:(NSMutableArray *)keys replacements:(NSDictionary *)replacements
{
	// Initialization
	NSScanner *scanner = [NSScanner scannerWithString: string];
	NSUInteger scanLocation = 0;
	NSUInteger updateLocation = 0;
	NSUInteger skips = 0;
	
	NSMutableString *result = nil;
	if (outString)
		result = [NSMutableString stringWithCapacity: [string length]];
	
	// Scanning loop, each run should be one key/value pair
	while (![scanner isAtEnd]) {
		NSString *key, *comment, *value;
		
		// Scan comments and key
		comment = [self _scannerScanComments: scanner];
		key = [self _scannerScanString: scanner];
		
		// Check for the = between key and value
		if (key && ![scanner scanString:@"=" intoString:NULL])
			BLLog(BLLogWarning, @"Expected a \"=\" after a key... Ignored. (line/position: %d/%d)", [scanner currentLine], [scanner currentOffsetInLine]);
		
		// Output structure
		if (result && [scanner scanLocation] != updateLocation) {
			[result appendString: [string substringWithRange: NSMakeRange(updateLocation, [scanner scanLocation] - updateLocation)]];
			updateLocation = [scanner scanLocation];
		}
		
		// Scan the value
		value = [self _scannerScanString: scanner];
		
		// Output value
		if (result && [scanner scanLocation] != updateLocation) {
			if ([replacements objectForKey: key])
				// Replacement found			
				[result appendFormat: @" \"%@\"", [self _prepareString: [replacements objectForKey: key]]];
			else
				// Use original
				[result appendString: [string substringWithRange: NSMakeRange(updateLocation, [scanner scanLocation] - updateLocation)]];
			
			updateLocation = [scanner scanLocation];
		}
		
		// Check for the ; at the pair end
		if ((value || key) && ![scanner scanString:@";" intoString:NULL])
			BLLog(BLLogWarning, @"Expected a \";\" after a value... Ignored. (line/position: %d/%d)", [scanner currentLine], [scanner currentOffsetInLine]);
		
		if (key) {
			[keys addObject: key];
			
			if (value)
				[strings setObject:value forKey:key];
			if (comment)
				[comments setObject:comment forKey:key];
		}
		
		// Liveness criteria
		if (scanLocation == [scanner scanLocation]) {
			// Abort on too many errors
			if (skips > 10) {
				BLLog(BLLogError, @"Strings scanner hung while scanning. Liveness criteria violated, aborting!");
				return NO;
			}
			
			// Try to skip several times
			BLLog(BLLogWarning, @"Skipping problematic character at line/position %d/%d.", [scanner currentLine], [scanner currentOffsetInLine]);
			[scanner setScanLocation: [scanner scanLocation]+1];
			skips++;
		}
		scanLocation = [scanner scanLocation];
	}
	
	// Output remainder
	if (result && [string length] != updateLocation)
		[result appendString: [string substringWithRange: NSMakeRange(updateLocation, [string length] - updateLocation)]];
	
	// Set output
	if (outString)
		*outString = [NSString stringWithString: result];
	
	// We're done
	return YES;
}

+ (NSString *)_scannerScanComments:(NSScanner *)scanner
{
	NSString *comment = nil;
	
	// Check for a comment start
	while (![scanner isAtEnd] && [scanner scanString:@"/" intoString:NULL]) {
		NSString *scan = nil;
		
		// A single line comment
		if ([scanner scanString:@"/" intoString:NULL]) {
			// Scan to the end of the line
			[scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&scan];
		}
		// A multi line comment
		else if ([scanner scanString:@"*" intoString:NULL]) {
			// Scan to to the end of the comment
			[scanner scanUpToString:@"*/" intoString:&scan];
			[scanner scanString:@"*/" intoString:NULL];
		}
		// No comment, just a slash?
		else {
			BLLog(BLLogWarning, @"Found a single unquoted slash at line/position %d/%d while scanning strings file... Ignored.", [scanner currentLine], [scanner currentOffsetInLine]);
			continue;
		}
		
		// Composite all found comments into a single one
		comment = (!comment) ? scan : [comment stringByAppendingFormat: @"\n%@", scan];
	}
	
	return (comment) ? [self _processComment: comment] : nil;
}

+ (NSString *)_scannerScanString:(NSScanner *)scanner
{
	// Our string starts with a quote
	if ([scanner scanString:@"\"" intoString:NULL]) {
		NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString: @"\\\""];
		
		// Set the scanner to be exact
		NSCharacterSet *skippedSet = [scanner charactersToBeSkipped];
		[scanner setCharactersToBeSkipped: nil];
		
		// The string is empty
		if ([scanner scanString:@"\"" intoString:NULL]) {
			// Reset the scanner to it's previous state
			[scanner setCharactersToBeSkipped: skippedSet];
			// Return an empty result
			return [self _processString: @""];
		}
		
		// Regular non-empty string scan
		NSMutableString *string = [NSMutableString string];
		NSString *scan = nil;
		
		while (![scanner isAtEnd]
			   && ([[scanner string] characterAtIndex: [scanner scanLocation]] == '\\'
				   || [scanner scanUpToCharactersFromSet:inStringSet intoString:&scan])) {
			if (scan)
				[string appendString: scan];
			
			// Check for a escape sequence
			if ([scanner scanString:@"\\" intoString:NULL]) {
				// Skip the escaped character
				[scanner setScanLocation: [scanner scanLocation] + 1];
				scan = [[scanner string] substringWithRange: NSMakeRange([scanner scanLocation]-2, 2)];
				
				// Append the escape sequence
				[string appendString: scan];
			}
			// Check for the quote end
			if ([scanner scanString:@"\"" intoString:NULL]) {
				// We're finished
				break;
			}
			
			scan = nil;
		}
		
		// Reset the scanner to it's previous state
		[scanner setCharactersToBeSkipped: skippedSet];
		
		return [self _processString: string];
	}
	// Try to find a single unquoted string
	else {
		NSMutableCharacterSet *stringSet = [NSMutableCharacterSet alphanumericCharacterSet];
		[stringSet addCharactersInString: @":.-_"];
		
		NSString *scan = nil;
		if ([scanner scanCharactersFromSet:stringSet intoString:&scan] && scan)
			return [self _processString: scan];
		else
			return nil;
	}
}


#pragma mark - Processing

+ (NSString *)_processString:(NSString *)string
{
	NSMutableString *mString = [NSMutableString stringWithString: string];
	
	// Decode Unicode escape sequences
	[mString replaceEscapedUnicodeCharacters];
	
	// Apply string replacements
	[mString applyReplacementDictionary:BLStandardStringReplacements reverseDirection:NO];
	
	return [NSString stringWithString: mString];
}

+ (NSString *)_processComment:(NSString *)comment
{
	NSMutableString *mString = [NSMutableString stringWithString: [self _processString: comment]];
	
	// Trim whitespace
	CFStringTrimWhitespace((__bridge CFMutableStringRef) mString);
	
	// Drop leading whitespace characters
	[mString replaceOccurrencesOfString:@"\n " withString:@"\n" options:NSLiteralSearch range:NSMakeRange(0, [mString length])];
	
	return [NSString stringWithString: mString];
}

+ (NSString *)_prepareString:(NSString *)string
{
	NSMutableString *mString = [NSMutableString stringWithString: string];
	
	// Apply string replacements
	[mString applyReplacementDictionary:BLStandardStringReplacements reverseDirection:YES];
	
	return [NSString stringWithString: mString];
}

@end


@implementation NSScanner (BLStringsScanner)

- (NSUInteger)currentLine
{
	NSCharacterSet *newlines = [NSCharacterSet newlineCharacterSet];
	NSRange scanRange = NSMakeRange(0, [self scanLocation]);
	NSUInteger lines = 1;
	
	while (scanRange.length) {
		NSRange lastNewline = [[self string] rangeOfCharacterFromSet:newlines options:NSBackwardsSearch range:scanRange];
		
		// Newline found
		if (lastNewline.length) {
			lines++;
			scanRange.length = lastNewline.location;
		} else {
			break;
		}
	}
	
	return lines;
}

- (NSUInteger)currentOffsetInLine
{
	NSUInteger position = [self scanLocation];
	NSRange lastNewline = [[self string] rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch range:NSMakeRange(0, position)];
	
	// Newline found -- we are not in the first line
	if (lastNewline.length)
		return position - NSMaxRange(lastNewline);
	else
		return position;
}

@end




