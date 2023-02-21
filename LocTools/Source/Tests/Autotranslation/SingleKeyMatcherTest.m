//
//  KeyMatcherTest.m
//  LocTools
//
//  Created by max on 07.06.09.
//  Copyright 2009 Blue Technologies Group. All rights reserved.
//

#import "SingleKeyMatcherTest.h"

#import <BlueLocalization/BLStringKeyObject.h>

#define HC_SHORTHAND
#import "KeyValueMatcher.h"
#import <hamcrest/hamcrest.h>

@implementation SingleKeyMatcherTest

- (void)setUp {
	NSFileWrapper *wrapper;
	NSArray *keyObjects;

	// Load Dictionary
	wrapper = [[NSFileWrapper alloc] initWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"AppKit-de" ofType:@"lod" inDirectory:@"Test Data/Autotranslation"]];
	keyObjects = [BLDictionaryFile objectsFromFile:wrapper readingProperties:NULL];
	XCTAssertTrue([keyObjects count] > 0, @"Dictionary not loaded");

	// Init Matcher
	matcher = [LTSingleKeyMatcher new];
	[matcher setMatchingKeyObjects:keyObjects];
	[matcher setMatchLanguage:@"en"];
	[matcher setTargetLanguage:@"de"];

	// Init Key object
	keyObject = [BLStringKeyObject keyObjectWithKey:@"test"];
	[matcher setTargetKeyObject:keyObject];

	// Init delegate
	BOOL value = YES;
	delegate = [OCMockObject mockForClass:[self class]];
	[[[delegate stub] andReturnValue:[NSValue value:(const void *)&value withObjCType:@encode(BOOL)]] respondsToSelector:(__bridge void *)OCMOCK_ANY];
	[matcher setDelegate:delegate];
}

- (void)testDelegate {
	// Setup
	[keyObject setObject:@"Apple" forLanguage:@"en"];

	[[delegate expect] keyMatcherBeganMatching:matcher];
	[[delegate expect] keyMatcher:matcher foundMatch:OCMOCK_ANY forKeyObject:keyObject];
	[[delegate expect] keyMatcherFinishedMatching:matcher];

	// Run and verify
	[matcher start];
	[matcher waitUntilFinished];
	[delegate verify];
}

- (void)testNoGuessingNoHit {
	// Setup
	[keyObject setObject:@"All" forLanguage:@"en"];

	[[delegate expect] keyMatcherBeganMatching:matcher];
	[[delegate expect] keyMatcherFinishedMatching:matcher];

	// Run and verify
	[matcher start];
	[matcher waitUntilFinished];
	[delegate verify];
}

- (void)testNoGuessingHit {
	// Setup
	[keyObject setObject:@"Cell" forLanguage:@"en"];

	[[delegate expect] keyMatcherBeganMatching:matcher];
	[[delegate expect] keyMatcher:matcher foundMatch:valueForKey(@"matchedValue", equalTo(@"Cell")) forKeyObject:keyObject];
	[[delegate expect] keyMatcherFinishedMatching:matcher];

	// Run and verify
	[matcher start];
	[matcher waitUntilFinished];
	[delegate verify];
}

- (void)testGuessing {
	// Setup
	[keyObject setObject:@"Align" forLanguage:@"en"];
	[matcher setGuessingIsEnabled:YES];

	[[delegate expect] keyMatcherBeganMatching:matcher];
	[[delegate expect] keyMatcher:matcher foundMatch:valueForKey(@"matchedValue", equalTo(@"Align left")) forKeyObject:keyObject];
	[[delegate expect] keyMatcher:matcher foundMatch:valueForKey(@"matchedValue", equalTo(@"Align Left")) forKeyObject:keyObject];
	[[delegate expect] keyMatcher:matcher foundMatch:valueForKey(@"matchedValue", equalTo(@"Align right")) forKeyObject:keyObject];
	[[delegate expect] keyMatcher:matcher foundMatch:valueForKey(@"matchedValue", equalTo(@"Align Right")) forKeyObject:keyObject];
	[[delegate expect] keyMatcherFinishedMatching:matcher];

	// Run and verify
	[matcher start];
	[matcher waitUntilFinished];
	[delegate verify];
}

- (void)testAborting {
	// Setup
	[keyObject setObject:@"Undo" forLanguage:@"en"];
	[matcher setGuessingIsEnabled:YES];

	[[delegate expect] keyMatcherBeganMatching:matcher];
	// This should actually find 4 matches now (see -testGuessing:), but hopefully we abort beforehand...
	[[delegate expect] keyMatcherFinishedMatching:matcher];

	// Run and verify
	[matcher start];
	[matcher stop];
	[delegate verify];
}

- (void)testBaseLanguage {
	// Setup
	[keyObject setObject:@"Cell" forLanguage:@"en"];
	[matcher setTargetLanguage:@"de_DE"];

	[[delegate expect] keyMatcherBeganMatching:matcher];
	[[delegate expect] keyMatcher:matcher
					   foundMatch:allOf(
									  valueForKey(@"matchedValue", equalTo(@"Cell")),
									  valueForKey(@"targetLanguage", equalTo(@"de_DE")),
									  valueForKey(@"actualTargetLanguage", equalTo(@"de")), nil)
					 forKeyObject:keyObject];
	[[delegate expect] keyMatcherFinishedMatching:matcher];

	// Run and verify
	[matcher start];
	[matcher waitUntilFinished];
	[delegate verify];
}

#pragma mark - Dummy Delegate

- (void)keyMatcherBeganMatching:(LTKeyMatcher *)matcher- (void)keyMatcherFinishedMatching:(LTKeyMatcher *)matcher- (void)keyMatcher:(LTKeyMatcher *)matcher foundMatch:(LTKeyMatch *)match forKeyObject:(BLKeyObject *)target
@end
