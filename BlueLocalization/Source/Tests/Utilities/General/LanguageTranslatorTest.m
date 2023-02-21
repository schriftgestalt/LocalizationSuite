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
	XCTAssertEqualObjects([BLLanguageTranslator descriptionForLanguage:@"en"], @"English", @"Mismatching description for english");
	XCTAssertEqualObjects([BLLanguageTranslator descriptionForLanguage:@"de"], @"German", @"Mismatching description for German");
	XCTAssertEqualObjects([BLLanguageTranslator descriptionForLanguage:@"fr"], @"French", @"Mismatching description for French");
}

- (void)testIdentifiers {
	XCTAssertEqualObjects([BLLanguageTranslator identifierForLanguage:@"English"], @"en", @"Mismatching identifier for english");
	XCTAssertEqualObjects([BLLanguageTranslator identifierForLanguage:@"German"], @"de", @"Mismatching identifier for German");
	XCTAssertEqualObjects([BLLanguageTranslator identifierForLanguage:@"French"], @"fr", @"Mismatching identifier for French");
}

- (void)testNorwegian {
	XCTAssertEqualObjects(@"nb", [BLLanguageTranslator identifierForLanguage:@"Norwegian"], @"Wrong identifier for Norwegian");
	XCTAssertEqualObjects(@"nb", [BLLanguageTranslator identifierForLanguage:@"Norwegian Bokmål"], @"Wrong identifier for Norwegian");
	XCTAssertEqualObjects(@"nn", [BLLanguageTranslator identifierForLanguage:@"Norwegian Nynorsk"], @"Wrong identifier for Norwegian Nynorsk");

	XCTAssertEqualObjects(@"Norwegian Bokmål", [BLLanguageTranslator descriptionForLanguage:@"no"], @"Wrong description for Norwegian Bokmål");
	XCTAssertEqualObjects(@"Norwegian Bokmål", [BLLanguageTranslator descriptionForLanguage:@"nb"], @"Wrong description for Norwegian Bokmål");
	XCTAssertEqualObjects(@"Norwegian Nynorsk", [BLLanguageTranslator descriptionForLanguage:@"nn"], @"Wrong description for Norwegian Nynorsk");
}

@end
