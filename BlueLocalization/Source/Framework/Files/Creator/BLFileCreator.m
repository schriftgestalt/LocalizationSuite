/*!
 @header
 BLFileCreator.m
 Created by Max on 29.11.04.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLFileCreator.h"

// Globals
NSMutableDictionary *__fileCreatorClasses = nil;

@implementation BLFileCreator

+ (void)registerCreatorClass:(Class)creatorClass forFileType:(NSString *)extension {
	if (!__fileCreatorClasses)
		__fileCreatorClasses = [[NSMutableDictionary alloc] init];

	if (![creatorClass isSubclassOfClass:[BLFileCreator class]])
		[NSException raise:NSInvalidArgumentException format:@"creatorClass is no subclass of BLFileCreator"];
	if ([__fileCreatorClasses objectForKey:extension]) {
		Class class = [__fileCreatorClasses objectForKey:extension];

		// Ignore late superclasses
		if ([class isSubclassOfClass:creatorClass])
			return;
		// Throw on inheritance conflict
		if (![creatorClass isSubclassOfClass:class])
			[NSException raise:NSInvalidArgumentException format:@"there is already an creator for this extension"];
	}

	[__fileCreatorClasses setObject:creatorClass forKey:extension];
}

+ (id)creatorForFileType:(NSString *)extension {
	Class creatorClass;

	creatorClass = [__fileCreatorClasses objectForKey:extension];
	if (creatorClass == Nil)
		return nil;

	return [[creatorClass alloc] init];
}

+ (id)creatorForFileObject:(BLFileObject *)object {
	return [self creatorForFileType:([object customFileType]) ? [object customFileType] : [[object path] pathExtension]];
}

- (id)init {
	self = [super init];

	if (self != nil) {
		_options = [[self class] defaultOptions];
	}

	return self;
}

#pragma mark - Options

- (NSUInteger)options {
	return _options;
}

- (void)setOptions:(NSUInteger)options {
	_options = options;
}

- (BOOL)optionIsActive:(NSUInteger)option {
	return (_options & option) != 0;
}

- (void)activateOptions:(NSUInteger)options {
	_options |= options;
}

- (void)deactivateOptions:(NSUInteger)options {
	_options = _options & ~options;
}

+ (NSUInteger)defaultOptions {
	return BLFileCreatorNoOptions;
}

#pragma mark - Actions

- (BOOL)writeFileToPath:(NSString *)path fromObject:(BLFileObject *)object withLanguage:(NSString *)language referenceLanguage:(NSString *)defaultLanguage {
	BOOL success, result;

	// Init
	success = YES;

	// Reinject
	if ([self optionIsActive:BLFileCreatorReinject]) {
		result = [self _prepareReinjectAtPath:path];
		success = success && result;
	}

	// Actual export
	result = [self _writeFileToPath:path fromObject:object withLanguage:language referenceLanguage:defaultLanguage];
	success = success && result;

	return success;
}

- (BOOL)_prepareReinjectAtPath:(NSString *)path {
	if (![[NSFileManager defaultManager] fileExistsAtPath:path])
		return YES;

	// Try to remove file
	BOOL success = [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
	if (!success)
		BLLog(BLLogError, @"Reinject failed: Cannot remove file at path %@", path);

	return success;
}

- (BOOL)_writeFileToPath:(NSString *)path fromObject:(BLFileObject *)object withLanguage:(NSString *)language referenceLanguage:(NSString *)defaultLanguage {
	// Default implementation just throws an exception
	[NSException raise:NSInternalInconsistencyException format:@"Method should have been overridden by a subclass!"];

	return NO;
}

@end
