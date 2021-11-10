//
//  CommentObject.m
//  Localization Manager
//
//  Created by Max on 12.02.05.
//  Copyright 2005 The Blue Technologies Group. All rights reserved.
//

#import "CommentObject.h"

#import "Document.h"
#import "OutlineItem.h"

NSString *commentOutlineViewFileColumnKey = @"file";
NSString *commentOutlineViewReferenceColumnKey = @"reference";
NSString *commentOutlineViewTranslatedColumnKey = @"translated";
NSString *commentOutlineViewCommentColumnKey = @"comment";

@implementation CommentObject

- (id)init {
	self = [super init];

	_keyArray = [[NSMutableArray alloc] init];
	_language = nil;
	_parentDocument = nil;

	return self;
}

- (void)dealloc {
	[window close];

	[_keyArray release];
	[_language release];

	[super dealloc];
}

#pragma mark -
#pragma mark Interface

- (void)createInterface {
	[NSBundle loadNibNamed:@"Comment" owner:self];

	[window setRepresentedFilename:[_parentDocument fileName]];
	[window setTitle:[NSString stringWithFormat:NSLocalizedString(@"CommentsWindowTitle", nil), [self language]]];
	[window setDelegate:self];

	[window setFrame:NSOffsetRect([window frame], 21, -23) display:YES];

	[window makeKeyAndOrderFront:self];
}

#pragma mark -
#pragma mark Accessors

- (NSArray *)keyArray {
	return _keyArray;
}

- (void)setKeyArray:(NSArray *)newArray {
	NSMutableArray *array;
	OutlineItem *parent;
	OutlineItem *item;
	unsigned i;

	array = [NSMutableArray array];
	[_keyArray removeAllObjects];

	for (i = 0; i < [newArray count]; i++) {
		if ([array indexOfObject:[[newArray objectAtIndex:i] fileObject]] == NSNotFound) {
			item = [[OutlineItem alloc] init];
			[item setObject:[[newArray objectAtIndex:i] fileObject]];
			[item setChildren:[NSMutableArray array]];

			[_keyArray addObject:item];
			[array addObject:[[newArray objectAtIndex:i] fileObject]];
			[item release];

			parent = item;
		}
		else {
			parent = [_keyArray objectAtIndex:[array indexOfObject:[[newArray objectAtIndex:i] fileObject]]];
		}

		item = [[OutlineItem alloc] init];

		[item setObject:[newArray objectAtIndex:i]];

		[[parent children] addObject:item];
		[item release];
	}

	[outlineView reloadData];
}

- (NSString *)language {
	return _language;
}

- (void)setLanguage:(NSString *)newLanguage {
	[_language release];
	_language = [newLanguage retain];
}

- (Document *)parentDocument {
	return _parentDocument;
}

- (void)setParentDocument:(Document *)document {
	_parentDocument = document;
}

#pragma mark -
#pragma mark Actions

- (IBAction)close:(id)sender {
	[_parentDocument closeComment:self];
}

#pragma mark -
#pragma mark Datasource methodes

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
	NSArray *array;

	if (item == nil)
		array = _keyArray;
	else
		array = [item children];

	return [array objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
	return ([[item children] count] > 0);
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
	if (item == nil)
		return [_keyArray count];
	else
		return [[item children] count];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
	NSString *identifier;

	identifier = [tableColumn identifier];

	if ([identifier isEqual:commentOutlineViewFileColumnKey]) {
		return [item dataForKey:@"key"];
	}
	if ([identifier isEqual:commentOutlineViewReferenceColumnKey]) {
		return [item dataForKey:[_parentDocument referenceLanguage]];
	}
	if ([identifier isEqual:commentOutlineViewTranslatedColumnKey]) {
		return [item dataForKey:[self language]];
	}
	if ([identifier isEqual:commentOutlineViewCommentColumnKey] && [[item object] isKindOfClass:[BLKeyObject class]]) {
		return [[item object] comment];
	}

	return nil;
}

#pragma mark -
#pragma mark Delegate methodes

- (BOOL)windowShouldClose:(id)sender {
	[self close:sender];
	return YES;
}

@end
