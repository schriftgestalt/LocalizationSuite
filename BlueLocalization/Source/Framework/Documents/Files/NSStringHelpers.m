//
//  NSStringHelpers.m
//  GlyphsCore
//
//  Created by Georg Seifert on 06.08.09.
//  Copyright 2009 schriftgestaltung.de. All rights reserved.
//

#import "NSStringHelpers.h"
#import "CFPropertyListWriter_vintage.h"

#import "NSData_Conversion.h"
#import <Carbon/Carbon.h>
//#include "u2985907.h"
#import <Carbon/Carbon.h>
#ifndef GLYPHS_VIEWER


void endArray(FILE *file) {
	fseek(file, -2, SEEK_CUR);
	fputs("\n);\n", file);
}
#endif

short GSActualPrecision(CGFloat aFloat, int precision) {
	short actualPrecision = precision;
	NSInteger integer = round(aFloat * pow(10, precision));
	while (actualPrecision >= 0) {
		// GSLog(@"__Int: %d, div: %d, (prec: %d)", (int)integer, (int)round(Integer/10.0)* 10, ActualPrecision);
		if (integer != (NSInteger)round((integer + 1) * 0.1) * 10.0) {
			return actualPrecision;
		}
		integer = round(integer / 10.0);
		actualPrecision--;
	}
	if (actualPrecision < 0)
		actualPrecision = 0;
	return actualPrecision;
}

#ifndef GLYPHS_VIEWER
NSString *GSFloatToStringFull(CGFloat aFloat, int precision) {
	if (aFloat != aFloat) {
		return @"NaN";
	}
	short actualPrecision = GSActualPrecision(aFloat, precision);
	precision = MIN(precision, actualPrecision);
	NSString *format = [NSString stringWithFormat:@"%%.%df", precision];
	return [NSString stringWithFormat:format, aFloat];
}

NSString *GSFloatToStringWithPrecision(CGFloat aFloat, int precision) {
	if (aFloat != aFloat) {
		return @"NaN";
	}

	if (fabs(aFloat) < 0.000001) {
		return @"0";
	}
	else if (fabs(aFloat - 1) < 0.000001) {
		return @"1";
	}
	float ganzzahl;
	short actualPrecision = GSActualPrecision(aFloat, precision);
	precision = MIN(precision, actualPrecision);
	float fractional = modff(fabsf((float)aFloat), &ganzzahl);
	if (precision >= 5 && fractional >= 0.000005 && fractional < 0.999995) {
		return [NSString stringWithFormat:@"%.5f", aFloat];
	}
	if (precision >= 4 && fractional >= 0.00005 && fractional < 0.99995) {
		return [NSString stringWithFormat:@"%.4f", aFloat];
	}
	if (precision >= 3 && fractional >= 0.0005 && fractional < 0.9995) {
		return [NSString stringWithFormat:@"%.3f", aFloat];
	}
	if (precision >= 2 && fractional >= 0.005 && fractional < 0.995) {
		return [NSString stringWithFormat:@"%.2f", aFloat];
	}
	if (precision >= 1 && fractional >= 0.05 && fractional < 0.95) {
		return [NSString stringWithFormat:@"%.1f", aFloat];
	}
	else {
		return [NSString stringWithFormat:@"%d", (int)round(aFloat)];
	}
}

size_t GSFloatToStringWithPrecisionToBuffer(char *buffer, CGFloat aFloat, int precision) {
	size_t idx = 0;
	if (fabs(aFloat) < 0.000001 || fabs(aFloat) > 100000000000) {
		buffer[0] = '0';
		idx++;
		return idx;
	}
	else if (fabs(aFloat - 1) < 0.000001) {
		buffer[0] = '1';
		idx++;
		return idx;
	}
	CGFloat ganzzahl;
	CGFloat fractional = modf(fabs(aFloat), &ganzzahl); // small optimisation to avoid
	if (fractional * pow(10, precision) < 0.001) {
		idx += sprintf(buffer, "%d", (int)round(aFloat));
		//idx += ufast_itoa10((int)round(aFloat), buffer);
		return idx;
	}
	if (precision >= 5) {
		idx += sprintf(buffer, "%.5f", aFloat);
	}
	else if (precision >= 4) {
		idx += sprintf(buffer, "%.4f", aFloat);
	}
	else if (precision >= 3) {
		idx += sprintf(buffer, "%.3f", aFloat);
	}
	else if (precision >= 2) {
		idx += sprintf(buffer, "%.2f", aFloat);
	}
	else if (precision >= 1) {
		idx += sprintf(buffer, "%.1f", aFloat);
	}
	else {
		idx += sprintf(buffer, "%d", (int)round(aFloat));
		//idx += ufast_itoa10((int)round(aFloat), buffer);
		return idx;
	}
	while (buffer[idx - 1] == '0') {
		idx--;
		buffer[idx] = 0;
	}
	if (buffer[idx - 1] == '.') {
		idx--;
		buffer[idx] = 0;
	}
	return idx;
}

void GSFloatToStringWithPrecisionToFile(FILE *file, CGFloat aFloat, int precision) {
	if (fabs(aFloat) < 0.000001 || fabs(aFloat) > 100000000000) {
		fputs("0", file);
		return;
	}
	else if (fabs(aFloat - 1) < 0.000001) {
		fputs("1", file);
		return;
	}
	CGFloat ganzzahl;
	CGFloat fractional = modf(fabs(aFloat), &ganzzahl); // small optimisation to avoid
	if (fractional * pow(10, precision) < 0.001) {
		fprintf(file, "%d", (int)round(aFloat));
		return;
	}

	short actualPrecision = GSActualPrecision(aFloat, precision);
	char *format;
	if (actualPrecision >= 5) {
		format = "%.5f";
	}
	else if (actualPrecision >= 4) {
		format = "%.4f";
	}
	else if (actualPrecision >= 3) {
		format = "%.3f";
	}
	else if (actualPrecision >= 2) {
		format = "%.2f";
	}
	else if (actualPrecision >= 1) {
		format = "%.1f";
	}
	else {
		fprintf(file, "%d", (int)round(aFloat));
		return;
	}
	fprintf(file, format, aFloat);
}

NSString *GSFloatToStringWithPrecisionMin(CGFloat aFloat, int precision, int minPrecision) {
	short ActualPrecision = GSActualPrecision(aFloat, precision);
	ActualPrecision = MIN(precision, ActualPrecision);
	ActualPrecision = MAX(ActualPrecision, minPrecision);
	if (ActualPrecision >= 3) {
		NSString *format = [NSString stringWithFormat:@"%%.%df", ActualPrecision];
		return [NSString stringWithFormat:format, aFloat];
	}
	if (ActualPrecision == 2) {
		return [NSString stringWithFormat:@"%.2f", aFloat];
	}
	if (ActualPrecision == 1) {
		return [NSString stringWithFormat:@"%.1f", aFloat];
	}
	else {
		return [NSString stringWithFormat:@"%d", (int)round(aFloat)];
	}
}
#endif

NSString *GSFloatToStringWithPrecisionLocalized(CGFloat aFloat, int precision) {
	// double ganzzahl;
	// GSLog(@"Float: %f > rest: %f", Float, modf(Float, &ganzzahl));
	//	double fractional = modf(fabs(Float), &ganzzahl);
	aFloat += 0.000001;
	short actualPrecision = GSActualPrecision(aFloat, precision);
	precision = MIN(precision, actualPrecision);
	NSNumberFormatter *formatter = [NSNumberFormatter new];
	formatter.numberStyle = NSNumberFormatterDecimalStyle;
	formatter.localizesFormat = YES;
	switch (precision) {
		case 2:
			formatter.format = @"0.00";
			break;
		case 1:
			formatter.format = @"0.0";
			break;
		case 0:
			formatter.format = @"0";
			break;
		default:
			formatter.format = @"0.000";
			break;
	}
	return [formatter stringFromNumber:@(aFloat)];
}

#ifndef GLYPHS_VIEWER
NSString *GSFloatToStringWithPrecisionLocale(CGFloat aFloat, int precision, NSLocale *locale) {

	short actualPrecision = GSActualPrecision(aFloat, precision);
	precision = MIN(precision, actualPrecision);
	NSNumberFormatter *formatter = [NSNumberFormatter new];
	formatter.locale = locale;
	formatter.numberStyle = NSNumberFormatterDecimalStyle;
	switch (precision) {
		case 2:
			formatter.format = @"0.00";
			break;
		case 1:
			formatter.format = @"0.0";
			break;
		case 0:
			formatter.format = @"0";
			break;
		default:
			formatter.format = @"0.000";
			break;
	}
	NSString *result = [formatter stringFromNumber:@(aFloat)];
	return result;
}

NSString *GSFloatToStringLocalized(CGFloat aFloat) {
	float ganzzahl;
	/// GSLog(@"Float: %f > rest: %f", Float, modf(Float, &ganzzahl));

	if (modff(fabsf((float)aFloat), &ganzzahl) >= 0.001) {
		// GSLog(@"return: %@", [NSString stringWithFormat:@"%.4f", Float]);
		return [NSString localizedStringWithFormat:@"%.3f", aFloat];
	}
	else {
		// GSLog(@"return: %@", [NSString stringWithFormat:@"%.0f", Float]);
		return [NSString localizedStringWithFormat:@"%d", (int)round(aFloat)];
	}
}

NSString *GSFloatToString(CGFloat aFloat) {
	float ganzzahl;
	/// GSLog(@"Float: %f > rest: %f", Float, modf(Float, &ganzzahl));

	if (modff(fabsf((float)aFloat), &ganzzahl) >= 0.001) {
		// GSLog(@"return: %@", [NSString stringWithFormat:@"%.4f", Float]);
		return [NSString stringWithFormat:@"%.3f", aFloat];
	}
	else {
		// GSLog(@"return: %@", [NSString stringWithFormat:@"%.0f", Float]);
		return [NSString stringWithFormat:@"%.0f", aFloat];
	}
}

NSString *GSPointToString(NSPoint P) {
	return [NSString stringWithFormat:@"{%@, %@}", GSFloatToStringWithPrecision(P.x, 2), GSFloatToStringWithPrecision(P.y, 2)];
}

NSCharacterSet *PropertyListValidChars = nil;
#endif

uint32_t lutHexString(uint64_t num, unichar *s) {
	static const char digits[513] =
		"000102030405060708090A0B0C0D0E0F"
		"101112131415161718191A1B1C1D1E1F"
		"202122232425262728292A2B2C2D2E2F"
		"303132333435363738393A3B3C3D3E3F"
		"404142434445464748494A4B4C4D4E4F"
		"505152535455565758595A5B5C5D5E5F"
		"606162636465666768696A6B6C6D6E6F"
		"707172737475767778797A7B7C7D7E7F"
		"808182838485868788898A8B8C8D8E8F"
		"909192939495969798999A9B9C9D9E9F"
		"A0A1A2A3A4A5A6A7A8A9AAABACADAEAF"
		"B0B1B2B3B4B5B6B7B8B9BABBBCBDBEBF"
		"C0C1C2C3C4C5C6C7C8C9CACBCCCDCECF"
		"D0D1D2D3D4D5D6D7D8D9DADBDCDDDEDF"
		"E0E1E2E3E4E5E6E7E8E9EAEBECEDEEEF"
		"F0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF";

	uint32_t x = (uint32_t)num;
	int idx = 3;
	// char *lut = (char *)digits;
	while (idx >= 0) {
		int pos = (x & 0xFF) * 2;
		char ch = digits[pos];
		s[idx * 2] = ch;

		ch = digits[pos + 1];
		s[idx * 2 + 1] = ch;

		x >>= 8;
		idx -= 1;
	}

	return 0;
}

@implementation NSString (UUID)
static BOOL _NSPropertyListNameSet[256] = {
	NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO,					// 0
	NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO,					// 16
	NO, NO, NO, NO, YES, NO, NO, NO, NO, NO, NO, NO, NO, NO, YES, YES,				// 32
	YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, NO, NO, NO, NO, NO, NO,		// 48
	NO, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES,	// 64
	YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, NO, NO, NO, NO, YES,		// 80
	NO, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES,	// 96
	YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, NO, NO, NO, NO, NO,		// 112
	NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO,					// 128
	NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO,					// 144
	NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO,					// 160
	NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO,					// 176
	NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO,					// 192
	NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO,					// 208
	NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO,					// 224
	NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO,					// 240
};

+ (NSString *)UUID {
	//	CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
	//	CFStringRef strRef = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
	//	NSString * uuidString = [NSString stringWithString:(__bridge NSString *)strRef];
	//	CFRelease(uuidRef);
	//	CFRelease(strRef);
	//	return uuidString;
	CFUUIDRef uuidRef = CFUUIDCreate(NULL);
	CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
	CFRelease(uuidRef);
	// if (uuidStringRef) NSMakeCollectable(uuidStringRef);
	return (NSString *)CFBridgingRelease(uuidStringRef);
}

+ (NSString *)hexStringFromInt:(NSInteger)integer {
	BOOL negative = NO;
	if (integer < 0) {
		negative = YES;
		integer = -integer;
	}
	if (integer > 0xFFFFFFFF)
		integer = 0xFFFFFFFF;
	unichar buffer[10] = {0};
	unichar *pos = buffer;
	pos++;
	lutHexString(integer, pos);
	while (pos[0] == '0' && pos - buffer < 5)
		pos++;
	if (negative) {
		pos--;
		pos[0] = '-';
	}
	NSString *unicode = [NSString stringWithCharacters:pos length:9 - (size_t)(pos - buffer)];
	return unicode;
}

#ifndef GLYPHS_VIEWER
+ (NSString *)hexStringFromUnsignedInteger:(NSUInteger)integer {
	unichar buffer[10] = {0};
	unichar *pos = buffer;
	if (integer > 0xFFFFFFFF)
		integer = 0xFFFFFFFF;
	lutHexString(integer, pos);
	while (pos[0] == '0' && pos - buffer < 4)
		pos++;
	// NSString *unicode = [NSString stringWithCString:pos encoding:NSASCIIStringEncoding];
	NSString *unicode = [NSString stringWithCharacters:pos length:8 - (size_t)(pos - buffer)];
	return unicode;
}

+ (NSString *)stringFromInt:(int)integer {
	char buffer[20];
	writeInt(integer, buffer);
	return [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
}
#endif

- (BOOL)isNumber {
	static NSCharacterSet *notNumberCharacterSet;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		notNumberCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789+-."] invertedSet];
	});
	return [self rangeOfCharacterFromSet:notNumberCharacterSet].location == NSNotFound;
}

- (BOOL)isAllDigits {
	static NSCharacterSet *noDigitsCharacterSet;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		noDigitsCharacterSet = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
	});
	return [self rangeOfCharacterFromSet:noDigitsCharacterSet].location == NSNotFound;
}

- (BOOL)isHexCapitalString {
	static NSCharacterSet *notHexCharacterSet;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		notHexCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet];
	});
	return [self rangeOfCharacterFromSet:notHexCharacterSet].location == NSNotFound;
}

- (BOOL)isHexCapitalStringWithLength:(NSUInteger)length {
	return self.length == length && [self isHexCapitalString];
}

// unsigned int toInt(char c) {
//	if (c >= '0' && c <= '9') return	  c - '0';
//	if (c >= 'A' && c <= 'F') return 10 + c - 'A';
//	if (c >= 'a' && c <= 'f') return 10 + c - 'a';
//	return -1;
// }
//- (int) hexStringToInt {
//	const char*input = [self UTF8String];
//	const size_t numdigits = strlen(input) / 2;
//
//	uint8_t * const output = malloc(numdigits);
//
//	for (size_t idx = 0; idx != numdigits; ++idx)
//	{
//		output[idx] = 16 * toInt(input[2 * idx]) + toInt(input[2 * idx + 1]);
//	}
//	return
//
//
// }

- (int)hexStringToInt {
	int L = (int)self.length;
	if (L == 0) {
		return INT_MAX;
	}
	int result = 0;

#if 0
	sscanf([self UTF8String], "%X", &result);
#else
	unichar C;

	BOOL negative = NO;
	const char *buffer = [self UTF8String];
	int numberCount = 0;
	for (int idx = 0; idx < L; idx++) {
		C = buffer[L - idx - 1];
		if (C >= '0' && C <= '9') {
			result += (C - 48) << numberCount;
			numberCount += 4;
		}
		else if (C >= 'A' && C <= 'F') {
			result += (C - 55) << numberCount;
			numberCount += 4;
		}
		else if (C >= 'a' && C <= 'f') {
			result += (C - 87) << numberCount;
			numberCount += 4;
		}
		else if (C == '-') {
			negative = YES;
		}
		else if (C == ' ') {}
		else
			return INT_MAX;
	}
	// GSLog(@"%@ > %d", self, result);
	if (negative) {
		result = -result;
	}
#endif
	return result;
}

+ (NSString *)stringWithChar:(UTF32Char)aChar {
	if (aChar > 0xffff) {
		if (aChar > 0x10FFFF) {
			return @"";
		}
		aChar = NSSwapHostIntToLittle(aChar); // swap to little-endian if necessary
		return [[NSString alloc] initWithBytes:&aChar length:4 encoding:NSUTF32LittleEndianStringEncoding];
	}
	if (aChar > 0)
		return [self stringWithFormat:@"%C", (unsigned short)aChar];
	return @"";
}

- (NSString *)ascciString {
	NSUInteger length = self.length;
	unichar buffer[length];
	BOOL escape = YES;

	[self getCharacters:buffer];

	if (length == 0) {

		return @"";
	}
	int idx = 0;
	for (; idx < length; idx++)
		if (buffer[idx] >= 128 || !_NSPropertyListNameSet[buffer[idx]])
			break;

	if (idx >= length) {
		return [self copy];
	}
	else {
		char *charBuf;
		int bufLen = 0;

		charBuf = NSZoneMalloc(NULL, length * 6 + 2);

		// charBuf[bufLen++]='\"';

		for (int jdx = 0; jdx < length; jdx++) {
			unichar unicode = buffer[jdx];

			if (unicode < ' ' || unicode == 127) {
				if (!escape && unicode == '\n') {
					charBuf[bufLen++] = (char)unicode;
				}
				else {
					charBuf[bufLen++] = '\\';
					charBuf[bufLen++] = (char)((unicode >> 6) + '0');
					charBuf[bufLen++] = (char)(((unicode >> 3) & 0x07) + '0');
					charBuf[bufLen++] = (char)((unicode & 0x07) + '0');
				}
			}
			else if (unicode < 128) {
				if (escape && (unicode == '\"' || unicode == '\\'))
					charBuf[bufLen++] = '\\';
				charBuf[bufLen++] = (char)unicode;
			}
			else {
				const char *hex = "0123456789ABCDEF";

				charBuf[bufLen++] = '\\';
				charBuf[bufLen++] = 'U';
				charBuf[bufLen++] = hex[(unicode >> 12) & 0x0F];
				charBuf[bufLen++] = hex[(unicode >> 8) & 0x0F];
				charBuf[bufLen++] = hex[(unicode >> 4) & 0x0F];
				charBuf[bufLen++] = hex[unicode & 0x0F];
			}
		}

		charBuf[bufLen] = '\0';

		NSString *result = @(charBuf);
		NSZoneFree(NULL, charBuf);
		return result;
	}
}

- (NSUInteger)countOfChar:(char)aChar {
	int lenght = (int)self.length;
	const char *chars = [self UTF8String];
	int count = 0;
	for (int idx = 0; idx < lenght; idx++) {
		if (chars[idx] == aChar)
			count++;
	}
	return count;
}

+ (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix {
	NSString *result;
	CFUUIDRef uuid;
	CFStringRef uuidStr;

	uuid = CFUUIDCreate(NULL);
	assert(uuid != NULL);

	uuidStr = CFUUIDCreateString(NULL, uuid);
	assert(uuidStr != NULL);

	result = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", prefix, uuidStr]];
	assert(result != nil);

	CFRelease(uuidStr);
	CFRelease(uuid);

	return result;
}

- (NSString *)absolutePathFromBaseDirPath:(NSString *)baseDirPath {
	if ([self hasPrefix:@"~"]) {
		return [self stringByExpandingTildeInPath];
	}

	NSString *theBasePath = [baseDirPath stringByExpandingTildeInPath];

	if (![self hasPrefix:@"."]) {
		return [theBasePath stringByAppendingPathComponent:self];
	}

	NSMutableArray *pathComponents1 = [NSMutableArray arrayWithArray:[self pathComponents]];
	NSMutableArray *pathComponents2 = [NSMutableArray arrayWithArray:[theBasePath pathComponents]];

	while (pathComponents1.count > 0) {
		NSString *topComponent1 = pathComponents1[0];
		[pathComponents1 removeObjectAtIndex:0];

		if ([topComponent1 isEqualToString:@".."]) {
			if (pathComponents2.count == 1) {
				// Error
				return nil;
			}
			[pathComponents2 removeLastObject];
		}
		else if ([topComponent1 isEqualToString:@"."]) {
			// Do nothing
		}
		else {
			[pathComponents2 addObject:topComponent1];
		}
	}

	return [NSString pathWithComponents:pathComponents2];
}

- (NSString *)relativePathFromBaseDirPath:(NSString *)baseDirPath {
	NSString *thePath = [self stringByExpandingTildeInPath];
	NSString *theBasePath = [baseDirPath stringByExpandingTildeInPath];

	NSMutableArray *pathComponents1 = [NSMutableArray arrayWithArray:[thePath pathComponents]];
	NSMutableArray *pathComponents2 = [NSMutableArray arrayWithArray:[theBasePath pathComponents]];

	// Remove same path components
	while (pathComponents1.count > 0 && pathComponents2.count > 0) {
		NSString *topComponent1 = pathComponents1[0];
		NSString *topComponent2 = pathComponents2[0];
		if (![topComponent1 isEqualToString:topComponent2]) {
			break;
		}
		[pathComponents1 removeObjectAtIndex:0];
		[pathComponents2 removeObjectAtIndex:0];
	}

	// Create result path
	for (int idx = 0; idx < pathComponents2.count; idx++) {
		[pathComponents1 insertObject:@".." atIndex:0];
	}
	if (pathComponents1.count == 0) {
		return @".";
	}
	return [NSString pathWithComponents:pathComponents1];
}

#if 0
- (NSString *)encodeForPlist {
	return stringWithPropertyList(self, -1);
	NSUInteger length = self.length;
	//CFStringGetBytes ((CFStringRef)string, range, kCFStringEncodingUTF8, 0, false, buffer, length, NULL);
	if (length == 0 || length > 20000) {
		return @"\"\"";
	}
	unichar buffer[length];
	NSInteger idx;

	//[string getCharacters:buffer];
	CFRange range;
	range.location = 0;
	range.length = (CFIndex) length;
	CFStringGetCharacters((__bridge CFStringRef) self, range, buffer);
	for (idx = 0; idx < length; idx++)
		if (buffer[idx] >= 128 || !_NSPropertyListNameSet[buffer[idx]])
			break;

	if (idx >= length) {
		return self;
	}
	else {
		char charBuf[length * 6 + 2];
		NSInteger bufLen = 0;
		// GSLog(@"Value: %@", Value);
		//charBuf=NSZoneMalloc(NULL,length*6+2);
		BOOL escape = YES;
		charBuf[bufLen++] = '\"';

		for (idx = 0; idx < length; idx++) {
			unichar unicode = buffer[idx];

			if (unicode < ' ' || unicode == 127) {
				if (!escape && unicode == '\n') {
					charBuf[bufLen++] = (char) unicode;
				}
				else {
					charBuf[bufLen++] = '\\';
					charBuf[bufLen++] = (char) ((unicode >> 6) + '0');
					charBuf[bufLen++] = (char) (((unicode >> 3) & 0x07) + '0');
					charBuf[bufLen++] = (char) ((unicode & 0x07) + '0');
				}
			}
			else if (unicode < 128) {
				if (escape && (unicode == '\"' || unicode == '\\'))
					charBuf[bufLen++] = '\\';
				charBuf[bufLen++] = (char) unicode;
			}
			else {
				const char *hex = "0123456789ABCDEF";

				charBuf[bufLen++] = '\\';
				charBuf[bufLen++] = 'U';
				charBuf[bufLen++] = hex[(unicode >> 12) & 0x0F];
				charBuf[bufLen++] = hex[(unicode >> 8) & 0x0F];
				charBuf[bufLen++] = hex[(unicode >> 4) & 0x0F];
				charBuf[bufLen++] = hex[unicode & 0x0F];
			}
		}
		charBuf[bufLen++] = '\"';
		charBuf[bufLen] = 0;
		return [[NSString alloc] initWithCString:charBuf encoding:NSASCIIStringEncoding];
	}
	return self;
}
#endif

- (UTF32Char)character32AtIndex:(NSUInteger *)idx {
	UTF32Char Char = [self characterAtIndex:*idx];
	if ((Char >= kUCHighSurrogateRangeStart && Char <= kUCHighSurrogateRangeEnd)) {
		UTF32Char outputchar = 0;
		BOOL result = [self getBytes:&outputchar maxLength:4 usedLength:NULL encoding:NSUTF32LittleEndianStringEncoding options:0 range:NSMakeRange(*idx, 2) remainingRange:NULL];
		if (result) {
			Char = NSSwapLittleIntToHost(outputchar);
		}
		(*idx)++;
	}
	return Char;
}

+ (NSString *)encodeForFilePath:(NSString *)string {
	/*

	 Illegeal on Win?
	 < (less than)
	 > (greater than)
	 : (colon)
	 " (double quote)
	 / (forward slash)
	 \ (backslash)
	 | (vertical bar or pipe)
	 ? (question mark)
	 * (asterisk)
	 Illegal on Mac
	 : (colon) HFS path separator
	 / (forward slash) does work in Finder but the unix level needs to escape it.
	 */

	if ([string respondsToSelector:@selector(UTF8String)]) {
		NSMutableString *mutableString = [string mutableCopy];
		NSCharacterSet *except = [NSCharacterSet characterSetWithCharactersInString:@"<>:\"/\\|?*"];
		for (int idx = (int)string.length - 1; idx >= 0; idx--) {
			unichar c = [string characterAtIndex:idx];
			if ([except characterIsMember:c] || c < ' ') {
				[mutableString replaceCharactersInRange:NSMakeRange(idx, 1) withString:@""];
			}
		}
		return mutableString;
	}
	return [NSString stringWithFormat:@"%@", string]; // might be a NSNumber
}

+ (NSString *)encodeForASCII:(NSString *)string {
	// 33 through 126, except for the 10 characters: '[', ']', '(', ')', '{', '}', '<', '>', '/', '%'.
	if ([string respondsToSelector:@selector(UTF8String)]) {
		NSData *data = [string dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
		NSMutableString *mutableString = [[NSMutableString alloc] initWithData:data encoding:NSASCIIStringEncoding];
		NSCharacterSet *except = [NSCharacterSet characterSetWithCharactersInString:@"[](){}<>/%"];
		for (int idx = (int)string.length - 1; idx >= 0; idx--) {
			unichar c = [string characterAtIndex:idx];
			if ([except characterIsMember:c]) {
				[mutableString replaceCharactersInRange:NSMakeRange(idx, 1) withString:@""];
			}
		}
		return mutableString;
	}
	return [NSString stringWithFormat:@"%@", string]; // might be a NSNumber
}

- (NSString *)stringByAppendingDotSuffix:(NSString *)suffix {
	if (suffix.length == 0) {
		return self;
	}
	if ([suffix characterAtIndex:0] != '.') {
		suffix = [@"." stringByAppendingString:suffix];
	}
	return [self stringByAppendingString:suffix];
}

- (NSString *)stringByDeletingDotSuffix {
	NSRange range = [self rangeOfString:@"."];
	if (range.location < NSNotFound) {
		return [self substringToIndex:range.location];
	}
	return self;
}

- (NSString *)stringByDeletingLastDotSuffix {
	NSRange range = [self rangeOfString:@"." options:NSBackwardsSearch];
	if (range.location < NSNotFound) {
		return [self substringToIndex:range.location];
	}
	return self;
}

- (NSString *)dotSuffix {
	NSRange range = [self rangeOfString:@"."];
	if (range.location < NSNotFound) {
		return [self substringFromIndex:range.location];
	}
	return nil;
}

- (float)localizedFloatValue {
	static NSNumberFormatter *formatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		formatter = [NSNumberFormatter new];
		formatter.numberStyle = NSNumberFormatterDecimalStyle;
	});
	NSNumber *formatterNumber = [formatter numberFromString:self];
	if (formatterNumber) {
		return [formatterNumber floatValue];
	}
	return NSNotFound;
}

- (double)localizedDoubleValue {
	static NSNumberFormatter *formatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		formatter = [NSNumberFormatter new];
		formatter.numberStyle = NSNumberFormatterDecimalStyle;
	});
	NSNumber *formatterNumber = [formatter numberFromString:self];
	if (formatterNumber) {
		return [formatterNumber doubleValue];
	}
	return NSNotFound;
}

- (NSString *)stringWithFirstLower {
	if (self.length > 1) {
		return [[[self substringToIndex:1] lowercaseString] stringByAppendingString:[self substringFromIndex:1]];
	}
	return [self lowercaseString];
}

- (NSString *)stringWithFirstUpper {
	if (self.length > 1) {
		return [[[self substringToIndex:1] uppercaseString] stringByAppendingString:[self substringFromIndex:1]];
	}
	return [self uppercaseString];
}

- (NSString *)camelCaseToSentenceCase {
	if (self.length < 3) {
		return [self stringWithFirstUpper];
	}
	NSString *modified = [self stringByReplacingOccurrencesOfString:@"([a-z])([A-Z])"
														 withString:@"$1 $2"
															options:NSRegularExpressionSearch
															  range:NSMakeRange(0, self.length)];
	return [modified stringWithFirstUpper];
}

- (NSRange)rangeOfLine:(NSUInteger)lineNumber {
	if (lineNumber == 0) {
		return NSMakeRange(0, 0);
	}
	NSRange __block range = NSMakeRange(0, 0);
	NSUInteger __block currentLineNumber = 1;
	[self enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
		if (currentLineNumber == lineNumber) {
			range.length = line.length;
			*stop = YES;
			return;
		}
		range.location += line.length + 1; // + line terminator
		currentLineNumber++;
	}];
	if (lineNumber != currentLineNumber) { // if not line was found, jump to the end
		range.location = self.length;
		range.length = 0;
	}
	return range;
}

- (NSUInteger)lineNumberAtIndex:(NSUInteger)idx {
	// https://stackoverflow.com/questions/37084589/getting-line-number-of-location-in-nsstring
	__block int lineNumber = 1;
	__block int locationNumber = 0;
	[self enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
		NSUInteger lineLength = line.length;
		if (idx > locationNumber + lineLength) {
			locationNumber += lineLength + 1; // Added 1 to line.length to account for newline character that was not included in line
			lineNumber++;
		}
		else {
			*stop = YES;
		}
	}];
	return lineNumber;
}

@end

size_t GSIndexPathToBuffer(char *buffer, NSIndexPath *indexPath, BOOL addSpace) {
	NSUInteger length = indexPath.length;
	size_t pos = 0;
	if (length > 0) {
		pos += writeInt((int)[indexPath indexAtPosition:0], buffer + pos);
		for (int idx = 1; idx < length; idx++) {
			buffer[pos++] = ',';
			if (addSpace) {
				buffer[pos++] = ' ';
			}
			//*buffer += sprintf(*buffer, ",%s%ld", addSpace ? " " : "", [indexPath indexAtPosition:idx]);
			pos += writeInt((int)[indexPath indexAtPosition:idx], buffer + pos);
		}
	}
	buffer[pos] = 0;
	return pos;
}

NSString *GSStringFromIndexPath(NSIndexPath *indexPath, BOOL addSpace) {
	if (!indexPath) {
		return @"-";
	}
	NSUInteger length = indexPath.length;
	char buffer[length * 5];
	GSIndexPathToBuffer(buffer, indexPath, addSpace);
	NSString *string = [NSString stringWithCString:buffer encoding:NSASCIIStringEncoding];
	return string;
}

NSIndexPath *GSIndexPathFromString(NSString *string) {
	int a, b, c, d, e, f;
	const char *cString = [string UTF8String];
	if (!cString) {
		return nil;
	}
	if (*cString == '{') {
		cString++;
	}
	int result = sscanf(cString, "%d, %d, %d, %d, %d, %d", &a, &b, &c, &d, &e, &f);
	NSUInteger indexes[6];
	indexes[0] = a;
	indexes[1] = b;
	indexes[2] = c;
	indexes[3] = d;
	indexes[4] = e;
	indexes[5] = f;
	if (result > 0) {
		return [[NSIndexPath alloc] initWithIndexes:(NSUInteger *)&indexes length:result];
	}
	return nil;
}

NSArray *GSIntListFromIndexPath(NSIndexPath *indexPath) {
	NSMutableArray *intList = [NSMutableArray new];
	NSUInteger length = indexPath.length;
	for (int idx = 0; idx < length; idx++) {
		[intList addObject:@([indexPath indexAtPosition:idx])];
	}
	return intList;
}

NSIndexPath *GSIndexPathFromIntList(NSArray *intList) {
	NSUInteger count = intList.count;
	if (count > 0) {
		NSUInteger indexes[count];
		NSUInteger idx = 0;
		for (NSNumber *index in intList) {
			indexes[idx++] = [index integerValue];
		}
		return [[NSIndexPath alloc] initWithIndexes:(NSUInteger *)&indexes length:count];
	}
	return nil;
}

NSString *GSTagStringFromFourCharCode(FourCharCode code) {
	unichar characters[4];
	characters[0] = (code >> 24) & 0xFF;
	characters[1] = (code >> 16) & 0xFF;
	characters[2] = (code >> 8) & 0xFF;
	characters[3] = (code >> 0) & 0xFF;
	return [NSString stringWithCharacters:characters length:4];
}

FourCharCode GSFourCharCodeFromTagString(NSString *tag) {
	NSCAssert(tag.length == 4, @"tag must be four ASCII characters long");
	NSData *data = [tag dataUsingEncoding:NSUTF8StringEncoding];
	const char *charBytes = (const char *)data.bytes;
	return (charBytes[0] << 24) + (charBytes[1] << 16) + (charBytes[2] << 8) + charBytes[3];
}

#ifndef GLYPHS_VIEWER
BOOL stringNeedsQuotes(NSString *string) {
	CFIndex length = string.length;
	unichar keyBuffer[length + 4];
	CFRange range;
	range.location = 0;
	range.length = length;
	CFStringGetCharacters((__bridge CFStringRef)string, range, keyBuffer);
	for (int idx = 0; idx < length; idx++) {
		unichar ch = keyBuffer[idx];
		if (ch >= 128 || !_NSPropertyListNameSet[ch]) {
			return YES;
		}
	}
	return NO;
}

void writeKeyString(FILE *file, NSString *key) {
	const char *charKey = [key UTF8String];
	writeKey(file, charKey);
}

size_t sWriteKey(char *buffer, const char *key) {
	unsigned char *_key = (unsigned char *)key;
	size_t length = strlen(key);
	size_t idx = 0;
	CFRange range;
	range.location = 0;
	range.length = (CFIndex)length;
	BOOL needsQuotes = NO;
	for (idx = 0; idx < length; idx++) {
		if (!_NSPropertyListNameSet[_key[idx]]) {
			needsQuotes = YES;
			break;
		}
	}
	idx = 0;
	if (!needsQuotes && length > 0) {
		stpncpy(buffer + idx, key, length);
		idx += length;
	}
	else {
		buffer[idx++] = '"';
		stpncpy(buffer + idx, key, length);
		idx += length;
		buffer[idx++] = '"';
	}
	buffer[idx++] = ' ';
	buffer[idx++] = '=';
	buffer[idx++] = ' ';
	buffer[idx] = 0;

	return idx;
}

void writeKey(FILE *file, const char *key) {
	size_t length = strlen((char *)key);
	char charBuffer[length + 6];
	sWriteKey(charBuffer, key);
	fputs(charBuffer, file);
}

BOOL writeKeyValueString(FILE *file, char *key, NSString *value) {
	return writeKeyValueStringEscape(file, key, value, YES);
}

BOOL writeKeyValueData(FILE *file, char *key, NSData *value) {
	writeKey(file, key);
	NSString *endcodedString = [value hexadecimalString];
	fprintf(file, "<%s>;\n", [endcodedString UTF8String]);
	return YES;
}

BOOL writeKeyValueStringLine(FILE *file, char *key, NSString *value) {
	return writeKeyValueStringEscape(file, key, value, NO);
}

BOOL writeStringEscape(FILE *file, NSString *value, BOOL escape) {
	NSUInteger length = value.length;
	// CFStringGetBytes ((CFStringRef)string, range, kCFStringEncodingUTF8, 0, false, buffer, length, NULL);
	if (length == 0) {
		fputs("\"\";\n", file);
		return YES;
	}
	NSRange range;
	range.location = 0;
	range.length = length;
	if (!PropertyListValidChars)
		PropertyListValidChars = [[NSCharacterSet characterSetWithCharactersInString:@"$./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz"] invertedSet];
	NSRange ValidRange = [value rangeOfCharacterFromSet:PropertyListValidChars];
	if (ValidRange.location > length) {
		unichar First = [value characterAtIndex:0];
		if ((First < '0' || First > '9') && First != '.') {
			char Buffer[length + 4];
			[value getBytes:&Buffer maxLength:length usedLength:NULL encoding:NSASCIIStringEncoding options:0 range:NSMakeRange(0, length) remainingRange:NULL];
			Buffer[length++] = ';';
			Buffer[length++] = '\n';
			Buffer[length] = 0;
			fputs(Buffer, file);
		}
		else {

			char Buffer[length + 6];
			Buffer[0] = '"';
			char *pointer = (char *)&Buffer;
			pointer++;
			[value getBytes:pointer maxLength:length usedLength:NULL encoding:NSASCIIStringEncoding options:0 range:NSMakeRange(0, length) remainingRange:NULL];
			length++;
			Buffer[length++] = '"';
			Buffer[length++] = ';';
			Buffer[length++] = '\n';
			Buffer[length] = 0;
			fputs(Buffer, file);
		}
	}
	else {
		NSMutableString *mutableValue = [value mutableCopy];
		[mutableValue replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:0 range:NSMakeRange(0, mutableValue.length)];
		if (escape) {
			if ([value containsString:@"\r"]) {
				[mutableValue replaceOccurrencesOfString:@"\r\n" withString:@"\n" options:0 range:NSMakeRange(0, mutableValue.length)];
				[mutableValue replaceOccurrencesOfString:@"\r" withString:@"\n" options:0 range:NSMakeRange(0, mutableValue.length)];
			}
			[mutableValue replaceOccurrencesOfString:@"\n" withString:@"\\012" options:0 range:NSMakeRange(0, mutableValue.length)];
		}
		[mutableValue replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:0 range:NSMakeRange(0, mutableValue.length)];
		fprintf(file, "\"%s\";\n", [mutableValue UTF8String]);
	}
	return YES;
}

size_t sWriteStringEscape(char *buffer, NSString *value, BOOL escape) {
	NSUInteger length = value.length;
	// CFStringGetBytes ((CFStringRef)string, range, kCFStringEncodingUTF8, 0, false, buffer, length, NULL);
	size_t idx = 0;
	if (length == 0) {
		// fputs("\"\";\n", file);
		buffer[idx++] = '"';
		buffer[idx++] = '"';
		buffer[idx++] = ';';
		buffer[idx++] = '\n';
		buffer[idx] = 0;
		return idx;
	}
	NSRange range = {0, length};
	if (!PropertyListValidChars)
		PropertyListValidChars = [[NSCharacterSet characterSetWithCharactersInString:@"$./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz"] invertedSet];
	NSRange ValidRange = [value rangeOfCharacterFromSet:PropertyListValidChars];
	if (ValidRange.location > length) {
		unichar First = [value characterAtIndex:0];
		BOOL needsQuotes = !((First < '0' || First > '9') && First != '.');
		if (needsQuotes) {
			buffer[idx++] = '"';
		}
		NSUInteger usedLength = 0;
		[value getBytes:buffer + idx maxLength:length usedLength:&usedLength encoding:NSASCIIStringEncoding options:0 range:range remainingRange:NULL];
		idx += usedLength;
		if (needsQuotes) {
			buffer[idx++] = '"';
		}
		buffer[idx++] = ';';
		buffer[idx++] = '\n';
	}
	else {
		NSMutableString *mutableValue = [value mutableCopy];
		[mutableValue replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:0 range:NSMakeRange(0, mutableValue.length)];
		if ([value containsString:@"\r"]) {
			[mutableValue replaceOccurrencesOfString:@"\r\n" withString:@"\n" options:0 range:NSMakeRange(0, mutableValue.length)];
			[mutableValue replaceOccurrencesOfString:@"\r" withString:@"\n" options:0 range:NSMakeRange(0, mutableValue.length)];
		}
		[mutableValue replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:0 range:NSMakeRange(0, mutableValue.length)];
		if (escape) {
			[mutableValue replaceOccurrencesOfString:@"\n" withString:@"\\012" options:0 range:NSMakeRange(0, mutableValue.length)];
		}
		// fprintf(file, "\"%s\";\n", [mutableValue UTF8String]);
		buffer[idx++] = '"';
		NSUInteger usedLength = 0;
		[mutableValue getBytes:buffer + idx maxLength:length usedLength:&usedLength encoding:NSUTF8StringEncoding options:0 range:range remainingRange:NULL];
		idx += usedLength;
		buffer[idx++] = '"';
		buffer[idx++] = ';';
		buffer[idx++] = '\n';
	}
	buffer[idx] = 0;
	return idx;
}

BOOL writeKeyValueStringEscape(FILE *file, char *key, NSString *value, BOOL escape) {
	writeKey(file, key);
	return writeStringEscape(file, value, escape);
}

BOOL writeKeyValueStringSimple(FILE *file, char *key, NSString *value) {
	writeKey(file, key);
	BOOL result = writeStringSimple(file, value);
	fputs(";\n", file);
	return result;
}

BOOL writeStringSimple(FILE *file, NSString *value) {
	NSUInteger length = value.length;
	// CFStringGetBytes ((CFStringRef)string, range, kCFStringEncodingUTF8, 0, false, buffer, length, NULL);
	if (length == 0) {
		fputs("\"\"", file);
		return YES;
	}
	if (length > 60000) {
		return NO;
	}
	NSRange range;
	range.location = 0;
	range.length = length;
	if (!PropertyListValidChars)
		PropertyListValidChars = [[NSCharacterSet characterSetWithCharactersInString:@"$./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz"] invertedSet];
	unichar First = [value characterAtIndex:0];
	NSRange inValidRange = [value rangeOfCharacterFromSet:PropertyListValidChars];
	BOOL needsQuotes = inValidRange.location < length || (First >= '0' && First <= '9') || (First == '/' && length > 1 && [value characterAtIndex:1] == '/');
	if (needsQuotes) {
		static NSCharacterSet *escapedChars = nil;
		if (!escapedChars)
			escapedChars = [NSCharacterSet characterSetWithCharactersInString:@"\\\""];
		NSRange escapeRange = [value rangeOfCharacterFromSet:escapedChars];
		if (escapeRange.location < NSNotFound) {
			value = [value stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
			value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
			length = value.length;
		}
		char Buffer[length * 3 + 5];
		char *pointer = Buffer + 1;
		NSUInteger pos = 0;
		Buffer[0] = '"';
		[value getBytes:pointer maxLength:length * 3 usedLength:&pos encoding:NSUTF8StringEncoding options:0 range:NSMakeRange(0, length) remainingRange:NULL];
		pos++;
		Buffer[pos++] = '"';
		Buffer[pos] = 0;
		fputs(Buffer, file);
	}
	else {
		char Buffer[length + 4];
		[value getBytes:&Buffer maxLength:length usedLength:NULL encoding:NSASCIIStringEncoding options:0 range:NSMakeRange(0, length) remainingRange:NULL];
		Buffer[length] = 0;
		fputs(Buffer, file);
	}
	return YES;
}

BOOL writeKeyValueString_(FILE *file, char *key, NSString *value) {
	writeKey(file, key);
	NSUInteger length = value.length;
	// CFStringGetBytes ((CFStringRef)string, range, kCFStringEncodingUTF8, 0, false, buffer, length, NULL);
	if (length == 0) {
		fputs("\"\";\n", file);
		return YES;
	}
	NSRange range;
	range.location = 0;
	range.length = length;
	if (!PropertyListValidChars)
		PropertyListValidChars = [[NSCharacterSet characterSetWithCharactersInString:@"$./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz"] invertedSet];
	NSRange ValidRange = [value rangeOfCharacterFromSet:PropertyListValidChars];
	unichar First = [value characterAtIndex:0];
	if (ValidRange.location > length && (First < '0' || First > '9')) {
		char Buffer[length + 4];
		[value getBytes:&Buffer maxLength:length usedLength:NULL encoding:NSASCIIStringEncoding options:0 range:NSMakeRange(0, length) remainingRange:NULL];
		Buffer[length++] = ';';
		Buffer[length++] = '\n';
		Buffer[length] = 0;
		fputs(Buffer, file);
	}
	else {
		NSUInteger bufferSizeLenght = length * 6 + 2;
		if (bufferSizeLenght > 32000) {
			bufferSizeLenght = 32000;
		}
		char charBuf[bufferSizeLenght];
		NSInteger bufLen = 0;
		// GSLog(@"Value: %@", Value);
		// charBuf=NSZoneMalloc(NULL,length*6+2);
		BOOL escape = YES;
		charBuf[bufLen++] = '\"';

		for (int idx = 0; idx < length; idx++) {
			unichar unicode = [value characterAtIndex:idx];
			if (unicode < ' ' || unicode == 127) {
				if (unicode == '\n' || unicode == '\t') {
					if (!escape) {
						charBuf[bufLen++] = (char)unicode;
					}
					else {
						charBuf[bufLen++] = '\\';
						charBuf[bufLen++] = (char)((unicode >> 6) + '0');
						charBuf[bufLen++] = (char)(((unicode >> 3) & 0x07) + '0');
						charBuf[bufLen++] = (char)((unicode & 0x07) + '0');
					}
				}
			}
			else if (unicode < 128) {
				if (escape && (unicode == '\"' || unicode == '\\'))
					charBuf[bufLen++] = '\\';
				charBuf[bufLen++] = (char)unicode;
			}
			else {
				charBuf[bufLen++] = (char)unicode;
				//				charBuf[bufLen++] = '\\';
				//				charBuf[bufLen++] = 'U';
				//				charBuf[bufLen++] = hex[(unicode >> 12) & 0x0F];
				//				charBuf[bufLen++] = hex[(unicode >> 8) & 0x0F];
				//				charBuf[bufLen++] = hex[(unicode >> 4) & 0x0F];
				//				charBuf[bufLen++] = hex[unicode & 0x0F];
			}
			if (bufLen > 31990) {
				charBuf[bufLen] = 0;
				fputs(charBuf, file);
				bufLen = 0;
			}
		}
		charBuf[bufLen++] = '\"';
		charBuf[bufLen++] = ';';
		charBuf[bufLen++] = '\n';
		charBuf[bufLen] = 0;
		fputs(charBuf, file);
	}
	return YES;
}
#endif

unsigned short writeInt(int n, char *restrict s) {
	unsigned short idx = 0;
	if (n < 0) {
		n = -n;
		s[idx++] = '-';
	}
	if (n < 10) {
		s[idx++] = n + '0';
		return idx;
	}
	if (n < 100) {
		s[idx + 1] = (n % 10) + '0';
		n *= 0.1;
		s[idx] = (n % 10) + '0';
		return idx + 2;
	}
	if (n < 1000) {
		s[idx + 2] = (n % 10) + '0';
		n *= 0.1;
		s[idx + 1] = (n % 10) + '0';
		n *= 0.1;
		s[idx] = (n % 10) + '0';
		return idx + 3;
	}

	short figureCount = 0;
	if (n < 10000)
		figureCount = 3;
	else if (n < 100000)
		figureCount = 4;
	else if (n < 1000000)
		figureCount = 5;
	short m = figureCount;
	for (; figureCount >= 0; figureCount--) {
		s[idx + figureCount] = (n % 10) + '0';
		n *= 0.1;
	}
	idx += m + 1;
	return idx;
}

#ifndef GLYPHS_VIEWER
BOOL writeKeyValueListBlock(FILE *file, char *key, NSArray *values, ListBlock_t block) {
	writeKey(file, key);
	fputs("(\n", file);
	for (NSObject *value in values) {
		block(file, value);
	}
	endArray(file);
	return YES;
}

BOOL writeIntList(FILE *file, NSArray *values) {
	fputs("(\n", file);
	for (NSNumber *value in values) {
		int intValue;
		if ([value isKindOfClass:[NSString class]] && ![(NSString *)value isNumber]) {
			writeStringSimple(file, (NSString *)value);
			fputs(",\n", file);
			continue;
		}
		intValue = [value intValue];
		char buffer[12];
		int result = writeInt(intValue, buffer);
		buffer[result++] = ',';
		buffer[result++] = '\n';
		buffer[result] = 0;
		fputs(buffer, file);
	}
	endArray(file);
	return YES;
}

BOOL writeKeyValueInt(FILE *file, char *key, int value) {
	writeKey(file, key);
	return writeValueInt(file, value);
}

BOOL writeValueInt(FILE *file, int Value) {
	char buffer[12];
	int result = writeInt(Value, buffer);
	buffer[result++] = ';';
	buffer[result++] = '\n';
	buffer[result] = 0;
	fputs(buffer, file);
	return YES;
}

BOOL writeFloat(FILE *file, CGFloat value, int precision) {
	GSFloatToStringWithPrecisionToFile(file, value, precision);
	return YES;
}

BOOL writeKeyValueFloat(FILE *file, char *key, CGFloat value) {
	size_t length = strlen((char *)key);
	char buffer[length + 20];
	size_t pos = 0;
	pos = sWriteKey(buffer, key);
	pos += GSFloatToStringWithPrecisionToBuffer(buffer + pos, value, 5);
	// writeFloat(file, value, 5);
	buffer[pos++] = ';';
	buffer[pos++] = '\n';
	buffer[pos] = 0;
	fputs(buffer, file);
	return YES;
}

BOOL writeValueFloat(FILE *file, CGFloat value) {
	writeFloat(file, value, 5);
	fputs(";\n", file);
	return YES;
}

BOOL writeKeyValueFloatList(FILE *file, char *key, NSArray *values, FloatValue_t block) {
	writeKey(file, key);
	fputs("(\n", file);
	for (NSObject *value in values) {
		char buffer[20] = {0};
		char *pos = buffer;
		GSFloatToStringWithPrecisionToBuffer(pos, block(value), 3);
		fprintf(file, "%s,\n", buffer);
	}
	endArray(file);
	return YES;
}

BOOL writeKeyValueFloatPrecision(FILE *file, char *key, CGFloat value, int precision) {
	writeKey(file, key);
	writeFloat(file, value, precision);
	fputs(";\n", file);
	return YES;
}

char *writeTransformToBuffer(NSAffineTransformStruct ts, char *buffer) {
	char *pos = buffer;
	pos += GSFloatToStringWithPrecisionToBuffer(pos, ts.m11, 5);
	pos[0] = ',';
	pos[1] = ' ';
	pos += 2;
	pos += GSFloatToStringWithPrecisionToBuffer(pos, ts.m12, 5);
	pos[0] = ',';
	pos[1] = ' ';
	pos += 2;
	pos += GSFloatToStringWithPrecisionToBuffer(pos, ts.m21, 5);
	pos[0] = ',';
	pos[1] = ' ';
	pos += 2;
	pos += GSFloatToStringWithPrecisionToBuffer(pos, ts.m22, 5);
	pos[0] = ',';
	pos[1] = ' ';
	pos += 2;
	pos += GSFloatToStringWithPrecisionToBuffer(pos, ts.tX, 3);
	pos[0] = ',';
	pos[1] = ' ';
	pos += 2;
	pos += GSFloatToStringWithPrecisionToBuffer(pos, ts.tY, 3);
	return pos;
}

BOOL writePoint(FILE *file, NSPoint pt, BOOL compact) {
	if (fabs(pt.x) > 0.0001 || fabs(pt.y) > 0.0001) {
		char *buffer = malloc(80);
		char *pos = buffer;
		if (compact) {
			strcpy(pos, "pos=(");
			pos += 5;
		}
		else {
			strcpy(pos, "pos = (");
			pos += 7;
		}
		pos += GSFloatToStringWithPrecisionToBuffer(pos, pt.x, 3);
		pos[0] = ',';
		pos++;
		pos += GSFloatToStringWithPrecisionToBuffer(pos, pt.y, 3);
		strcpy(pos, ");\n");
		pos += 3;
		pos[0] = '\0';
		fputs(buffer, file);
		if (buffer)
			free(buffer);
	}
	return YES;
}

BOOL writeTuple2(FILE *file, char *key, CGFloat value1, CGFloat value2, int precision) {
	if (fabs(value1) > 0.0001 || fabs(value2) > 0.0001) {
		char *buffer = malloc(80);
		char *pos = buffer;
		strcpy(pos, key);
		pos += strlen(key);
		strcpy(pos, " = (");
		pos += 4;
		pos += GSFloatToStringWithPrecisionToBuffer(pos, value1, precision);
		pos[0] = ',';
		pos++;
		pos += GSFloatToStringWithPrecisionToBuffer(pos, value2, precision);
		strcpy(pos, ");\n");
		pos += 3;
		pos[0] = '\0';
		fputs(buffer, file);
		if (buffer)
			free(buffer);
	}
	return YES;
}

BOOL writeTransform(FILE *file, NSAffineTransformStruct ts, BOOL compact) {
	if (fabs(ts.m11 - 1) > 0.0001 || fabs(ts.m12) > 0.0001 || fabs(ts.m21) > 0.0001 || fabs(ts.m22 - 1) > 0.0001 || fabs(ts.tX) > 0.0001 || fabs(ts.tY) > 0.0001) {
		char *buffer = malloc(100);
		char *pos = buffer;
		if (compact) {
			strcpy(pos, "transform = \"");
			pos += 13;
		}
		else {
			strcpy(pos, "transform = \"{");
			pos += 14;
		}
		pos = writeTransformToBuffer(ts, pos);
		if (compact) {
			strcpy(pos, "\";\n");
			pos += 3;
		}
		else {
			strcpy(pos, "}\";\n");
			pos += 4;
		}
		pos[0] = '\0';
		fputs(buffer, file);
		if (buffer)
			free(buffer);
	}
	return YES;
}

BOOL writeDateString(FILE *file, NSDate *date) {
	// 2012-05-24 16:44:10 +0000
	time_t time = [date timeIntervalSince1970];
	struct tm timeStruct = *gmtime(&time);
	fprintf(file, "\"%d-%02d-%02d %02d:%02d:%02d +0000\"", timeStruct.tm_year + 1900, timeStruct.tm_mon + 1, timeStruct.tm_mday, timeStruct.tm_hour, timeStruct.tm_min, timeStruct.tm_sec);
	return YES;
}
#endif
