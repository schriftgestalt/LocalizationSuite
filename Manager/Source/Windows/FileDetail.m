//
//  FileDetail.m
//  Localization Manager
//
//  Created by Max Seelemann on 04.09.06.
//  Copyright 2006 The Blue Technologies Group. All rights reserved.
//

#import "FileDetail.h"

#import "Document.h"
#import "LanguageNameButtonCell.h"

#import "NSAlert-Extensions.h"

NSString *FileDetailWindowNibName = @"FileDetail";

NSString *FileDetailPathHistoryBundle = @"bundle";
NSString *FileDetailPathHistoryPath = @"path";
NSString *FileDetailPathHistoryFullPath = @"fullPath";

@interface FileDetail () {
	BLFileObject *_fileObject;
	CGFloat _matrixTop;
}

/*!
 @abstract Just a cast to -document.
 */
@property (strong, readonly) Document *parentDocument;

@end

@implementation FileDetail

- (id)init {
	self = [super init];

	if (self) {
		_fileObject = nil;

		[self setShouldCloseDocument:NO];
		[self setShouldCascadeWindows:YES];
	}

	return self;
}

- (void)close {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Interface

- (NSString *)windowNibName {
	return FileDetailWindowNibName;
}

- (Document *)parentDocument {
	return (Document *)[self document];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName {
	return [NSString stringWithFormat:NSLocalizedString(@"DetailWindowTitle", nil), displayName, [self.fileObject name]];
}

- (void)windowDidLoad {
	NSArray *extensions;
	NSMenuItem *item;
	NSMenu *menu;
	NSRect frame;

	// Matrix frame adjustments setup
	frame = [changeMatrix frame];
	frame.origin.y = NSMinY(frame) + 16 - frame.size.height;
	[changeMatrix setFrameOrigin:frame.origin];

	_matrixTop = [[self.window contentView] frame].size.height - NSMaxY(frame);
	[self.window setMinSize:NSMakeSize([self.window minSize].width, _matrixTop + frame.size.height + 40)];

	frame = [self.window frame];
	frame.size.height = fmaxf([self.window minSize].height, frame.size.height);
	[self.window setFrame:frame display:YES];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(matrixUpdated) name:NSViewFrameDidChangeNotification object:changeMatrix];

	// Create the type menu
	menu = [[NSMenu alloc] init];

	item = [menu addItemWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Default type (%@)", nil), [[_fileObject path] pathExtension]] action:nil keyEquivalent:@""];
	[item setRepresentedObject:@""];
	[menu addItem:[NSMenuItem separatorItem]];

	extensions = [BLFileObject availablePathExtensions];
	extensions = [extensions sortedArrayUsingSelector:@selector(compare:)];

	for (NSUInteger i = 0; i < [extensions count]; i++) {
		item = [menu addItemWithTitle:[extensions objectAtIndex:i] action:nil keyEquivalent:@""];
		[item setRepresentedObject:[extensions objectAtIndex:i]];
	}

	[typePopUp setMenu:menu];
	if ([_fileObject customFileType] == nil)
		[typePopUp selectItemAtIndex:[menu indexOfItemWithRepresentedObject:[NSNull null]]];
	else
		[typePopUp selectItemAtIndex:[menu indexOfItemWithRepresentedObject:[_fileObject customFileType]]];
}

- (void)matrixUpdated {
	NSRect frame;
	NSSize size;
	float delta;

	frame = [changeMatrix frame];
	frame.origin.y = [[self.window contentView] frame].size.height - _matrixTop - frame.size.height;

	if (frame.origin.y != [changeMatrix frame].origin.y) {
		[changeMatrix setFrameOrigin:frame.origin];

		size = [self.window minSize];
		delta = _matrixTop + frame.size.height + 40 - size.height;
		size.height += delta;
		[self.window setMinSize:size];

		frame = [self.window frame];
		if (delta) {
			frame.size.height += delta;
			frame.origin.y -= delta;
			[self.window setFrame:frame display:YES];
		}
	}
}

#pragma mark - Accessors

@synthesize fileObject = _fileObject;

- (NSString *)fullPath {
	return [[self.parentDocument pathCreator] absolutePathForFile:_fileObject andLanguage:[self.parentDocument referenceLanguage]];
}

- (NSString *)currentErrors {
	return [[_fileObject errors] componentsJoinedByString:@", "];
}

- (NSString *)customFileType {
	return [_fileObject customFileType];
}

- (void)setCustomFileType:(NSString *)type {
	[_fileObject setCustomFileType:type];
	[_fileObject setChangeDate:[NSDate distantPast]];
	[self.parentDocument rescanObjects:[NSArray arrayWithObject:_fileObject] force:YES];

	[self.parentDocument updateChangeCount:NSChangeDone];
}

#pragma mark - Interface Actions

- (IBAction)choosePath:(id)sender {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];

	[openPanel setCanChooseFiles:YES];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setAllowedFileTypes:[NSArray arrayWithObject:[[_fileObject path] pathExtension]]];
	[openPanel setDirectoryURL:[NSURL fileURLWithPath:[[self fullPath] stringByDeletingLastPathComponent]]];

	[openPanel beginSheetModalForWindow:self.window
					  completionHandler:^(NSInteger result) {
		if (result != NSModalResponseOK)
			return;

		[self setFilePath:[[openPanel URL] path]];
	}];
}

- (IBAction)moveFile:(id)sender {
	// Issue a warning
	NSAlert *sheet = [NSAlert new];
	[sheet setMessageText:NSLocalizedString(@"MoveFileTitle", nil)];
	[sheet addButtonWithTitle:NSLocalizedString(@"OK", nil)];
	[sheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
	[sheet setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"MoveFileText", nil), [_fileObject name]]];

	[sheet beginSheetModalForWindow:self.window
				  completionHandler:^(NSInteger result) {
		if (result != NSAlertFirstButtonReturn)
			return;

		// Ask for the new name
		NSSavePanel *savePanel = [NSSavePanel savePanel];

		[savePanel setCanCreateDirectories:YES];
		[savePanel setAllowedFileTypes:[NSArray arrayWithObject:[[self fullPath] pathExtension]]];
		[savePanel setDirectoryURL:[NSURL fileURLWithPath:[[self fullPath] stringByDeletingLastPathComponent]]];

		[savePanel beginSheetModalForWindow:self.window
						  completionHandler:^(NSInteger result) {
			if (result != NSModalResponseOK)
				return;

			// Perform the move
			[self moveFileToPath:[[savePanel URL] path]];
		}];
	}];
}

- (IBAction)showFile:(id)sender {
	NSString *path;

	path = [[self.parentDocument pathCreator] absolutePathForFile:_fileObject andLanguage:[self.parentDocument referenceLanguage]];
	[[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:[path stringByDeletingLastPathComponent]];
}

#pragma mark - Internal Actions

- (void)setFilePath:(NSString *)newPath {
	BLPathCreator *pathCreator = [self.parentDocument pathCreator];

	// Generate history path
	NSString *path = [pathCreator absolutePathForFile:_fileObject andLanguage:[self.parentDocument referenceLanguage]];
	path = [pathCreator documentRelativePathOfFullPath:path];

	// Change file
	[_fileObject setPath:[BLPathCreator relativePartOfFilePath:newPath]];

	// Check the bundle
	BLBundleObject *bundle = [self.parentDocument bundleObjectWithPath:[BLPathCreator bundlePartOfFilePath:newPath] create:YES];
	if (bundle != [_fileObject bundleObject]) {

		[[_fileObject bundleObject] removeFile:_fileObject];
		[bundle addFile:_fileObject];
	}

	[self willChangeValueForKey:@"fullPath"];
	[self didChangeValueForKey:@"fullPath"];

	[self.parentDocument updateChangeCount:NSChangeDone];
}

- (void)moveFileToPath:(NSString *)newPath {
	NSString *path, *oldPath, *bundlePath;
	NSFileManager *fileManager;
	BLPathCreator *pathCreator;
	BLBundleObject *bundle;
	NSArray *languages;
	NSUInteger i;

	fileManager = [NSFileManager defaultManager];
	pathCreator = [self.parentDocument pathCreator];
	languages = [self.parentDocument languages];

	// Check the bundle
	if (!(bundlePath = [BLPathCreator bundlePartOfFilePath:newPath]))
		bundlePath = [newPath stringByDeletingLastPathComponent];
	bundle = [self.parentDocument bundleObjectWithPath:bundlePath create:YES];

	// Move all files
	for (i = 0; i < [languages count]; i++) {
		// Get the .lproj folder
		path = [pathCreator realPathForFolderOfLanguage:[languages objectAtIndex:i] inBundle:bundle];
		if (!path)
			path = [pathCreator pathForFolderOfLanguage:[languages objectAtIndex:i] inBundle:bundle];
		// Create if neccessary
		if (![fileManager fileExistsAtPath:path])
			[fileManager createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:NULL];

		path = [path stringByAppendingPathComponent:[BLPathCreator relativePartOfFilePath:newPath]];

		if ([fileManager fileExistsAtPath:path])
			[fileManager removeItemAtPath:path error:NULL];
		[fileManager moveItemAtPath:[pathCreator absolutePathForFile:_fileObject andLanguage:[languages objectAtIndex:i]] toPath:path error:NULL];
	}

	// Generate history and new path
	oldPath = [pathCreator absolutePathForFile:_fileObject andLanguage:[self.parentDocument referenceLanguage]];
	oldPath = [pathCreator documentRelativePathOfFullPath:oldPath];

	path = [pathCreator realPathForFolderOfLanguage:[self.parentDocument referenceLanguage] inBundle:bundle];
	path = [path stringByAppendingPathComponent:[BLPathCreator relativePartOfFilePath:newPath]];
	path = [BLPathCreator relativePartOfFilePath:path];

	// Change file
	if (bundle != [_fileObject bundleObject]) {

		[[_fileObject bundleObject] removeFile:_fileObject];
		[bundle addFile:_fileObject];
	}

	[self willChangeValueForKey:@"fullPath"];
	[_fileObject setPath:path];

	path = [pathCreator absolutePathForFile:_fileObject andLanguage:[self.parentDocument referenceLanguage]];
	path = [pathCreator documentRelativePathOfFullPath:path];

	[self didChangeValueForKey:@"fullPath"];

	[self.parentDocument updateChangeCount:NSChangeDone];
}

@end
