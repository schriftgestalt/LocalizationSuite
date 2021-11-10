/*!
 @header
 LIStatusDisplay.h
 Created by Max Seelemann on 18.11.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

/*!
 @abstract Shows a little modal panel with information about currently displayed content.
 */
@interface LIStatusDisplay : NSObject {
	IBOutlet NSView *calcStatsView;
	IBOutlet NSPanel *panel;
	IBOutlet NSView *splitView;
	IBOutlet NSView *statsView;

	BOOL _abortCalculation;
	BOOL _calculating;
	NSUInteger _calculationProgress;
	id _currentResponder;
	NSDictionary *_counters;
	NSDictionary *_selectionInfo;
	NSDictionary *_statistics;
	NSMutableDictionary *_visibility;
}

/*!
 @abstract Returns the single default status display
 */
+ (id)statusDisplay;

/*!
 @abstract Opens the status diplay utility window.
 */
- (void)show;

/*!
 @abstract The first language which statistics are being displayed.
 */
@property (nonatomic, strong, readonly) NSString *firstLanguage;

/*!
 @abstract The second language which statistics are being displayed.
 */
@property (nonatomic, strong, readonly) NSString *secondLanguage;

/*!
 @abstract A dictionary defining which parts of the statistics panel are visible.
 @discussion Holds three keys, "info", "counters" and "statistics", each refering to a boolean NSNumber for the visibility.
 */
@property (nonatomic, strong) NSDictionary *visibility;

/*!
 @abstract Returns a dictionary containing statistics about the current selection.
 @discussion Precisely, the dictionary contains three keys, "bundles", "files" and "keys", each refereing to an NSNumber object with an integer value of the respective count of selected objects.
 */
@property (nonatomic, readonly) NSDictionary *selectionInfo;

/*!
 @abstract Returns a dictionary containing the statistics of the first language.
 @discussion Precisely, the dictionary contains two keys, "first" and "second", where each object is again a dictionary with these keys:
	- "sentences" (the number of sentences in the keys),
	- "words" (the number of words in the keys) and
	- "characters" (the number of characters in the keys)
 Each of them is refering to an NSNumber object with an integer value of the respective statistical value of the selected objects.
 */
@property (nonatomic, readonly) NSDictionary *counters;

/*!
 @abstract Returns a dictionary containing the statistics of the second language.
 @discussion Precisely, the dictionary contains two keys, "keys" and "words", where each object is again a dictionary with these keys:
	- "translated" (keys that are already translated),
	- "exact" (keys that have an exact match),
	- "above75" (keys that have a guess above or equal 75%),
	- "above50" (keys that have a guess above or equal 75%) and
	- "noMatch" (keys for with no match was found).
 Each of them keys refers to a NSNumber with an integer value of the respective statistical value of the selected objects. Matches are calculated with the first as source and the second being the target language.
 */
@property (nonatomic, readonly) NSDictionary *statistics;

/*!
 @abstract Interface action when user wants the statistics to be calculated.
 */
- (IBAction)calculateStatistics:(id)sender;

/*!
 @abstract Information whether the stistics are currently being calculated.
 */
@property (nonatomic, readonly) BOOL isCalculatingStatistics;

/*!
 @abstract The progess of the statistics calculation in percent.
 */
@property (nonatomic, readonly) NSUInteger statisticsCalculationProgress;

@end

/*!
 @abstract The status display goes up the reponder chain and checks for objects implementing this protocol. If no object is found, a "no selection" placeholder is shown.
 */
@protocol LIStatusObjects <NSObject>

/*!
 @abstract Return the objects currently displayed or selected in the view.
 @discussion Should return an NSArray of BLObjects.
 */
- (NSArray *)currentObjects;

/*!
 @abstract Return the languages currently visible or displayed.
 @discussion Should return an NSArray of NSStrings representing language identifiers.
 */
- (NSArray *)currentLanguages;

@end

/*!
 @abstract A default implementation for the LIStatusObjects protocol for table views
 */
@interface NSTableView (LIStatusObjects) <LIStatusObjects>

/*!
 @abstract Notify the table view to update the current objects.
 */
- (void)updateCurrentObjects;

@end

/*!
 @abstract A extension to the NSTableView delegate protocol, providing an opportunity for easy implementation of the LIStatusObjects protocol for a table view.
 */
@protocol LIStatusObjectsTableViewDelegate
@optional

/*!
 @abstract The objects currently selected/visible in the table view.
 */
- (NSArray *)currentObjectsInTableView:(NSTableView *)tableView;

/*!
 @abstract The languages currently selected/visible in the table view.
 */
- (NSArray *)currentLanguagesInTableView:(NSTableView *)tableView;

@end
