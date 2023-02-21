/*!
 @header
 BLDictionaryController.m
 Created by max on 16.08.06.

 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "BLDictionaryController.h"

NSString *LTDictionaryControllerDictionaryURLsKey = @"LTDictionaryControllerDictionaryURLs";
NSString *LTDictionaryControllerUseDocumentsKey = @"LTDictionaryControllerUseDocuments";

/*!
 @abstract Internal methods of LTDictionaryController
 */
@interface BLDictionaryController (LTDictionaryControllerInternal)

/*!
 @abstract Loads the persistent settings from the user defaults.
 */
- (void)loadSettings;

/*!
 @abstract Registers a set of dictionaries using path urls.
 @discussion The passed objects are strings of urls (retrieved using -absoluteString).
 */
- (void)registerDictionariesAtPathURLs:(NSArray *)paths;

/*!
 @abstract Registers a set of dictionaries.
 @discussion E.g. called by -registerDictionaryAtURL: to load new dictionaries.
 */
- (void)registerDictionariesAtURLs:(NSArray *)urls;

/*!
 @abstract Updates the available keys according to settings.
 @discussion This method is internally used whenever something changed.
 */
- (void)updateKeys;

@end

@implementation BLDictionaryController

id __sharedDictionaryController = nil;

- (id)init {
	self = [super init];

	_dictionaries = [[NSMutableArray alloc] init];
	_documents = [[NSMutableArray alloc] init];
	_keys = [[NSMutableArray alloc] init];
	_useDocuments = NO;

	__sharedDictionaryController = self;

	[self loadSettings];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:NSApp];

	return self;
}

- (void)dealloc {

	__sharedDictionaryController = nil;
}

+ (id)sharedInstance {
	if (!__sharedDictionaryController)
		__sharedDictionaryController = [[self alloc] init];

	return __sharedDictionaryController;
}

#pragma mark - Persistent Settings

- (void)loadSettings {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[self registerDictionariesAtPathURLs:[defaults objectForKey:LTDictionaryControllerDictionaryURLsKey]];
	[self setUseDocuments:[defaults boolForKey:LTDictionaryControllerUseDocumentsKey]];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	[defaults setObject:[_dictionaries valueForKeyPath:@"fileURL.absoluteString"] forKey:LTDictionaryControllerDictionaryURLsKey];
	[defaults setBool:[self useDocuments] forKey:LTDictionaryControllerUseDocumentsKey];
}

#pragma mark - Keys

- (NSArray *)availableKeys {
	return [NSArray arrayWithArray:_keys];
}

- (void)updateKeys {
	// Clean up
	[self willChangeValueForKey:@"availableKeys"];
	[_keys removeAllObjects];

	// Add the dictionary keys
	for (BLDictionaryDocument *dict in _dictionaries)
		[_keys addObjectsFromArray:[dict keys]];

	// Add the document keys
	for (BLLocalizerDocument *doc in _documents) {
		if ([doc respondsToSelector:@selector(embeddedDictionary)])
			[_keys addObjectsFromArray:[[doc embeddedDictionary] keys]];
		if (_useDocuments)
			[_keys addObjectsFromArray:[BLObject keyObjectsFromArray:[doc bundles]]];
	}

	// Notify
	[self didChangeValueForKey:@"availableKeys"];
}

#pragma mark - Dictionaries

- (NSArray *)loadedDictionaries {
	return _dictionaries;
}

- (void)registerDictionaryAtURL:(NSURL *)url {
	[self registerDictionariesAtURLs:[NSArray arrayWithObject:url]];
}

- (void)registerDictionariesAtPathURLs:(NSArray *)paths {
	NSMutableArray *urls;

	urls = [NSMutableArray arrayWithCapacity:[paths count]];
	for (NSString *path in paths) {
		if ([NSFileManager.defaultManager isReadableFileAtPath:path]) {
			[urls addObject:[NSURL URLWithString:path]];
		}
	}
	if (urls.count > 0) {
		[self registerDictionariesAtURLs:urls];
	}
}

- (void)registerDictionariesAtURLs:(NSArray *)urls {
	BLDictionaryDocument *document;
	NSError *error = nil;

	[self willChangeValueForKey:@"loadedDictionaries"];

	for (NSURL *url in urls) {
		// Try to open the dictionary
		document = [[BLDictionaryDocument alloc] initWithContentsOfURL:url ofType:@"" error:&error];
		if (!document) {
			BLLog(BLLogError, [error localizedDescription]);
			continue;
		}

		[_dictionaries addObject:document];
	}

	[self didChangeValueForKey:@"loadedDictionaries"];

	// Update the keys
	[self updateKeys];
}

- (void)unregisterDictionary:(BLDictionaryDocument *)aDocument {
	[self willChangeValueForKey:@"loadedDictionaries"];
	[_dictionaries removeObject:aDocument];
	[self didChangeValueForKey:@"loadedDictionaries"];

	[self updateKeys];
}

#pragma mark - Documents

- (BOOL)useDocuments {
	return _useDocuments;
}

- (void)setUseDocuments:(BOOL)flag {
	if (_useDocuments != flag) {
		_useDocuments = flag;
		[self updateKeys];
	}
}

- (NSArray *)loadedDocuments {
	return _documents;
}

- (void)registerDocument:(id)aDocument {
	if (![aDocument conformsToProtocol:@protocol(BLDocumentProtocol)] || ![aDocument respondsToSelector:@selector(bundles)])
		[NSException raise:NSInternalInconsistencyException format:@"Passed document %@ does not qualify! Check documentation.", aDocument];

	if (![_documents containsObject:aDocument]) {
		[self willChangeValueForKey:@"loadedDocuments"];
		[_documents addObject:aDocument];
		[self didChangeValueForKey:@"loadedDocuments"];

		[self updateKeys];
	}
}

- (void)unregisterDocument:(id)aDocument {
	if ([_documents containsObject:aDocument]) {
		[self willChangeValueForKey:@"loadedDocuments"];
		[_documents removeObject:aDocument];
		[self didChangeValueForKey:@"loadedDocuments"];

		[self updateKeys];
	}
}

@end
