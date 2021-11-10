/*!
 @header
 LTAutotranslationStep.m
 Created by max on 26.06.09.

 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "LTAutotranslationStep.h"

#import "LTKeyMatch.h"
#import "LTMultipleKeyMatcher.h"

/*!
 @abstract Internal methods of LTAutotranslationStep.
 */
@interface LTAutotranslationStep (LTAutotranslationStepInternal)

- (id)initForAutotranslatingObjects:(NSArray *)objects forLanguage:(NSString *)language andReferenceLanguage:(NSString *)referenceLanguage;

@end

@implementation LTAutotranslationStep

+ (id)stepForAutotranslatingObjects:(NSArray *)objects forLanguage:(NSString *)language andReferenceLanguage:(NSString *)referenceLanguage {
	return [[[self class] alloc] initForAutotranslatingObjects:objects forLanguage:language andReferenceLanguage:referenceLanguage];
}

- (id)initForAutotranslatingObjects:(NSArray *)objects forLanguage:(NSString *)language andReferenceLanguage:(NSString *)referenceLanguage {
	self = [super init];

	if (self) {
		_objects = objects;
		_language = language;
		_reference = referenceLanguage;
	}

	return self;
}

#pragma mark - Runtime

- (void)perform {
	NSMutableArray *emptyObjects;

	// Filter all empty objects
	emptyObjects = [NSMutableArray arrayWithCapacity:[_objects count]];
	for (BLKeyObject *object in _objects) {
		if ([object isEmptyForLanguage:_language])
			[emptyObjects addObject:object];
	}

	// Set up matcher
	_matcher = [LTMultipleKeyMatcher new];
	[_matcher setDelegate:self];

	[_matcher setTargetKeyObjects:emptyObjects];
	[_matcher setTargetLanguage:_language];

	[_matcher setMatchingKeyObjects:[[BLDictionaryController sharedInstance] availableKeys]];
	[_matcher setMatchLanguage:_reference];

	// Run matching
	[_matcher start];
	[_matcher waitUntilFinished];

	// Finish
	_matcher = nil;
}

- (void)keyMatcher:(LTKeyMatcher *)matcher foundMatch:(LTKeyMatch *)match forKeyObject:(BLKeyObject *)target {
	NSAssert(matcher == _matcher, @"Wrong matcher returning data");
	NSAssert([[match targetLanguage] isEqual:_language], @"Wrong target language");

	[target setObject:[match targetValue] forLanguage:_language];
	[target setFlags:[target flags] | BLKeyObjectAutotranslatedFlag];
}

- (NSString *)action {
	return NSLocalizedStringFromTableInBundle(@"Autotranslating", @"LTAutotranslationStep", [NSBundle bundleForClass:[self class]], nil);
}

- (NSString *)description {
	return [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"AutotranslatingText", @"LTAutotranslationStep", [NSBundle bundleForClass:[self class]], nil), [_objects count], [BLLanguageTranslator descriptionForLanguage:_language]];
}

@end
