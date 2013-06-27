/*!
 @header
 BLStringSegmentation.h
 Created by Max on 17.02.10.
 
 @copyright 2010 Localization Suite. All rights reserved.
 */

/*!
 @abstract Methods fore splitting strings into segments.
 */
@interface NSString (BLStringSegmentation)

/*!
 @abstract Constants defining the kind of segmentation to be applied.
 
 @const BLParagraphSegmentation		Strings are split by paragraphs, namely newline characters.
 @const BLSentenceSegmentation		Strings are split by sentcences, denoted by punctuation characters.
 @const BLWordSegmentation			Strings are split by words, delimited by whitespace characters. Words DO include punctuation characters such as sentence marks. If you do not want this binding, use BLDetailedSegmentation.
 @const BLDetailedSegmentation		Strings are split by detailled words. This is similar to BLWordSegmentation, except that punctuation characters are separate segments.
 */
typedef enum {
	BLParagraphSegmentation	= 1,
	BLSentenceSegmentation	= 2,
	BLWordSegmentation		= 3,
	BLDetailedSegmentation	= 4
} BLSegmentationType;

/*!
 @abstract Segments the string according to a segmentation type.
 @discussion The returned array are the segments. If delimiters is not NULL, it will be set with the strings that delimit the segments. As such, the count of the delimiters is always one larger than the count of the returned segments. The first delimiter is sequence of leading characters that were dropped, the last on the trailing part. Inbetween, the i-th segment was split from the (i+1)-th one by the (i+1)-th delimiter.
 */
- (NSArray *)segmentsForType:(BLSegmentationType)type delimiters:(NSArray **)delimiters;

/*!
 @abstract Splits the string into segments and delimiters.
 @discussion The resulting array has the form delimiter.(segment.delimiter)*. It thus always starts and ends with a delimiter and has a delimiter between any two segments.
 */
- (NSArray *)splitForType:(BLSegmentationType)type;

/*!
 @abstract Convenience method to join previously split segments and delimiters back into a single string.
 */
+ (NSString *)stringByJoiningSegments:(NSArray *)segments withDelimiters:(NSArray *)delimiters;

@end
