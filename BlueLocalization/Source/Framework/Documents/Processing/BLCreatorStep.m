//
//  BLCreatorStep.m
//  BlueLocalization
//
//  Created by Max Seelemann on 29.04.09.
//  Copyright 2009 The Blue Technologies Group. All rights reserved.
//

#import "BLCreatorStep.h"

#import "BLCreationStep.h"
#import "BLProcessManager.h"

/*!
 @abstract Internal methods of BLCreatorStep.
 */
@interface BLCreatorStep (BLCreatorStepInternal)

- (id)initForCreatingObjects:(NSArray *)objects inLanguages:(NSArray *)languages reinject:(BOOL)reinject;

@end

@implementation BLCreatorStep

#pragma mark - Initialization

+ (id)stepForCreatingObjects:(NSArray *)objects inLanguages:(NSArray *)languages reinject:(BOOL)reinject {
	return [[self alloc] initForCreatingObjects:objects inLanguages:languages reinject:reinject];
}

- (id)initForCreatingObjects:(NSArray *)objects inLanguages:(NSArray *)languages reinject:(BOOL)reinject {
	self = [super init];

	if (self != nil) {
		objects = [BLObject fileObjectsFromArray:objects];
		objects = [BLObject proxiesForObjects:objects];

		_languages = languages;
		_objects = objects;
		_reinject = reinject;
	}

	return self;
}

#pragma mark - Runtime

- (void)perform {
	NSMutableArray *group = [NSMutableArray arrayWithCapacity:[_objects count] * [_languages count]];
	NSMutableArray *referenceGroup = [NSMutableArray arrayWithCapacity:[_objects count]];
	NSMutableArray *referenceFileObjects = [NSMutableArray arrayWithCapacity:[_objects count]];

	NSDocument<BLDocumentProtocol> *document = [[self manager] document];
	BLPathCreator *pathCreator = [document pathCreator];
	NSString *reference = [document referenceLanguage];
	NSArray *allLanguages = [document languages];

	// Run through all objects
	for (BLFileObject *fileObject in _objects) {
		NSMutableArray *languages = [NSMutableArray arrayWithArray:fileObject.changedLanguages];

		// Filter the reference language and update the object
		if (fileObject.referenceChanged) {
			[languages setArray:allLanguages];
			if (![fileObject.changedValues containsObject:reference])
				[languages removeObject:reference];

			[fileObject setChangedLanguages:languages];
			fileObject.referenceChanged = NO;
		}

		// Get the languages currently to be created
		if (!_reinject) {
			NSMutableSet *writeLanguages = [NSMutableSet setWithArray:languages];

			// Include languages missing the files
			for (NSString *language in allLanguages) {
				NSString *path = [pathCreator absolutePathForFile:fileObject andLanguage:language];
				if (![[NSFileManager defaultManager] fileExistsAtPath:path])
					[writeLanguages addObject:language];
			}

			// Only the languages requested
			[writeLanguages intersectSet:[NSSet setWithArray:_languages]];
			[languages setArray:[writeLanguages allObjects]];
		}
		else {
			// All languages have to be updated
			[languages setArray:_languages];
			[languages removeObject:reference];
		}

		// Add a creator step for each language
		for (NSString *language in languages) {
			NSString *path = [pathCreator absolutePathForFile:fileObject andLanguage:language];
			BLCreationStep *step = [[BLCreationStep alloc] initForCreatingFile:path fromObject:fileObject withLanguage:language reinject:_reinject];

			if ([language isEqual:reference]) {
				[referenceGroup addObject:step];
				[referenceFileObjects addObject:fileObject];
			}
			else {
				[group addObject:step];
			}
		}
	}

	// Enqueue group if it is not empty
	if ([group count])
		[[self manager] enqueueStepGroup:group afterGroup:[NSNull null]];
	if ([referenceGroup count]) {
		if ([group count])
			[[self manager] enqueueStepGroup:referenceGroup afterGroup:group];
		else
			[[self manager] enqueueStepGroup:referenceGroup];

		if ([document isKindOfClass:[BLDatabaseDocument class]])
			[(BLDatabaseDocument *)document rescanObjects:referenceFileObjects force:NO];
	}
}

- (NSString *)action {
	return NSLocalizedStringFromTableInBundle(@"Preparing", @"BLProcessStep", [NSBundle bundleForClass:[self class]], nil);
}

@end
