/*!
 @header
 LIAttachmentCell.h
 Created by max on 17.03.10.
 
 @copyright 2010 Localization Suite. All rights reserved.
 */

#import "LIAttachmentCell.h"

#import <objc/message.h>


NSString *LIAttachmentPasteboardType	= @"LIAttachment";

#define kDeleteButtonSize	10


@implementation LIAttachmentCell

@synthesize fileWrapper;


- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder: aDecoder];
	
	if (self) {
		fileWrapper = nil;
	}
	
	return self;
}


#pragma mark - Accessors

- (NSImage *)iconWithSize:(NSSize)size
{
	NSImage *icon = [[fileWrapper icon] copy];
	if (!icon)
		icon = [[NSWorkspace sharedWorkspace] iconForFileType: [[fileWrapper preferredFilename] pathExtension]];
	[icon setSize: size];
	
	return icon;
}

- (void)setFileWrapper:(NSFileWrapper *)wrapper
{
	fileWrapper = wrapper;
	
	if (fileWrapper) {
		[self setImage: [self iconWithSize: NSMakeSize(15, 15)]];
		[self setTitle: [fileWrapper preferredFilename]];
	} else {
		[self setImage: nil];
		[self setTitle: nil];
	}
}


#pragma mark - Drawing

- (NSImage *)deleteImageWithColor:(NSColor *)color
{
	NSImage *delete = [NSImage imageNamed: NSImageNameStopProgressFreestandingTemplate];
	NSImage *image = [[NSImage alloc] initWithSize: NSMakeSize(kDeleteButtonSize, kDeleteButtonSize)];
	
	[delete setSize: [image size]];
	
	[image lockFocus];
	
	[color set];
	[NSBezierPath fillRect: NSMakeRect(0, 0, kDeleteButtonSize, kDeleteButtonSize)];
	[delete compositeToPoint:NSZeroPoint operation:NSCompositeDestinationAtop];
	
	[image unlockFocus];
	
	return image;
}

- (NSRect)deleteButtonFrame:(NSRect)cellFrame
{
	NSRect rect = cellFrame;
	rect.size = NSMakeSize(kDeleteButtonSize, kDeleteButtonSize);
	rect.origin.x += cellFrame.size.width - rect.size.width;
	rect.origin.y += floorf((cellFrame.size.height - rect.size.height) / 2);
	
	return rect;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	if (!fileWrapper || [self state] || ![self isEditable] || [self backgroundStyle] != NSBackgroundStyleDark) {
		[super drawWithFrame:cellFrame inView:controlView];
		return;
	}
	
	// Contents
	BOOL hightlighted = [self isHighlighted];
	[self setHighlighted: NO];
	
	NSRect newFrame = cellFrame;
	newFrame.size.width -= kDeleteButtonSize;
	[super drawWithFrame:newFrame inView:controlView];
	
	[self setHighlighted: hightlighted];
	
	// Delete mark
	NSImage *delete = [self deleteImageWithColor: (![self isHighlighted]) ? [NSColor whiteColor] : [NSColor lightGrayColor]];
	NSRect fromRect = NSMakeRect(0, 0, [delete size].width, [delete size].height);
	
	[delete drawInRect:[self deleteButtonFrame: cellFrame] fromRect:fromRect operation:NSCompositeSourceOver fraction:1];
}


#pragma mark - Events

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)flag
{
	// Only left clicks
	if ([theEvent type] != NSLeftMouseDown)
		return NO;
	
	// Double click open preview panel
	if ([theEvent clickCount] == 2 && fileWrapper) {
		[[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFront: nil];
		return YES;
	}
	
	// Begin event tracking
	NSPoint position;
	BOOL isDeleting;
	BOOL delete;
	
	position = [controlView convertPoint:[theEvent locationInWindow] fromView:nil];
	isDeleting = [self isEditable] && NSPointInRect(position, [self deleteButtonFrame: cellFrame]);
	[self setHighlighted: isDeleting];
	
	// Wait for next event
	do {
		theEvent = [[controlView window] nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask | NSMouseMovedMask];
		
		position = [controlView convertPoint:[theEvent locationInWindow] fromView:nil];
		delete = NSPointInRect(position, [self deleteButtonFrame: cellFrame]);
		
		if (isDeleting)
			[self setHighlighted: delete];
	}
	while (isDeleting && [theEvent type] != NSLeftMouseUp);
	
	// Deleting the attachment
	if ([theEvent type] == NSLeftMouseUp && isDeleting && delete) {
		[[self target] performSelector:[self action] withObject:self];
		return YES;
	}
	
	// Dragging the file
	if ([theEvent type] == NSLeftMouseDragged) {
		NSPasteboard *pboard = [NSPasteboard pasteboardWithName: NSDragPboard];
		[pboard declareTypes:[NSArray arrayWithObjects: NSFilesPromisePboardType, LIAttachmentPasteboardType, nil] owner:self];
		
		[pboard setPropertyList:[NSNumber numberWithInteger: (NSUInteger)((__bridge_retained void *) fileWrapper)] forType:LIAttachmentPasteboardType];
		[pboard setPropertyList:[NSArray arrayWithObject: [[fileWrapper preferredFilename] pathExtension]] forType:NSFilesPromisePboardType];
		
		NSPoint dragPosition = [controlView convertPoint:[theEvent locationInWindow] fromView:nil];
		dragPosition.x -= 16;
		dragPosition.y += 16;
		
		[self setState: YES];
		[self setHighlighted: YES];
		[controlView dragImage:[self iconWithSize: NSMakeSize(32, 32)] at:dragPosition offset:NSZeroSize event:theEvent pasteboard:pboard source:self slideBack:YES];
		
		return YES;
	}
	
	return YES;
}

- (NSArray *)namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination
{
	NSString *path = [dropDestination path];
	path = [path stringByAppendingPathComponent: [fileWrapper preferredFilename]];
	[fileWrapper writeToFile:path atomically:YES updateFilenames:NO];
	
	return [NSArray arrayWithObject: [fileWrapper preferredFilename]];
}

- (void)draggedImage:(NSImage *)image endedAt:(NSPoint)screenPoint operation:(NSDragOperation)operation
{
	[self setState: 0];
}

@end
