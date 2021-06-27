/*!
 @header
 BLStringReplacement.m
 Created by Max on 10.08.05.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLStringReplacement.h"

// Declarations

NSDictionary *BLStandardStringReplacements = nil;

// Implementation

@implementation NSMutableString (BLStringReplacement)

+ (void)initialize
{
    [super initialize];
    
	if (!BLStandardStringReplacements) {
		BLStandardStringReplacements = [[NSDictionary alloc] initWithObjectsAndKeys:
										@"\\\\", @"\\",
										@"\\t", @"\t",
										@"\\n", @"\n",
										@"\\r", @"\r",
										@"\\U2028", @"\u2028",
										@"\\U2029", @"\u2029",
										@"\\\"", @"\"",
										nil];
	}
}

- (void)applyReplacementDictionary:(NSDictionary *)dict reverseDirection:(BOOL)reverse
{
    NSUInteger i, count, location, new_location, new_index;
    NSArray *keys, *values;
    NSScanner *scanner;
    
    keys = (reverse) ? [dict allKeys] : [dict allValues];
    values = (reverse) ? [dict allValues] : [dict allKeys];
    count = [dict count];
    
    scanner = [NSScanner scannerWithString: self];
    [scanner setCharactersToBeSkipped: nil];
    
    while (![scanner isAtEnd])
     {
        location = [scanner scanLocation];
        new_location = [self length];
		new_index = 0;
        
        for (i=0; i<count; i++)
         {
            [scanner setScanLocation: location];
            [scanner scanUpToString:[keys objectAtIndex: i] intoString:nil];
            
            if ([scanner scanLocation] < new_location) {
                new_location = [scanner scanLocation];
                new_index = i;
            }
         }
        
        if (new_location < [self length])
         {
            [self replaceCharactersInRange:NSMakeRange(new_location, [[keys objectAtIndex: new_index] length]) withString:[values objectAtIndex: new_index]];
            scanner = [NSScanner scannerWithString: self];
            [scanner setCharactersToBeSkipped: nil];
            [scanner setScanLocation: new_location + [[values objectAtIndex: new_index] length]];
         }
     }
}

- (void)replaceEscapedCharacters
{
	NSMutableString *string;
	NSScanner *scanner;
	
	// Set up the scanner
	scanner = [NSScanner scannerWithString: self];
	[scanner setCharactersToBeSkipped: nil];
	
	// Create a temporary copy
	string = [[NSMutableString alloc] initWithCapacity: [self length]];
	
	// Scan through the string, finding "\" chars
	while (![scanner isAtEnd]) {
		while ([scanner scanString:@"\\" intoString:nil]) {
			// We've reached an escape sequence

			if ([scanner scanString:@"U" intoString:nil] || [scanner scanString:@"u" intoString:nil]) {
				// Found a unicode sequence
				
				// Skip the (optional) leading +
				[scanner scanString:@"+" intoString:nil];
				
				// Scan exactly 4 bytes of hex numbers
				NSUInteger pos = [scanner scanLocation];
				unsigned val = 0;
				
				if (pos+3 >= [self length])
					break;
				
				for (NSUInteger i=0; i<4; i++) {
					val *= 16;
					
					UniChar c = [self characterAtIndex: pos+i];
					if (c >= '0' && c <='9')
						val += c - '0';
					if (c >= 'A' && c <= 'F')
						val += c - 'A' + 0xA;
					if (c >= 'a' && c <= 'f')
						val += c - 'a' + 0xA;
				}
				
				// We scanned a 4-byte hex int
				[scanner setScanLocation: pos+4];
				[string appendString: [NSString stringWithCharacters:(unichar[]){val} length:1]];
			} else {
				// Let's assume it's a single character after the backslash, which we can then replace.
				// Ideally, we'd also handle hex (\x54) and octal (\123) and NUL (\0) sequences, but they do not
				// seem to appear in the field (i.e. in .strings files) so far.
				NSUInteger pos = [scanner scanLocation];
				unichar ch = [self characterAtIndex:pos];
				scanner.scanLocation += 1;
				NSString *replacement;
				if (ch == 'n') {
					replacement = @"\n";
				} else if (ch == 'r') {
					replacement = @"\r";
				} else if (ch == 't') {
					replacement = @"\t";
				} else if (ch == '"') {
					replacement = @"\"";
				} else {
					// Replace with the single char after the backslash (so that \' turns into ')
					replacement = [NSString stringWithCharacters:&ch length:1];
				}
				[string appendString:replacement];
			}
		}

		// Scan the remainder
		if (![scanner isAtEnd]) {
			// Scan to the next escape sequence
			NSString *scan;
			[scanner scanUpToString:@"\\" intoString:&scan];
			[string appendString: scan];
		}
	}
	
	// Update
	[self setString: string];
}

- (void)replaceUnescapedComposedCharacters
{
	for (NSUInteger pos=0; pos<[self length]; ) {
		UniChar c = [self characterAtIndex: pos];
		
		// Composed character
		if (c > 0xFF) {
			NSString *replacement = [NSString stringWithFormat: @"\\U%04X", c];
			[self replaceCharactersInRange:NSMakeRange(pos, 1) withString:replacement];
			
			pos += [replacement length];
			continue;
		}
		
		pos++;
	}
}

@end

@implementation NSString (BLStringReplacement)

- (NSArray *)rangesOfString:(NSString *)str
{
    NSMutableArray *array;
    NSRange range, r;
    NSUInteger length;
    
    array = [NSMutableArray array];
    length = [self length];
    range = NSMakeRange(0, length);
    
    while (range.location < length)
     {
        r = [self rangeOfString:str options:0 range:range];
        if (r.location != NSNotFound)
            [array addObject: [NSValue valueWithRange: r]];
        range = NSMakeRange(NSMaxRange(r), length - NSMaxRange(r));
     }
    
    return array;
}

@end
