//
//  DescriptionLoaderTest.m
//  NibPreview
//
//  Created by max on 02.03.09.
//  Copyright 2009 Localization Suite. All rights reserved.
//

#import "DescriptionLoaderTest.h"

#import "NPDescriptionLoader.h"

@implementation DescriptionLoaderTest

- (void)testSharedInstance
{
	// There should be exactly one shared instance
	
	id instance1, instance2;
	
	instance1 = [NPDescriptionLoader sharedInstance];
	STAssertNotNil(instance1, @"No shared description loader");
	
	instance2 = [NPDescriptionLoader sharedInstance];
	STAssertTrue([instance1 isEqual: instance2], @"Amibigious shared instance");
}

- (void)testSimpleLoad
{
	// Try the read from disk and compare with earlier output
	
	NSString *outPath = [[NSBundle bundleForClass: [self class]] pathForResource:@"Loader-1" ofType:@"out" inDirectory:@"Test Data/Loader"];
	NSString *xibPath = [[NSBundle bundleForClass: [self class]] pathForResource:@"Loader-1" ofType:@"xib" inDirectory:@"Test Data/Loader"];
	
	STAssertNotNil(outPath, @"Can't find out file");
	STAssertNotNil(xibPath, @"Can't find xib file");
	
	NSDictionary *contents = [NSDictionary dictionaryWithContentsOfFile: outPath];
	NSDictionary *description = [[NPDescriptionLoader sharedInstance] loadDescriptionFromPath: xibPath];
	
	STAssertNotNil(contents, @"Can't load out file");
	STAssertNotNil(description, @"Can't load xib description");
	
	STAssertTrue([contents isEqual: description], @"ibtool out and loader data do not match!");
}

@end
