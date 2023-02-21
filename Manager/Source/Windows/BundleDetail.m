//
//  BundleDetailWindow.m
//  Localization Manager
//
//  Created by Max Seelemann on 04.09.06.
//  Copyright 2006 The Blue Technologies Group. All rights reserved.
//

#import "BundleDetail.h"

#import "Document.h"
#import "NSAlert-Extensions.h"

NSString *BundleDetailWindowNibName = @"BundleDetail";

@interface BundleDetail (BundleDetailWindowInternal)

/*!
 @abstract Just a cast to -document.
 */
@property (readonly) Document *parentDocument;

@end

@implementation BundleDetail

- (id)init {
	self = [super init];

	if (self) {
		_bundle = nil;

		[self setShouldCloseDocument:NO];
		[self setShouldCascadeWindows:YES];
	}

	return self;
}

#pragma mark - Interface

- (NSString *)windowNibName {
	return BundleDetailWindowNibName;
}

- (Document *)parentDocument {
	return (Document *)[self document];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName {
	return [NSString stringWithFormat:NSLocalizedString(@"DetailWindowTitle", nil), displayName, [self.bundleObject name]];
}

#pragma mark - Accessors

@synthesize bundleObject = _bundle;

- (void)setBundleObject:(BLBundleObject *)newBundleObject {
	if (_bundle)
		[_bundle removeObserver:self forKeyPath:@"namingStyle"];

	_bundle = newBundleObject;

	if (_bundle)
		[_bundle addObserver:self forKeyPath:@"namingStyle" options:0 context:nil];
}

- (BLReferencingStyle)referencingStyle {
	return [_bundle referencingStyle];
}

- (void)setReferencingStyle:(BLReferencingStyle)referencingStyle {
	if (referencingStyle == [_bundle referencingStyle])
		return;

	switch (referencingStyle) {
		case BLAbsoluteReferencingStyle:
			[_bundle setPath:[[self.parentDocument pathCreator] fullPathForBundle:_bundle]];
			break;
		case BLRelativeReferencingStyle:
			[_bundle setPath:[[self.parentDocument pathCreator] relativePathForBundle:_bundle]];
			break;
	}
	[_bundle setReferencingStyle:referencingStyle];
}

#pragma mark -

- (NSString *)fullPath {
	return [[self.parentDocument pathCreator] fullPathForBundle:_bundle];
}

- (NSString *)namingStyleComment {
	switch ([_bundle namingStyle]) {
		case BLIdentifiersAndDescriptionsNamingStyle:
			return NSLocalizedString(@"NamingStyleIndentifiersDescriptions", nil);
		case BLIdentifiersNamingStyle:
			return NSLocalizedString(@"NamingStyleIndentifiers", nil);
		case BLDescriptionsNamingStyle:
			return NSLocalizedString(@"NamingStyleDescriptions", nil);
		default:
			return nil;
	}
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	[self willChangeValueForKey:@"namingStyleComment"];
	[self didChangeValueForKey:@"namingStyleComment"];
}

#pragma mark - Actions

- (IBAction)choosePath:(id)sender {
	NSOpenPanel *openPanel;

	openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setDirectoryURL:[NSURL fileURLWithPath:_bundle.path]];

	[openPanel beginSheetModalForWindow:self.window
					  completionHandler:^(NSInteger result) {
		if (result != NSModalResponseOK)
			return;
		[self setBundlePath:[[openPanel URL] path]];
	}];
}

- (IBAction)moveBundle:(id)sender {
	// Issue a warning first
	NSAlert *alert = [NSAlert new];
	[alert setMessageText:NSLocalizedString(@"MoveBundleTitle", nil)];
	[alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
	[alert addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
	[alert setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"MoveBundleText", nil), [_bundle name]]];
	[alert beginSheetModalForWindow:self.window
				  completionHandler:^(NSInteger result) {
		if (result != NSAlertFirstButtonReturn)
			return;

		// Then allow to select a new path
		NSOpenPanel *openPanel = [NSOpenPanel openPanel];

		[openPanel setCanChooseFiles:NO];
		[openPanel setCanChooseDirectories:YES];
		[openPanel setCanCreateDirectories:YES];
		[openPanel setDirectoryURL:[NSURL fileURLWithPath:[[self fullPath] stringByDeletingLastPathComponent]]];

		[openPanel beginSheetModalForWindow:self.window
						  completionHandler:^(NSInteger result) {
			if (result != NSModalResponseOK)
				return;

			// On success, move the bundle
			[self moveBundleToPath:[[openPanel URL] path]];
		}];
	}];
}

- (IBAction)renameFolders:(id)sender {
	NSAlert *alert = [NSAlert new];
	[alert setMessageText:NSLocalizedString(@"RenameFoldersTitle", nil)];
	[alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
	[alert addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
	[alert setInformativeText:[NSString stringWithFormat:NSLocalizedString(@"RenameFoldersText", nil), [_bundle name]]];
	[alert beginSheetModalForWindow:self.window
				  completionHandler:^(NSInteger result) {
		if (result != NSAlertFirstButtonReturn)
			return;

		[self updateLanguageFolderNames];
	}];
}

- (IBAction)showBundle:(id)sender {
	NSString *path;

	path = [[self.parentDocument pathCreator] fullPathForBundle:_bundle];
	[[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:[path stringByDeletingLastPathComponent]];
}

- (IBAction)addXcodeProject:(id)sender {
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowsMultipleSelection:YES];
	[openPanel setAllowedFileTypes:[BLXcodeProjectParser pathExtensions]];
	[openPanel setDirectoryURL:[NSURL fileURLWithPath:[self.parentDocument.pathCreator fullPathForBundle:_bundle]]];

	[openPanel beginSheetModalForWindow:self.window
					  completionHandler:^(NSInteger result) {
		if (result != NSModalResponseOK)
			return;

		BLPathCreator *pathCreator = [self.parentDocument pathCreator];
		NSString *bundlePath = [pathCreator fullPathForBundle:_bundle];

		for (NSURL *url in [openPanel URLs])
			[_bundle addAssociatedXcodeProject:[BLPathCreator relativePathFromPath:bundlePath toPath:[url path]]];

		[self.parentDocument updateChangeCount:NSChangeDone];
	}];
}

#pragma mark - Internal Actions

- (void)setBundlePath:(NSString *)newPath {
	if ([BLPathCreator bundlePartOfFilePath:newPath] && ![BLPathCreator relativePartOfFilePath:newPath])
		newPath = [BLPathCreator bundlePartOfFilePath:newPath];

	// Set new path
	switch ([_bundle referencingStyle]) {
		case BLAbsoluteReferencingStyle:
			[_bundle setPath:newPath];
			break;
		case BLRelativeReferencingStyle:
			[_bundle setPath:[[self.parentDocument pathCreator] documentRelativePathOfFullPath:newPath]];
			break;
	}

	[self willChangeValueForKey:@"fullPath"];
	[self didChangeValueForKey:@"fullPath"];

	[self.parentDocument updateChangeCount:NSChangeDone];
}

- (void)moveBundleToPath:(NSString *)newPath {
	NSString *path, *oldPath;
	BLBundleObject *bundle;

	NSFileManager *fileManager = [NSFileManager defaultManager];
	BLPathCreator *pathCreator = [self.parentDocument pathCreator];
	NSArray *languages = [self.parentDocument languages];

	// Check path
	if ([BLPathCreator bundlePartOfFilePath:newPath] && ![BLPathCreator relativePartOfFilePath:newPath])
		newPath = [BLPathCreator bundlePartOfFilePath:newPath];

	// Check for existing bundle
	if ((bundle = [self.parentDocument bundleObjectWithPath:newPath create:NO]) && ([[pathCreator fullPathForBundle:bundle] isEqualToString:newPath])) {
		path = [pathCreator documentRelativePathOfFullPath:newPath];
		if (![path length])
			path = NSLocalizedString(@"CantMoveBundleLDBFolder", nil);
		else
			path = [NSString stringWithFormat:NSLocalizedString(@"PathBrackets", nil), path];

		NSBeep();
		NSBeginAlertSheet(NSLocalizedString(@"CantMoveBundleTitle", nil), NSLocalizedString(@"OK", nil), nil, nil, self.window, self, nil, nil, nil, NSLocalizedString(@"CantMoveBundleText", nil), [_bundle name], path);
		return;
	}

	// Move all .lproj folders
	for (NSString *language in languages) {
		oldPath = [pathCreator realPathForFolderOfLanguage:language inBundle:_bundle];
		path = [newPath stringByAppendingPathComponent:[oldPath lastPathComponent]];

		if ([fileManager fileExistsAtPath:path])
			[fileManager removeItemAtPath:path error:NULL];
		[fileManager moveItemAtPath:oldPath toPath:path error:NULL];
	}

	// Set new path
	switch ([_bundle referencingStyle]) {
		case BLAbsoluteReferencingStyle:
			[_bundle setPath:newPath];
			break;
		case BLRelativeReferencingStyle:
			[_bundle setPath:[pathCreator documentRelativePathOfFullPath:newPath]];
			break;
	}

	[self willChangeValueForKey:@"fullPath"];
	[self didChangeValueForKey:@"fullPath"];

	[self.parentDocument updateChangeCount:NSChangeDone];
}

- (void)updateLanguageFolderNames {
	for (NSString *language in [self.parentDocument languages])
		[[NSFileManager defaultManager] moveItemAtPath:[[self.parentDocument pathCreator] realPathForFolderOfLanguage:language inBundle:_bundle]
												toPath:[[self.parentDocument pathCreator] pathForFolderOfLanguage:language inBundle:_bundle]
												 error:NULL];
}

@end
