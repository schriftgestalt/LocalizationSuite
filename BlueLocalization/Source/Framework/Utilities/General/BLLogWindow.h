/*!
 @header
 BLLogWindow.h
 Created by Max Seelemann on 03.09.06.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

@interface BLLogWindow : NSObject
{
    IBOutlet NSTextView *textView;
    IBOutlet NSPanel    *window;
    
    NSTextStorage   *_cache;
    NSFileHandle    *_error;
	NSTimer			*_readTimer;
}

+ (id)logWindow;

- (void)show;

@end
