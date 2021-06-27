//
//  DocumentInternal.h
//  Localization Manager
//
//  Created by Max on Thu Oct 23 2008.
//  Copyright (c) 2003-2008 The Blue Technologies Group. All rights reserved.
//

// Paths
extern NSString *kLprojPathExtension;
extern NSString *kLocalizerPathExtension;
extern NSString *kDictionaryPathExtension;
extern NSString *kStringsPathExtension;

@interface Document () <NSMenuDelegate>

/*!
 @abstract Performs a check whether all bundles are still at the right path.
 */
- (void)checkBundlePaths;

/*!
 @abstract Returns the selected objects.
 @param	extend	If YES and no objects are selected, all objects will be returned.
 */
- (NSArray *)getSelectedObjects:(BOOL)extend;

@end

@interface Document (DocumentInternal)
/*!
 @abstract Notifies the document that a detail window was closed.
 */
- (void)detailWindowDidClose:(NSWindowController *)windowController;

- (void)beginSelectReferenceLanguageSheetWithSelector:(SEL)selector;

- (NSString *)pathForLocalizationFileOfLanguage:(NSString *)language;
- (NSString *)nameOfCompression:(NSInteger)compression;
- (void)compressFileAtPath:(NSString *)path usingCompression:(NSInteger)compression keepOriginal:(BOOL)keepOriginal;

- (void)readLocalizationFiles:(NSArray *)filenames importCompleteFile:(BOOL)import;
- (void)saveLocalizationFilesAndOpen:(BOOL)open;

@end
