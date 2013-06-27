//
//  CommentObject.h
//  Localization Manager
//
//  Created by Max on 12.02.05.
//  Copyright 2005 The Blue Technologies Group. All rights reserved.
//

@class Document;

@interface CommentObject : NSObject
{
    IBOutlet NSOutlineView  *outlineView;
    IBOutlet NSWindow       *window;
    
    NSMutableArray  *_keyArray;
    NSString        *_language;
    Document        *_parentDocument;
}

// Interface
- (void)createInterface;

// Accessors
- (NSArray *)keyArray;
- (void)setKeyArray:(NSArray *)newArray;

- (NSString *)language;
- (void)setLanguage:(NSString *)newLanguage;

- (Document *)parentDocument;
- (void)setParentDocument:(Document *)document;

// Actions
- (IBAction)close:(id)sender;

@end
