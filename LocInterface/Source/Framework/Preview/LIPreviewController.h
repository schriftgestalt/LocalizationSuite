/*!
 @header
 LIPreviewController.h
 Created by max on 05.04.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

#import <LocInterface/LIPreviewRootItem.h>

@class LIHighlightWindow, LIPreviewContent, LIPreviewContentView;

/*!
 @abstract A window controller displaying previews of BLFileObjects.
 @discussion Needs to be attached to an object conforming to the BLDocumentProtocol protocol.
 */
@interface LIPreviewController : NSWindowController <NSWindowDelegate, NSToolbarDelegate>
{
	IBOutlet LIPreviewContentView	*contentView;
	IBOutlet NSView					*languageView;
	IBOutlet NSView					*objectView;
	
	LIPreviewContent	*_content;
	NSMapTable			*_contentCache;
	NSString			*_currentLanguage;
	BLFileObject		*_file;
	LIHighlightWindow	*_highlightWindow;
	BLKeyObject			*_key;
	NSArray				*_languages;
	NSDictionary		*_toolbarItems;
	NSTimer				*_updateTimer;
	BOOL				_visible;
}

/*!
 @abstract Hides or shows the window without closing it.
 */
@property(nonatomic, assign) BOOL windowIsVisible;

/*!
 @abstract The file object the preview should be shown for.
 @discussion If a preview cannot be displayed, the window will contain a message displaying this to the user. If this is being set directly, keyObject is set to nil.
 */
@property(nonatomic, strong) BLFileObject *fileObject;

/*!
 @abstract The key object the preview should be shown for.
 @discussion Basically, this just load's the key's fileObject into the preview and focusses it, if at all possible.
 */
@property(nonatomic, strong) BLKeyObject *keyObject;

/*!
 @abstract The currently selected language.
 */
@property(nonatomic, strong) NSString *currentLanguage;

/*!
 @abstract All available languages.
 @discussion This has to be set by the provider of the file object to reflect the available languages.
 */
@property(nonatomic, strong) NSArray *languages;

/*!
 @abstract The root item currently being displayed.
 */
@property(nonatomic, strong) NSObject<LIPreviewRootItem> *currentRootItem;

/*!
 @abstract The root items currently available.
 @discussion Return value is an array containing objects conforming to LIPreviewRootItem.
 */
@property(nonatomic, strong, readonly) NSArray *availableRootItems;

@end

