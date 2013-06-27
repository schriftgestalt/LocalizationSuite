/*!
 @header
 LINibPreviewContent.m
 Created by max on 06.04.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "LINibPreviewContent.h"

#import <BlueLocalization/BLNibFileObject.h>


/*!
 @abstract Internal extensions to NPObject used by LINibPreviewContentInternal only
 */
@interface NPObject (LINibPreviewContentInternal)

/*!
 @abstract Find a preview object for a nib object id
 @discussion Searches for the preview object belonging to the given object id by traversing the object tree.
 */
- (NPObject *)objectForNibObjectID:(NSString *)objectID;

/*!
 @abstract Find a preview object for a display view
 @discussion Searches for the preview object owning the given original by traversing the object tree.
 */
- (NPObject *)objectForDisplayView:(id)displayView;

@end

/*!
 @abstract The internal interface of the nib content object.
 */
@interface LINibPreviewContent ()
{
	NPObject		*_currentRoot;
	NPPreview		*_preview;
}

@end


@implementation LINibPreviewContent

+ (void)load
{
	[LIPreviewContent registerContentClass:[LINibPreviewContent class] forFileObjectClass:[BLNibFileObject class]];
}


#pragma mark - General

- (id)init
{
	self = [super init];
	
	if (self) {
		_currentRoot = nil;
		_preview = nil;
	}
	
	return self;
}



#pragma mark - Actions

- (BOOL)load
{
	BOOL isTemporary = YES;
	
	// Extract teh backup to a file
	NSFileWrapper *file = [self.fileObject attachedObjectForKey: BLBackupAttachmentKey];
	NSString *path = [@"/tmp" stringByAppendingPathComponent: [file preferredFilename]];
	
	// Fall back to the path creator if file cannot be written
	if (![file writeToFile:path atomically:YES updateFilenames:NO]) {
		BLLog(BLLogInfo, @"No backup available for file %@", [self.fileObject name]);
		
		path = [[self.document pathCreator] absolutePathForFile:self.fileObject andLanguage:[self.document referenceLanguage]];
		isTemporary = NO;
		
		if (![[NSFileManager defaultManager] fileExistsAtPath: path]) {
			BLLog(BLLogError, @"File for nib preview does not exist: %@", path);
			return NO;
		}
	}
	
	// Create the owner
	_preview = [[NPPreview alloc] initWithNibAtPath: path];
	if (!_preview) {
		BLLog(BLLogError, @"Cannot create preview object for nib file at path %@", path);
		return NO;
	}
	
	// Load the preview
	[_preview loadNib];
	if (_preview.rootObjects == nil) {
		BLLog(BLLogError, @"Unable to load preview for nib file at path %@", path);
		return NO;
	}
	
	[_preview setAssociatedFileObject: self.fileObject];
	[_preview setDisplayLanguage: self.language];
	
	// Select a preliminary root
	if (self.availableRootItems.count > 0)
		_currentRoot = [self.availableRootItems objectAtIndex: 0];
	
	// Delete the temporary file
	if (isTemporary)
		[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
	
	return YES;
}

- (NSObject<LIPreviewRootItem> *)rootItem
{
	return (id)_currentRoot;
}

- (NSArray *)availableRootItems
{
	NSMutableArray *objects;
	
	objects = [NSMutableArray array];
	for (NPObject *object in _preview.rootObjects) {
		if ([object displayView])
			[objects addObject: object];
	}
	
	return objects;
}

- (void)changeRootItem:(NSObject<LIPreviewRootItem> *)item
{
	if (![item isKindOfClass: [NPObject class]])
		[NSException raise:NSInvalidArgumentException format:@"Object passed to changeRootItem: is of class %@, but should be of class %@!", NSStringFromClass([item class]), NSStringFromClass([NPObject class])];
	
	[self willChangeValueForKey: @"rootItem"];
	_currentRoot = (NPObject *)item;
	[self didChangeValueForKey: @"rootItem"];
}

- (NSView *)rootView
{
	return [_currentRoot displayView];
}

+ (NSSet *)keyPathsForValuesAffectingRootView
{
	return [NSSet setWithObject: @"rootItem"];
}

- (void)setLanguage:(NSString *)aLanguage
{
	[super setLanguage: aLanguage];
	[_preview setDisplayLanguage: self.language];
}

#pragma mark - View Interaction

- (void)setFocussedKeyObject:(BLKeyObject *)keyObject
{
	NSString *objectID;
	NPObject *object;
	
	// Call super's implementation
	[super setFocussedKeyObject: keyObject];
	
	// Get the associated preview object
	for (NPObject *root in self.availableRootItems) {
		objectID = [self.focussedKeyObject nibObjectID];
		object = [root objectForNibObjectID: objectID];
		if (object)
			break;
	}
	if (!object)
		return;
	
	// Do we need to change the root?
	if (_currentRoot != [object rootObject])
		[self changeRootItem: (id)[object rootObject]];
	
	// Show the item
	[object makeOriginalVisible];
}

- (NSRect)rectOfFocussedKeyObject
{
	NSString *objectID;
	NPObject *object;
	
	// Get the preview object
	objectID = [self.focussedKeyObject nibObjectID];
	object = [_currentRoot objectForNibObjectID: objectID];
	if (!object)
		return NSZeroRect;
	
	// Get its frame
	return [object frameInRootDisplayView];
}

- (BLKeyObject *)keyObjectAtPoint:(NSPoint)point
{
	NPObject *object, *other;
	NSView *view, *rootView;
	
	// Find the targeted view
	rootView = self.rootView;
	view = [rootView hitTest: [rootView convertPoint:point toView:[rootView superview]]];
	if (!view)
		return nil;
	
	// Find the right preview object
	object = [_currentRoot objectForDisplayView: view];
	if (!object)
		return nil;
	
	// Find any matching key object downwards
	other = object;
	while (other && other.associatedKeyObjects.count == 0) {
		NPObject *child = nil;
		
		for (child in other.children) {
			if (NSPointInRect(point, [child frameInRootDisplayView]))
				break;
		}
		
		other = child;
	}
	
	// If nothing found search upwards
	if (!other)
		other = object;
	while (other && other.associatedKeyObjects.count == 0)
		other = other.parent;
	
	// Return the any of the found key objects 
	if (other)
		return [other.associatedKeyObjects objectAtIndex: 0];
	else
		return nil;
}

@end

@implementation NPObject (LINibPreviewContentInternal)

- (NPObject *)objectForNibObjectID:(NSString *)objectID
{
	if (!objectID)
		return nil;
	if ([self.nibObjectID isEqual: objectID])
		return self;
	
	for (NPObject *object in self.children) {
		NPObject *match = [object objectForNibObjectID: objectID];
		if (match)
			return match;
	}
	
	return nil;
}

- (NPObject *)objectForDisplayView:(id)displayView
{
	if ([self displayView] == displayView)
		return self;
	if (![self parent] && [self displayView] == [displayView superview])
		return self;
	
	for (NPObject *object in self.children) {
		NPObject *match = [object objectForDisplayView: displayView];
		if (match)
			return match;
	}
	
	return nil;
}

@end

