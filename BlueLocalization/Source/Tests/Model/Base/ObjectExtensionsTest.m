//
//  ObjectExtensionsTest.m
//  BlueLocalization
//
//  Created by max on 19.11.09.
//  Copyright 2009 The Soulmen. All rights reserved.
//

#import "ObjectExtensionsTest.h"

#import <BlueLocalization/BLStringKeyObject.h>


@implementation ObjectExtensionsTest

- (void)testStatistics
{
	BLKeyObject *keyObject;
	
	// Setup object
	keyObject = [[BLStringKeyObject alloc] init];
	
	[keyObject setValue:@"" forKey:@"en"];
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsSentences forLanguage:@"en"], (NSUInteger)0, @"Wrong number of sentences");
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsWords forLanguage:@"en"], (NSUInteger)0, @"Wrong number of words");
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsCharacters forLanguage:@"en"], (NSUInteger)0, @"Wrong number of characters");
	
	[keyObject setValue:@"a" forKey:@"en"];
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsSentences forLanguage:@"en"], (NSUInteger)1, @"Wrong number of sentences");
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsWords forLanguage:@"en"], (NSUInteger)1, @"Wrong number of words");
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsCharacters forLanguage:@"en"], (NSUInteger)1, @"Wrong number of characters");
	
	[keyObject setValue:@"." forKey:@"en"];
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsSentences forLanguage:@"en"], (NSUInteger)1, @"Wrong number of sentences");
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsWords forLanguage:@"en"], (NSUInteger)1, @"Wrong number of words");
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsCharacters forLanguage:@"en"], (NSUInteger)1, @"Wrong number of characters");
	
	[keyObject setValue:@"Two words" forKey:@"en"];
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsSentences forLanguage:@"en"], (NSUInteger)1, @"Wrong number of sentences");
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsWords forLanguage:@"en"], (NSUInteger)2, @"Wrong number of words");
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsCharacters forLanguage:@"en"], (NSUInteger)9, @"Wrong number of characters");
	
	[keyObject setValue:@"Two words." forKey:@"en"];
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsSentences forLanguage:@"en"], (NSUInteger)1, @"Wrong number of sentences");
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsWords forLanguage:@"en"], (NSUInteger)2, @"Wrong number of words");
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsCharacters forLanguage:@"en"], (NSUInteger)10, @"Wrong number of characters");
	
	[keyObject setValue:@"Two words..." forKey:@"en"];
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsSentences forLanguage:@"en"], (NSUInteger)1, @"Wrong number of sentences");
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsWords forLanguage:@"en"], (NSUInteger)2, @"Wrong number of words");
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsCharacters forLanguage:@"en"], (NSUInteger)12, @"Wrong number of characters");
	
	[keyObject setValue:@"Two\nwords. Two sentences!" forKey:@"en"];
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsSentences forLanguage:@"en"], (NSUInteger)2, @"Wrong number of sentences");
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsWords forLanguage:@"en"], (NSUInteger)4, @"Wrong number of words");
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsCharacters forLanguage:@"en"], (NSUInteger)25, @"Wrong number of characters");
	
	[keyObject setValue:@"Two words; Two sentences! One question?\nDunno\n\n\n" forKey:@"en"];
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsSentences forLanguage:@"en"], (NSUInteger)3, @"Wrong number of sentences");
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsWords forLanguage:@"en"], (NSUInteger)7, @"Wrong number of words");
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsCharacters forLanguage:@"en"], (NSUInteger)48, @"Wrong number of characters");
	
	[keyObject setValue:@"%d %@ addresses; were imported. 2s" forKey:@"en"];
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsSentences forLanguage:@"en"], (NSUInteger)2, @"Wrong number of sentences");
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsWords forLanguage:@"en"], (NSUInteger)6, @"Wrong number of words");
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsCharacters forLanguage:@"en"], (NSUInteger)34, @"Wrong number of characters");
	
	[keyObject setValue:@"Asking \"wtf...\" is no good!\nDarling" forKey:@"en"];
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsSentences forLanguage:@"en"], (NSUInteger)2, @"Wrong number of sentences");
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsWords forLanguage:@"en"], (NSUInteger)6, @"Wrong number of words");
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsCharacters forLanguage:@"en"], (NSUInteger)35, @"Wrong number of characters");
	
	[keyObject setValue:@"Info.plist" forKey:@"en"];
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsSentences forLanguage:@"en"], (NSUInteger)1, @"Wrong number of sentences");
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsWords forLanguage:@"en"], (NSUInteger)1, @"Wrong number of words");
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsCharacters forLanguage:@"en"], (NSUInteger)10, @"Wrong number of characters");
	
	[keyObject setValue:@"Info. plist" forKey:@"en"];
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsSentences forLanguage:@"en"], (NSUInteger)2, @"Wrong number of sentences");
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsWords forLanguage:@"en"], (NSUInteger)2, @"Wrong number of words");
	STAssertEquals([keyObject countForStatistic:BLObjectStatisticsCharacters forLanguage:@"en"], (NSUInteger)11, @"Wrong number of characters");
}

@end
