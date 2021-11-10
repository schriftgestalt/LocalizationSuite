/*!
 @header
 LIProcessDisplay.h
 Created by Max Seelemann on 29.04.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

/*!
 @abstract A simple class that attaches to a process manager and shows a status sheet while it's running.
 */
@interface LIProcessDisplay : NSObject {
	IBOutlet NSButton *cancelButton;
	IBOutlet NSPanel *panel;

	BLProcessManager *_manager;
	NSTimer *_openTimer;
	NSWindow *_window;
}

/*!
 @abstract Designated initializer.
 */
- (id)initWithProcessManager:(BLProcessManager *)manager;

/*!
 @abstract Retruns the manager the display is currently attached to. Bindable.
 */
- (BLProcessManager *)manager;

/*!
 @abstract Cancel the current process.
 @discussion The sender will be disabled.
 */
- (IBAction)cancel:(id)sender;

/*!
 @abstract Opens the status sheet attached to the managers document window.
 @discussion Do not call directly, will be called automatically when the manager starts processing.
 */
- (void)openSheet;

/*!
 @abstract Closes the status sheet wherever it is attached.
 @discussion Do not call directly, will be called automatically when the manager stops processing.
 */
- (void)closeSheet;

/*!
 @abstract The window the process display sheet will be attached too.
 @discussion If this is nil (which is the default), then the sheet will be attached to the process manager's document's window for sheet.
 */
@property (strong) NSWindow *windowForSheet;

@end
