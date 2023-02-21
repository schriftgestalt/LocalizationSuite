//
//  Document.h
//  Localizer
//
//  Created by Max on 01.12.2004
//  Copyright (c) 2003-2005 The Blue Technologies Group. All rights reserved.
//

extern NSString *DocumentViewOptionDisplayEqualsAsOne;
extern NSString *DocumentViewOptionSearch;
extern NSString *DocumentViewOptionLeftLanguage;
extern NSString *DocumentViewOptionRightLanguage;
extern NSString *DocumentViewOptionShowComments;
extern NSString *DocumentViewOptionShowEditor;
extern NSString *DocumentViewOptionShowPreview;
extern NSString *DocumentViewOptionShowProblems;
extern NSString *DocumentViewOptionFilter;

@class Editor, InterfacePreviewController, DataSource;

@interface Document : BLLocalizerDocument {
	IBOutlet NSTreeController *bundlesController;
	IBOutlet LIContentController *content;
	IBOutlet Editor *editor;

	LIPreviewController *_previewController;
	LIProcessDisplay *_processDisplay;
	BLKeyObject *_selectedObject;
	NSMutableDictionary *_viewOptions;
	NSWindowController *_windowController;
}

// Properties
@property (strong) BLKeyObject *selectedObject;

@property (weak) IBOutlet NSView *languageSelectionView;
@property (weak) IBOutlet NSOutlineView *bundleListTableView;

- (NSArray *)filteredKeys;
- (NSUInteger)progress;

// Interface actions
- (IBAction)copyFromReference:(id)sender;
- (IBAction)editCopyOfRefernence:(id)sender;
- (IBAction)insertMissingPlaceholders:(id)sender;
- (IBAction)openSeparateEditor:(id)sender;

- (IBAction)editDictionaries:(id)sender;
- (IBAction)autotranslate:(id)sender;

- (IBAction)selectNext:(id)sender;
- (IBAction)selectPrevious:(id)sender;

- (IBAction)useFirstMatch:(id)sender;
- (IBAction)useSecondMatch:(id)sender;
- (IBAction)useThirdMatch:(id)sender;

// Import
- (IBAction)importStrings:(id)sender;
- (IBAction)importXLIFF:(id)sender;

// Export
- (IBAction)exportAsDictionary:(id)sender;
- (IBAction)exportIntoDictionary:(id)sender;

- (IBAction)exportStrings:(id)sender;
- (IBAction)exportXLIFF:(id)sender;

@end
