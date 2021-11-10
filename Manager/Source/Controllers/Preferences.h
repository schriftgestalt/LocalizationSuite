//
//  Preferences.h
//  Localization Manager
//
//  Created by Max Seelemann on 30.11.06.
//  Copyright 2006 The Blue Technologies Group. All rights reserved.
//

@interface Preferences : LIPreferences <NSToolbarDelegate, NSTableViewDataSource> {
	IBOutlet NSView *generalView;
	IBOutlet NSView *importView;
	IBOutlet NSView *xcodeView;
	IBOutlet NSView *filesView;

	IBOutlet NSWindow *placeholdersSheet;
	IBOutlet NSTableView *placeholdersTableView;
}

- (IBAction)setSaveLocation:(id)sender;
- (IBAction)showDictionaries:(id)sender;
- (IBAction)editPlaceholders:(id)sender;

- (IBAction)didSelectToolbarItem:(NSToolbarItem *)sender;
- (void)showViewWithIdentifier:(NSString *)identifier;

- (IBAction)addPlaceholder:(id)sender;
- (IBAction)removePlaceholders:(id)sender;
- (IBAction)closePlaceholdersSheet:(id)sender;

@end

// User preference keys
extern NSString *PreferencesOpenFolderAfterWriteoutKey;
extern NSString *PreferencesLastSelectedLanguageKey;
extern NSString *PreferencesShowCommentsKey;
extern NSString *PreferencesShowEmptyStringsKey;
extern NSString *PreferencesShowRemovedStringsKey;
