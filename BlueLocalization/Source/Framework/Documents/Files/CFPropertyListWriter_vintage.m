/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

// Original - Christopher Lloyd <cjwl@objc.net>
#import "CFPropertyListWriter_vintage.h"
#import "NSStringHelpers.h"
#import "NSData_Conversion.h"
#import "utf8.h"

static BOOL _NSPropertyListNameSet[128] = {
	NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO,				   // 0
	NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO, NO,				   // 16
	NO, NO, NO, NO, YES, NO, NO, NO, NO, NO, NO, NO, NO, NO, YES, NO,			   // 32
	YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, NO, NO, NO, NO, NO, NO,	   // 48
	NO, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, // 64
	YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, NO, NO, NO, NO, YES,	   // 80
	NO, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, // 96
	YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, YES, NO, NO, NO, NO, NO,	   // 112
};

static inline void GSEncodePropertyList(id plist, CFMutableDataRef data, BOOL escape);
#if 0
static NSInteger keySort(id key1, id key2, void *context) {

	if ([key1 isKindOfClass:[NSString class]]
			&& [key2 isKindOfClass:[NSString class]])
		return [key1 compare:key2];
	else
		//undefined
		return NSOrderedDescending;
}
#endif

static inline void _encodeString(unichar *buffer, CFMutableDataRef data, BOOL escape, NSUInteger length, NSString *string) {
	NSInteger idx;

	CFRange range;
	range.location = 0;
	range.length = (CFIndex)length;
	CFStringGetCharacters((__bridge CFStringRef)string, range, buffer);
	NSInteger isNumber = -1;
	for (idx = 0; idx < length; idx++) {
		if (buffer[idx] >= 128 || !_NSPropertyListNameSet[buffer[idx]]) {
			break;
		}
		if (isNumber < 0 && !((buffer[idx] >= '0' && buffer[idx] <= '9') || (idx == 0 && buffer[idx] == '-') || buffer[idx] == '.')) {
			isNumber = idx;
		}
	}
	// const char *hex = "0123456789ABCDEF";
	if (idx >= length && isNumber == 0) {
		UInt8 charBuf[length];

		for (idx = 0; idx < length; idx++)
			charBuf[idx] = (UInt8)buffer[idx];

		CFDataAppendBytes((CFMutableDataRef)data, charBuf, (CFIndex)length);
	}
	else {
		NSInteger maxBufLen = (length * 6);
		if (maxBufLen > 2000) {
			maxBufLen = 2000;
		}
		char charBuf[maxBufLen + 8];
		NSInteger bufLen = 0;
		const UTF16 *source = buffer;
		UTF16 *sourceEnd = (UTF16 *)(source + length);
		UTF8 *target = charBuf;
		UTF8 *targetEnd = charBuf + maxBufLen + 6;
		*target++ = '\"';

		while (source < sourceEnd) {
			unichar unicode = *source++;
			if (unicode < ' ' || unicode == 127) {
				if (!escape && (unicode == '\t' || unicode == '\n')) {
					*target++ = (UInt8)unicode;
				}
				else {
					*target++ = '\\';
					*target++ = (UInt8)((unicode >> 6) + '0');
					*target++ = (UInt8)(((unicode >> 3) & 0x07) + '0');
					*target++ = (UInt8)((unicode & 0x07) + '0');
				}
			}
			else if (unicode < 128) {
				if (unicode == '\"' || unicode == '\\')
					*target++ = '\\';
				*target++ = (UInt8)unicode;
			}
			else {
				source--;
				charUTF16toUTF8(&source, sourceEnd, &target, targetEnd, lenientConversion);
				//				*target++ = '\\';
				//				*target++ = 'U';
				//				*target++ = (UInt8) hex[(unicode >> 12) & 0x0F];
				//				*target++ = (UInt8) hex[(unicode >> 8) & 0x0F];
				//				*target++ = (UInt8) hex[(unicode >> 4) & 0x0F];
				//				*target++ = (UInt8) hex[unicode & 0x0F];
			}
			bufLen = target - charBuf;
			if (bufLen > maxBufLen) {
				CFDataAppendBytes((CFMutableDataRef)data, (UInt8 *)charBuf, bufLen);
				bufLen = 0;
				target = charBuf;
			}
		}
		*target++ = '\"';
		bufLen++;
		CFDataAppendBytes((CFMutableDataRef)data, (UInt8 *)charBuf, bufLen);
	}
}

inline void GSEncodeString(NSString *string, CFMutableDataRef data, BOOL escape) {
	const NSUInteger length = string.length;
	if (length == 0) {
		CFDataAppendBytes((CFMutableDataRef)data, (UInt8 *)"\"\"", 2);
		return;
	}
	if (length < 2000) {
		unichar buffer[length + 2];
		_encodeString(buffer, data, escape, length, string);
	}
	else {
		unichar *buffer = malloc((length + 2) * sizeof(unichar));
		_encodeString(buffer, data, escape, length, string);
		free(buffer);
	}
}

/*
void encodeString_(NSString * string, CFMutableDataRef data, BOOL escape) {
	NSUInteger length = string.length;
	unichar  buffer[length];
	int	  i;

	//[string getCharacters:buffer];
	CFRange range;
	range.location = 0;
	range.length = length;
	CFStringGetCharacters((CFStringRef)string, range, buffer);
	//CFStringGetBytes ((CFStringRef)string, range, kCFStringEncodingUTF8, 0, false, buffer, length, NULL);
	if (length == 0) {
		CFDataAppendBytes((CFMutableDataRef)data, (UInt8*)"\"\"", 2);
		return;
	}
	for (idx = 0; idx < length; idx++)
		if (buffer[idx] >= 128 || !_NSPropertyListNameSet[buffer[idx]])
			break;

	if (idx >= length){
		//char *charBuf;
		UInt8 charBuf[length];

		//charBuf = NSZoneMalloc(NULL, length);

		for (idx = 0; idx < length; idx++)
			charBuf[idx] = buffer[idx];

		//[_data appendBytes:charBuf length:length];
		CFDataAppendBytes ((CFMutableDataRef)data, charBuf, length);
		//NSZoneFree(NULL,charBuf);
	}
	else {
		//char *charBuf;
		UInt8 charBuf[length * 6 + 2];
		int  bufLen=0;

		//charBuf = NSZoneMalloc(NULL,length*6+2);

		charBuf[bufLen++] = '\"';

		for (idx = 0; idx < length; idx++){
			unichar unicode = buffer[idx];

			if (unicode < ' ' || unicode == 127){
				if (!escape && unicode == '\n'){
					charBuf[bufLen++] = unicode;
				}
				else {
					charBuf[bufLen++] = '\\';
					charBuf[bufLen++] = (unicode>>6)+'0';
					charBuf[bufLen++] = ((unicode>>3)&0x07)+'0';
					charBuf[bufLen++] = (unicode&0x07)+'0';
				}
			}
			else if (unicode < 128){
				if (escape && (unicode == '\"' || unicode == '\\'))
					charBuf[bufLen++] = '\\';
				charBuf[bufLen++] = unicode;
			}
			else {
				const char *hex="0123456789ABCDEF";

				charBuf[bufLen++] = '\\';
				charBuf[bufLen++] = 'U';
				charBuf[bufLen++] = hex[(unicode>>12)&0x0F];
				charBuf[bufLen++] = hex[(unicode>>8)&0x0F];
				charBuf[bufLen++] = hex[(unicode>>4)&0x0F];
				charBuf[bufLen++] = hex[unicode&0x0F];
			}
		}

		charBuf[bufLen++] = '\"';
		CFDataAppendBytes ((CFMutableDataRef)data, charBuf, bufLen);
		//[_data appendBytes:charBuf length:bufLen];
		//NSZoneFree(NULL,charBuf);
	}
}
*/

void GSEncodeArray(NSArray *array, CFMutableDataRef data, BOOL escape) {
	NSInteger count = array.count;
	NSInteger idx = 0;
	//[_data appendBytes:"(\n" length:2];
	CFDataAppendBytes(data, (UInt8 *)"(\n", 2);
	for (id object in array) {
		//[self encodeIndent:indent];
		GSEncodePropertyList(object, data, escape);
		if (idx + 1 < count) {
			CFDataAppendBytes((CFMutableDataRef)data, (UInt8 *)",\n", 2);
			//[_data appendBytes:",\n" length:2];
		}
		else {
			CFDataAppendBytes((CFMutableDataRef)data, (UInt8 *)"\n", 1);
			//[_data appendBytes:"\n" length:1];
		}
		idx++;
	}
	//[self encodeIndent:indent-1];
	CFDataAppendBytes((CFMutableDataRef)data, (UInt8 *)")", 1);
	//[_data appendBytes:")" length:1];
}

static inline void GSEncodeDictionary(NSDictionary *dictionary, CFMutableDataRef data, BOOL escape);
static inline void GSEncodeDictionary(NSDictionary *dictionary, CFMutableDataRef data, BOOL escape) {
	// NSArray *allKeys = [[dictionary allKeys] sortedArrayUsingFunction:keySort context:NULL];
	NSArray *allKeys = [[dictionary allKeys] sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
		if ([obj1 isKindOfClass:[obj2 class]]) { // this is the most common case as there will be most likly NSStrings
			return [obj1 compare:obj2];
		}
		NSString *string1 = [obj1 description]; // this is needed to get rid of OC_BuiltinPythonNumbers and such
		NSString *string2 = [obj2 description];
		return [string1 compare:string2];
	}];
	CFDataAppendBytes(data, (UInt8 *)"{\n", 2);
	for (id key in allKeys) {
		if ([key respondsToSelector:@selector(UTF8String)]) {
			GSEncodeString(key, data, escape);
		}
		else if ([key isKindOfClass:[NSNumber class]]) {
			char buffer[20];
			char *pos = buffer;
			pos += GSFloatToStringWithPrecisionToBuffer(pos, [(NSNumber *)key floatValue], 8);
			NSUInteger length = pos - buffer;
			CFDataAppendBytes(data, (UInt8 *)buffer, length);
		}
		else {
			GSEncodeString([key description], data, escape);
		}
		//[_data appendBytes:" = " length:3];
		CFDataAppendBytes(data, (UInt8 *)" = ", 3);
		GSEncodePropertyList(dictionary[key], data, escape);
		//[_data appendBytes:";\n" length:2];
		CFDataAppendBytes(data, (UInt8 *)";\n", 2);
	}
	//	if (indent > 0)
	//		[self encodeIndent:indent-1];
	//[_data appendBytes:"}" length:1];
	CFDataAppendBytes(data, (UInt8 *)"}", 1);
}

@interface NSObject (property)
- (id)propertyListValueFormat:(int)format;
- (BOOL)propertyListToData:(CFMutableDataRef)data format:(int)formatVersion error:(NSError **)error;
@end

void GSEncodeFloat(CGFloat aFloat, CFMutableDataRef data) {
	char buffer[20];
	NSUInteger length = GSFloatToStringWithPrecisionToBuffer(buffer, aFloat, 5);
	CFDataAppendBytes(data, (UInt8 *)buffer, length);
}

void GSEncodeColor(NSColor *color, CFMutableDataRef data) {
	CGFloat C1 = 0;
	CGFloat C2 = 0;
	CGFloat C3 = 0;
	CGFloat C4 = 1;
	CGFloat C5 = 1;
	int count;
	int components = -1;
	@try { // from 10.13 we could check color.type
		components = (int)[color numberOfComponents];
	}
	@catch (NSException *exception) {
		color = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
		components = (int)[color numberOfComponents];
	}
	switch (components) {
		case 2:
			C1 = [color whiteComponent];
			C2 = [color alphaComponent];
			count = 2;
			break;
		case 4:
			C1 = [color redComponent];
			C2 = [color greenComponent];
			C3 = [color blueComponent];
			C4 = [color alphaComponent];
			count = 4;
			break;
		case 5:
			C1 = [color cyanComponent];
			C2 = [color magentaComponent];
			C3 = [color yellowComponent];
			C4 = [color blackComponent];
			C5 = [color alphaComponent];
			count = 5;
			break;
		default:
			NSLog(@"invalid Color");
			return;
	}
	char buffer[20];
	char *pos = buffer;
	pos[0] = '(';
	pos++;
	pos += GSFloatToStringWithPrecisionToBuffer(pos, C1 * 255, 0);
	pos[0] = ',';
	pos++;
	pos += GSFloatToStringWithPrecisionToBuffer(pos, C2 * 255, 0);
	if (count > 2) {
		pos[0] = ',';
		pos++;
		pos += GSFloatToStringWithPrecisionToBuffer(pos, C3 * 255, 0);
		pos[0] = ',';
		pos++;
		pos += GSFloatToStringWithPrecisionToBuffer(pos, C4 * 255, 0);
	}
	if (count > 4) {
		pos[0] = ',';
		pos++;
		pos += GSFloatToStringWithPrecisionToBuffer(pos, C5 * 255, 0);
	}
	pos[0] = ')';
	pos++;
	NSUInteger length = pos - buffer;
	CFDataAppendBytes(data, (UInt8 *)buffer, length);
}

inline void GSEncodePoint(NSPoint point, CFMutableDataRef data) {
	char buffer[20];
	char *pos = buffer;
	pos[0] = '(';
	pos++;
	pos += GSFloatToStringWithPrecisionToBuffer(pos, point.x, 4);
	pos[0] = ',';
	pos++;
	pos += GSFloatToStringWithPrecisionToBuffer(pos, point.y, 4);
	pos[0] = ')';
	pos++;
	NSUInteger length = pos - buffer;
	CFDataAppendBytes(data, (UInt8 *)buffer, length);
}

static inline void GSEncodePropertyList(id plist, CFMutableDataRef data, BOOL escape) {
	if ([plist isKindOfClass:[NSString class]])
		GSEncodeString(plist, data, escape);
	else if ([plist isKindOfClass:[NSArray class]])
		GSEncodeArray(plist, data, escape);
	else if ([plist isKindOfClass:[NSDictionary class]])
		GSEncodeDictionary(plist, data, escape);
	else if ([plist isKindOfClass:[NSNumber class]]) {
		GSEncodeFloat([plist doubleValue], data);
	}
	else if ([plist isKindOfClass:[NSData class]]) {
		NSString *endcodedString = [(NSData *)plist hexadecimalString];
		CFDataAppendBytes(data, (UInt8 *)"<", 1);
		CFDataAppendBytes(data, (const unsigned char *)[[endcodedString dataUsingEncoding:NSUTF8StringEncoding] bytes], endcodedString.length);
		CFDataAppendBytes(data, (UInt8 *)">", 1);
	}
	else if ([plist isKindOfClass:[NSColor class]]) {
		GSEncodeColor(plist, data);
	}
	else if ([plist isKindOfClass:[NSValue class]]) {
		const char *cType = [plist objCType];
		if (strcmp(cType, "{CGPoint=dd}") == 0) {
			NSPoint point = [plist pointValue];
			GSEncodePoint(point, data);
		}
		else if (strcmp(cType, "{CGSize=dd}") == 0) {
			NSPoint size = [plist pointValue]; // luckily, NSPoint and NSSize are "compatible"
			GSEncodePoint(size, data);
		}
	}
	else {
		GSEncodeString([plist description], data, escape);
	}
}

//-(void)encodePropertyList_:plist {
//	[self encodePropertyList:plist escape:YES];
//}

//-(NSData *)dataForRootObject:object {
//	[self encodePropertyList:object escape:YES];
//	return _data;
//}

// NSData * nullTerminatedASCIIDataWithString(NSString * string);
// CFMutableDataRef nullTerminatedASCIIDataWithString(NSString * string) {
//	[self encodeString:string escape:NO];
//	//[_data appendBytes:"\0" length:1];
//	CFDataAppendBytes ((CFMutableDataRef)_data, (UInt8*)"\0", 1);
//	return _data;
// }
//
//+(NSData *)nullTerminatedASCIIDataWithString:(NSString *)string {
//	NSPropertyListWriter_vintage *writer = [self new];
//	NSData *result=[[[writer nullTerminatedASCIIDataWithString:string] retain] autorelease];
//
//	[writer release];
//
//	return result;
// }

//-(NSData *)nullTerminatedASCIIDataWithPropertyList:plist {
//	[self encodePropertyList:plist escape:YES];
//	[_data appendBytes:"\0" length:1];
//	CFDataAppendBytes ((CFMutableDataRef)_data, (UInt8*)"\0", 1);
//	return _data;
//}

//+(NSData *)nullTerminatedASCIIDataWithPropertyList:plist {
//	NSPropertyListWriter_vintage *writer = [self new];
//	NSData *result = [[[writer nullTerminatedASCIIDataWithPropertyList:plist] retain] autorelease];
//
//	[writer release];
//
//	return result;
//}

NSData *dataWithPropertyList(id plist) {
	NSMutableData *data = [NSMutableData data];
	GSEncodePropertyList(plist, (__bridge CFMutableDataRef)data, YES);
	return data;
}

BOOL writePropertyListToFileNoEscape(FILE *file, id plist) {
	// NSPropertyListWriter_vintage *writer = [self new];
	NSMutableData *data = [NSMutableData new];
	GSEncodePropertyList(plist, (__bridge CFMutableDataRef)data, NO);
	fwrite([data bytes], data.length, 1, file);
	return YES;
}

BOOL writePropertyListToFile(FILE *file, id plist) {
	// NSPropertyListWriter_vintage *writer = [self new];
	NSMutableData *data = [NSMutableData new];
	GSEncodePropertyList(plist, (__bridge CFMutableDataRef)data, YES);
	fwrite([data bytes], data.length, 1, file);
	return YES;
}

NSString *stringWithPropertyListNoEscape(id plist) {
	// NSPropertyListWriter_vintage *writer = [self new];
	NSMutableData *data = [NSMutableData new];
	GSEncodePropertyList(plist, (__bridge CFMutableDataRef)data, NO);
	NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return result;
}

NSString *stringWithPropertyList(id plist) {
	// NSPropertyListWriter_vintage *writer = [self new];
	NSMutableData *data = [NSMutableData new];
	GSEncodePropertyList(plist, (__bridge CFMutableDataRef)data, YES);
	NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return result;
}

/*
BOOL GSWritePropertyListToFile(id plist, NSString *path, BOOL atomically) {
#ifdef DEBUG
	NSDate *startTime = [NSDate date];
#endif
	NSMutableData *data = [NSMutableData new];
	encodePropertyList(plist, (__bridge CFMutableDataRef) data, YES);

	GSLog(@"dataForRootObject time: %f", [startTime timeIntervalSinceNow] * -1.0);
	BOOL result = [data writeToFile:path atomically:atomically];
	GSLog(@"writeToFile time: %f", [startTime timeIntervalSinceNow] * -1.0);
	return result;
}

BOOL GSWritePropertyListToURL(id plist, NSURL *url, BOOL atomically) {
#ifdef DEBUG
	NSDate *startTime = [NSDate date];
#endif
	NSMutableData *data = [[NSMutableData alloc] initWithCapacity:200000];
	encodePropertyList(plist, (__bridge CFMutableDataRef) data, YES);
	GSLog(@"dataForRootObject time: %f", [startTime timeIntervalSinceNow] * -1.0);
	//BOOL						  result = [data writeToFile:path atomically:atomically];
	SInt32 errorCode;
	BOOL result = CFURLWriteDataAndPropertiesToResource((__bridge CFURLRef) url, (__bridge CFDataRef) data, NULL, &errorCode);
	GSLog(@"writeToFile time: %f", [startTime timeIntervalSinceNow] * -1.0);
	return result;
}
 */
