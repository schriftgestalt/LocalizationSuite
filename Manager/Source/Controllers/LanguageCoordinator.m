//
//  LanguageCoordinator.m
//  Localization Manager
//
//  Created by Max Seelemann on 27.08.06.
//  Copyright 2006 The Blue Technologies Group. All rights reserved.
//

#import "LanguageCoordinator.h"

#import "Document.h"
#import "LanguageObject.h"

#import "NSAlert-Extensions.h"


@interface LanguageCoordinator ()
{
	BOOL			_isConnected;
}

@property(strong, readwrite) NSArray *usedLanguageObjects;
@property(strong, readwrite) NSArray *unusedLanguages;

- (void)rebuildLanguageArrays;
- (void)updateBundles;

@end

@implementation LanguageCoordinator

- (void)awakeFromNib
{
	[document addObserver:self forKeyPath:@"languages" options:0 context:@"LANGUAGES"];
    [document addObserver:self forKeyPath:@"referenceLanguage" options:0 context:@"LANGUAGES"];
    [document addObserver:self forKeyPath:@"bundles" options:0 context:@"BUNDLES"];
	
	_isConnected = YES;
	
    [self rebuildLanguageArrays];
}

- (void)disconnect
{
	if (_isConnected) {
		[document removeObserver:self forKeyPath:@"languages"];
		[document removeObserver:self forKeyPath:@"referenceLanguage"];
		[document removeObserver:self forKeyPath:@"bundles"];
		
		_isConnected = NO;
	}
}


#pragma mark - Accessors

@synthesize usedLanguageObjects, unusedLanguages;


#pragma mark - Actions

- (void)addLanguages
{
	LILanguageSelection *selection = [LILanguageSelection languageSelection];
	
	// Display
	[selection setMessageText: NSLocalizedString(@"AddLanguagesTitle", nil)];
	[selection setInformativeText: NSLocalizedString(@"AddLanguagesText", nil)];
	[selection addButtonWithTitle: NSLocalizedString(@"Add", nil)];
	[selection addButtonWithTitle: NSLocalizedString(@"Cancel", nil)];
	
	selection.availableLanguages = [self unusedLanguages];
	
	[selection beginSheetModalForWindow:[document windowForSheet] completionHandler:^(NSInteger result) {
		if (result != NSAlertFirstButtonReturn)
			return;
		
		for (NSString *language in selection.selectedLanguages)
			[document addLanguage: [BLLanguageTranslator identifierForLanguage: language]];
	}];
}

- (void)addCustomLanguage
{
	LICustomLanguageSelection *selection = [LICustomLanguageSelection customLanguageSelection];
	
	// Display
	[selection setMessageText: NSLocalizedString(@"AddCustomLanguageTitle", nil)];
	[selection setInformativeText: NSLocalizedString(@"AddCustomLanguageText", nil)];
	[selection addButtonWithTitle: NSLocalizedString(@"Add", nil)];
	[selection addButtonWithTitle: NSLocalizedString(@"Cancel", nil)];
	
	[selection beginSheetModalForWindow:[document windowForSheet] completionHandler:^(NSInteger result) {
		if (result != NSAlertFirstButtonReturn)
			return;
		
		[document addLanguage: selection.language];
	}];
}


#pragma mark - Observation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == @"BUNDLES") {
		[self performSelectorOnMainThread:@selector(updateBundles) withObject:nil waitUntilDone:NO];
	}
	else if (context == @"LANGUAGES") {
		[self performSelectorOnMainThread:@selector(rebuildLanguageArrays) withObject:nil waitUntilDone:NO];
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)updateStatus
{
    for (LanguageObject *object in self.usedLanguageObjects) {
		[object willChangeValueForKey: @"status"];
		[object didChangeValueForKey: @"status"];
	}
}

- (void)updateStatusForLanguage:(NSString *)language
{
    for (LanguageObject *object in self.usedLanguageObjects) {
		if ([[object identifier] isEqual: language]) {
			[object willChangeValueForKey: @"status"];
			[object didChangeValueForKey: @"status"];
			break;
		}
	}
}

- (void)rebuildLanguageArrays
{
    NSArray *allLanguages = [BLLanguageTranslator allLanguageIdentifiers];
	NSArray *languages = [document languages];
	
	// Build used language objects
	NSMutableArray *newUsedLanguageObjects = [NSMutableArray array];
    for (NSString *language in languages) {
		LanguageObject *object = [LanguageObject languageObjectWithLanguage:language andBundles:[document bundles]];
		[object setIsReference: [[document referenceLanguage] isEqual: language]];
		
        [newUsedLanguageObjects addObject: object];
	}
	self.usedLanguageObjects = newUsedLanguageObjects;
    
	// Build unused languges
	NSMutableArray *newUnusedLanguages = [NSMutableArray arrayWithArray: allLanguages];
	[newUnusedLanguages removeObjectsInArray: languages];
	self.unusedLanguages = newUnusedLanguages;
}

- (void)updateBundles
{
	for (LanguageObject *object in self.usedLanguageObjects)
		[object updateBundles: [document bundles]];
}

@end


