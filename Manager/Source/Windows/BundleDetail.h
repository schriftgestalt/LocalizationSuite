//
//  BundleDetailWindow.h
//  Localization Manager
//
//  Created by Max Seelemann on 04.09.06.
//  Copyright 2006 The Blue Technologies Group. All rights reserved.
//

@class Document;

@interface BundleDetail : NSWindowController {
	BLBundleObject *_bundle;
}

@property (nonatomic, strong) BLBundleObject *bundleObject;
@property (nonatomic, assign) BLReferencingStyle referencingStyle;

@property (strong, nonatomic, readonly) NSString *fullPath;
@property (strong, nonatomic, readonly) NSString *namingStyleComment;

// Actions
- (IBAction)choosePath:(id)sender;
- (IBAction)moveBundle:(id)sender;
- (IBAction)showBundle:(id)sender;

- (IBAction)renameFolders:(id)sender;

- (IBAction)addXcodeProject:(id)sender;

// Internal actions
- (void)setBundlePath:(NSString *)newPath;
- (void)moveBundleToPath:(NSString *)newPath;
- (void)updateLanguageFolderNames;

@end
