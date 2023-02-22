//
//  utf8.h
//  GlyphsCore
//
//  Created by Georg Seifert on 29/12/15.
//  Copyright (c) 2015 schriftgestaltung.de. All rights reserved.
//

#ifndef __GlyphsCore__utf8__
#define __GlyphsCore__utf8__

#include <stdio.h>

typedef enum UTF8ConversionResult {
	ConversionSuccess = 0, /* conversion successful */
	SourceExhausted = 1,   /* partial char in source, but hit end */
	SourceCorrupt = 2,	   /* corrupted character in source */
	TargetExhausted = 4	   /* no room in target for conversion */
} ConversionResult;		   /* bit-field holding conversion result */

typedef char UTF8;
typedef unsigned short UTF16;
typedef unsigned int UTF32;

typedef enum {
	strictConversion = 0,
	lenientConversion
} ConversionFlags;

ConversionResult convertUTF8toUTF16(const UTF8 **source_p, const UTF8 *sourceEnd, UTF16 **target_p, ConversionFlags flags);
ConversionResult charUTF16toUTF8(const UTF16 **sourceStart, const UTF16 *sourceEnd, UTF8 **targetStart, UTF8 *targetEnd, ConversionFlags flags);

unsigned short UTF32toUTF8(UTF32 ch, UTF8 *target);

#endif /* defined(__GlyphsCore__utf8__) */
