//
//  Preferences.m
//  Localization Manager
//
//  Created by Max Seelemann on 30.11.06.
//  Copyright 2006 The Blue Technologies Group. All rights reserved.
//

#import "Preferences.h"

#import "Controller.h"
#import "Document.h"

NSString *PreferencesNibFilename = @"Preferences";

NSString *PreferencesLastSelectedLanguageKey        = @"lastSelectedLanguage";
NSString *PreferencesOpenFolderAfterWriteoutKey		= @"openFolderAfterWriteOut";
NSString *PreferencesShowCommentsKey				= @"showComments";
NSString *PreferencesShowEmptyStringsKey			= @"showEmptyStrings";
NSString *PreferencesShowRemovedStringsKey          = @"showRemovedStrings";

NSString *PreferencesGeneralViewIdentifier			= @"general";
NSString *PreferencesImportViewIdentifier			= @"import";
NSString *PreferencesXcodeViewIdentifier			= @"xcode";
NSString *PreferencesFilesViewIdentifier			= @"files";


@implementation Preferences

- (NSString *)windowNibName
{
	return PreferencesNibFilename;
}

- (void)windowDidLoad
{
	[super windowDidLoad];
	
	NSToolbarItem *firstItem = [self.window.toolbar.items objectAtIndex: 0]; 
	[self.window.toolbar setSelectedItemIdentifier: firstItem.itemIdentifier];
	[self didSelectToolbarItem: firstItem];
	
	[self.window setFrameAutosaveName: @"Preferences"];
}

- (IBAction)didSelectToolbarItem:(NSToolbarItem *)sender
{
	[self showViewWithIdentifier: sender.itemIdentifier];
}

- (void)showViewWithIdentifier:(NSString *)identifier
{
	NSView *view = nil;
	
	if ([identifier isEqualToString: PreferencesGeneralViewIdentifier])
		view = generalView;
	else if ([identifier isEqualToString: PreferencesImportViewIdentifier])
		view = importView;
	else if ([identifier isEqualToString: PreferencesXcodeViewIdentifier])
		view = xcodeView;
	else if ([identifier isEqualToString: PreferencesFilesViewIdentifier])
		view = filesView;
	else
		return;
	
	// Update toolbar if neeeded
	if (![self.window.toolbar.selectedItemIdentifier isEqualToString: identifier])
		  self.window.toolbar.selectedItemIdentifier = identifier;
	
	// No need to switch
	if (view == self.window.contentView)
		return; 
	
	// Remove old view
	NSView *oldView = self.window.contentView;
	[self.window setContentView: nil];
	
	// Resize window
	NSRect frame = self.window.frame;
	frame.size.height += view.frame.size.height - oldView.frame.size.height;
	frame.size.width = view.frame.size.width;
	frame.origin.y -= view.frame.size.height - oldView.frame.size.height;
	[self.window setFrame:frame display:YES animate:YES];
	
	// Add new view
	[self.window setContentView: view];
}

#pragma mark - Interface Actions

- (IBAction)setSaveLocation:(id)sender
{
	[self showWindow: sender];
	[self showViewWithIdentifier: PreferencesFilesViewIdentifier];
	
	// Set up the panel
    NSOpenPanel *panel = [NSOpenPanel openPanel];
	
    [panel setCanChooseFiles: NO];
    [panel setCanChooseDirectories: YES];
    [panel setCanCreateDirectories: YES];
	[panel setMessage: NSLocalizedString(@"SelectLocalizerFileFolder", nil)];
    
	// Get the initial path
    NSString *path = [self.selectedDocument.preferences objectForKey: BLDatabaseDocumentLocalizerFilesPathKey];
	path = [[self.selectedDocument pathCreator] fullPathOfDocumentRelativePath: path];
	[panel setDirectoryURL: [NSURL fileURLWithPath: path]];
    
	// Show
	[panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
		if (result != NSFileHandlingPanelOKButton)
			return;
		
		NSString *path = [[self.selectedDocument pathCreator] documentRelativePathOfFullPath: [[panel URL] path]];
		if ([path length])
			[self.selectedDocument.preferences setObject:path forKey:BLDatabaseDocumentLocalizerFilesPathKey];
		else
			[self.selectedDocument.preferences removeObjectForKey:BLDatabaseDocumentLocalizerFilesPathKey];
		
		[self.selectedDocument updateChangeCount: NSChangeDone];
	}];
}

- (IBAction)showDictionaries:(id)sender
{
	[[Controller sharedInstance] showDictionaries: sender];
}

- (IBAction)editPlaceholders:(id)sender
{
	// Init placeholders if missing
	if (![self.selectedDocument.preferences objectForKey: BLDatabaseDocumentIgnoredPlaceholderStringsKey])
		[self.selectedDocument.preferences setObject:[BLDatabaseDocument defaultIgnoredPlaceholderStrings] forKey:BLDatabaseDocumentIgnoredPlaceholderStringsKey];
	
	// Show placeholder setup
	[placeholdersTableView selectRowIndexes:nil byExtendingSelection:NO];
	[placeholdersTableView reloadData];
	
	[NSApp beginSheet:placeholdersSheet modalForWindow:self.window modalDelegate:nil didEndSelector:nil contextInfo:NULL];
}

- (IBAction)closePlaceholdersSheet:(id)sender
{
	[NSApp endSheet: placeholdersSheet];
	[placeholdersSheet close];
}


#pragma mark - Placeholders Sheet

- (IBAction)addPlaceholder:(id)sender
{
	// Get mutable placeholder proxy
	NSMutableArray *mutablePlaceholders = [self.selectedDocument.preferences mutableArrayValueForKey: BLDatabaseDocumentIgnoredPlaceholderStringsKey];
	
	// Add data and reload
	NSUInteger row = (placeholdersTableView.selectedRow != -1) ? placeholdersTableView.selectedRow+1 : [mutablePlaceholders count];
	[mutablePlaceholders insertObject:@"" atIndex:row];
	[placeholdersTableView reloadData];
	
	// Begin editing
	[placeholdersTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
	[placeholdersTableView editColumn:0 row:row withEvent:nil select:YES];
	
	// Update change state
	[self.selectedDocument updateChangeCount: NSChangeDone];
}

- (IBAction)removePlaceholders:(id)sender
{
	// Get mutable placeholder proxy
	NSMutableArray *mutablePlaceholders = [self.selectedDocument.preferences mutableArrayValueForKey: BLDatabaseDocumentIgnoredPlaceholderStringsKey];
	
	// Remove and update view
	[mutablePlaceholders removeObjectsAtIndexes: placeholdersTableView.selectedRowIndexes];
	[placeholdersTableView selectRowIndexes:nil byExtendingSelection:NO];
	[placeholdersTableView reloadData];
	
	// Update change state
	[self.selectedDocument updateChangeCount: NSChangeDone];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [[self.selectedDocument.preferences objectForKey: BLDatabaseDocumentIgnoredPlaceholderStringsKey] count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	return [[self.selectedDocument.preferences objectForKey: BLDatabaseDocumentIgnoredPlaceholderStringsKey] objectAtIndex: row];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	// Get mutable placeholder proxy
	NSMutableArray *mutablePlaceholders = [self.selectedDocument.preferences mutableArrayValueForKey: BLDatabaseDocumentIgnoredPlaceholderStringsKey];
	
	// Replace object
	[mutablePlaceholders replaceObjectAtIndex:row withObject:object];
	
	// Update change state
	[self.selectedDocument updateChangeCount: NSChangeDone];
}

@end
