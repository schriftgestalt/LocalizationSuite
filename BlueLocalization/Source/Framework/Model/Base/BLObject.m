/*!
 @header
 BLObject.m
 Created by Max Seelemann on 24.07.06.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLObject.h"

#import "BLFileInternal.h"

NSString *BLObjectReferenceChangedKey = @"<reference>";

NSString *BLObjectFiletypeUnknownError = @"File type unknown";
NSString *BLObjectFileNotFoundError = @"File has not been found";
NSString *BLObjectFileUnimportableError = @"File cannot be imported";

@implementation BLObject

#pragma mark - Initializers

- (id)init {
	self = [super init];

	if (self) {
		_changeDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:0];
		_changedValues = [[NSMutableArray alloc] init];
		_flags = 0;

		_errors = [[NSMutableArray alloc] init];
	}

	return self;
}

#pragma mark - Serialization

- (id)initWithPropertyList:(NSDictionary *)plist {
	self = [self init];

	if (self) {
		[self setChangeDate:[plist objectForKey:BLFileChangeDateKey]];
		[self setFlags:[[plist objectForKey:BLFileFlagsKey] unsignedIntValue]];
		[self setErrors:[plist objectForKey:BLFileErrorsKey]];

		[_changedValues setArray:[plist objectForKey:BLFileChangedValuesKey]];
	}

	return self;
}

- (NSDictionary *)propertyListWithAttributes:(NSDictionary *)attributes {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];

	[dict secureSetObject:[self changeDate] forKey:BLFileChangeDateKey];
	[dict secureSetObject:[self errors] forKey:BLFileErrorsKey];
	[dict secureSetObject:[NSNumber numberWithUnsignedInteger:[self flags]] forKey:BLFileFlagsKey];

	if (![[attributes objectForKey:BLClearChangeInformationSerializationKey] boolValue])
		[dict secureSetObject:[self changedValues] forKey:BLFileChangedValuesKey];

	return dict;
}

#pragma mark - NSCopying Implementation

- (id)copyWithZone:(NSZone *)zone {
	BLObject *newObject;

	newObject = [[[self class] alloc] initWithPropertyList:[self propertyListWithAttributes:nil]];

	return newObject;
}

#pragma mark - Change Tracking

- (NSArray *)changedValues {
	return _changedValues;
}

- (NSString *)changeDescription {
	if ([[self errors] count]) {
		return [[self errors] componentsJoinedByString:@", "];
	}
	else {
		NSMutableArray *changes = [NSMutableArray arrayWithArray:[self changedValues]];
		NSString *description = @"";

		// Reference changed
		if ([changes containsObject:BLObjectReferenceChangedKey]) {
			description = NSLocalizedStringFromTableInBundle(@"Reference", @"Localizable", [NSBundle bundleForClass:[self class]], nil);
			[changes removeObject:BLObjectReferenceChangedKey];
		}
		// Languages changed
		if ([changes count]) {
			if ([description length])
				description = [description stringByAppendingString:@", "];
			description = [description stringByAppendingString:[[changes valueForKey:@"languageDescription"] componentsJoinedByString:@", "]];
		}

		return description;
	}
}

+ (NSSet *)keyPathsForValuesAffectingChangeDescription {
	return [NSSet setWithObjects:@"changedValues", @"errors", nil];
}

- (void)setChangedValues:(NSArray *)array {
	[_changedValues setArray:array];
	[[self parentObject] addChangedValues:array];
}

- (void)addChangedValues:(NSArray *)array {
	for (NSUInteger i = 0; i < [array count]; i++)
		[self setValue:[array objectAtIndex:i] didChange:YES];
}

- (void)setValue:(NSString *)key didChange:(BOOL)changed {
	[self willChangeValueForKey:@"changedValues"];

	if (changed) {
		if (![_changedValues containsObject:key])
			[_changedValues addObject:key];
	}
	else {
		if ([_changedValues containsObject:key])
			[_changedValues removeObject:key];
		for (NSUInteger i = 0; i < [[self objects] count]; i++)
			[[[self objects] objectAtIndex:i] setValue:key didChange:NO];
	}
	[[self parentObject] setObjectValue:key didChange:changed];

	[self didChangeValueForKey:@"changedValues"];
}

- (void)setObjectValue:(NSString *)key didChange:(BOOL)changed {
	[self willChangeValueForKey:@"changedValues"];
	if (changed) {
		[self setValue:key didChange:YES];
	}
	else {
		changed = NO;
		for (NSUInteger i = 0; i < [[self objects] count]; i++) {
			if ((changed = [[[self objects] objectAtIndex:i] valueDidChange:key]))
				break;
		}
		if (!changed && [_changedValues containsObject:key])
			[_changedValues removeObject:key];
		[[self parentObject] setObjectValue:key didChange:changed];
	}
	[self didChangeValueForKey:@"changedValues"];
}

- (void)setNothingDidChange {
	[self willChangeValueForKey:@"changedValues"];
	[_changedValues removeAllObjects];
	[self didChangeValueForKey:@"changedValues"];

	if ([self objects])
		[[self objects] makeObjectsPerformSelector:@selector(setNothingDidChange)];
}

- (BOOL)didChange {
	return ([_changedValues count] > 0);
}

+ (NSSet *)keyPathsForValuesAffectingDidChange {
	return [NSSet setWithObjects:@"changedValues", nil];
}

- (BOOL)valueDidChange:(NSString *)key {
	return [_changedValues containsObject:key];
}

- (BOOL)referenceChanged {
	return [self valueDidChange:BLObjectReferenceChangedKey];
}

- (void)setReferenceChanged:(BOOL)changed {
	[self setValue:BLObjectReferenceChangedKey didChange:changed];
}

+ (NSSet *)keyPathsForValuesAffectingReferenceChanged {
	return [NSSet setWithObjects:@"changedValues", nil];
}

- (NSArray *)changedLanguages {
	NSMutableArray *languages = [NSMutableArray array];

	for (NSString *value in self.changedValues) {
		if ([value isEqual:BLObjectReferenceChangedKey])
			continue;
		if ([BLLanguageTranslator isLanguageIdentifier:value])
			[languages addObject:value];
	}

	return languages;
}

- (void)setChangedLanguages:(NSArray *)languages {
	NSMutableArray *newChangedValues = [NSMutableArray arrayWithArray:_changedValues];
	[newChangedValues removeObjectsInArray:self.changedLanguages];
	[newChangedValues addObjectsFromArray:languages];

	// Remove values
	for (NSString *key in [NSArray arrayWithArray:_changedValues]) {
		if (![newChangedValues containsObject:key])
			[self setValue:key didChange:NO];
	}

	// Add values
	for (NSString *key in newChangedValues) {
		if (![_changedValues containsObject:key])
			[self setValue:key didChange:YES];
	}
}

+ (NSSet *)keyPathsForValuesAffectingChangedLanguages {
	return [NSSet setWithObjects:@"changedValues", nil];
}

- (NSDate *)changeDate {
	return _changeDate;
}

- (void)setChangeDate:(NSDate *)date {
	_changeDate = date;
}

#pragma mark - Accessors

- (NSUInteger)flags {
	return _flags;
}

- (void)setFlags:(NSUInteger)flags {
	_flags = flags;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@ %p>[%@]", NSStringFromClass([self class]), self, [self name]];
}

- (NSString *)name {
	return @"BLObject";
}

- (NSArray *)errors {
	return _errors;
}

- (void)setErrors:(NSArray *)newErrors {
	[_errors setArray:newErrors];
	[[self parentObject] addObjectErrors:newErrors];
}

- (void)addObjectErrors:(NSArray *)newErrors {
	if ([newErrors count]) {
		[self willChangeValueForKey:@"errors"];
		[_errors addObjectsFromArray:newErrors];
		[self didChangeValueForKey:@"errors"];

		[[self parentObject] addObjectErrors:newErrors];
	}
	else {
		NSMutableSet *allErrors;

		allErrors = [NSMutableSet set];
		for (NSUInteger i = 0; i < [[self objects] count]; i++)
			[allErrors addObjectsFromArray:[[[self objects] objectAtIndex:i] errors]];

		[self setErrors:[allErrors allObjects]];
	}
}

- (id)valueForUndefinedKey:(NSString *)key {
	return nil;
}

#pragma mark - Scripting

- (BOOL)isActive {
	return !([self flags] & BLObjectDeactivatedFlag);
}

- (void)setIsActive:(BOOL)flag {
	if (([self flags] & BLObjectDeactivatedFlag) && flag)
		[self setFlags:[self flags] - BLObjectDeactivatedFlag];
	if (!([self flags] & BLObjectDeactivatedFlag) && !flag)
		[self setFlags:[self flags] + BLObjectDeactivatedFlag];
}

- (BOOL)wasUpdated {
	return ([self flags] & BLObjectUpdatedFlag) != 0;
}

- (void)setWasUpdated:(BOOL)flag {
	if (([self flags] & BLObjectUpdatedFlag) && !flag)
		[self setFlags:[self flags] - BLObjectUpdatedFlag];
	if (!([self flags] & BLObjectUpdatedFlag) && flag)
		[self setFlags:[self flags] + BLObjectUpdatedFlag];
}

#pragma mark - Treeing

- (NSArray *)objects {
	return nil;
}

+ (NSSet *)keyPathsForValuesAffectingNumberOfObjects {
	return [NSSet setWithObjects:@"objects", nil];
}

- (id)parentObject {
	return nil;
}

- (id)rootObject {
	return ([self parentObject]) ? [self parentObject] : self;
}

#pragma mark - Utilities

- (id)object {
	return self;
}

- (BOOL)isEqual:(id)other {
	// Compare Classes
	if (![other isKindOfClass:[self class]])
		return NO;

	// Changes
	if (![[self changedValues] isEqual:[other changedValues]]) {
		if (![[NSSet setWithArray:(NSArray *)[self changedValues]] isEqual:[NSSet setWithArray:(NSArray *)[other changedValues]]])
			return NO;
	}
	if (![[self changeDate] isEqual:[other changeDate]])
		return NO;

	// Erros, flags
	if (![[self errors] isEqual:[other errors]])
		return NO;
	if ([self flags] != [other flags])
		return NO;

	return YES;
}

@end
