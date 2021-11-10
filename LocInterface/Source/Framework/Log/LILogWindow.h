/*!
 @header
 LILogWindow.h
 Created by Max Seelemann on 03.09.06.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

/*!
 @abstract The default GUI display method for the BLProcessLog.
 */
@interface LILogWindow : NSResponder {
	BLProcessLogLevel _displayLevel;
	BOOL _wasClosed;

	IBOutlet NSOutlineView *outlineView;
	IBOutlet NSPanel *window;
}

/*!
 @abstract Returns the single default log window controller.
 */
+ (id)logWindow;

/*!
 @abstract Opens the log utility window.
 */
- (void)show;

@end
