//
//  MultipleKeyMatcherTest
//  LocTools
//
//  Created by max on 28.06.09.
//  Copyright 2009 Blue Technologies Group. All rights reserved.
//

#import "MultipleKeyMatcherTest.h"

#import <BlueLocalization/BLStringKeyObject.h>

#define HC_SHORTHAND
#import <hamcrest/hamcrest.h>
#import "KeyValueMatcher.h"

@implementation MultipleKeyMatcherTest

- (void)setUp
{
	NSArray *matchKeyObjects;
	NSFileWrapper *wrapper;
	
	NSLog(@"%@", [NSBundle bundleForClass: [self class]]);
	// Load Dictionary
	wrapper = [[NSFileWrapper alloc] initWithPath: [[NSBundle bundleForClass: [self class]] pathForResource:@"AppKit-de" ofType:@"lod" inDirectory:@"Test Data/Autotranslation"]];
	matchKeyObjects = [BLDictionaryFile objectsFromFile:wrapper readingProperties:NULL];
	STAssertTrue([matchKeyObjects count] > 0, @"Dictionary not loaded");
	
	// Init Matcher
	matcher = [LTMultipleKeyMatcher new];
	[matcher setMatchingKeyObjects: matchKeyObjects];
	[matcher setMatchLanguage: @"en"];
	[matcher setTargetLanguage: @"de"];
	
	// Init Key objects
	keyObjects = [NSMutableArray array];
	[matcher setTargetKeyObjects: keyObjects];
	
	// Init delegate
	BOOL value = YES;
	delegate = [OCMockObject mockForClass: [self class]];
	[[[delegate stub] andReturnValue: [NSValue value:(const void *)&value withObjCType:@encode(BOOL)]] respondsToSelector: (__bridge void*)OCMOCK_ANY];
	[matcher setDelegate: delegate];
}

- (void)testDelegate
{
	BLKeyObject *keyObject;
	
	// Setup
	keyObject = [BLStringKeyObject keyObjectWithKey: @"test"];
	[keyObject setObject:@"Apple" forLanguage:@"en"];
	[keyObjects addObject: keyObject];
	[matcher setTargetKeyObjects: keyObjects];
	
	// Set delegate
	[[delegate expect] keyMatcherBeganMatching: matcher];
	[[delegate expect] keyMatcher:matcher foundMatch:OCMOCK_ANY forKeyObject:keyObject];
	[[delegate expect] keyMatcherFinishedMatching: matcher];
	
	// Run and verify
	[matcher start];
	[matcher waitUntilFinished];
	[delegate verify];
}

- (void)testDoubleKey
{
	BLKeyObject *keyObject;
	
	// Expect start
	[[delegate expect] keyMatcherBeganMatching: matcher];
	
	// Setup objects
	keyObject = [BLStringKeyObject keyObjectWithKey: @"test"];
	[keyObject setObject:@"Apple" forLanguage:@"en"];
	[keyObjects addObject: keyObject];
	[[delegate expect] keyMatcher:matcher foundMatch:OCMOCK_ANY forKeyObject:keyObject];
	
	keyObject = [BLStringKeyObject keyObjectWithKey: @"test"];
	[keyObject setObject:@"Apple" forLanguage:@"en"];
	[keyObjects addObject: keyObject];
	[[delegate expect] keyMatcher:matcher foundMatch:OCMOCK_ANY forKeyObject:keyObject];
	
	// Expect finish
	[[delegate expect] keyMatcherFinishedMatching: matcher];
	[matcher setTargetKeyObjects: keyObjects];
	
	// Run and verify
	[matcher start];
	[matcher waitUntilFinished];
	[delegate verify];
}

- (void)testManyKeys
{
	BLKeyObject *keyObject;
	
	// Expect start
	[[delegate expect] keyMatcherBeganMatching: matcher];
	
	// Setup objects
	keyObject = [BLStringKeyObject keyObjectWithKey: @"test"];
	[keyObject setObject:@"Apple" forLanguage:@"en"];
	[keyObjects addObject: keyObject];
	[[delegate expect] keyMatcher:matcher foundMatch:OCMOCK_ANY forKeyObject:keyObject];
	
	keyObject = [BLStringKeyObject keyObjectWithKey: @"test"];
	[keyObject setObject:@"Blue" forLanguage:@"en"];
	[keyObjects addObject: keyObject];
	[[delegate expect] keyMatcher:matcher foundMatch:OCMOCK_ANY forKeyObject:keyObject];
	
	keyObject = [BLStringKeyObject keyObjectWithKey: @"test"];
	[keyObject setObject:@"Correct" forLanguage:@"en"];
	[keyObjects addObject: keyObject];
	[[delegate expect] keyMatcher:matcher foundMatch:OCMOCK_ANY forKeyObject:keyObject];
	
	keyObject = [BLStringKeyObject keyObjectWithKey: @"test"];
	[keyObject setObject:@"Error" forLanguage:@"en"];
	[keyObjects addObject: keyObject];
	[[delegate expect] keyMatcher:matcher foundMatch:OCMOCK_ANY forKeyObject:keyObject];
	
	keyObject = [BLStringKeyObject keyObjectWithKey: @"test"];
	[keyObject setObject:@"Green" forLanguage:@"en"];
	[keyObjects addObject: keyObject];
	[[delegate expect] keyMatcher:matcher foundMatch:OCMOCK_ANY forKeyObject:keyObject];
	
	// Expect finish
	[[delegate expect] keyMatcherFinishedMatching: matcher];
	[matcher setTargetKeyObjects: keyObjects];
	
	// Run and verify
	[matcher start];
	[matcher waitUntilFinished];
	[delegate verify];
}

- (void)testNoMatch
{
	BLKeyObject *keyObject;
	
	// Setup
	keyObject = [BLStringKeyObject keyObjectWithKey: @"test"];
	[keyObject setObject:@"Non-existent-word" forLanguage:@"en"];
	[keyObjects addObject: keyObject];
	
	// Set delegate
	[[delegate expect] keyMatcherBeganMatching: matcher];
	[[delegate expect] keyMatcherFinishedMatching: matcher];
	
	// Run and verify
	[matcher start];
	[matcher waitUntilFinished];
	[delegate verify];
}

- (void)testAborting
{
	BLKeyObject *keyObject;
	
	// Setup
	keyObject = [BLStringKeyObject keyObjectWithKey: @"test"];
	[keyObject setObject:@"Undo" forLanguage:@"en"];
	[keyObjects addObject: keyObject];
	
	// Set delegate
	[[delegate expect] keyMatcherBeganMatching: matcher];
	// This should actually find 1 match now (see -testDelegate:), but hopefully we abort beforehand...
	[[delegate expect] keyMatcherFinishedMatching: matcher];
	
	// Run and verify
	[matcher start];
	[matcher stop];
	[delegate verify];
}

- (void)testBaseLanguage
{
	BLKeyObject *keyObject;
	
	// Expect start
	[[delegate expect] keyMatcherBeganMatching: matcher];
	
	// Setup objects
	keyObject = [BLStringKeyObject keyObjectWithKey: @"test"];
	[keyObject setObject:@"Cell" forLanguage:@"en"];
	[keyObjects addObject: keyObject];
	[[delegate expect] keyMatcher:matcher
					   foundMatch:allOf(
										valueForKey(@"targetLanguage", equalTo(@"de_DE")),
										valueForKey(@"actualTargetLanguage", equalTo(@"de")), nil
										)
					 forKeyObject:keyObject];
	
	keyObject = [BLStringKeyObject keyObjectWithKey: @"test"];
	[keyObject setObject:@"Apple" forLanguage:@"en"];
	[keyObjects addObject: keyObject];
	[[delegate expect] keyMatcher:matcher
					   foundMatch:allOf(
										valueForKey(@"targetLanguage", equalTo(@"de_DE")),
										valueForKey(@"actualTargetLanguage", equalTo(@"de")), nil
										)
					 forKeyObject:keyObject];
	
	// Expect finish
	[[delegate expect] keyMatcherFinishedMatching: matcher];
	[matcher setTargetKeyObjects: keyObjects];
	[matcher setTargetLanguage: @"de_DE"];
	
	// Run and verify
	[matcher start];
	[matcher waitUntilFinished];
	[delegate verify];
}

- (void)testNoMatchingKeys
{
	matcher.matchingKeyObjects = nil;
	
	// Setup
	BLKeyObject *keyObject = [BLStringKeyObject keyObjectWithKey: @"test"];
	[keyObject setObject:@"Apple" forLanguage:@"en"];
	[keyObjects addObject: keyObject];
	[matcher setTargetKeyObjects: keyObjects];
	
	// Set delegate
	[[delegate expect] keyMatcherBeganMatching: matcher];
	[[delegate expect] keyMatcherFinishedMatching: matcher];
	
	// Run and verify
	[matcher start];
	[matcher waitUntilFinished];
	[delegate verify];
}

- (void)testNoMatchingNoTargetKeys
{
	matcher.matchingKeyObjects = nil;
	[matcher setTargetKeyObjects: nil];
	
	// Set delegate
	[[delegate expect] keyMatcherBeganMatching: matcher];
	[[delegate expect] keyMatcherFinishedMatching: matcher];
	
	// Run and verify
	[matcher start];
	[matcher waitUntilFinished];
	[delegate verify];
}


#pragma mark - Dummy Delegate

- (void)keyMatcherBeganMatching:(LTKeyMatcher *)matcher
{
}
- (void)keyMatcherFinishedMatching:(LTKeyMatcher *)matcher
{
}
- (void)keyMatcher:(LTKeyMatcher *)matcher foundMatch:(LTKeyMatch *)match forKeyObject:(BLKeyObject *)target
{
}

@end
