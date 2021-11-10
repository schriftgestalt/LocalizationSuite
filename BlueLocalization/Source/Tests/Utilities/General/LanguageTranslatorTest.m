//
//  LanguageTranslatorTest.m
//  BlueLocalization
//
//  Created by max on 09.09.09.
//  Copyright 2009 Blue Technologies Group. All rights reserved.
//

#import "LanguageTranslatorTest.h"

@implementation LanguageTranslatorTest

- (void)testDescriptions {
	STAssertEqualObjects([BLLanguageTranslator descriptionForLanguage:@"en"], @"English", @"Mismatching description for english");
	STAssertEqualObjects([BLLanguageTranslator descriptionForLanguage:@"de"], @"German", @"Mismatching description for German");
	STAssertEqualObjects([BLLanguageTranslator descriptionForLanguage:@"fr"], @"French", @"Mismatching description for French");
}

- (void)testIdentifiers {
	STAssertEqualObjects([BLLanguageTranslator identifierForLanguage:@"English"], @"en", @"Mismatching identifier for english");
	STAssertEqualObjects([BLLanguageTranslator identifierForLanguage:@"German"], @"de", @"Mismatching identifier for German");
	STAssertEqualObjects([BLLanguageTranslator identifierForLanguage:@"French"], @"fr", @"Mismatching identifier for French");
}

- (void)testNorwegian {
	STAssertEqualObjects(@"nb", [BLLanguageTranslator identifierForLanguage:@"Norwegian"], @"Wrong identifier for Norwegian");
	STAssertEqualObjects(@"nb", [BLLanguageTranslator identifierForLanguage:@"Norwegian Bokmål"], @"Wrong identifier for Norwegian");
	STAssertEqualObjects(@"nn", [BLLanguageTranslator identifierForLanguage:@"Norwegian Nynorsk"], @"Wrong identifier for Norwegian Nynorsk");

	STAssertEqualObjects(@"Norwegian Bokmål", [BLLanguageTranslator descriptionForLanguage:@"no"], @"Wrong description for Norwegian Bokmål");
	STAssertEqualObjects(@"Norwegian Bokmål", [BLLanguageTranslator descriptionForLanguage:@"nb"], @"Wrong description for Norwegian Bokmål");
	STAssertEqualObjects(@"Norwegian Nynorsk", [BLLanguageTranslator descriptionForLanguage:@"nn"], @"Wrong description for Norwegian Nynorsk");
}

@end
