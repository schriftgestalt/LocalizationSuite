/*!
 @header
 LTSingleKeyMatcher.h
 Created by max on 26.06.09.

 @copyright 2009 Localization Suite. All rights reserved.
 */

#import <LocTools/LTDifferenceEngine.h>
#import <LocTools/LTKeyMatcher.h>

/*!
 @abstract A matching object that assynchronously matches a single key object with set of key objects.
 @discussion In order to find matches, the match languages's value of the target key object is compared to same value of each matching key object. This can either be done exactly (guessingEnabled == NO) or using the LTDifferenceEngine, which also returns matches that have a value higher than 50%. Any matched key objects must contain a non-empty value for the target language.
 For matching multiple key objects, please refer to LTMultipleKeyMatcher for a more efficient implementation.
 */
@interface LTSingleKeyMatcher : LTKeyMatcher {
	BOOL _guessing;
	BLSegmentationType _guessingType;
	BLKeyObject *_keyObject;
}

/*!
 @abstract The key object for which matches should be found.
 */
@property (strong) BLKeyObject *targetKeyObject;

/*!
 @abstract Returns whether guessing is enabled or not.
 @discussion If enabled, also key objects with non-exact match values will be retuned as match. Of course, this adds an extra complexity to the process.
 */
@property (assign) BOOL guessingIsEnabled;

/*!
 @abstract The type used for guessing the match value.
 @discussion Defaults to BLDetailedSegmentation.
 */
@property (assign) BLSegmentationType guessingType;

@end
