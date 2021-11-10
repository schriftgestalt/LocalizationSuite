/*!
 @header
 LTMultipleKeyMatcher.m
 Created by max on 26.06.09.

 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "LTMultipleKeyMatcher.h"

#import "LTKeyMatch.h"
#import "LTKeyMatchInternal.h"

@implementation LTMultipleKeyMatcher

- (id)init {
	self = [super init];

	if (self != nil) {
		_keyObjects = nil;
		_keysAreSorted = NO;
		_matchesAreSorted = NO;
	}

	return self;
}

#pragma mark - Accessors

@synthesize targetKeyObjects = _keyObjects;

- (void)setTargetKeyObjects:(NSArray *)keyObjects {
	_keyObjects = keyObjects;
	_keysAreSorted = NO;
}

- (void)setMatchingKeyObjects:(NSArray *)objects {
	[super setMatchingKeyObjects:objects];
	_matchesAreSorted = NO;
}

#pragma mark - Actions

- (void)matchingThread {
	@autoreleasepool {

		// Init
		NSArray *sorting = [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:_matchLanguage ascending:YES selector:@selector(compareAsString:)]];
		NSString *baseTargetLanguage = [[self class] baseLanguageForLanguage:_targetLanguage];

		// Start
		if ([[self delegate] respondsToSelector:@selector(keyMatcherBeganMatching:)])
			[[self delegate] keyMatcherBeganMatching:self];

		// Sort both the target keys and the matching keys if necessary
		if (!_keysAreSorted) {
			[self setTargetKeyObjects:[_keyObjects sortedArrayUsingDescriptors:sorting]];
			_keysAreSorted = YES;
		}
		if (!_matchesAreSorted) {
			[self setMatchingKeyObjects:[_matchingObjects sortedArrayUsingDescriptors:sorting]];
			_matchesAreSorted = YES;
		}

		// Perform
		for (NSUInteger m = 0, k = 0; k < [_keyObjects count] && m < [_matchingObjects count]; k++) {
			// Loop was aborted
			if (_abort)
				break;

			// Get the key objects
			BLKeyObject *keyObject = [_keyObjects objectAtIndex:k];
			BLKeyObject *matchKeyObject = [_matchingObjects objectAtIndex:m];

			// Get the string to match
			NSString *targetString = [keyObject stringForLanguage:_matchLanguage];
			if (![targetString length])
				continue;

			// Search for the right match key object
			while (([targetString compareAsString:[matchKeyObject valueForKey:_matchLanguage]] == NSOrderedDescending || ([matchKeyObject isEmptyForLanguage:_targetLanguage] && [matchKeyObject isEmptyForLanguage:baseTargetLanguage])) && m < [_matchingObjects count] - 1)
				matchKeyObject = [_matchingObjects objectAtIndex:++m];

			// No key object found, try the next one
			if ([targetString compareAsString:[matchKeyObject valueForKey:_matchLanguage]] != NSOrderedSame)
				continue;

			// Create match object
			NSString *actualTargetLanguage = ([matchKeyObject isEmptyForLanguage:_targetLanguage]) ? baseTargetLanguage : _targetLanguage;
			LTKeyMatch *match = [[LTKeyMatch alloc] initWithKeyObject:matchKeyObject matchPercentage:1.0 forTargetLanguage:_targetLanguage actualTargetLanguage:actualTargetLanguage andMatchLanguage:_matchLanguage];
			if ([[self delegate] respondsToSelector:@selector(keyMatcher:foundMatch:forKeyObject:)])
				[[self delegate] keyMatcher:self foundMatch:match forKeyObject:keyObject];
		}

		// Finish
		if ([[self delegate] respondsToSelector:@selector(keyMatcherFinishedMatching:)])
			[[self delegate] keyMatcherFinishedMatching:self];

	end:
		_abort = NO;
		_running = NO;
	}
}

@end
