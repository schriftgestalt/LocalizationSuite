/*
 *  Reading and writing UTF-8 and ISO-Latin-1 streams.
 *
 *  Platform: Neutral
 *
 *  Version: 3.00  2001/05/05  First release.
 *  Version: 3.01  2001/09/18  Updated.
 *  Version: 3.08  2001/11/11  Added utf8_to_latin1, utf8_is_latin1.
 *  Version: 3.11  2001/12/12  Added unicode_char_to_utf8 and vice versa.
 *  Version: 3.12  2001/12/13  Added utf8_length function.
 *  Version: 3.29  2002/08/22  Fixed bugs in utf8_to_latin1, write_latin1.
 *  Version: 3.32  2002/09/04  Added correct_utf8 function.
 *  Version: 3.50  2004/01/11  Uses const keyword for some param strings.
 *  Version: 3.56  2005/08/09  Silenced some conversion warnings.
 */

/* Copyright (c) L. Patrick and the Unicode organisation.

 This file is part of the App cross-platform programming package.
 You may redistribute it and/or modify it under the terms of the
 App Software License. See the file LICENSE.TXT for details.

 Portions of this code were developed by the Unicode organisation
 for free use by programmers, to promote the Unicode standard.
 */

/*
 *  UTF-8 is a way of reading and writing Unicode 32-bit characters
 *  to ordinary 8-bit communications streams.
 *
 *  The UTF-8 algorithm stores characters into variable-sized
 *  chunks. Characters in the range 0x00 to 0x7F fit into one
 *  byte, since these will be quite common (ASCII values).
 *  Characters with higher values fit into two, three, four,
 *  five, or six bytes, depending on the number of significant
 *  bits, according to the following pattern:
 *
 *  Bits  Pattern
 *  ----  -------
 *    7   0xxxxxxx
 *   11   110xxxxx 10xxxxxx
 *   16   1110xxxx 10xxxxxx 10xxxxxx
 *   21   11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
 *   26   111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
 *   32   111111xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
 *
 *  As can be seen from the table, at most 32 bits can be stored
 *  using this algorithm (the x's mark where the actual bits go,
 *  the numbers signify the padding bits). The padding "10" at
 *  the start of a byte uniquely identifies a continuation byte,
 *  which is never used as the start of a UTF-8 character sequence,
 *  so if a stream is broken for some reason, the algorithm can
 *  skip those bytes to find the next start of a character.
 *
 *  ASCII is a 7-bit encoding for the English language alphabet
 *  and various digits and symbols. Its values range from 0x00 to 0x7F.
 *
 *  A superset of ASCII is ISO-Latin-1 (code page 8859-1). This is
 *  an 8-bit encoding for Western European languages, with values
 *  in the range 0x00 to 0xFF. The lower half of this range is
 *  the same as ASCII, while the upper half includes many accented
 *  characters.
 *
 *  Unicode is a superset of ISO-Latin-1, which mostly fits into
 *  16-bits, but which is actually a 32-bit encoding for most
 *  language symbols on Earth, including Eastern European, African,
 *  Asian, and many other languages. It allows a single document
 *  to contain mixtures of all languages.
 *
 *  This file contains functions for reading and writing Unicode
 *  and ISO-Latin-1 streams, to and from an array of 32-bit
 *  Unicode values in memory. Each 32-bit value is called a Char.
 */

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>

//#include "apputils.h"
#include "utf8.h"

enum {
	Low6Bits = 0x3F,  /* 00111111 */
	High2Bits = 0xC0, /* 11000000 */
	ByteMask = 0xBF,  /* 10111111 */
	ByteMark = 0x80	  /* 10xxxxxx */
};

typedef uint8_t byte;
typedef uint8_t Char;

// static const unsigned long ReplacementChar = 0x0000FFFDUL;
// static const unsigned long MaximumChar     = 0x7FFFFFFFUL;

static const byte UTF8ExtraBytes[256] = {
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
	2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5};
/*
 * Magic values subtracted from a buffer value during UTF8 conversion.
 * This table contains as many values as there might be trailing bytes
 * in a UTF-8 sequence.
 */

static const UTF32 offsetsFromUTF8[6] = {0x00000000UL, 0x00003080UL, 0x000E2080UL,
										 0x03C82080UL, 0xFA082080UL, 0x82082080UL};

#define UNI_SUR_HIGH_START (UTF32)0xD800
#define UNI_SUR_HIGH_END (UTF32)0xDBFF
#define UNI_SUR_LOW_START (UTF32)0xDC00
#define UNI_SUR_LOW_END (UTF32)0xDFFF

/* Some fundamental constants */
#define UNI_REPLACEMENT_CHAR (UTF32)0x0000FFFD
#define UNI_MAX_BMP (UTF32)0x0000FFFF
#define UNI_MAX_UTF16 (UTF32)0x0010FFFF
#define UNI_MAX_UTF32 (UTF32)0x7FFFFFFF
#define UNI_MAX_LEGAL_UTF32 (UTF32)0x0010FFFF

#define UNI_MAX_UTF8_BYTES_PER_CODE_POINT 4

static const int halfShift = 10; /* used for shifting by 10 bits */

static const UTF32 halfBase = 0x0010000UL;
static const UTF32 halfMask = 0x3FFUL;

static const UTF8 firstByteMark[7] = {0x00, 0x00, 0xC0, 0xE0, 0xF0, 0xF8, 0xFC};

static bool isLegalUTF8(const UTF8 *source, int length) {
	byte a;
	const UTF8 *srcptr = source + length;
	switch (length) {
		default:
			return false;
			/* Everything else falls through when "true"... */
		case 4:
			if ((a = (byte)(*--srcptr)) < 0x80 || a > 0xBF)
				return false;
		case 3:
			if ((a = (byte)(*--srcptr)) < 0x80 || a > 0xBF)
				return false;
		case 2:
			if ((a = (byte)(*--srcptr)) < 0x80 || a > 0xBF)
				return false;

			switch ((int)*source) {
					/* no fall-through in this inner switch */
				case 0xE0:
					if (a < 0xA0)
						return false;
					break;
				case 0xED:
					if (a > 0x9F)
						return false;
					break;
				case 0xF0:
					if (a < 0x90)
						return false;
					break;
				case 0xF4:
					if (a > 0x8F)
						return false;
					break;
				default:
					if (a < 0x80)
						return false;
			}

		case 1:
			if ((byte)*source >= 0x80 && (byte)*source < 0xC2)
				return false;
	}
	if ((int)*source > 0xF4)
		return false;
	return true;
}

ConversionResult convertUTF8toUTF16(const UTF8 **source_p, const UTF8 *sourceEnd, UTF16 **target_p, ConversionFlags flags) {
	byte extraBytesToRead = UTF8ExtraBytes[(byte) * *source_p];
	if (extraBytesToRead == 0) {
		*(*target_p)++ = **source_p;
		return ConversionSuccess;
	}
	if (extraBytesToRead >= sourceEnd - *source_p) {
		return SourceExhausted;
	}
	/* Do this check whether lenient or strict */
	if (!isLegalUTF8(*source_p, extraBytesToRead + 1)) {
		return SourceCorrupt;
	}
	/*
	 * The cases all fall through. See "Note A" below.
	 */
	UTF32 ch = 0;
	switch (extraBytesToRead) {
		case 5:
			ch += (byte) * (*source_p)++;
			ch <<= 6; /* remember, illegal UTF-8 */
		case 4:
			ch += (byte) * (*source_p)++;
			ch <<= 6; /* remember, illegal UTF-8 */
		case 3:
			ch += (byte) * (*source_p)++;
			ch <<= 6;
		case 2:
			ch += (byte) * (*source_p)++;
			ch <<= 6;
		case 1:
			ch += (byte) * (*source_p)++;
			ch <<= 6;
		case 0:
			ch += (byte) * (*source_p)++;
	}
	ch -= offsetsFromUTF8[extraBytesToRead];

	if (ch <= UNI_MAX_BMP) { /* Target is a character <= 0xFFFF */
		/* UTF-16 surrogate values are illegal in UTF-32 */
		if (ch >= UNI_SUR_HIGH_START && ch <= UNI_SUR_LOW_END) {
			if (flags == strictConversion) {
				*source_p -= (extraBytesToRead + 1); /* return to the illegal value itself */
				return SourceCorrupt;
			}
			else {
				*(*target_p)++ = UNI_REPLACEMENT_CHAR;
			}
		}
		else {
			*(*target_p)++ = (UTF16)ch; /* normal case */
		}
	}
	else if (ch > UNI_MAX_UTF16) {
		if (flags == strictConversion) {
			*source_p -= (extraBytesToRead + 1); /* return to the start */
			return SourceCorrupt;
		}
		else {
			*(*target_p)++ = UNI_REPLACEMENT_CHAR;
		}
	}
	else {
		/* target is a character in range 0xFFFF - 0x10FFFF. */
		ch -= halfBase;
		*(*target_p)++ = (UTF16)((ch >> halfShift) + UNI_SUR_HIGH_START);
		*(*target_p)++ = (UTF16)((ch & halfMask) + UNI_SUR_LOW_START);
	}
	return ConversionSuccess;
}

ConversionResult ConvertUTF8toUTF16(const UTF8 **sourceStart, const UTF8 *sourceEnd,
									UTF16 **targetStart, UTF16 *targetEnd, ConversionFlags flags) {
	ConversionResult result = ConversionSuccess;
	const UTF8 *source = *sourceStart;
	UTF16 *target = *targetStart;
	while (source < sourceEnd) {
		result = convertUTF8toUTF16(&source, sourceEnd, &target, flags);
	}
	*sourceStart = source;
	*targetStart = target;
	return result;
}

ConversionResult charUTF16toUTF8(const UTF16 **sourceStart, const UTF16 *sourceEnd, UTF8 **targetStart, UTF8 *targetEnd, ConversionFlags flags) {
	ConversionResult result = ConversionSuccess;
	const UTF16 *source = *sourceStart;
	UTF8 *target = *targetStart;
	UTF32 ch;
	unsigned short bytesToWrite = 0;

	// const UTF16* oldSource = source; /* In case we have to back up because of target overflow. */
	ch = *source++;
	/* If we have a surrogate pair, convert to UTF32 first. */
	if (ch >= UNI_SUR_HIGH_START && ch <= UNI_SUR_HIGH_END) {
		/* If the 16 bits following the high surrogate are in the source buffer... */
		if (source < sourceEnd) {
			UTF32 ch2 = *source;
			/* If it's a low surrogate, convert to UTF32. */
			if (ch2 >= UNI_SUR_LOW_START && ch2 <= UNI_SUR_LOW_END) {
				ch = ((ch - UNI_SUR_HIGH_START) << halfShift) + (ch2 - UNI_SUR_LOW_START) + halfBase;
				++source;
			}
			else if (flags == strictConversion) { /* it's an unpaired high surrogate */
				--source;						  /* return to the illegal value itself */
				return SourceCorrupt;
			}
		}
		else {		  /* We don't have the 16 bits following the high surrogate. */
			--source; /* return to the high surrogate */
			return SourceExhausted;
		}
	}
	else if (flags == strictConversion) {
		/* UTF-16 surrogate values are illegal in UTF-32 */
		if (ch >= UNI_SUR_LOW_START && ch <= UNI_SUR_LOW_END) {
			--source; /* return to the illegal value itself */
			return SourceCorrupt;
		}
	}
	/* Figure out how many bytes the result will require */
	if (ch < 0x80) {
		bytesToWrite = 1;
	}
	else if (ch < 0x800) {
		bytesToWrite = 2;
	}
	else if (ch < 0x10000) {
		bytesToWrite = 3;
	}
	else if (ch < 0x110000) {
		bytesToWrite = 4;
	}
	else {
		bytesToWrite = 3;
		ch = UNI_REPLACEMENT_CHAR;
	}

	target += bytesToWrite;
	if (target > targetEnd) {
		return TargetExhausted;
	}
	switch (bytesToWrite) { /* note: everything falls through. */
		case 4:
			*--target = (UTF8)((ch | ByteMark) & ByteMask);
			ch >>= 6;
		case 3:
			*--target = (UTF8)((ch | ByteMark) & ByteMask);
			ch >>= 6;
		case 2:
			*--target = (UTF8)((ch | ByteMark) & ByteMask);
			ch >>= 6;
		case 1:
			*--target = (UTF8)(ch | firstByteMark[bytesToWrite]);
	}
	target += bytesToWrite;
	*sourceStart = source;
	*targetStart = target;
	return result;
}

unsigned short UTF32toUTF8(UTF32 ch, UTF8 *target) {

	unsigned short bytesToWrite = 0;
	/* Figure out how many bytes the result will require */
	if (ch < 0x80) {
		bytesToWrite = 1;
	}
	else if (ch < 0x800) {
		bytesToWrite = 2;
	}
	else if (ch < 0x10000) {
		bytesToWrite = 3;
	}
	else if (ch < 0x110000) {
		bytesToWrite = 4;
	}
	else {
		bytesToWrite = 3;
		ch = UNI_REPLACEMENT_CHAR;
	}

	target += bytesToWrite;

	switch (bytesToWrite) { /* note: everything falls through. */
		case 4:
			*--target = (UTF8)((ch | ByteMark) & ByteMask);
			ch >>= 6;
		case 3:
			*--target = (UTF8)((ch | ByteMark) & ByteMask);
			ch >>= 6;
		case 2:
			*--target = (UTF8)((ch | ByteMark) & ByteMask);
			ch >>= 6;
		case 1:
			*--target = (UTF8)(ch | firstByteMark[bytesToWrite]);
	}

	return bytesToWrite;
}
