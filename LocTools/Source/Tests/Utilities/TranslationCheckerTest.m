//
//  TranslationCheckerTest.m
//  LocTools
//
//  Created by Max on 07.05.10.
//  Copyright 2010 The Soulmen. All rights reserved.
//

#import "TranslationCheckerTest.h"
#import <BlueLocalization/BLStringKeyObject.h>

@implementation TranslationCheckerTest

- (void)setUp {
	keyObject = [BLStringKeyObject keyObjectWithKey:@"key"];
}

- (void)testPlaceholders {
}

- (void)testSinglePercentages {
	// No errors
	[keyObject setObject:@"From %i%% to 10% inset." forLanguage:@"en"];
	[keyObject setObject:@"Von %i%% bis 10% Einzug." forLanguage:@"de"];

	NSArray *errors = [LTTranslationChecker calculateTranslationErrorsForKeyObject:keyObject forLanguage:@"de" withReference:@"en"];
	NSLog(@"%@", errors);
	STAssertEquals([errors count], (NSUInteger)0, @"No errors should be found!");

	// Count error
	[keyObject setObject:@"Von %i% % bis 10% Einzug." forLanguage:@"de"];
	errors = [LTTranslationChecker calculateTranslationErrorsForKeyObject:keyObject forLanguage:@"de" withReference:@"en"];
	STAssertEquals([errors count], (NSUInteger)1, @"One error should be found!");

	LTTranslationProblem *problem = [errors objectAtIndex:0];
	STAssertEquals(problem.type, LTTranslationProblemError, @"Wrong type");
	STAssertFalse(problem.hasFix, @"Should have no fix");
	STAssertTrue([problem.description rangeOfString:@"Wrong number"].length > 0, @"Should deal with counts");
}

@end
