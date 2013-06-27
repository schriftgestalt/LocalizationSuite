/*!
 @header
 LTKeyMatchCollector.h
 Created by max on 19.02.10.
 
 @copyright 2010 Localization Suite. All rights reserved.
 */

/*!
 @abstract An object that can be used as the delegate of a LTKeyMatcher to collect all matches.
 */
@interface LTKeyMatchCollector : NSObject
{
	NSMutableArray	*_matches;
	NSMutableSet	*_keyObjects;
}

/*!
 @abstract Convenience allocator, creates a blank collector.
 */
+ (LTKeyMatchCollector *)collector;

/*!
 @abstract The matches found
 */
- (NSArray *)matches;

/*!
 @abstract The matching key objects that were found by the matchers.
 */
- (NSArray *)matchingKeyObjects;

/*!
 @abstract Clears all found objects.
 */
- (void)reset;

@end
