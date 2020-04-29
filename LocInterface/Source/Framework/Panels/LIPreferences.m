//
//  LIPreferences.m
//  LocInterface
//
//  Created by Max Seelemann on 02.11.10.
//  Copyright 2010 Localization Suite. All rights reserved.
//

#import "LIPreferences.h"

@interface LIPreferences () {
	NSArray *openDocuments;
	BLDocument *selectedDocument;
	NSMetadataQuery *query;
}

@property (strong, readwrite) NSArray *openDocuments;
- (void)startToolsQuery;

@end

@implementation LIPreferences

id __sharedLIPreferences;

- (NSString *)windowNibName {
	return nil;
}

- (id)init {
	self = [super init];

	if (self) {
		self.openDocuments = [NSArray array];
		self.selectedDocument = nil;

		[self addObserver:self forKeyPath:@"openDocuments" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionPrior context:@"documents"];
	}

	return self;
}

- (void)dealloc {
	__sharedLIPreferences = nil;
	[query removeObserver:self forKeyPath:@"results"];
}

+ (id)sharedInstance {
	if (!__sharedLIPreferences)
		__sharedLIPreferences = [[self alloc] init];

	return __sharedLIPreferences;
}

#pragma mark - Actions

- (void)open {
	[self.window makeKeyAndOrderFront:self];
}

- (void)close {
	[self.window close];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == @"documents") {
		if (![self.openDocuments containsObject:self.selectedDocument]) {
			if ([self.openDocuments count])
				self.selectedDocument = [self.openDocuments objectAtIndex:0];
			else
				self.selectedDocument = nil;
		}
	}
	else if (context == @"toolPaths") {
		if ([change objectForKey:NSKeyValueChangeNotificationIsPriorKey])
			[self willChangeValueForKey:@"availableDeveloperTools"];
		else
			[self didChangeValueForKey:@"availableDeveloperTools"];
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark - Document Management

@synthesize openDocuments;
@synthesize selectedDocument;

- (BOOL)multipleOpenDocuments {
	return ([self.openDocuments count] > 1);
}

+ (NSSet *)keyPathsForValuesAffectingMultipleOpenDocuments {
	return [NSSet setWithObject:@"openDocuments"];
}

- (void)initDocument:(BLDocument *)document {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *preferences = document.preferences;

	for (NSString *key in preferences) {
		if ([defaults objectForKey:key])
			[preferences setObject:[defaults objectForKey:key] forKey:key];
	}
}

- (void)registerDocument:(BLDocument *)document {
	[[self mutableArrayValueForKey:@"openDocuments"] addObject:document];
}

- (void)unregisterDocument:(BLDocument *)document {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary *preferences = document.preferences;

	for (NSString *key in preferences)
		[defaults setObject:[preferences objectForKey:key] forKey:key];

	[[self mutableArrayValueForKey:@"openDocuments"] removeObject:document];
}

#pragma mark - Developer tool paths

- (NSArray *)availableDeveloperTools {
	NSMutableArray *tools = [NSMutableArray array];

	for (__strong NSString *path in [self allXcodeApplicationPaths]) {
		NSDictionary *info = [NSBundle bundleWithPath:path].infoDictionary;

		// Search may return flase hits
		if (![[info objectForKey:@"CFBundleName"] isEqual:@"Xcode"])
			continue;

		NSString *version = [info objectForKey:@"CFBundleShortVersionString"];

		// Xcode >=4.3
		if ([version localizedStandardCompare:@"4.3"] != NSOrderedAscending) {
			[tools addObject:[NSDictionary dictionaryWithObjectsAndKeys:
											   [[path stringByAppendingPathComponent:@"Contents"] stringByAppendingPathComponent:@"Developer"], @"path",
											   path, @"displayPath",
											   version, @"version", nil]];
		}
		// Xcode <=4.2
		else {
			path = [[path stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
			[tools addObject:[NSDictionary dictionaryWithObjectsAndKeys:
											   path, @"path",
											   path, @"displayPath",
											   version, @"version", nil]];
		}
	}

	return tools;
}

- (NSArray *)allXcodeApplicationPaths {
	if (!query)
		[self startToolsQuery];

	// Get
	NSMutableArray *paths = [NSMutableArray array];
	for (NSMetadataItem *item in [query results])
		[paths addObject:[item valueForAttribute:(id)kMDItemPath]];

	// Sort
	[paths sortUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES]]];

	return paths;
}

- (void)startToolsQuery {
	// Search for Xcode
	query = [[NSMetadataQuery alloc] init];
	[query setPredicate:[NSPredicate predicateWithFormat:@"(kMDItemContentType = %@) && (kMDItemFSName LIKE 'Xcode*.app')", kUTTypeApplicationBundle]];
	[query setValueListAttributes:[NSArray arrayWithObjects:(id)kMDItemPath, nil]];

	// Run
	[query addObserver:self forKeyPath:@"results" options:NSKeyValueObservingOptionPrior context:@"toolPaths"];
	[query startQuery];
}

@end
