//
//  AppleGlotIntegrationTest.m
//  BlueLocalization
//
//  Created by max on 25.01.10.
//  Copyright 2010 The Soulmen. All rights reserved.
//

#import "AppleGlotIntegrationTest.h"

#import <BlueLocalization/BLAppleGlotDocument.h>


@implementation AppleGlotIntegrationTest

- (void)testImport
{
	NSString *path = [[NSBundle bundleForClass: [self class]] pathForResource:@"appleglot-sample" ofType:@"ad" inDirectory:@"Test Data/Utilities"];
	BLAppleGlotDocument *document = [BLAppleGlotDocument documentWithFileAtPath: path];
	
	STAssertEquals([document.keyObjects count], (NSUInteger)7, @"Wrong number of key objects");
	for (BLKeyObject *key in document.keyObjects) {
		STAssertTrue([[key objectForLanguage: @"en"] length] > 0, @"Missing string for \"en\"");
		STAssertTrue([[key objectForLanguage: @"de"] length] > 0, @"Missing string for \"de\"");
	}
}

@end
