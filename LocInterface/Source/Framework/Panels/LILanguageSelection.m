/*!
 @header
 LILanguageSelection.m
 Created by Max Seelemann on 20.03.08.

 @copyright 2004-2010 the Localization Suite. All rights reserved.
 */

#import "LILanguageSelection.h"

NSString *LILanguageSelectionNibName = @"LILanguageSelection";

/*!
 @abstract Internal methods used by LILanguageSelection.
 */
@interface LILanguageSelection (LILanguageSelectionInternal)

/*!
 @abstract Loads the auxiliary language selection view.
 */
- (void)loadInterface;

@end

@implementation LILanguageSelection

+ (LILanguageSelection *)languageSelection {
	return [[self alloc] init];
}

- (id)init {
	self = [super init];

	if (self != nil) {
		_languages = nil;
		_multiple = NO;
		_selected = nil;
		_search = nil;
	}

	return self;
}

#pragma mark - Accessors

@synthesize availableLanguages = _languages;
@synthesize allowMultipleSelection = _multiple;

@synthesize search = _search;

- (void)setSearch:(NSString *)newSearch {
	_search = newSearch;

	// Build filter
	if ([newSearch length])
		[controller setFilterPredicate:[NSPredicate predicateWithFormat:@"(SELF contains[cd] %@) or (%K contains[cd] %@)", newSearch, @"languageDescription", newSearch]];
	else
		[controller setFilterPredicate:nil];

	// Select object
	if (![[controller selectedObjects] count])
		[controller setSelectionIndex:0];
}

- (NSArray *)selectedLanguages {
	return [controller selectedObjects];
}

#pragma mark - Interface

- (void)loadInterface {
	[NSBundle loadNibNamed:LILanguageSelectionNibName owner:self];

	[controller setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"languageDescription" ascending:YES]]];

	[tableView setAllowsMultipleSelection:_multiple];

	if ([[self buttons] count]) {
		NSButton *defaultButton = [[self buttons] objectAtIndex:0];

		[tableView setTag:[defaultButton tag]];
		[tableView setTarget:[defaultButton target]];
		[tableView setDoubleAction:[defaultButton action]];
	}
}

- (void)beginSheetModalForWindow:(NSWindow *)sheetWindow completionHandler:(void (^)(NSModalResponse))handler {
	if (!view)
		[self loadInterface];
	[self setAccessoryView:view];

	[super beginSheetModalForWindow:sheetWindow completionHandler:handler];
	[[self window] makeFirstResponder:searchField];
}

- (void)beginSheetModalForWindow:(NSWindow *)window modalDelegate:(id)delegate didEndSelector:(SEL)didEndSelector contextInfo:(void *)contextInfo {
	if (!view)
		[self loadInterface];
	[self setAccessoryView:view];

	[super beginSheetModalForWindow:window modalDelegate:delegate didEndSelector:didEndSelector contextInfo:contextInfo];
	[[self window] makeFirstResponder:searchField];
}

@end
