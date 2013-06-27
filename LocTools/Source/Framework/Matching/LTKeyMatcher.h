/*!
 @header
 LTKeyMatcher.h
 Created by max on 06.06.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

@class LTKeyMatch;

/*!
 @abstract Abstract superclass of all key matchers.
 @discussion Basically this class hosts everything that all matchers have in common, with the differneces only being quite small.
 */
@interface LTKeyMatcher : NSObject
{
	BOOL		_abort;
	id			_delegate;
	NSString	*_matchLanguage;
	NSArray		*_matchingObjects;
	BOOL		_running;
	NSString	*_targetLanguage;
}

/*!
 @abstract Returns the base language for a given language.
 @discussion The base language of a language is created by removing county and script codes. For example, the base of pt_BR is pt, whereas the base for fr is still fr.
 */
+ (NSString *)baseLanguageForLanguage:(NSString *)language;

/*!
 @abstract The language the matching is to be performed on.
 */
@property(strong) NSString *matchLanguage;

/*!
 @abstract The language for which the matches are to be found.
 @discussion All matching key objects must have a non-empty value for this language.
 */
@property(strong) NSString *targetLanguage;

/*!
 @abstract The key objects to match with.
 @discussion The contained objects are of class BLKeyObjects.
 */
@property(strong) NSArray *matchingKeyObjects;

/*!
 @abstract The delegate of the matcher.
 @discussion While this can be any arbitrary object, if will only be sent the messages defined in LTDictionaryMatcherDelegate.
 */
@property(strong) id delegate;


/*!
 @abstract Start the matching.
 @discussion If a match is currently being performed, it is aborted. Make sure that the delegate is set.
 */
- (void)start;

/*!
 @abstract Stops the matching immediatelly.
 @discussion This is a blocking call that stops any running match or does nothing if no match was started beforehand.
 */
- (void)stop;

/*!
 @abstract Returns whether the matcher is currently running.
 */
- (BOOL)isRunning;

/*!
 @abstract Blocks the current thread until the matcher is finished (isRunning returns NO).
 */
- (void)waitUntilFinished;

@end

@interface NSObject (LTDictionaryMatcherDelegate)

/*!
 @abstract Delegate notification that matching has begun.
 */
- (void)keyMatcherBeganMatching:(LTKeyMatcher *)matcher;

/*!
 @abstract Delegate notification that matching has ended.
 @discussion This can be either due to a manual stop using -stop or because the match finished.
 */
- (void)keyMatcherFinishedMatching:(LTKeyMatcher *)matcher;

/*!
 @abstract Informs about a found match.
 @discussion Primary matching delegate method.
 */
- (void)keyMatcher:(LTKeyMatcher *)matcher foundMatch:(LTKeyMatch *)match forKeyObject:(BLKeyObject *)target;

@end

