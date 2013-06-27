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

- (IBAction)addNewLanguage:(id)sender
{
    [languageCoordinator addLanguages];
}

- (IBAction)addCustomLanguage:(id)sender
{
    [languageCoordinator addCustomLanguage];
}

- (IBAction)removeLanguages:(id)sender
{
	NSArray *languages = [self selectedLanguages];
	for (NSUInteger l=0; l<[languages count]; l++)
		[self removeLanguage: [languages objectAtIndex: l]];
}


#pragma mark -

- (IBAction)updateLanguage:(id)sender
{
	[self synchronizeObjects:_bundles forLanguages:[self selectedLanguages] reinject:NO];
}

- (IBAction)resetLanguage:(id)sender
{
	NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"ResetLanguagesTitle", nil)
									 defaultButton:NSLocalizedString(@"Yes", nil)
								   alternateButton:NSLocalizedString(@"No", nil) 
									   otherButton:nil
						 informativeTextWithFormat:NSLocalizedString(@"ResetLanguagesText", nil)];
	[alert beginSheetModalForWindow:[self windowForSheet] completionHandler:^(NSInteger result) {
		if (result != NSAlertDefaultReturn)
			return;
		
		[self synchronizeObjects:_bundles forLanguages:[self selectedLanguages] reinject:YES];
	}];
}

- (IBAction)reimportLanguage:(id)sender
{
	NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"ReimportLanguagesTitle", nil)
									 defaultButton:NSLocalizedString(@"Yes", nil)
								   alternateButton:NSLocalizedString(@"No", nil) 
									   otherButton:nil
						 informativeTextWithFormat:NSLocalizedString(@"ReimportLanguagesText", nil)];
	[alert beginSheetModalForWindow:[self windowForSheet] completionHandler:^(NSInteger result) {
		if (result != NSAlertDefaultReturn)
			return;
		
		[self reimportFiles:[self bundles] forLanguages:[self selectedLanguages]];
	}];
}


#pragma mark -

- (IBAction)changeReferenceLanguage:(id)sender
{
	LILanguageSelection *selection = [LILanguageSelection languageSelection];
	
	// Display
	[selection setMessageText: NSLocalizedString(@"SelectReferenceLanguageTitle", nil)];
	[selection setInformativeText: NSLocalizedString(@"SelectReferenceLanguageText", nil)];
	[selection addButtonWithTitle: NSLocalizedString(@"Select", nil)];
	[selection addButtonWithTitle: NSLocalizedString(@"Cancel", nil)];
	
	// Languages
	selection.availableLanguages = self.languages;
	
	[selection beginSheetModalForWindow:[self windowForSheet] completionHandler:^(NSInteger result) {
		if (result != NSAlertFirstButtonReturn)
			return;
		
		if ([selection.selectedLanguages count])
			[self setReferenceLanguage: [selection.selectedLanguages lastObject]];
	}];
}

@end
