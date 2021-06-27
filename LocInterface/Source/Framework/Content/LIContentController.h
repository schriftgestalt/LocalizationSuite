/*!
 @header
 LIContentController.h
 Created by max on 25.08.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

@class LIContentArrayController;

extern NSString *LIContentStatusColumnIdentifier;
extern NSString *LIContentActiveColumnIdentifier;
extern NSString *LIContentUpdatedColumnIdentifier;
extern NSString *LIContentFileColumnIdentifier;
extern NSString *LIContentKeyColumnIdentifier;
extern NSString *LIContentLeftColumnIdentifier;
extern NSString *LIContentRightColumnIdentifier;
extern NSString *LIContentCommentColumnIdentifier;
extern NSString *LIContentMediaColumnIdentifier;

/*!
 @abstract Controller object holding a view for displaying an array of key objects.
 @discussion The view being provided is a scroll view containing a table view. Users may set the hostView outlet to a instance of a content controller in interface builder. This results in the controller automatically placing it's view to fill the host.
 */
@interface LIContentController : NSObject <QLPreviewPanelDataSource> {
	IBOutlet LIContentArrayController *arrayController;
	IBOutlet NSView *hostView;
	IBOutlet NSScrollView *scrollView;
	IBOutlet NSTableView *tableView;

	NSString *_leftLanguage;
	NSArray *_objects;
	NSString *_previewPath;
	NSString *_rightLanguage;
}

/*!
 @abstract Designated Initializer.
 */
- (id)init;

/*!
 @abstract The scroll view containing the content display.
 @discussion You might adjust this view to your needs, like changing control sizes and changing the frame.
 */
- (NSScrollView *)view;

/*!
 @abstract The table view displaying the content.
 */
- (NSTableView *)contentView;

/*!
 @abstract The objects whose keys are being displayed.
 @discussion Need not be key objects only, might be any mixture of BLObjects.
 */
@property (nonatomic, strong) NSArray *objects;

/*!
 @abstract The key objects actually being displayed.
 */
@property (strong, nonatomic, readonly) NSArray *keyObjects;

/*!
 @abstract For performance considerations, bound the number of visible objects to a reasonable amount.
 @discussion Setting 0 means no limit.
 */
@property (nonatomic, assign) NSUInteger maximumVisibleObjects;

/*!
 @abstract The currently visible objects.
 @discussion This is affected by searches, filterPredicates, languages etc.
 */
@property (strong, nonatomic, readonly) NSArray *visibleObjects;

/*!
 @abstract The object currently selected in the table.
 @discussion This property is observable and also bindable. If multiple selections are allowed, this property always represents the last item.
 */
@property (nonatomic, strong) BLKeyObject *selectedObject;

/*!
 @abstract Whether the view allows multiple selection or not.
 */
@property (nonatomic) BOOL allowsMultipleSelection;

/*!
 @abstract The objects currently selected in the table.
 @discussion This property is observable and also bindable.
 */
@property (nonatomic, strong) NSArray *selectedObjects;

/*!
 @abstract The (identifier of the) language to be shown in the left content column.
 */
@property (nonatomic, strong) NSString *leftLanguage;

/*!
 @abstract Whether the left language column in user-editable.
 */
@property (nonatomic, assign) BOOL leftLanguageEditable;

/*!
 @abstract The (identifier of the) language to be shown in the right content column.
 */
@property (nonatomic, strong) NSString *rightLanguage;

/*!
 @abstract Whether the right language column in user-editable.
 */
@property (nonatomic, assign) BOOL rightLanguageEditable;

/*!
 @abstract Whether the user can edit the attached media of keys.
 */
@property (nonatomic, assign) BOOL attachedMediaEditable;

/*!
 @abstract Allows to show or hide several columns.
 */
@property (strong, nonatomic) NSArray *visibleColumnIdentifiers;

/*!
 @abstract Sets the hidden property of the passed table column.
 */
- (void)setColumnWithIdentifier:(NSString *)identifier isVisible:(BOOL)visible;

/*!
 @abstract Permanently and irreversibly removes a table column.
 */
- (void)removeColumnWithIdentifier:(NSString *)identifier;

/*!
 @abstract A string the key objects should be filter for.
 @discussion Matches will be highlighted in the interface. Set to nil or @"" if no search should be performed.
 */
@property (nonatomic, strong) NSString *search;

/*!
 @abstract A predicate that can be set to filter the keys.
 @discussion This works in conjunction with the search string that may also be set.
 */
@property (nonatomic, strong) NSPredicate *filterPredicate;

/*!
 @abstract Changed the selected object to the "next" object as currently visible.
 */
- (IBAction)selectNext:(id)sender;

/*!
 @abstract Changed the selected object to the "next" object as currently visible.
 */
- (IBAction)selectPrevious:(id)sender;

@end
