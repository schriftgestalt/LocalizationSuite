//
//  NSStringHelpers.h
//  GlyphsCore
//
//  Created by Georg Seifert on 06.08.09.
//  Copyright 2009 schriftgestaltung.de. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define MAX_UNICODE 0x10FFFF

#ifndef GLYPHS_VIEWER
NSString *GSFloatToStringFull(CGFloat Float, int precision);

NSString *GSFloatToStringWithPrecision(CGFloat Float, int precision);

size_t GSFloatToStringWithPrecisionToBuffer(char *buffer, CGFloat Float, int precision);

void GSFloatToStringWithPrecisionToFile(FILE *file, CGFloat Float, int precision);

NSString *GSFloatToStringWithPrecisionMin(CGFloat Float, int precision, int minPrecision);
#endif
NSString *GSFloatToStringWithPrecisionLocalized(CGFloat Float, int precision);
#ifndef GLYPHS_VIEWER
NSString *GSFloatToStringWithPrecisionLocale(CGFloat Float, int precision, NSLocale *locale);

NSString *GSFloatToStringLocalized(CGFloat Float);

NSString *GSFloatToString(CGFloat Float);

NSString *GSPointToString(NSPoint P);
#endif

size_t GSIndexPathToBuffer(char *buffer, NSIndexPath *indexPath, BOOL addSpace);

NSString *GSStringFromIndexPath(NSIndexPath *indexPath, BOOL addSpace);

NSIndexPath *GSIndexPathFromString(NSString *string);

NSArray *GSIntListFromIndexPath(NSIndexPath *indexPath);
NSIndexPath *GSIndexPathFromIntList(NSArray *intList);

NSString *GSTagStringFromFourCharCode(FourCharCode code);
/// Panics if the tag string is not four `unichar` characters long.
FourCharCode GSFourCharCodeFromTagString(NSString *tag);

@interface NSString (UUID)

+ (NSString *)UUID;

+ (NSString *)hexStringFromInt:(NSInteger)integer;

#ifndef GLYPHS_VIEWER
+ (NSString *)hexStringFromUnsignedInteger:(NSUInteger)integer;
#endif

- (int)hexStringToInt;

+ (NSString *)stringWithChar:(UTF32Char)aChar;

- (NSString *)ascciString;

- (NSUInteger)countOfChar:(char)aChar;

+ (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix;

- (NSString *)absolutePathFromBaseDirPath:(NSString *)baseDirPath;

- (NSString *)relativePathFromBaseDirPath:(NSString *)baseDirPath;

//- (NSString *)encodeForPlist;

/**
 @param index A 16-bit character index, by reference. If the index points to a high surrogate character, it will be incremented on output so that the low surrogate is skipped.
 */
- (UTF32Char)character32AtIndex:(NSUInteger *)index;

+ (NSString *)encodeForFilePath:(NSString *)string;

+ (NSString *)encodeForASCII:(NSString *)string;

+ (NSString *)createStringForKey:(CGKeyCode)keyCode;

- (NSString *)stringByDeletingDotSuffix;

- (NSString *)stringByDeletingLastDotSuffix;

- (NSString *)dotSuffix;

- (NSString *)stringByAppendingDotSuffix:(NSString *)suffix;

- (float)localizedFloatValue;

- (double)localizedDoubleValue;

- (NSString *)stringWithFirstLower;

- (NSString *)stringWithFirstUpper;

- (NSString *)camelCaseToSentenceCase;

- (NSRange)rangeOfLine:(NSUInteger)line;

- (NSUInteger)lineNumberAtIndex:(NSUInteger)idx;

- (BOOL)isNumber;

- (BOOL)isAllDigits;

- (BOOL)isHexCapitalString;

- (BOOL)isHexCapitalStringWithLength:(NSUInteger)length;

@end

unsigned short writeInt(int n, char *restrict s);

#ifndef GLYPHS_VIEWER
BOOL writeIntList(FILE *file, NSArray *values);

BOOL stringNeedsQuotes(NSString *string);

void writeKeyString(FILE *File, NSString *key);

void writeKey(FILE *file, const char *key);

size_t sWriteKey(char *buffer, const char *key);

BOOL writeKeyValueStringEscape(FILE *file, char *key, NSString *Value, BOOL escape);
BOOL writeStringEscape(FILE *file, NSString *value, BOOL escape);

size_t sWriteStringEscape(char *buffer, NSString *value, BOOL escape);

BOOL writeKeyValueString(FILE *file, char *key, NSString *Value);
BOOL writeKeyValueStringLine(FILE *file, char *key, NSString *Value);
BOOL writeKeyValueStringSimple(FILE *file, char *key, NSString *Value);
BOOL writeKeyValueInt(FILE *file, char *key, int Value);
BOOL writeValueInt(FILE *file, int Value);

BOOL writeKeyValueData(FILE *file, char *key, NSData *Value);

BOOL writeKeyValueInt(FILE *file, char *key, int Value);
BOOL writeFloat(FILE *file, CGFloat value, int precision);
BOOL writeKeyValueFloat(FILE *file, char *key, CGFloat Value);
BOOL writeValueFloat(FILE *file, CGFloat value);
BOOL writeKeyValueFloatPrecision(FILE *file, char *key, CGFloat Value, int precision);

typedef double (^FloatValue_t)(NSObject *);

BOOL writeKeyValueFloatList(FILE *file, char *key, NSArray *values, FloatValue_t block);

typedef void (^ListBlock_t)(FILE *file, NSObject *value);

BOOL writeKeyValueListBlock(FILE *file, char *key, NSArray *values, ListBlock_t block);

BOOL writePoint(FILE *file, NSPoint pt, BOOL Compact);
BOOL writeTuple2(FILE *file, char *key, CGFloat value1, CGFloat value2, int precision);
BOOL writeColor(FILE *file, char *key, NSColor *color);
BOOL writeTransform(FILE *file, NSAffineTransformStruct ts, BOOL Compact);
char *writeTransformToBuffer(NSAffineTransformStruct ts, char *buffer);

BOOL writeStringSimple(FILE *file, NSString *Value);
BOOL writeDateString(FILE *file, NSDate *date);

short GSActualPrecision(CGFloat Float, int precision);
void endArray(FILE *file);
#endif
