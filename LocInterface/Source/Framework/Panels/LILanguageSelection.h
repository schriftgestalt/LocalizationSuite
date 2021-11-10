/*!
 @header
 LILanguageSelection.h
 Created by Max Seelemann on 20.03.08.

 @copyright 2004-2010 the Localization Suite. All rights reserved.
 */

/*!
 @abstract Represents a sheet that can be displayed to the user when he has to choose a language from a given set.
 */
@interface LILanguageSelection : NSAlert {
	IBOutlet NSArrayController *controller;
	IBOutlet NSSearchField *searchField;
	IBOutlet NSTableView *tableView;
	IBOutlet NSView *view;

	BOOL _multiple;
	NSArray *_languages;
	NSString *_search;
	NSArray *_selected;
}

/*!
 @abstract Designated initializer.
 */
+ (LILanguageSelection *)languageSelection;

/*!
 @abstract The languages that are presented to the user to choose from.
 */
@property (nonatomic, strong) NSArray *availableLanguages;

/*!
 @abstract The languages that were selected.
 @discussion If not set, this defaults to the first available language.
 */
@property (nonatomic, strong, readonly) NSArray *selectedLanguages;

/*!
 @abstract Sets whether multiple languages can be selected or not.
 @discussion Defaults to NO.
 */
@property (nonatomic, assign) BOOL allowMultipleSelection;

/*!
 @abstract The search entered by the user.
 */
@property (nonatomic, strong) NSString *search;

@end