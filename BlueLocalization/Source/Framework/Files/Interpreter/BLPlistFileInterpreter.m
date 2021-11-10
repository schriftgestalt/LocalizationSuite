/*!
 @header
 BLPlistFileInterpreter.m
 Created by Max Seelemann on 04.09.06.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLPlistFileInterpreter.h>

@implementation BLPlistFileInterpreter

+ (void)load {
	[super registerInterpreterClass:self forFileType:@"plist"];
}

+ (NSUInteger)defaultOptions {
	return BLFileInterpreterValueChangesResetKeys | BLFileInterpreterReferenceImportCreatesBackup;
}

#pragma mark -

- (BOOL)_interpreteFile:(NSString *)path {
	NSDictionary *dict;
	NSString *error;
	NSArray *keys;
	NSData *data;
	id plist;

	// Get the localization dictionary
	data = [NSData dataWithContentsOfFile:path];
	error = nil;

	plist = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:nil errorDescription:&error];
	if (!plist) {
		BLLog(BLLogError, @"Failed to parse plist. Reason: %@", error);
		return NO;
	}

	dict = [plist localizationDictionary];
	if (!dict) {
		BLLog(BLLogError, @"Failed to retrieve localization dictionary.");
		return NO;
	}

	// Emit all keys
	keys = [dict allKeys];

	for (NSUInteger i = 0; i < [keys count]; i++) {
		NSString *key = [keys objectAtIndex:i];
		[self _emitKey:key value:[dict objectForKey:key] leadingComment:nil inlineComment:nil];
	}

	return YES;
}

@end

@implementation NSDictionary (BLPlistLocalization)

- (NSDictionary *)localizationDictionary {
	NSMutableDictionary *dict = [NSMutableDictionary new];

	[self enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
		if ([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSArray class]])
			[dict addEntriesFromDictionary:[object localizationDictionary]];
		if ([object isKindOfClass:[NSString class]])
			[dict setObject:object forKey:object];
	}];

	return dict;
}

@end

@implementation NSMutableDictionary (BLPlistLocalization)

- (void)localizeUsingDictionary:(NSDictionary *)translation {
	[self.allKeys enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
		id object = [self objectForKey:key];

		if ([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSArray class]])
			[object localizeUsingDictionary:translation];
		if ([object isKindOfClass:[NSString class]] && [translation objectForKey:object])
			[self setObject:[translation objectForKey:object] forKey:key];
	}];
}

@end

@implementation NSArray (BLPlistLocalization)

- (NSDictionary *)localizationDictionary {
	NSMutableDictionary *dict = [NSMutableDictionary new];

	[self enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
		if ([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSArray class]])
			[dict addEntriesFromDictionary:[object localizationDictionary]];
		if ([object isKindOfClass:[NSString class]])
			[dict setObject:object forKey:object];
	}];

	return dict;
}

@end

@implementation NSMutableArray (BLPlistLocalization)

- (void)localizeUsingDictionary:(NSDictionary *)translation {
	for (NSUInteger i = 0; i < self.count; i++) {
		id object = [self objectAtIndex:i];

		if ([object isKindOfClass:[NSDictionary class]] || [object isKindOfClass:[NSArray class]])
			[object localizeUsingDictionary:translation];
		if ([object isKindOfClass:[NSString class]] && [translation objectForKey:object])
			[self replaceObjectAtIndex:i withObject:[translation objectForKey:object]];
	}
}

@end
