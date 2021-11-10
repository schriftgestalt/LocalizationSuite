/*!
 @header
 LTDifferenceEngine.h
 Created by max on 20.03.05.

 @copyright 2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract A engine that computes the difference between two given strings.
 @discussion The input is a "old" string and a "new" string which can be seen as generations of the same object. The algorithm then computes all differences using a given granularity. The result is a array of differences where substrings of the input strings are matched against each other. Another outcome is a "match value" which basically represents how similar or different the strings are.
 */
@interface LTDifferenceEngine : NSObject {
	NSMutableArray *_differences;
	void *engine;
	float _matchValue;
	NSArray *_newSegments;
	NSString *_newString;
	NSArray *_oldSegments;
	NSString *_oldString;
	BLSegmentationType _segmentation;
}

/*!
 @abstract The granularity of the comparison.
 */
@property (nonatomic, assign) BLSegmentationType segmentation;

/*!
 @abstract The new (or right) string in the comparison.
 */
@property (nonatomic, strong) NSString *newString;

/*!
 @abstract The old (or left) string in the comparison.
 */
@property (nonatomic, strong) NSString *oldString;

/*!
 @abstract Runs the engine and computes differences.
 @discussion After the method returns, -differences and -matchValue will contain valid return values for the comparison.
 */
- (void)computeDifferences;

/*!
 @abstract Runs the engine and computes the match value only.
 @discussion While this method has the same run time as -computeDifferences, it only computes the match value, saving the memory that would have been occupied by the difference objects otherwise.
 */
- (void)computeMatchValueOnly;

/*!
 @abstract An array of differences.
 @discussion Returns an array of LTDifference objects describing the differences of the both strings in detail. This method will only return reliable values after either -computeDifferences have been called.
 */
- (NSArray *)differences;

/*!
 @abstract The percentace the given strings match.
 @discussion Possible value range is [0.0,1.0] where 0 means nothing in common and 1 means that the strings are the same. This method will only return reliable values after either -computeDifferences or -computeMatchValueOnly have been called.
 */
- (float)matchValue;

@end
