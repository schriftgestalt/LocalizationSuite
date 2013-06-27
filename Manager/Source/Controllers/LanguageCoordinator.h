//
//  LanguageCoordinator.h
//  Localization Manager
//
//  Created by Max Seelemann on 27.08.06.
//  Copyright 2006 The Blue Technologies Group. All rights reserved.
//

@class Document;

@interface LanguageCoordinator : NSObject
{
    IBOutlet Document	*document;
}

/*!
 @abstract Language objects for the languges in the document.
 */
@property(strong, readonly) NSArray *usedLanguageObjects;

/*!
 @abstract Indentifiers for all languages except the used ones of the document.
 */
@property(strong, readonly) NSArray *unusedLanguages;


/*!
 @abstract Opens a sheet to add alanguage form a list.
 */
- (void)addLanguages;

/*!
 @abstract Opens a sheet to add a custom language.
 */
- (void)addCustomLanguage;


/*!
 @abstract Update the status percentage for all languages.
 */
- (void)updateStatus;

/*!
 @abstract Update the status percentage of a single language.
 */
- (void)updateStatusForLanguage:(NSString *)language;

// Internal
- (void)disconnect;

@end
