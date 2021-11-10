/*!
 @header
 LTSingleKeyMatcher.m
 Created by max on 26.06.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "LTSingleKeyMatcher.h"

#import "LTKeyMatch.h"
#import "LTKeyMatchInternal.h"
#import "LTDifferenceEngine.h"


@implementation LTSingleKeyMatcher

- (id)init
{
	self = [super init];
	
	if (self != nil) {
		_keyObject = nil;
		_guessing = NO;
		_guessingType = BLDetailedSegmentation;
	}
	
	return self;
}



#pragma mark - Accessors

@synthesize targetKeyObject=_keyObject;
@synthesize guessingIsEnabled=_guessing;
@synthesize guessingType=_guessingType;


#pragma mark - Actions

- (void)matchingThread
{
	@autoreleasepool {
		NSOperationQueue *queue = [NSOperationQueue mainQueue];
		
		// Init
		NSString *targetString = [_keyObject stringForLanguage: _matchLanguage];
		if (![targetString length])
			goto bail;
			
		// Start
		if ([[self delegate] respondsToSelector: @selector(keyMatcherBeganMatching:)])
			[[self delegate] keyMatcherBeganMatching: self];
		
		// Perform
		NSRange range = NSMakeRange(0, 100);
		while (range.location < [_matchingObjects count]) {
			NSArray *objects = [_matchingObjects subarrayWithRange: NSIntersectionRange(range, NSMakeRange(0, [_matchingObjects count]))];
			[queue addOperation: [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(processObjects:) object:objects]];
			
			range.location += range.length;
		}
		
		// Finish
		[queue waitUntilAllOperationsAreFinished];
		
		if ([[self delegate] respondsToSelector: @selector(keyMatcherFinishedMatching:)])
			[[self delegate] keyMatcherFinishedMatching: self];
		
bail:
		_abort = NO;
		_running = NO;
		
	}
}

- (void)processObjects:(NSArray *)objects
{
	@autoreleasepool {
	
	// Setup
		NSString *targetString = [_keyObject stringForLanguage: _matchLanguage];
		LTDifferenceEngine	*engine = [[LTDifferenceEngine alloc] init];
		[engine setSegmentation: _guessingType];
		[engine setNewString: targetString];	
		
		NSString *baseTargetLanguage = [[self class] baseLanguageForLanguage: _targetLanguage];
		
		// Process
		for (BLKeyObject *matchKey in objects) {
			if (_abort)
				break;
			
			// Check target value
			if (matchKey == _keyObject)
				continue;
			
			// Try to find a target language
			NSString *actualTargetLanguage = _targetLanguage;
			if ([matchKey isEmptyForLanguage: actualTargetLanguage])
				actualTargetLanguage = baseTargetLanguage;
			if ([matchKey isEmptyForLanguage: actualTargetLanguage])
				continue;
			
			// Match matching value
			NSString *matchString = [matchKey stringForLanguage: _matchLanguage];
			BOOL result = [targetString isEqual: matchString];
			float matchValue = 1;
			
			// Guess matching value
			if (!result && _guessing) {
				[engine setOldString: matchString];
				[engine computeMatchValueOnly];
				
				matchValue = [engine matchValue]; 
				result = (matchValue > 0.50);
			}
			if (!result)
				continue;
			
			// Create match object
			LTKeyMatch *match = [[LTKeyMatch alloc] initWithKeyObject:matchKey matchPercentage:matchValue forTargetLanguage:_targetLanguage actualTargetLanguage:actualTargetLanguage andMatchLanguage:_matchLanguage];
			if ([[self delegate] respondsToSelector: @selector(keyMatcher:foundMatch:forKeyObject:)])
				[[self delegate] keyMatcher:self foundMatch:match forKeyObject:_keyObject];
		}
		
		// Clean up
	}
}

@end
