/* Copyright (c) 2006-2007 Christopher J. W. Lloyd

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

#import <Foundation/NSObject.h>

@class NSMutableData, NSData;

// void encodePropertyList(id plist, CFMutableDataRef data, BOOL escape);
//-(NSData*)dataForRootObject:object;

NSData *nullTerminatedASCIIDataWithString(NSString *string);

NSData *nullTerminatedASCIIDataWithPropertyList(id plist);

NSData *dataWithPropertyList(id plist);

NSString *stringWithPropertyList(id plist);

NSString *stringWithPropertyListNoEscape(id plist);

BOOL writePropertyListToFile(FILE *file, id plist);

BOOL writePropertyListToFileNoEscape(FILE *file, id plist);

void GSEncodeArray(NSArray *array, CFMutableDataRef data, BOOL escape);
void GSEncodeString(NSString *string, CFMutableDataRef data, BOOL escape);
void GSEncodePoint(NSPoint point, CFMutableDataRef data);
void GSEncodeFloat(CGFloat Float, CFMutableDataRef data);
void GSEncodeColor(NSColor *color, CFMutableDataRef data);
// BOOL GSWritePropertyListToFile(id object, NSString *path, BOOL atomically);

// BOOL GSWritePropertyListToURL(id plist, NSURL *url, BOOL atomically);
