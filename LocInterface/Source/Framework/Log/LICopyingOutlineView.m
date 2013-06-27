/*!
 @header
 LICopyingOutlineView.h
 Created by Max Seelemann on 19.05.09.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "LICopyingOutlineView.h"


@implementation LICopyingOutlineView

- (IBAction)copy:(id)sender
{
	if ([[self delegate] respondsToSelector: @selector(copySelectionInOutlineView:toPasteboard:)])
		[(id)[self delegate] copySelectionInOutlineView:self toPasteboard:[NSPasteboard generalPasteboard]];
}

@end
