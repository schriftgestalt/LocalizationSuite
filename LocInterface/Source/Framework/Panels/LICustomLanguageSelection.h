/*!
 @header
 LICustomLanguageSelection.h
 Created by Max Seelemann on 26.01.10.

 @copyright 2004-2010 the Localization Suite. All rights reserved.
 */

/*!
 @abstract Represents a sheet that can be displayed to the user when he has enter a custom language identifier.
 */
@interface LICustomLanguageSelection : NSAlert {
	IBOutlet NSTextField *textField;
	IBOutlet NSView *view;

	NSString *_language;
}

/*!
 @abstract Designated initializer.
 */
+ (LICustomLanguageSelection *)customLanguageSelection;

/*!
 @abstract The language that was entered by the user.
 */
@property (strong) NSString *language;

@end
