/*!
 @header
 NPObject.m
 Created by max on 15.06.08.
 
 @copyright 2008-2009 Localization Suite. All rights reserved.
 */

#import "NPObject.h"

#import "NPObjectInterfaceExtensions.h"
#import "NPObjectPropertyExtensions.h"
#import "NPWindowObject.h"


NSString *NPObjectDidUpdateOriginalNotificationName = @"NPObjectDidUpdateOriginal";


@interface NPObject ()

/*!
 @abstract Returns a custom object class for a given original.
 */
+ (Class)previewObjectClassForOriginal:(id)original;

/*!
 @abstract Adds the observation for the display language to the associated key objects.
 */
- (void)addLanguageObservation;

/*!
 @abstract Removes the observation for the display language from the associated key objects.
 */
- (void)removeLanguageObservation;

@end


@implementation NPObject

+ (Class)previewObjectClassForOriginal:(id)original
{
	if ([original isKindOfClass: [NSWindow class]])
		return [NPWindowObject class];
	
	return [NPObject class];
}

+ (NPObject *)previewObjectWithOriginal:(id)original andID:(NSString *)identifier
{
	return [[[self previewObjectClassForOriginal: original] alloc] initWithOriginal:original andID:identifier];
}


#pragma mark - Initialization

- (id)init
{
	self = [super init];
	
	_children = [[NSMutableArray alloc] init];
	_keyObjects = nil;
	_label = nil;
	_objectID = nil;
	_original = nil;
	_parent = nil;
	_snapshot = NO;
	
	return self;
}

- (id)initWithOriginal:(id)original andID:(NSString *)identifier
{
	self = [self init];
	
	[self setOriginal: original];
	[self setNibObjectID: identifier];
	
	return self;
}

- (void)dealloc
{
	[self removeLanguageObservation];
	
	
}


#pragma mark - Accessors

- (NPObject *)rootObject
{
	if (!_parent)
		return self;
	else
		return _parent.rootObject;
}

@synthesize parent=_parent;
@synthesize children=_children;

- (void)setChildren:(NSArray *)someChildren
{
	[_children setValue:nil forKey:@"parent"];
	[_children setArray: someChildren];
	[_children setValue:self forKey:@"parent"];
}

@synthesize nibObjectID=_objectID;

@synthesize original=_original;
@synthesize label=_label;

@synthesize associatedKeyObjects=_keyObjects;

- (void)setAssociatedKeyObjects:(NSArray *)objects
{
	[self removeLanguageObservation];
	
	_keyObjects = objects;
	
	[self addLanguageObservation];
}


#pragma mark - Localization

@synthesize displayLanguage=_language;

- (void)setDisplayLanguage:(NSString *)language
{
	[self setDisplayLanguage:language useSnapshot:NO];
}

- (void)setDisplayLanguage:(NSString *)language useSnapshot:(BOOL)snapshot
{
	[self removeLanguageObservation];
	
	_language = language;
	_snapshot = snapshot;
	
	[self addLanguageObservation];
}

- (void)addLanguageObservation
{
	if (_language && [_language length]) {
		// Live updates
		if (!_snapshot) {
			NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [_keyObjects count])];
			@try {
				[_keyObjects addObserver:self toObjectsAtIndexes:indexes forKeyPath:_language options:NSKeyValueObservingOptionInitial context:NULL];
			}
			@catch (NSException *e) {
				// We cannot start observation, so just set
				for (BLKeyObject *key in _keyObjects)
					[self observeValueForKeyPath:_language ofObject:key change:nil context:NULL];
			}
		}
		// Read snapshot strings
		else {
			for (BLKeyObject *keyObject in _keyObjects) {
				NSString *property = [keyObject propertyName];
				id value = [keyObject snapshotForLanguage: _language];
				
				if (![[keyObject class] isEmptyValue: value])
					[_original setMappedValue:value forKey:property];
			}
		}
	}
}

- (void)removeLanguageObservation
{
	if (_language && [_language length] && !_snapshot) {
		NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [_keyObjects count])];
		@try {
			[_keyObjects removeObserver:self fromObjectsAtIndexes:indexes forKeyPath:_language];
		}
		@catch (NSException *e) {}
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	NSString *property = [object propertyName];
	if (property && ![object isEmptyForLanguage: keyPath]) {
		@try {
			id value = [object valueForKeyPath: keyPath];
			[_original setMappedValue:value forKey:property];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:NPObjectDidUpdateOriginalNotificationName object:self];
		}
		@catch (NSException *e) {}
	}
}


#pragma mark - Frames

- (NSRect)frameInRootView
{
	// Root
	if (!self.parent)
		return [_original frameOfChild: nil];
	
	// Calculate
	NSRect parentFrame = [self.parent frameInRootDisplayView];
	NSRect childFrame = [self.parent.original frameOfChild: self.original];
	
	NSRect frame;
	if (!NSEqualSizes(childFrame.size, NSZeroSize)) {
		frame = childFrame;
		frame.origin.x += parentFrame.origin.x;
		frame.origin.y += parentFrame.origin.y;
	} else {
		frame = parentFrame;
	}
	
	return frame;
}

- (void)setFrameInRootView:(NSRect)frame
{
	if (![self.original canSetFrame])
		return;
	
	// Calculate
	NSRect parentFrame = [self.parent frameInRootDisplayView];
	frame.origin.x -= parentFrame.origin.x;
	frame.origin.y -= parentFrame.origin.y;
	
	[self.parent.original setFrame:frame ofChild:self.original];
}


#pragma mark - Display Attributes

- (NSView *)displayView
{
	if ([_original isKindOfClass: [NSView class]])
		return _original;
	else
		return nil;
}

- (NSRect)frameInRootDisplayView
{
	NSRect parentFrame, childFrame, frame;
	
	// We are the root
	if (!self.parent)
		return [[self displayView] frameOfChild: nil];
	
	// Calculate
	parentFrame = [self.parent frameInRootDisplayView];
	
	if ([self.parent displayView]) {
		childFrame = [[self.parent displayView] frameOfChild: ([self displayView]) ?: self.original];
	}
	else {
		childFrame = [self.parent.original frameOfChild: self.original];
	}
	
	if (!NSEqualSizes(childFrame.size, NSZeroSize)) {
		frame = childFrame;
		frame.origin.x += parentFrame.origin.x;
		frame.origin.y += parentFrame.origin.y;
	} else {
		frame = parentFrame;
	}
	
	return frame;
}

- (void)makeOriginalVisible
{
	NPObject *object = self;
	while (object.parent) {
		[object.parent.original makeChildVisible:object.original target:self.original];
		object = object.parent;
	}
}

@end


