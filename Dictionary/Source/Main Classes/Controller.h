//
//  Controller.h
//  Localizer
//
//  Created by Max on 01.12.2004
//  Copyright (c) 2003-2005 The Blue Technologies Group. All rights reserved.
//

#import <Sparkle/Sparkle.h>

@interface Controller : NSObject <SUVersionComparison> {
}

+ (Controller *)sharedInstance;

// General Actions
- (IBAction)showAboutBox:(id)sender;

// File menu
- (IBAction)importFiles:(id)sender;

- (IBAction)exportDictionary:(id)sender;
- (IBAction)exportTMX:(id)sender;

// Edit menu
- (IBAction)selectNext:(id)sender;
- (IBAction)selectPrevious:(id)sender;

// Dictionary menu
- (IBAction)showFilterSettings:(id)sender;
- (IBAction)addKey:(id)sender;
- (IBAction)deleteKey:(id)sender;
- (IBAction)addLanguage:(id)sender;
- (IBAction)deleteLanguage:(id)sender;

// Window menu
- (IBAction)showProcessLog:(id)sender;
- (IBAction)showStatusDisplay:(id)sender;

@end
