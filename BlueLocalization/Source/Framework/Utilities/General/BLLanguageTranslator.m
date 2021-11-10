/*!
 @header
 BLLanguageTranslator.m
 Created by Max Seelemann on 04.08.06.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLLanguageTranslator.h>

NSString *BLLanguageNameValueTransformerName = @"LanguageName";
NSString *BLLanguageIdentifierValueTransformerName = @"LanguageIdentifier";

@implementation BLLanguageTranslator

NSMutableDictionary *__languageTranslatorCache = nil;

+ (void)initialize {
	[super initialize];

	__languageTranslatorCache = [[NSMutableDictionary alloc] init];
}

#pragma mark - Language names and descriptions

+ (BOOL)isLanguageIdentifier:(NSString *)language {
	return ([[self localeForLanguage:language] objectForKey:NSLocaleIdentifier] != nil);
}

+ (NSString *)identifierForLanguage:(NSString *)language {
	if (!language)
		return nil;

	NSString *identifier = [[self localeForLanguage:language] objectForKey:NSLocaleIdentifier];
	if (!identifier)
		identifier = language;

	return identifier;
}

+ (NSString *)descriptionForLanguage:(NSString *)language {
	// Get the identifier
	NSString *identifier = [self identifierForLanguage:language];
	if (!identifier)
		return nil;

	// Use the default english NSLocale description
	NSLocale *enLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];
	return [enLocale displayNameForKey:NSLocaleIdentifier value:identifier];
}

+ (NSArray *)descriptionsForLanguages:(NSArray *)languages {
	NSMutableArray *descriptions = [NSMutableArray arrayWithCapacity:[languages count]];

	for (NSUInteger i = 0; i < [languages count]; i++) {
		NSString *desc = [self descriptionForLanguage:[languages objectAtIndex:i]];
		if (desc)
			[descriptions addObject:desc];
	}

	return descriptions;
}

#pragma mark - About NSLocale

+ (NSArray *)allLanguageIdentifiers {
	return [NSLocale availableLocaleIdentifiers];
}

+ (NSLocale *)localeForLanguage:(NSString *)language {
	NSString *identifier;
	NSLocale *locale, *enLocale;

	// No input
	if (!language)
		return nil;

	// Use cache
	if ((locale = [__languageTranslatorCache objectForKey:language]))
		return ([locale isKindOfClass:[NSNull class]]) ? nil : locale;

	// Try to find a match
	identifier = [NSLocale canonicalLocaleIdentifierFromString:language];
	if ([identifier length] > 10) {
		return nil;
	}
	if (!identifier || [identifier rangeOfString:@" "].location != NSNotFound || [identifier rangeOfString:@"("].location != NSNotFound) {
		NSString *otherID;
		NSArray *locales;
		NSUInteger i;

		locales = [NSLocale availableLocaleIdentifiers];
		enLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];

		for (i = 0; i < [locales count]; i++) {
			if ([language isEqualToString:[enLocale displayNameForKey:NSLocaleIdentifier value:[locales objectAtIndex:i]]]) {
				identifier = [locales objectAtIndex:i];
				break;
			}
			otherID = [[[NSLocale alloc] initWithLocaleIdentifier:[locales objectAtIndex:i]] objectForKey:NSLocaleIdentifier];
			if ([language isEqualToString:[enLocale displayNameForKey:NSLocaleIdentifier value:otherID]]) {
				identifier = otherID;
				break;
			}
		}
	}

	// No locale identifier found
	if (!identifier) {
		[__languageTranslatorCache setObject:[NSNull null] forKey:language];
		return nil;
	}

	// Update the cache with the right locales
	locale = [[NSLocale alloc] initWithLocaleIdentifier:identifier];
	enLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];

	if (language)
		[__languageTranslatorCache setObject:locale forKey:language];
	if (identifier)
		[__languageTranslatorCache setObject:locale forKey:identifier];
	if ([enLocale displayNameForKey:NSLocaleIdentifier value:identifier]) {
		[__languageTranslatorCache setObject:locale forKey:[enLocale displayNameForKey:NSLocaleIdentifier value:identifier]];
	}
	return locale;
}

#pragma mark - RFC 4646 Language Codes

+ (NSString *)languageIdentifierFromRFCLanguage:(NSString *)language {
	NSArray *components = [language componentsSeparatedByString:@"-"];
	NSEnumerator *enumerator = [components objectEnumerator];
	NSString *identifier;

	identifier = [[enumerator nextObject] lowercaseString];
	for (NSString *comp in enumerator) {
		if ([comp length] >= 3)
			identifier = [identifier stringByAppendingFormat:@"-%@", [comp capitalizedString]];
		else
			identifier = [identifier stringByAppendingFormat:@"_%@", [comp uppercaseString]];
	}

	return [BLLanguageTranslator identifierForLanguage:identifier];
}

+ (NSString *)RFCLanguageFromLanguageIdentifier:(NSString *)identifier {
	NSArray *components = [identifier componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_-"]];
	NSString *language = [components componentsJoinedByString:@"-"];
	language = [language lowercaseString];
	return language;
}

@end

#pragma mark -

@implementation NSString (BLLanguageTranslator)

- (NSString *)languageDescription {
	return [BLLanguageTranslator descriptionForLanguage:self];
}

- (NSString *)languageIdentifier {
	return [BLLanguageTranslator identifierForLanguage:self];
}

@end

#pragma mark -

@implementation BLLanguageValueTransformer

+ (void)load {
	[NSValueTransformer setValueTransformer:[BLLanguageValueTransformer new] forName:BLLanguageNameValueTransformerName];
	[NSValueTransformer setValueTransformer:[BLLanguageValueTransformer reversedTransformer] forName:BLLanguageIdentifierValueTransformerName];
}

+ (Class)transformedValueClass {
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
	return YES;
}

+ (id)reversedTransformer {
	BLLanguageValueTransformer *t = [self new];
	t.isReversed = YES;
	return t;
}

- (id)init {
	self = [super init];

	if (self) {
		self.isReversed = NO;
	}

	return self;
}

- (id)transformedValue:(id)value {
	if ([value isKindOfClass:[NSNull class]])
		return [NSNull null];

	if ([value isKindOfClass:[NSString class]]) {
		id result = (!self.isReversed
						 ? [BLLanguageTranslator descriptionForLanguage:value]
						 : [BLLanguageTranslator identifierForLanguage:value]);
		return (result) ? result : value;
	}

	if ([value isKindOfClass:[NSArray class]]) {
		NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:[value count]];
		for (NSUInteger i = 0; i < [value count]; i++)
			[newArray addObject:[self transformedValue:[value objectAtIndex:i]]];
		return newArray;
	}

	return nil;
}

- (id)reverseTransformedValue:(id)value {
	if ([value isKindOfClass:[NSNull class]])
		return [NSNull null];

	if ([value isKindOfClass:[NSString class]]) {
		id result = (!self.isReversed
						 ? [BLLanguageTranslator identifierForLanguage:value]
						 : [BLLanguageTranslator descriptionForLanguage:value]);
		return (result) ? result : value;
	}

	if ([value isKindOfClass:[NSArray class]]) {
		NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:[value count]];
		for (NSUInteger i = 0; i < [value count]; i++)
			[newArray addObject:[self reverseTransformedValue:[value objectAtIndex:i]]];
		return newArray;
	}

	return nil;
}

@end
