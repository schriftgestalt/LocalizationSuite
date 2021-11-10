//
//  LanguageObject.m
//  Localization Manager
//
//  Created by Max Seelemann on 27.08.06.
//  Copyright 2006 The Blue Technologies Group. All rights reserved.
//

#import "LanguageObject.h"

@implementation LanguageObject

- (id)initWithLanguage:(NSString *)aLanguage andBundles:(NSArray *)someBundles {
	self = [super init];

	_bundles = someBundles;
	_identifier = aLanguage;
	_description = [BLLanguageTranslator descriptionForLanguage:_identifier];
	_reference = NO;

	return self;
}

#pragma mark -

+ (id)languageObjectWithLanguage:(NSString *)aLanguage {
	return [[LanguageObject alloc] initWithLanguage:aLanguage andBundles:nil];
}

+ (id)languageObjectWithLanguage:(NSString *)aLanguage andBundles:(NSArray *)someBundles {
	return [[LanguageObject alloc] initWithLanguage:aLanguage andBundles:someBundles];
}

#pragma mark - Accessors

- (NSString *)identifier {
	return _identifier;
}

- (NSString *)description {
	return _description;
}

- (NSString *)status {
	NSUInteger missing, all;

	if (!_bundles)
		return NSLocalizedString(@"N/A", nil);

	all = [BLObject numberOfKeysInObjects:_bundles];
	missing = [BLObject numberOfKeysMissingForLanguage:_identifier inObjects:_bundles];

	if (all == 0)
		return NSLocalizedString(@"N/A", nil);
	if (missing == all)
		return NSLocalizedString(@"nothing", nil);
	if (missing == 0)
		return NSLocalizedString(@"complete", nil);

	return [NSString stringWithFormat:@"%1.1f%%", (1. - ((float)missing / all)) * 100.];
}

- (BOOL)isReference {
	return _reference;
}

- (void)setIsReference:(BOOL)flag {
	_reference = flag;
}

- (void)updateBundles:(NSArray *)bundles {
	[self willChangeValueForKey:@"status"];

	_bundles = bundles;

	[self didChangeValueForKey:@"status"];
}

@end
