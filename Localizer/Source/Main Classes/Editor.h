//
//  EditorController.h
//  Localizer
//
//  Created by Max on 04.12.04.
//  Copyright 2004 The Blue Technologies Group. All rights reserved.
//

#import "StatisticsTextView.h"

@class Document;

@interface Editor : NSObject <StatisticsTextViewDelegate>
{
    IBOutlet NSView				*commentView;
	IBOutlet NSTableView		*errorsTableView;
	IBOutlet NSArrayController	*errorsArrayController;
    IBOutlet StatisticsTextView	*leftEditor;
	IBOutlet NSTableView		*matchesTableView;
	IBOutlet NSArrayController	*matchesArrayController;
    IBOutlet StatisticsTextView	*rightEditor;
	
	IBOutlet Document			*document;
	
	NSArray				*_errorsCache;
	NSTimer				*_errorsTimer;
	LTSingleKeyMatcher	*_matcher;
	NSArray				*_matchesCache;
	BOOL				_matchingEnabled;
}

- (void)setUp;
- (void)cleanUp;

@property(weak, readonly) Document *document;

// Content
@property(strong) NSString *comment;
@property(strong) NSObject *valueForLeftLanguage;
@property(strong) NSObject *valueForRightLanguage;

// Matching
@property(assign) BOOL matchingEnabled;
@property(assign) BOOL guessingEnabled;
@property(assign) BOOL useDocuments;

@property(strong, nonatomic) NSArray *matches;
- (IBAction)useMatch:(id)sender;
- (void)useMatchAtIndex:(NSUInteger)index;
- (void)useKeyMatch:(LTKeyMatch *)match;

// Translation Errors
@property(strong) NSArray *translationErrors;
- (IBAction)fixError:(id)sender;

// Interface accessors
@property(readonly) BOOL leftFieldEditable;
@property(readonly) BOOL rightFieldEditable;

@property(strong, readonly) NSColor *leftBackgroundColor;
@property(strong, readonly) NSColor *rightBackgroundColor;

// Editing
@property(readonly,getter=isEditing) BOOL editing;
- (void)beginEditing;

@end
