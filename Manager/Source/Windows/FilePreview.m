//
//  FilePreviewWindow.m
//  Localization Manager
//
//  Created by max on 10.09.09.
//  Copyright 2009 Localization Foundation. All rights reserved.
//

#import "FilePreview.h"


@implementation FilePreview

- (id)init
{
	self = [super init];
	
	if (self) {
		[self setShouldCloseDocument: NO];
		[self setShouldCascadeWindows: YES];
	}
	
	return self;
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
	return [NSString stringWithFormat: NSLocalizedString(@"PreviewWindowTitle", nil), displayName, [self.fileObject name]];
}

- (void)setDocument:(NSDocument *)document
{
	[super setDocument: document];
	
	[self.window setRepresentedURL: [document fileURL]];
}

- (void)windowDidLoad
{
	[super windowDidLoad];
	[self.window setRepresentedURL: [self.document fileURL]];
}

@end
