/*!
 @header
 LIPreviewContent.m
 Created by max on 05.04.09.

 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "LIPreviewContent.h"

@implementation LIPreviewContent

NSMutableDictionary *__previewContentClasses = nil;

#pragma mark - Class Methods

+ (Class)contentClassForFileObjectClass:(Class)fileClass {
	for (NSString *className in __previewContentClasses.allKeys) {
		if ([fileClass isSubclassOfClass:NSClassFromString(className)])
			return NSClassFromString([__previewContentClasses objectForKey:className]);
	}

	return Nil;
}

+ (void)registerContentClass:(Class)aClass forFileObjectClass:(Class)fileClass {
	@autoreleasepool {

		if (!__previewContentClasses)
			__previewContentClasses = [[NSMutableDictionary alloc] init];
		[__previewContentClasses setObject:NSStringFromClass(aClass) forKey:NSStringFromClass(fileClass)];
	}
}

+ (LIPreviewContent *)contentWithFileObject:(BLFileObject *)object inDocument:(id<BLDocumentProtocol>)document {
	LIPreviewContent *content;
	Class aClass;

	aClass = [self contentClassForFileObjectClass:[object class]];
	if (aClass == Nil)
		return nil;

	content = [[aClass alloc] init];
	[content setFileObject:object];
	[content setDocument:document];

	// Try to load the preview
	if (![content load]) {
		return nil;
	}

	return content;
}

#pragma mark - Actions

- (id)init {
	self = [super init];

	if (self) {
		_document = nil;
		_fileObject = nil;
		_language = nil;
	}

	return self;
}

- (BOOL)load {
	return NO;
}

#pragma mark - Accessors

@synthesize document = _document;
@synthesize fileObject = _fileObject;
@synthesize focussedKeyObject = _keyObject;
@synthesize language = _language;

- (NSObject<LIPreviewRootItem> *)rootItem {
	return nil;
}

- (NSArray *)availableRootItems {
	return nil;
}

- (void)changeRootItem:(NSObject<LIPreviewRootItem> *)item {
}

- (NSView *)rootView {
	return nil;
}

- (NSRect)rectOfFocussedKeyObject {
	return NSZeroRect;
}

- (BLKeyObject *)keyObjectAtPoint:(NSPoint)point {
	return nil;
}

@end
