/*!
 @header
 LIContentTableView.h
 Created by max on 03.09.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

#import <LocInterface/LICustomColumnTableView.h>
#import <LocInterface/LIStatusDisplay.h>

/*!
 @abstract A custom table view used by the LIContent.
 @discussion Currently only invalidates row heigts after a edit.
 */
@interface LIContentTableView : LICustomColumnTableView
{
	QLPreviewPanel	*_previewPanel;
}

@end

/*!
 @abstract Extension to the delegate methods of a table view.
 */
@interface NSObject (LIContentTableViewDelegate)

/*!
 @abstract The delegate should copy the currently selected item to the default pasteboard.
 */
- (void)tableViewShouldCopySelection:(LIContentTableView *)tableView;

/*!
 @abstract The delegate should return the data source for the QuickLook preview panel.
 */
- (id <QLPreviewPanelDataSource>)dataSourceForPreviewPanel:(QLPreviewPanel *)previewPanel inTableView:(LIContentTableView *)tableView;

@end