//
//  DocumentPreferencesTest.h
//  BlueLocalization
//
//  Created by Max Seelemann on 29.10.10.
//  Copyright 2010 The Soulmen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@interface DocumentPreferencesTest : SenTestCase {
	BLDocument *document;
	NSMutableDictionary *preferences;
	NSDictionary *userPrefs;
	NSDictionary *prefs;
}

@end
