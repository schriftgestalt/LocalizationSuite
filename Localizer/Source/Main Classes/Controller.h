//
//  Controller.h
//  Localizer
//
//  Created by Max on 01.12.2004
//  Copyright (c) 2003-2005 The Blue Technologies Group. All rights reserved.
//

#import <Sparkle/Sparkle.h>

@interface Controller : NSObject <SUVersionComparison>
{
}

// Localizer menu
- (IBAction)showPreferences:(id)sender;

// File menu
- (IBAction)importStrings:(id)sender;
- (IBAction)importXLIFF:(id)sender;

- (IBAction)exportAsDictionary:(id)sender;
- (IBAction)exportIntoDictionary:(id)sender;
- (IBAction)exportStrings:(id)sender;
- (IBAction)exportXLIFF:(id)sender;

// Edit menu
- (IBAction)selectNext:(id)sender;
- (IBAction)selectPrevious:(id)sender;

// Translation menu
- (IBAction)copyFromReference:(id)sender;
- (IBAction)editCopyOfRefernence:(id)sender;
- (IBAction)insertMissingPlaceholders:(id)sender;

- (IBAction)useFirstMatch:(id)sender;
- (IBAction)useSecondMatch:(id)sender;
- (IBAction)useThirdMatch:(id)sender;

- (IBAction)autotranslate:(id)sender;

// Window menu
- (IBAction)showDictionaries:(id)sender;
- (IBAction)showProcessLog:(id)sender;
- (IBAction)showStatusDisplay:(id)sender;


@end
