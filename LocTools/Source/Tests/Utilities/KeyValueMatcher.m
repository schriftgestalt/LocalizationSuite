//
//  KeyValueMatcher.m
//  LocTools
//
//  Created by max on 07.06.09.
//  Copyright 2009 Blue Technologies Group. All rights reserved.
//

#import "KeyValueMatcher.h"

#import <hamcrest/HCDescription.h>

@implementation KeyValueMatcher

+ (KeyValueMatcher *)valueForKey:(NSString *)key matches:(id<HCMatcher>)theMatcher {
	return [[self alloc] initWithKey:key andMatcher:theMatcher];
}

- (id)initWithKey:(NSString *)theKey andMatcher:(id<HCMatcher>)theMatcher {
	self = [super init];

	if (self) {
		key = theKey;
		matcher = theMatcher;
	}

	return self;
}

- (BOOL)matches:(id)item {
	return [matcher matches:[item valueForKey:key]];
}

- (void)describeTo:(id<HCDescription>)description {
	[description appendText:@"valueForKey(\""];
	[description appendText:key];
	[description appendText:@"\", "];
	[description appendDescriptionOf:matcher];
	[description appendText:@")"];
}

@end

id<HCMatcher> HC_valueForKey(NSString *key, id item) {
	return [KeyValueMatcher valueForKey:key matches:item];
}
