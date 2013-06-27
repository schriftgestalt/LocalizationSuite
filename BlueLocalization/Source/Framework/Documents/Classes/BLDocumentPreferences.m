//
//  BLDocumentPreferences.m
//  BlueLocalization
//
//  Created by Max Seelemann on 28.10.10.
//  Copyright 2010 The Soulmen. All rights reserved.
//

#import "BLDocumentPreferences.h"


@implementation BLDocumentPreferences

- (id)initWithDictionary:(NSMutableDictionary *)preferences userDictionary:(NSMutableDictionary *)userPreferences andUserKeys:(NSArray *)userKeys
{
	self = [super init];
	
	if (self) {
		_preferences = preferences;
		_userPreferences = userPreferences;
		_userKeys = [userKeys copy];
	}
	
	return self;
}



#pragma mark - Internals

- (NSMutableDictionary *)userPreferences
{
	NSMutableDictionary *dict = [_userPreferences objectForKey: NSUserName()];
	
	if (!dict) {
		dict = [NSMutableDictionary dictionary];
		[_userPreferences setObject:dict forKey:NSUserName()];
	}
	
	return dict;
}


#pragma mark - NSDictionary methods

- (NSUInteger)count
{
	return [[self allKeys] count];
}

- (NSArray *)allKeys
{
	NSMutableSet *keys = [NSMutableSet set];
	[keys addObjectsFromArray: [_preferences allKeys]];
	[keys addObjectsFromArray: [[self userPreferences] allKeys]];
	return [keys allObjects];
}

- (id)objectForKey:(id)aKey
{
	if ([_userKeys containsObject: aKey])
		return [[self userPreferences] objectForKey: aKey];
	else
		return [_preferences objectForKey: aKey];
}

- (NSEnumerator *)keyEnumerator
{
	return [[self allKeys] objectEnumerator];
}

- (void)removeObjectForKey:(id)aKey
{
	[self willChangeValueForKey: aKey];
	
	if ([_userKeys containsObject: aKey])
		[[self userPreferences] removeObjectForKey: aKey];
	else
		[_preferences removeObjectForKey: aKey];
	
	[self didChangeValueForKey: aKey];
}

- (void)setObject:(id)anObject forKey:(id)aKey
{
	[self willChangeValueForKey: aKey];
	
	if ([_userKeys containsObject: aKey])
		[[self userPreferences] setObject:anObject forKey: aKey];
	else
		[_preferences setObject:anObject forKey: aKey];
	
	[self didChangeValueForKey: aKey];
}


@end
