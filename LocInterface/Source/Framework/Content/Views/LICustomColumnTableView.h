/*!
 @header
 LICustomColumnTableView.h
 Created by max on 11.03.05.

 @copyright 2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract A table view that allows the user to hide and show columns using a context menu in it's header view.
 @discussion In addition it allows to save and restore the column state.
 */
@interface LICustomColumnTableView : NSTableView {
}

/*!
 @abstract The autosave data for the table column setup.
 @discussion Can be restored using setPersistentColumnSettings: and may be saved alongside other application data.
 */
- (NSArray *)persistentColumnSettings;

/*!
 @abstract Restores a persistent column setup.
 */
- (void)setPersistentColumnSettings:(NSArray *)settings;

@end

/*!
 @abstract A delegate extension to deliver different column names for the popup menu.
 */
@interface NSObject (LICustomColumnTableViewDelegate)

/*!
 @abstract Returns the name to be displayed for a given table column.
 */
- (NSString *)tableView:(NSTableView *)tableView customNameForColumn:(NSTableColumn *)column;

@end
