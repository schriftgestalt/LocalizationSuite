//
//  LanguageObject.h
//  Localization Manager
//
//  Created by Max Seelemann on 27.08.06.
//  Copyright 2006 The Blue Technologies Group. All rights reserved.
//

@interface LanguageObject : NSObject {
	NSArray *_bundles;
	NSString *_description;
	NSString *_identifier;
	BOOL _reference;
}

+ (id)languageObjectWithLanguage:(NSString *)aLanguage;
+ (id)languageObjectWithLanguage:(NSString *)aLanguage andBundles:(NSArray *)someBundles;

- (id)initWithLanguage:(NSString *)aLanguage andBundles:(NSArray *)someBundles;

- (NSString *)identifier;
- (NSString *)description;

- (NSString *)status;

- (BOOL)isReference;
- (void)setIsReference:(BOOL)flag;

- (void)updateBundles:(NSArray *)bundles;

@end
