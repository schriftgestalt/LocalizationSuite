/*!
 @header
 LTKeyMatchCollector.h
 Created by max on 19.02.10.
 
 @copyright 2010 Localization Suite. All rights reserved.
 */

#import "LTKeyMatchCollector.h"

@implementation LTKeyMatchCollector

+ (LTKeyMatchCollector *)collector
{
	return [[self alloc] init];
}

- (id)init
{
	self = [super init];
	
	if (self != nil) {
		_matches = [[NSMutableArray alloc] init];
		_keyObjects = [[NSMutableSet alloc] init];
	}
	
	return self;
}


- (NSArray *)matches
{
	NSArray *matches;
	
	@synchronized(_matches) {
		matches = [NSArray arrayWithArray: _matches];
	}
	return matches;
}

- (NSArray *)matchingKeyObjects
{
	NSArray *keyObjects;
	@synchronized(_keyObjects) {
		keyObjects = [_keyObjects allObjects];
	}
	return keyObjects;
}

- (void)reset
{
	@synchronized(_matches) {
		[_matches removeAllObjects];
	}
	@synchronized(_keyObjects) {
		[_keyObjects removeAllObjects];
	}
}

- (void)keyMatcher:(LTKeyMatcher *)matcher foundMatch:(LTKeyMatch *)match forKeyObject:(BLKeyObject *)target
{
	@synchronized(_matches) {
		[_matches addObject: match];
	}
	@synchronized(_keyObjects) {
		[_keyObjects addObject: [match keyObject]];
	}
}

@end
