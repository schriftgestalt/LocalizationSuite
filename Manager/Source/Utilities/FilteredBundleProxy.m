//
//  FilteredBundleProxy.m
//  Localization Manager
//
//  Created by Max on 08.05.10.
//  Copyright 2010 Localization Foundation. All rights reserved.
//

#import "FilteredBundleProxy.h"


@implementation FilteredBundleProxy

- (id)initWithBundle:(BLBundleObject *)bundle andSearchString:(NSString *)string forLanguages:(NSArray *)languages
{
	if (self) {
		_bundle = bundle;
		_files = nil;
		_languages = languages;
		_search = string;
	}
	
	return self;
}


- (BOOL)fileObjectMatches:(BLFileObject *)file
{
	// Check name
	if ([[file name] rangeOfString: _search].length)
		return YES;
	
	// Create the filter
	NSMutableArray *filters = [NSMutableArray array];
	[filters addObject: [NSPredicate predicateWithFormat:@"key contains[cd] %@", _search]];
	for (NSString *language in _languages)
		[filters addObject: [NSPredicate predicateWithFormat:@"%K contains[cd] %@", language, _search]];
	
	NSPredicate *filter = [NSCompoundPredicate orPredicateWithSubpredicates: filters];
	
	// Filter all keys
	for (BLKeyObject *keyObject in file.objects) {
		if ([[[keyObject class] classOfObjects] isSubclassOfClass: [NSString class]] && [filter evaluateWithObject: keyObject])
			return YES;
	}
	
	return NO;
}

- (NSArray *)files
{
	if (!_files) {
		NSMutableArray *newFiles = [NSMutableArray array];
		
		for (BLFileObject *file in _bundle.files) {
			if ([self fileObjectMatches: file])
				[newFiles addObject: file];
		}
		
		_files = newFiles;
	}
	
	return _files;
}

- (id)valueForKey:(NSString *)key
{
	if ([key isEqual: @"files"])
		return [self files];
	else
		return [_bundle valueForKey: key];
}

- (id)valueForKeyPath:(NSString *)keyPath
{
	if ([keyPath isEqual: @"files"])
		return [self files];
	else
		return [_bundle valueForKeyPath: keyPath];
}

- (BLBundleObject *)original
{
	return _bundle;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
	[invocation invokeWithTarget: _bundle];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
	return [_bundle methodSignatureForSelector: sel];
}

@end
