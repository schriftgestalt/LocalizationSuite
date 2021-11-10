/*!
 @header
 BLPreparationStep.m
 Created by Max on 27.04.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLInterpreterStep.h"

#import "BLInterpretationStep.h"
#import "BLProcessManager.h"

enum {
	BLInterpreterStepTypeObjects,
	BLInterpreterStepTypeFiles
};

/*!
 @abstract Internal methods of BLInterpreterStep.
 */
@interface BLInterpreterStep () {
	NSArray *_languages;
	NSArray *_objects;
	NSDictionary *_parameters;
	NSUInteger _options;
	NSUInteger _type;
}

- (id)initForInterpertingObjects:(NSArray *)objects withOptions:(NSUInteger)options parameters:(NSDictionary *)parameters andLanguages:(NSArray *)languages;
- (id)initForInterpretingFiles:(NSArray *)files withOptions:(NSUInteger)options parameters:(NSDictionary *)parameters;

- (NSMutableArray *)getPathDictsFromObjects;
- (NSMutableArray *)getPathDictsFromFiles;

@end

@implementation BLInterpreterStep

#pragma mark - Initialization

+ (id)stepForInterpertingObjects:(NSArray *)objects withOptions:(NSUInteger)options parameters:(NSDictionary *)parameters andLanguages:(NSArray *)languages {
	return [[self alloc] initForInterpertingObjects:objects withOptions:options parameters:parameters andLanguages:languages];
}

- (id)initForInterpertingObjects:(NSArray *)objects withOptions:(NSUInteger)options parameters:(NSDictionary *)parameters andLanguages:(NSArray *)languages {
	self = [super init];

	if (self) {
		objects = [BLObject fileObjectsFromArray:objects];
		objects = [BLObject proxiesForObjects:objects];

		_languages = languages;
		_options = options;
		_parameters = parameters;
		_objects = objects;
		_type = BLInterpreterStepTypeObjects;
	}

	return self;
}

+ (id)stepForInterpretingFiles:(NSArray *)files withOptions:(NSUInteger)options parameters:(NSDictionary *)parameters {
	return [[self alloc] initForInterpretingFiles:files withOptions:options parameters:parameters];
}

- (id)initForInterpretingFiles:(NSArray *)files withOptions:(NSUInteger)options parameters:(NSDictionary *)parameters {
	self = [super init];

	if (self) {
		_languages = nil;
		_options = options;
		_parameters = parameters;
		_objects = [BLFileInterpreter filePathsFromPaths:files];
		_type = BLInterpreterStepTypeFiles;
	}

	return self;
}

#pragma mark - Constants

+ (NSUInteger)optionsForReferenceFiles {
	return BLFileInterpreterAllowChangesToKeyObjects | BLFileInterpreterTrackValueChangesAsUpdate;
}

+ (NSUInteger)optionsForRegularFiles {
	return BLFileInterpreterNoOptions;
}

#pragma mark - Runtime

- (void)perform {
	// Reduce input to path commands
	NSMutableArray *paths;

	switch (_type) {
		case BLInterpreterStepTypeObjects:
			paths = [self getPathDictsFromObjects];
			break;
		case BLInterpreterStepTypeFiles:
			paths = [self getPathDictsFromFiles];
			break;
		default:
			return;
	}

	// If no files need to be imported, we abort here
	if (![paths count])
		return;

	// Get all paths for the reference language
	NSArray *referencePaths = [paths objectsContainingValue:[[[self manager] document] referenceLanguage] forKeyPath:@"language"];

	NSMutableArray *referenceGroup = [NSMutableArray arrayWithCapacity:[referencePaths count]];
	for (NSUInteger i = 0; i < [referencePaths count]; i++) {
		NSDictionary *pathDict = [referencePaths objectAtIndex:i];
		[referenceGroup addObject:[[BLInterpretationStep alloc] initForInterpretingFile:[pathDict objectForKey:@"path"] toObject:[pathDict objectForKey:@"fileObject"] withLanguage:[pathDict objectForKey:@"language"] andOptions:(_options | [[self class] optionsForReferenceFiles]) parameters:_parameters]];
	}
	if ([referenceGroup count])
		[[self manager] enqueueStepGroup:referenceGroup afterGroup:[NSNull null]];

	// Get all paths for the other languages
	[paths removeObjectsInArray:referencePaths];

	NSMutableArray *group = [NSMutableArray arrayWithCapacity:[paths count]];
	for (NSUInteger i = 0; i < [paths count]; i++) {
		NSDictionary *pathDict = [paths objectAtIndex:i];
		[group addObject:[[BLInterpretationStep alloc] initForInterpretingFile:[pathDict objectForKey:@"path"] toObject:[pathDict objectForKey:@"fileObject"] withLanguage:[pathDict objectForKey:@"language"] andOptions:(_options | [[self class] optionsForRegularFiles]) parameters:_parameters]];
	}
	if ([group count]) {
		if ([referenceGroup count])
			[[self manager] enqueueStepGroup:group afterGroup:referenceGroup];
		else
			[[self manager] enqueueStepGroup:group afterGroup:[NSNull null]];
	}
}

- (NSMutableArray *)getPathDictsFromObjects {
	BLPathCreator *pathCreator;
	NSMutableArray *paths;

	pathCreator = [[[self manager] document] pathCreator];
	paths = [NSMutableArray arrayWithCapacity:[_objects count]];

	// Go through all objects and check
	for (NSUInteger i = 0; i < [_objects count]; i++) {
		BLFileInterpreter *interpreter;
		BLFileObject *file;

		// Get file and an according interpreter
		file = [_objects objectAtIndex:i];
		interpreter = [BLFileInterpreter interpreterForFileObject:file];
		[interpreter setOptions:_options];

		for (NSUInteger l = 0; l < [_languages count]; l++) {
			NSString *language, *path;

			// Check import
			language = [_languages objectAtIndex:l];
			if (![interpreter willInterpreteFileObject:file inDocument:[[self manager] document] withLanguage:language])
				continue;

			// Get path and add it
			path = [pathCreator absolutePathForFile:file andLanguage:language];
			[paths addObject:[NSDictionary dictionaryWithObjectsAndKeys:path, @"path", language, @"language", file, @"fileObject", nil]];
		}
	}

	return paths;
}

- (NSMutableArray *)getPathDictsFromFiles {
	NSMutableArray *paths = [NSMutableArray arrayWithCapacity:[_objects count]];

	// This just extracts the language from the path
	for (NSUInteger i = 0; i < [_objects count]; i++) {
		NSString *path = [_objects objectAtIndex:i];
		NSString *language = [BLPathCreator languageOfFileAtPath:path];

		if (path && language)
			[paths addObject:[NSDictionary dictionaryWithObjectsAndKeys:path, @"path", language, @"language", nil]];
	}

	return paths;
}

- (NSString *)action {
	return NSLocalizedStringFromTableInBundle(@"Preparing", @"BLProcessStep", [NSBundle bundleForClass:[self class]], nil);
}

@end
