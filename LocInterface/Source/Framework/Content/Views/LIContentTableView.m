/*!
 @header
 LIContentTableView.m
 Created by max on 03.09.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "LIContentTableView.h"


@implementation LIContentTableView

- (void)textDidEndEditing:(NSNotification *)notification
{
	[super textDidEndEditing: notification];
	
	if ([[self dataSource] respondsToSelector: @selector(invalidateHeightOfRow:)])
		[(id)[self dataSource] invalidateHeightOfRow: [self selectedRow]];
}


#pragma mark - Copying

- (void)copy:(id)sender
{
	if ([[self delegate] respondsToSelector: @selector(tableViewShouldCopySelection:)])
		[(id)[self delegate] tableViewShouldCopySelection: self];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if ([menuItem action] == @selector(copy:)
		&& [[self delegate] respondsToSelector: @selector(tableViewShouldCopySelection:)])
		return YES;
	
	if ([[self nextResponder] respondsToSelector: @selector(validateMenuItem:)])
		return [[self nextResponder] validateMenuItem: menuItem];
	else
		return NO;
}


#pragma mark - QuickLook

- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel
{
	return [[self delegate] respondsToSelector: @selector(dataSourceForPreviewPanel:inTableView:)];
}

- (void)beginPreviewPanelControl:(QLPreviewPanel *)panel
{
	_previewPanel = panel;
	[_previewPanel setDataSource: [(id)[self delegate] dataSourceForPreviewPanel:panel inTableView:self]];
}

- (void)endPreviewPanelControl:(QLPreviewPanel *)panel
{
	_previewPanel = nil;
}

- (void)selectRowIndexes:(NSIndexSet *)indexes byExtendingSelection:(BOOL)extend
{
	[super selectRowIndexes:indexes byExtendingSelection:extend];
	
	if (_previewPanel)
		[_previewPanel reloadData];
}

- (void)keyDown:(NSEvent *)theEvent
{
	if ([[theEvent characters] isEqual: @" "]) {
		if ([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible])
			[[QLPreviewPanel sharedPreviewPanel] orderOut: nil];
		else
			[[QLPreviewPanel sharedPreviewPanel] orderFront: nil];
		return;
	}
	
	[super keyDown: theEvent];
}

@end
