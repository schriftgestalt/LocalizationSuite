//
//  FileDetail.h
//  Localization Manager
//
//  Created by Max Seelemann on 04.09.06.
//  Copyright 2006 The Blue Technologies Group. All rights reserved.
//

@class Document;

@interface FileDetail : NSWindowController
{
    IBOutlet NSMatrix       *changeMatrix;
    IBOutlet NSPopUpButton  *typePopUp;
}

@property(strong) BLFileObject *fileObject;

@property(strong, readonly) NSString *fullPath;
@property(strong, readonly) NSString *currentErrors;

// Actions
- (IBAction)choosePath:(id)sender;
- (IBAction)moveFile:(id)sender;
- (IBAction)showFile:(id)sender;

// Internal actions
- (void)setFilePath:(NSString *)newPath;
- (void)moveFileToPath:(NSString *)newPath;

@end
