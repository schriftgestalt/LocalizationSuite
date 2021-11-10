//
//  Document.h
//  Localization Dictionary
//
//  Created by Max on 14.03.05.
//  Copyright 2005 The Blue Technologies Group. All rights reserved.
//

@interface Document : BLDictionaryDocument {
	IBOutlet LIContentController *content;
	IBOutlet NSPanel *filterSettingsPanel;

	NSMutableDictionary *_viewOptions;
	LIProcessDisplay *_processDisplay;
	BLKeyObject *_selectedObject;
}

@property (strong) NSDictionary *viewOptions;
@property (strong) BLKeyObject *selectedObject;

- (NSString *)filterDescription;

// Actions
- (IBAction)selectNext:(id)sender;
- (IBAction)selectPrevious:(id)sender;
- (IBAction)addKey:(id)sender;
- (IBAction)deleteKey:(id)sender;
- (IBAction)beginAddLanguage:(id)sender;
- (IBAction)beginDeleteLanguage:(id)sender;

- (IBAction)beginImportFiles:(id)sender;

- (IBAction)exportDictionary:(id)sender;
- (IBAction)exportTMX:(id)sender;

- (IBAction)showFilterSettings:(id)sender;
- (IBAction)closeFilterSettings:(id)sender;

@end
