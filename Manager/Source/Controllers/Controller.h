//
//  Controller.h
//  Localization Manager
//
//  Created by Max on Wed Nov 26 2003.
//  Copyright (c) 2003-2005 The Blue Technologies Group. All rights reserved.
//

#import <Sparkle/Sparkle.h>

@interface Controller : NSObject <SUVersionComparison> {
}

// Application Boot
+ (Controller *)sharedInstance;

// Interface Actions
- (IBAction)showPreferences:(id)sender;

- (IBAction)newDocument:(id)sender;
- (IBAction)newFromXcodeProject:(id)sender;

- (IBAction)importStrings:(id)sender;
- (IBAction)importXcodeProject:(id)sender;
- (IBAction)importXLIFF:(id)sender;

- (IBAction)exportAsDictionary:(id)sender;
- (IBAction)exportIntoDictionary:(id)sender;
- (IBAction)exportStrings:(id)sender;
- (IBAction)exportToXcodeProject:(id)sender;
- (IBAction)exportXLIFF:(id)sender;

// Localization Menu
- (IBAction)rescanFiles:(id)sender;
- (IBAction)rescanAllFiles:(id)sender;
- (IBAction)rescanFilesForced:(id)sender;
- (IBAction)synchronizeFiles:(id)sender;
- (IBAction)synchronizeAllFiles:(id)sender;

- (IBAction)convertFilesToXIB:(id)sender;

- (IBAction)copyFromReference:(id)sender;
- (IBAction)deleteTranslation:(id)sender;

// Languages menu
- (IBAction)addLanguage:(id)sender;
- (IBAction)addCustomLanguage:(id)sender;
- (IBAction)removeLanguage:(id)sender;
- (IBAction)updateLanguage:(id)sender;
- (IBAction)resetLanguage:(id)sender;
- (IBAction)reimportLanguage:(id)sender;
- (IBAction)changeReferenceLanguage:(id)sender;

// Files menu
- (IBAction)addFile:(id)sender;
- (IBAction)removeFile:(id)sender;
- (IBAction)viewFileContents:(id)sender;
- (IBAction)viewFileDetails:(id)sender;
- (IBAction)viewFilePreview:(id)sender;
- (IBAction)reInjectFile:(id)sender;
- (IBAction)reImportFile:(id)sender;

// Localizer Files menu
- (IBAction)setSaveLocation:(id)sender;
- (IBAction)exportLocalizerFiles:(id)sender;
- (IBAction)importLocalizerFiles:(id)sender;
- (IBAction)importLocalizerFilesDirectly:(id)sender;
- (IBAction)editLocalizerFiles:(id)sender;

// Window menu
- (IBAction)showProcessLog:(id)sender;
- (IBAction)showStatusDisplay:(id)sender;
- (IBAction)showDictionaries:(id)sender;

@end
