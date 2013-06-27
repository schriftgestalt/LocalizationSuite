/*!
 @header
 BLLocalizerExportStepExtensions.m
 Created by max on 19.02.10.
 
 @copyright 2010 Localization Suite. All rights reserved.
 */

#import "BLLocalizerExportStepExtensions.h"

@interface BLLocalizerExportStep (BLLocalizerExportStepInternal)

- (void)setDescriptionWithStatus:(NSString *)status;

@end


@implementation BLLocalizerExportStep (BLLocalizerExportStepExtensions)

- (NSArray *)tailoredKeysFromAvailableKeys:(NSArray *)availableKeys
{
	// Get the languages
	NSString *referenceLanguage = [[[self manager] document] referenceLanguage];
	NSMutableArray *targetLanguages = [NSMutableArray arrayWithArray: _languages];
	[targetLanguages removeObject: referenceLanguage];
	
	// Create the collector
	LTKeyMatchCollector *collector = [LTKeyMatchCollector collector];
	
	// Match without guessing
	if (!(_options & BLLocalizerExportStepIncludeGuessesOption)) {
		// Set up the matcher
		LTMultipleKeyMatcher *matcher = [[LTMultipleKeyMatcher alloc] init];
		matcher.matchLanguage = referenceLanguage;
		matcher.matchingKeyObjects = availableKeys;
		matcher.targetKeyObjects = [BLObject keyObjectsFromArray: _objects];
		matcher.delegate = collector;
		
		// Update status
		[self setDescriptionWithStatus: NSLocalizedStringFromTableInBundle(@"LTLocalizerExportDictionary", @"Localizable", [NSBundle bundleForClass: [LTMultipleKeyMatcher class]], nil)];
		
		// We track the remining keys to reduce the matching overhead with each language
		NSMutableSet *remainingKeys = [NSMutableSet setWithArray: availableKeys];
		
		for (NSString *language in targetLanguages) {
			matcher.targetLanguage = language;
			
			// Run matcher
			[matcher start];
			[matcher waitUntilFinished];
			
			// Remove already matched (included) keys
			[remainingKeys minusSet: [NSSet setWithArray: [collector matchingKeyObjects]]];
			matcher.matchingKeyObjects = [remainingKeys allObjects];
		}
	}
	// Match with guessing
	else {
		// Set up the matcher
		LTSingleKeyMatcher *matcher = [[LTSingleKeyMatcher alloc] init];
		matcher.matchLanguage = referenceLanguage;
		matcher.matchingKeyObjects = availableKeys;
		matcher.guessingIsEnabled = YES;
		matcher.delegate = collector;
		
		// We track the remining keys to reduce the matching overhead with each iteration
		NSMutableSet *remainingKeys = [NSMutableSet setWithArray: availableKeys];
		
		// Match all keys for all languages
		NSArray *targetKeys = [BLObject keyObjectsFromArray: _objects];
		NSUInteger counter = 0;
		
		for (NSString *language in targetLanguages) {
			matcher.targetLanguage = language;
			
			for (BLKeyObject *key in targetKeys) {
				// Find matched for the specific key
				matcher.targetKeyObject = key;
				
				[matcher start];
				[matcher waitUntilFinished];
				
				// Remove already matched (included) keys
				[remainingKeys minusSet: [NSSet setWithArray: [collector matchingKeyObjects]]];
				matcher.matchingKeyObjects = [remainingKeys allObjects];
				
				// And sometimes...
				if (counter % 20 == 0) {
					// Update status
					NSUInteger progress = ((counter * 100) / ([targetKeys count] * [targetLanguages count]));
					[self setDescriptionWithStatus: [NSString stringWithFormat: NSLocalizedStringFromTableInBundle(@"LTLocalizerExportMatchStatus", @"Localizable", [NSBundle bundleForClass: [LTSingleKeyMatcher class]], nil), progress]];
					
					// Check abortion status
					if ([self isCancelled])
						return nil;
				}
				counter++;
			}
		}
	}
	
	// Done
	return [collector matchingKeyObjects];
}

@end
