/*!
 @header
 LIContentArrayController.h
 Created by max on 26.08.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract A custom array controller providing variable row heights and searching.
 @discussion Can also be used as data source. To use variable row heights, set the delegate outlet of the table to this controller or forward all calls to tableView:heightOfRow:. Column resizes will be detected and result in an update of the row heights.
 */
@interface LIContentArrayController : NSArrayController <NSTableViewDelegate>
{
	NSMapTable	*_columnCounts;
	BOOL		_editAttachments;
	NSUInteger	_maxCount;
	NSMapTable	*_rowCache;
	NSString	*_search;
	NSArray		*_searchPaths;
}

/*!
 @abstract The string to search for.
 */
@property(nonatomic, strong) NSString *searchPattern;

/*!
 @abstract The key paths of content objects to be searched.
 @discussion Searchable values must be of class NSString or NSAttributedString, others will be ignored.
 */
@property(nonatomic, strong) NSArray *searchableKeyPaths;

/*!
 @abstract Explicitly force the row heights to be recalulated.
 */
- (void)invalidateRowHeightsForTableView:(NSTableView *)tableView;

/*!
 @abstract Explicitly force the row height of one row to be recalulated for all table views.
 */
- (void)invalidateHeightOfRow:(NSUInteger)row;

/*!
 @abstract Limit the number of actually returned key objects.
 @discussion The only reason to do so would be performance considderations. Setting 0 means no limit.
 */
@property(nonatomic, assign) NSUInteger maximumArrangedObjects;

/*!
 @abstract Allows to disable the edition of attached media.
 */
@property(nonatomic, assign) BOOL canEditAttachments;

@end
