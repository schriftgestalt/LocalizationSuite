/*!
 @header
 LIAttachmentCell.h
 Created by max on 17.03.10.
 
 @copyright 2010 Localization Suite. All rights reserved.
 */

/*!
 @abstract Pasteboard type when dragging attachments.
 */
extern NSString *LIAttachmentPasteboardType;

/*!
 @abstract A custom cell that provides access to the attached media of a key object.
 */
@interface LIAttachmentCell : NSButtonCell
{
	NSFileWrapper	*fileWrapper;
}

@property(nonatomic, strong) NSFileWrapper *fileWrapper;

@end
