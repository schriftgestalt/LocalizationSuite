/*!
 @header
 LIDictionarySettings.m
 Created by max on 28.06.09.

 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "LIDictionarySettings.h"

NSString *LIDictionarySettingsNibName = @"LIDictionarySettings";

@implementation LIDictionarySettings

static id __sharedDictionarySettings = nil;

- (id)init {
	self = [super init];

	__sharedDictionarySettings = self;

	return self;
}

- (void)dealloc {
	__sharedDictionarySettings = nil;
}

+ (id)sharedInstance {
	if (!__sharedDictionarySettings)
		__sharedDictionarySettings = [[self alloc] init];

	return __sharedDictionarySettings;
}

#pragma mark - WindowController Accessors

- (NSString *)windowNibName {
	return LIDictionarySettingsNibName;
}

#pragma mark - Accessors

- (BLDictionaryController *)controller {
	return [BLDictionaryController sharedInstance];
}

#pragma mark - Interface Actions

- (IBAction)addDictionary:(id)sender {
	NSOpenPanel *panel = [NSOpenPanel openPanel];

	[panel setAllowsMultipleSelection:YES];
	[panel setAllowedFileTypes:[NSArray arrayWithObject:[BLDictionaryFile pathExtension]]];
	
	[panel beginSheetModalForWindow:[self window]
				  completionHandler:^(NSInteger result) {
		if (result != NSModalResponseOK)
			return;
		
		BLDictionaryController *controller = [BLDictionaryController sharedInstance];
		for (NSURL *url in [panel URLs])
			[controller registerDictionaryAtURL:url];
	}];
}

- (IBAction)removeDictionaries:(id)sender {
	BLDictionaryController *controller = [BLDictionaryController sharedInstance];
	NSArray *dicts = [dictsController selectedObjects];
	
	for (BLDictionaryDocument *dict in dicts)
		[controller unregisterDictionary:dict];
}

@end
