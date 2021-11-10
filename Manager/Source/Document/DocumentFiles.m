//
//  DocumentFiles.m
//  Localization Manager
//
//  Created by Max Seelemann on 23.10.08.
//  Copyright 2008 The Blue Technologies Group. All rights reserved.
//

#import "Document.h"
#import "DocumentInternal.h"

#import "BundleDetail.h"
#import "FileContent.h"
#import "FileDetail.h"
#import "FilePreview.h"
#import "NSAlert-Extensions.h"
#import "Preferences.h"
#import <BlueLocalization/BLStringsFileObject.h>

@implementation Document (DocumentFiles)

#pragma mark - Manage Files

- (IBAction)addFile:(id)sender {
	NSOpenPanel *openPanel;

	openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setAllowsMultipleSelection:YES];

	[openPanel beginSheetModalForWindow:[self windowForSheet]
					  completionHandler:^(NSInteger result) {
						  if (result == NSAlertDefaultReturn)
							  [self addFiles:[[openPanel URLs] valueForKey:@"path"]];
					  }];
}

- (IBAction)removeFile:(id)sender {
	NSArray *objects = [self getSelectedObjects:NO];

	for (NSUInteger i = 0; i < [objects count]; i++) {
		BLObject *object = [objects objectAtIndex:i];

		if ([object isKindOfClass:[BLFileObject class]])
			[[(BLFileObject *)object bundleObject] removeFile:(BLFileObject *)object];
		if ([object isKindOfClass:[BLBundleObject class]])
			[self removeBundle:(BLBundleObject *)object];
	}

	[self updateChangeCount:NSChangeDone];
}

- (void)removeFilePanelDidEnd:(NSOpenPanel *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	NSArray *selectedObjects;
	NSUInteger i;

	selectedObjects = [self getSelectedObjects:NO];

	// remove files
	for (i = 0; i < [selectedObjects count]; i++) {
		id object = [selectedObjects objectAtIndex:i];
		if ([object isKindOfClass:[BLFileObject class]])
			[[object bundleObject] removeFile:object];
	}
	// remove bundles
	for (i = 0; i < [selectedObjects count]; i++) {
		id object = [selectedObjects objectAtIndex:i];
		if ([object isKindOfClass:[BLBundleObject class]])
			[self removeBundle:object];
	}
}

#pragma mark -

- (IBAction)rescanReferenceFiles:(id)sender {
	[self rescanObjects:[self getSelectedObjects:YES] force:NO];
}

- (IBAction)rescanReferenceFilesForced:(id)sender {
	[self rescanObjects:[self getSelectedObjects:NO] force:YES];
}

- (IBAction)rescanAllReferenceFiles:(id)sender {
	[self rescan:NO];
}

- (IBAction)reimportFiles:(id)sender {
	[self reimportFiles:[self getSelectedObjects:YES] forLanguages:[self languages]];
}

- (IBAction)reimportFilesForLanguage:(id)sender {
	[self reimportFiles:[self getSelectedObjects:YES] forLanguages:[NSArray arrayWithObject:[sender representedObject]]];
}

- (IBAction)synchronizeFiles:(id)sender {
	[self synchronizeObjects:[self getSelectedObjects:YES] forLanguages:[self languages] reinject:NO];
}

- (IBAction)synchronizeAllFiles:(id)sender {
	[self synchronizeObjects:[self bundles] forLanguages:[self languages] reinject:NO];
}

- (IBAction)reinjectFiles:(id)sender {
	// Get objects
	BOOL all = NO;
	if ([sender isKindOfClass:[NSView class]])
		all = (([[[sender window] currentEvent] modifierFlags] & NSAlternateKeyMask) != 0);
	NSArray *objects = (all) ? [self bundles] : [self getSelectedObjects:YES];

	// Show warning
	NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"ResetFilesTitle", nil)
									 defaultButton:NSLocalizedString(@"Yes", nil)
								   alternateButton:NSLocalizedString(@"No", nil)
									   otherButton:nil
						 informativeTextWithFormat:NSLocalizedString(@"ResetFilesText", nil)];
	[alert beginSheetModalForWindow:[self windowForSheet]
				  completionHandler:^(NSInteger result) {
					  if (result != NSAlertDefaultReturn)
						  return;

					  // Perform reinject
					  [self synchronizeObjects:objects forLanguages:[self languages] reinject:YES];
				  }];
}

- (IBAction)reinjectFilesForLanguage:(id)sender {
	NSString *language = [sender representedObject];
	NSString *languageName = [BLLanguageTranslator descriptionForLanguage:language];

	NSAlert *alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:NSLocalizedString(@"ResetFilesLanguageTitle", nil), languageName]
									 defaultButton:NSLocalizedString(@"Yes", nil)
								   alternateButton:NSLocalizedString(@"No", nil)
									   otherButton:nil
						 informativeTextWithFormat:NSLocalizedString(@"ResetFilesLanguageText", nil), languageName];
	[alert beginSheetModalForWindow:[self windowForSheet]
				  completionHandler:^(NSInteger result) {
					  if (result != NSAlertDefaultReturn)
						  return;

					  [self synchronizeObjects:[self getSelectedObjects:YES] forLanguages:[NSArray arrayWithObject:language] reinject:YES];
				  }];
}

#pragma mark - File Detail Windows

- (IBAction)showFileDetail:(id)sender {
	NSArray *objects = [self getSelectedObjects:NO];

	for (BLObject *object in objects) {
		NSWindowController *detail;

		// Check for already open window
		detail = [_fileDetailWindows objectForKey:object];

		// Create only if needed
		if (!detail) {
			// File object detail
			if ([object isKindOfClass:[BLFileObject class]]) {
				detail = [[FileDetail alloc] init];
				((FileDetail *)detail).fileObject = (BLFileObject *)object;
			}
			// Bundle object detail
			else if ([object isKindOfClass:[BLBundleObject class]]) {
				detail = [[BundleDetail alloc] init];
				((BundleDetail *)detail).bundleObject = (BLBundleObject *)object;
			}
			// Wrong input
			else {
				continue;
			}

			// Add to window controllers list
			[self addWindowController:detail];
			[_fileDetailWindows setObject:detail forKey:object];
		}

		// Make sure the window is open
		[detail showWindow:self];
	}
}

- (IBAction)showFilePreview:(id)sender {
	NSArray *objects = [self getSelectedObjects:NO];

	for (BLObject *fileObject in objects) {
		FilePreview *detail;

		// File objects only
		if (![fileObject isKindOfClass:[BLFileObject class]])
			continue;

		// Check for already open window
		detail = [_filePreviewWindows objectForKey:fileObject];

		// Create only if needed
		if (!detail) {
			detail = [[FilePreview alloc] init];
			detail.fileObject = (BLFileObject *)fileObject;
			[detail bind:@"languages" toObject:self withKeyPath:@"languages" options:nil];

			[self addWindowController:detail];
			[_filePreviewWindows setObject:detail forKey:fileObject];
		}

		// Make sure the window is open
		[detail showWindow:self];
	}
}

- (IBAction)showFileContent:(id)sender {
	NSArray *objects = [self getSelectedObjects:NO];

	for (BLObject *fileObject in objects) {
		FileContent *detail;

		// File objects only
		if (![fileObject isKindOfClass:[BLFileObject class]])
			continue;

		// Check for already open window
		detail = [_fileContentWindows objectForKey:fileObject];

		// Create only if needed
		if (!detail) {
			detail = [[FileContent alloc] init];
			detail.fileObject = (BLFileObject *)fileObject;

			[self addWindowController:detail];
			[_fileContentWindows setObject:detail forKey:fileObject];
		}

		// Make sure the window is open
		[detail showWindow:self];
	}
}

- (IBAction)revealFile:(id)sender {
	NSString *filePath, *folderPath;
	NSArray *objects;
	NSUInteger i;
	id object;

	objects = [self getSelectedObjects:NO];

	for (i = 0; i < [objects count]; i++) {
		object = [objects objectAtIndex:i];

		if ([object isKindOfClass:[BLFileObject class]]) {
			filePath = [[self pathCreator] absolutePathForFile:object andLanguage:_referenceLanguage];
			folderPath = [[self pathCreator] realPathForFolderOfLanguage:_referenceLanguage inBundle:[object bundleObject]];
		}
		else if ([object isKindOfClass:[BLBundleObject class]]) {
			filePath = [[self pathCreator] fullPathForBundle:object];
			folderPath = [filePath stringByDeletingLastPathComponent];
		}
		else {
			continue;
		}

		[[NSWorkspace sharedWorkspace] selectFile:filePath inFileViewerRootedAtPath:folderPath];
	}
}

- (IBAction)autotranslate:(id)sender {
	if (!_processManager)
		_processManager = [[BLProcessManager alloc] initWithDocument:self];
	//	if (!_processDisplay) {
	//		_processDisplay = [[LIProcessDisplay alloc] initWithProcessManager:_processManager];
	//		_processDisplay.windowForSheet = [self window];
	//	}
	[_processManager startWithName:@"Autotranslating"];
	for (BLStringsFileObject *file in [self getSelectedObjects:YES]) {
		for (NSString *language in self.languages) {
			if ([[self referenceLanguage] isEqualToString:language]) {
				continue;
			}
			[_processManager enqueueStep:[LTAutotranslationStep stepForAutotranslatingObjects:file.objects forLanguage:language andReferenceLanguage:[self referenceLanguage]]];
		}
	}
}

- (void)detailWindowDidClose:(NSWindowController *)windowController {
	// Bundle windows
	if ([windowController isKindOfClass:[BundleDetail class]])
		[_fileDetailWindows removeObjectForKey:[(BundleDetail *)windowController bundleObject]];

	// File windows
	if ([windowController isKindOfClass:[FileDetail class]])
		[_fileDetailWindows removeObjectForKey:[(FileDetail *)windowController fileObject]];
	if ([windowController isKindOfClass:[FilePreview class]])
		[_filePreviewWindows removeObjectForKey:[(FilePreview *)windowController fileObject]];
	if ([windowController isKindOfClass:[FileContent class]])
		[_fileContentWindows removeObjectForKey:[(FileContent *)windowController fileObject]];
}

#pragma mark - Files TableView

- (NSDragOperation)tableView:(NSTableView *)tv validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op {
	return NSDragOperationLink;
}

- (BOOL)tableView:(NSTableView *)tv acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)op {
	[self addFiles:[[info draggingPasteboard] propertyListForType:NSFilenamesPboardType]];
	return YES;
}

- (NSString *)tableView:(NSTableView *)tableView customNameForColumn:(NSTableColumn *)column {
	NSString *table = @"", *key;

	if (tableView == tableLanguages)
		table = @"languages";
	if (tableView == tableBundles)
		table = @"files";

	key = [NSString stringWithFormat:@"%@.%@", table, [column identifier]];

	return NSLocalizedStringFromTable(key, @"TableHeaders", nil);
}

@end
