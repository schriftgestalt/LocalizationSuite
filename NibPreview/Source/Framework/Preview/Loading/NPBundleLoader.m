/*!
 @header
 NPBundleLoader.m
 Created by max on 09.03.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "NPBundleLoader.h"

NSString *IBPreferencesIdentifier	= @"com.apple.InterfaceBuilder3.plist";
NSString *IBKnownPluginPathsKey		= @"IBKnownPluginPaths";
NSString *IBFrameworkName			= @"InterfaceBuilderKit.framework";


@implementation NPBundleLoader

id __sharedBundleLoader = nil;

- (id)init
{
	self = [super init];
	
	if (self != nil) {
		__sharedBundleLoader = self;
	}
	
	return self;
}

- (void)dealloc
{
	__sharedBundleLoader = nil;
}

+ (id)sharedInstance
{
	if (!__sharedBundleLoader)
		__sharedBundleLoader = [[self alloc] init];
	
	return __sharedBundleLoader;
}


#pragma mark - Class Actions

+ (NSArray *)interfaceBuilderKnownPluginPaths
{
	NSDictionary *prefs;
	NSString *path;
	NSArray *paths;
	
	paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
	
	path = [paths objectAtIndex: 0];
	path = [path stringByAppendingPathComponent: @"Preferences"];
	path = [path stringByAppendingPathComponent: IBPreferencesIdentifier];
	
	prefs = [NSDictionary dictionaryWithContentsOfFile: path];
	
	// Find plugin paths entries
	NSIndexSet *indexes = [[prefs allKeys] indexesOfObjectsPassingTest:^BOOL(NSString *key, NSUInteger idx, BOOL *stop) {
		return [key hasPrefix: IBKnownPluginPathsKey];
	}];
	NSArray *sortedKeys = [[[prefs allKeys] objectsAtIndexes: indexes] sortedArrayUsingSelector: @selector(localizedCompare:)];
	
	return [[prefs objectForKey: [sortedKeys lastObject]] allValues];
}

+ (NSString *)interfaceBuilderFrameworkPath
{
	NSString *path;
	
	path = BLToolPath.developerDirectory;
	path = [path stringByAppendingPathComponent: @"Library"];
	path = [path stringByAppendingPathComponent: @"Frameworks"];
	path = [path stringByAppendingPathComponent: IBFrameworkName];
	
	return path;
}


#pragma mark - Actions

- (void)loadBundles:(NSArray *)array
{
	for (NSString *path in array) {
		@try {
			[self loadBundle: path];
		}
		@catch (NSException *e) {
			NSLog(@"Can't load bundle: %@ Reason: %@", path, e.reason);
		}
	}
}

- (void)loadBundle:(NSString *)path
{
	NSBundle *bundle;
	NSError *error;
	
	// Test whether bundle exists
	if (![[NSFileManager defaultManager] fileExistsAtPath: path])
		[[NSException exceptionWithName:NSInvalidArgumentException reason:@"invalid path" userInfo:nil] raise];
	
	bundle = [NSBundle bundleWithPath: path];
	
	// We don't need to load bunldes twice
	if ([bundle isLoaded])
		return;
	
	// Prefilight test
	if (![bundle preflightAndReturnError: nil])
		[self loadInterfaceBuilderFrameworks];
	
	// Prefilight
	if (![bundle preflightAndReturnError: &error]) {
		NSLog(@"Can't load bundle: %@ Reason: %@", path, [error.userInfo objectForKey: @"NSDebugDescription"]);
		[[NSException exceptionWithName:NSGenericException reason:@"Preflight failed" userInfo:error.userInfo] raise];
	}
	
	// Load
	if (![bundle loadAndReturnError: &error]) {
		NSLog(@"Can't load bundle: %@ Reason: %@", path, [error.userInfo objectForKey: @"NSDebugDescription"]);
		[[NSException exceptionWithName:NSGenericException reason:@"Load failed" userInfo:error.userInfo] raise];
	}
}

- (void)loadInterfaceBuilderFrameworks
{
	// Make sure we only try once to load all the frameworks
	static BOOL __loadAttempted = NO;
	if (__loadAttempted)
		return;
	__loadAttempted = YES;
	
	// Attempt the load
	@try {
		[self loadBundle: [[self class] interfaceBuilderFrameworkPath]];
	}
	@catch (NSException *e) {}
}

@end


