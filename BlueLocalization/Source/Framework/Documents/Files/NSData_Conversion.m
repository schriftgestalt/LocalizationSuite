//
//  NSData+NSData_Conversion.m
//  Glyphs
//
//  Created by Georg Seifert on 17.04.12.
//  Copyright (c) 2012 schriftgestaltung.de. All rights reserved.
//

#import "NSData_Conversion.h"

@implementation NSString (HexData)
#pragma mark - String Conversion

- (NSData *)hexadecimalData {
	unsigned char whole_byte;
	int dataLength = (int)self.length;
	char *dataBytes = malloc(dataLength + 10);
	char byte_chars[3] = {
		'\0', '\0', '\0'};
	int idx;
	int jdx = 0;
	for (idx = 0; idx < dataLength;) {
		byte_chars[0] = [self characterAtIndex:idx++];
		if (byte_chars[0] == ' ') {
			continue;
		}
		byte_chars[1] = [self characterAtIndex:idx++];
		whole_byte = strtol(byte_chars, NULL, 16);
		dataBytes[jdx++] = whole_byte;
	}
	NSData *data = [[NSData alloc] initWithBytes:dataBytes length:jdx];
	free(dataBytes);
	return data;
}

- (NSString *)hexDescription {
	NSMutableString *description = [NSMutableString string];
	for (int idx = 0; idx < self.length; idx++) {
		[description appendFormat:@"%X", [self characterAtIndex:idx]];
	}
	return description;
}

@end

@implementation NSData (Hex_String)
#if 0
- (NSString *)hexadecimalString {
	// Returns hexadecimal string of NSData. Empty string if data is empty.

	const unsigned char *dataBuffer = (const unsigned char *)[self bytes];

	if (!dataBuffer) {
		return [NSString string];
	}

	NSUInteger dataLength = self.length;
	NSMutableString *hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];

	for (int idx = 0; idx < dataLength; ++i) {
		[hexString appendString:[NSString stringWithFormat:@"%02x", (unsigned int)dataBuffer[idx]]];
	}

	return [NSString stringWithString:hexString];
}
#endif

static char _NSData_BytesConversionString_[512] = "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f404142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f808182838485868788898a8b8c8d8e8f909192939495969798999a9b9c9d9e9fa0a1a2a3a4a5a6a7a8a9aaabacadaeafb0b1b2b3b4b5b6b7b8b9babbbcbdbebfc0c1c2c3c4c5c6c7c8c9cacbcccdcecfd0d1d2d3d4d5d6d7d8d9dadbdcdddedfe0e1e2e3e4e5e6e7e8e9eaebecedeeeff0f1f2f3f4f5f6f7f8f9fafbfcfdfeff";

- (NSString *)hexadecimalString {
	UInt16 *mapping = (UInt16 *)_NSData_BytesConversionString_;
	register NSUInteger len = self.length;
	char *hexChars = (char *)malloc(sizeof(char) * (len * 2));
	register UInt16 *dst = ((UInt16 *)hexChars) + len - 1;
	register unsigned char *src = (unsigned char *)self.bytes + len - 1;

	while (len--)
		*dst-- = mapping[*src--];

	NSString *retVal = [[NSString alloc] initWithBytesNoCopy:hexChars length:self.length * 2 encoding:NSASCIIStringEncoding freeWhenDone:YES];
#if (!__has_feature(objc_arc))
	return [retVal autorelease];
#else
	return retVal;
#endif
}
@end
