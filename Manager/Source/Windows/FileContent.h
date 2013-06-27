//
//  FileContentWindow.h
//  Localization Manager
//
//  Created by Max on 28.01.05.
//  Copyright 2005 The Blue Technologies Group. All rights reserved.
//

@class Document;

@interface FileContent : NSWindowController
{
	IBOutlet LIContentController	*content;
	IBOutlet LIContentController	*oldContent;
    IBOutlet NSSplitView			*splitview;
    IBOutlet NSView					*removedStringsView;
    
    BLFileObject		*_fileObject;
    NSString			*_otherLanguage;
	LIProcessDisplay	*_processDisplay;
	BLProcessManager	*_processManager;
    NSString			*_searchString;
	BOOL				_showComments;
    BOOL				_showEmptyStrings;
    BOOL				_showRemovedStrings;
}

// Accessors
@property(nonatomic, strong) BLFileObject *fileObject;

@property(nonatomic, strong) NSString *otherLanguage;
@property(nonatomic, strong, readonly) NSArray *availableOtherLanguages;
@property(nonatomic, strong) NSString *searchString;

@property(nonatomic) BOOL showComments;
@property(nonatomic) BOOL showEmptyStrings;
@property(nonatomic) BOOL showRemovedStrings;

// Actions
- (IBAction)markAsActive:(id)sender;
- (IBAction)markAsUpdated:(id)sender;

- (IBAction)copyFromReference:(id)sender;
- (IBAction)deleteTranslation:(id)sender;
- (IBAction)autotranslate:(id)sender;

- (void)beginObservationOfObjects:(NSArray *)objects;
- (void)endObservationOfObjects:(NSArray *)objects;

@end