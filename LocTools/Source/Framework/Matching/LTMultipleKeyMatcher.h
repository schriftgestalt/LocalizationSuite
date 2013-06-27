/*!
 @header
 LTMultipleKeyMatcher.h
 Created by max on 26.06.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

#import <LocTools/LTKeyMatcher.h>

/*!
 @abstract A matching object that assynchronously matches a multiple key objects with set of key objects.
 @discussion In order to find matches, the match languages's value of the target key object is compared to same value of each matching key object. This matcher does NOT support any kinf of guessing but is optimized for performance on plain matches (liear time). Any matched key objects must contain a non-empty value for the target language.
 During matching, at most one match per key object is returned, even if there would be multiple translations.
 For matching single key objects or guessing support, please refer to LTSingleKeyMatcher.
 */
@interface LTMultipleKeyMatcher : LTKeyMatcher
{
	NSArray	*_keyObjects;
	BOOL	_keysAreSorted;
	BOOL	_matchesAreSorted;
}

/*!
 @abstract The key objects for which matches should be found.
 */
@property(nonatomic, strong) NSArray *targetKeyObjects;

@end
