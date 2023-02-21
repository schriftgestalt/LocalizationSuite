//
//  DocumentLanguages.m
//  Localization Manager
//
//  Created by Max Seelemann on 23.10.08.
//  Copyright 2008 The Blue Technologies Group. All rights reserved.
//

#import "Document.h"
#import "DocumentInternal.h"

#import "LanguageCoordinator.h"
#import "Preferences.h"

#import "NSAlert-Extensions.h"

@implementation Document (DocumentLanguages)

#pragma mark - Manage Languages

- (IBAction)addNewLanguage:(id)sender {
	[languageCoordinator addLanguages];
}

- (IBAction)beginAddLanguage:(id)sender {
	LILanguageSelection *selection = [LILanguageSelection languageSelection];
	// Display
	[selection setMessageText:NSLocalizedString(@"AddLanguagesTitle", nil)];
	[selection setInformativeText:NSLocalizedString(@"AddLanguagesText", nil)];
	[selection addButtonWithTitle:NSLocalizedString(@"Add", nil)];
	[selection addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];

	// Languages
	NSMutableArray *languages = [NSMutableArray arrayWithArray:[BLLanguageTranslator allLanguageIdentifiers]];
	[languages removeObjectsInArray:self.languages];
	selection.availableLanguages = languages;
	selection.allowMultipleSelection = YES;

	[selection beginSheetModalForWindow:[self windowForSheet]
					  completionHandler:^(NSInteger result) {
		if (result != NSAlertFirstButtonReturn)
			return;

		[self addLanguage:selection.selectedLanguages.firstObject];
	}];
}

- (IBAction)addCustomLanguage:(id)sender {
	[languageCoordinator addCustomLanguage];
}

- (IBAction)removeLanguages:(id)sender {
	NSArray *languages = [self selectedLanguages];
	for (NSUInteger l = 0; l < [languages count]; l++)
		[self removeLanguage:[languages objectAtIndex:l]];
}

#pragma mark -

- (IBAction)updateLanguage:(id)sender {
	[self synchronizeObjects:_bundles forLanguages:[self selectedLanguages] reinject:NO];
}

- (IBAction)resetLanguage:(id)sender {
	NSAlert *alert = [NSAlert new];
	[alert setMessageText:NSLocalizedString(@"ResetLanguagesTitle", nil)];
	[alert addButtonWithTitle:NSLocalizedString(@"Yes", nil)];
	[alert addButtonWithTitle:NSLocalizedString(@"No", nil)];
	[alert setInformativeText:NSLocalizedString(@"ResetLanguagesText", nil)];
	[alert beginSheetModalForWindow:[self windowForSheet]
				  completionHandler:^(NSInteger result) {
		if (result != NSAlertFirstButtonReturn)
			return;

		[self synchronizeObjects:_bundles forLanguages:[self selectedLanguages] reinject:YES];
	}];
}

- (IBAction)reimportLanguage:(id)sender {
	NSAlert *alert = [NSAlert new];
	[alert setMessageText:NSLocalizedString(@"ReimportLanguagesTitle", nil)];
	[alert addButtonWithTitle:NSLocalizedString(@"Yes", nil)];
	[alert addButtonWithTitle:NSLocalizedString(@"No", nil)];
	[alert setInformativeText:NSLocalizedString(@"ReimportLanguagesText", nil)];
	[alert beginSheetModalForWindow:[self windowForSheet]
				  completionHandler:^(NSInteger result) {
		if (result != NSAlertFirstButtonReturn)
			return;

		[self reimportFiles:[self bundles] forLanguages:[self selectedLanguages]];
	}];
}

#pragma mark -

- (IBAction)changeReferenceLanguage:(id)sender {
	LILanguageSelection *selection = [LILanguageSelection languageSelection];

	// Display
	[selection setMessageText:NSLocalizedString(@"SelectReferenceLanguageTitle", nil)];
	[selection setInformativeText:NSLocalizedString(@"SelectReferenceLanguageText", nil)];
	[selection addButtonWithTitle:NSLocalizedString(@"Select", nil)];
	[selection addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];

	// Languages
	selection.availableLanguages = self.languages;
	
	[selection beginSheetModalForWindow:[self windowForSheet]
					  completionHandler:^(NSInteger result) {
		if (result != NSAlertFirstButtonReturn)
			return;
		
		if ([selection.selectedLanguages count])
			[self setReferenceLanguage:[selection.selectedLanguages lastObject]];
	}];
}

@end
