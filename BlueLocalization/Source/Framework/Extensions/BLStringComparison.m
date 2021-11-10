/*!
 @header
 BLStringComparisson.m
 Created by Max on 13.05.09.

 @copyright 2004-2009 Localization Suite. All rights reserved.
 */

#import "BLStringComparison.h"

@implementation NSObject (BLStringComparison)

- (NSComparisonResult)compareAsString:(id)other {
	id obj1, obj2;

	// init
	obj1 = self;
	obj2 = other;

	// convert if neccessary
	if ([obj1 isKindOfClass:[NSAttributedString class]])
		obj1 = [obj1 string];
	if ([obj2 isKindOfClass:[NSAttributedString class]])
		obj2 = [obj2 string];

	// just some crash safety
	if (![obj1 isKindOfClass:[NSString class]])
		obj1 = [obj1 description];
	if (![obj2 isKindOfClass:[NSString class]])
		obj2 = [obj2 description];

	// let the others do the job
	return [obj1 compare:obj2];
}

@end

#define SELECTOR @selector(characterAtIndex:)

typedef unichar (*unichar_IMP)(id, SEL, ...);

static inline BOOL isHexDigit(unichar c) {
	return (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F');
}

static inline int hexValue(unichar c) {
	if (c >= '0' && c <= '9')
		return c - '0';
	if (c >= 'a' && c <= 'f')
		return c - 87;
	if (c >= 'A' && c <= 'F')
		return c - 55;

	return 0;
}

static inline NSComparisonResult compareUnsigned(unsigned a, unsigned b) {
	if (a >= 'a' && a <= 'z')
		a -= 32;
	if (b >= 'a' && b <= 'z')
		b -= 32;

	return (a == b) ? NSOrderedSame : (a < b ? NSOrderedAscending : NSOrderedDescending);
}

static NSComparisonResult compareHexaNumerically(NSString *s1, NSString *s2, unsigned int offset1, unsigned int offset2, unichar_IMP imp1, unichar_IMP imp2) {
	unsigned int len1 = (unsigned int)[s1 length] - offset1;
	unsigned int len2 = (unsigned int)[s2 length] - offset2;
	unichar c1 = 0, c2 = 0;

	// skip all common, nonnumeric characters
	unsigned int i, count = MIN(len1, len2);

	for (i = 0; i < count; i++) {
		c1 = imp1(s1, SELECTOR, offset1 + i);
		c2 = imp2(s2, SELECTOR, offset2 + i);
		if (c1 != c2 || isHexDigit(c1) || isHexDigit(c2))
			break;
	}

	// one string is prefix of the other string
	// so we just need to compare the two lengths
	if (i == count) {
		return compareUnsigned(len1, len2);
	}
	else {
		BOOL isHex1 = isHexDigit(c1);
		BOOL isHex2 = isHexDigit(c2);

		// both substrings have a numeric prefix
		if (isHex1 && isHex2) {
			unsigned long long v1 = hexValue(c1);
			unsigned long long v2 = hexValue(c2);
			unsigned int i1, i2;

			// calculate the integer values
			for (i1 = i + 1; i1 < len1; i1++) {
				unichar c = imp1(s1, SELECTOR, offset1 + i1);
				if (isHexDigit(c))
					v1 = (16 * v1) + hexValue(c);
				else
					break;
			}

			for (i2 = i + 1; i2 < len2; i2++) {
				unichar c = imp2(s2, SELECTOR, offset2 + i2);
				if (isHexDigit(c))
					v2 = (16 * v2) + hexValue(c);
				else
					break;
			}

			// recursive function call if both values are equal
			return (v1 == v2) ? compareHexaNumerically(s1, s2, offset1 + i1, offset2 + i2, imp1, imp2) : ((v1 < v2) ? NSOrderedAscending : NSOrderedDescending);

			// both characters are nonnumeric and not equal
		}
		else {
			return compareUnsigned(c1, c2);
		}
	}
}

@implementation NSString (BLStringComparison)

- (NSComparisonResult)naturalCompare:(NSString *)aString {
	return [self compare:aString options:NSNumericSearch];
}

- (NSComparisonResult)hexanumericalCompare:(NSString *)aString {
	if (self == aString)
		return NSOrderedSame;
	else
		return compareHexaNumerically(self, aString, 0, 0, (unichar_IMP)[self methodForSelector:SELECTOR], (unichar_IMP)[aString methodForSelector:SELECTOR]);
}

@end
