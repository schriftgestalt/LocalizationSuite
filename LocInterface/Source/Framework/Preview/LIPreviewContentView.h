/*!
 @header
 LIPreviewContentView.h
 Created by max on 05.04.09.

 @copyright 2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract The content view in the preview scroll view.
 @discussion Displays a white bevel over the dark gray background.
 */
@interface LIPreviewContentView : NSView {
	NSString *_statusText;
}

@property (nonatomic, strong) NSString *statusText;

@end
