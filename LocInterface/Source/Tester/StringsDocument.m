//
//  StringsDocument.m
//  LocInterface
//
//  Created by max on 27.08.09.
//  Copyright 2009 Localization Suite. All rights reserved.
//

#import "StringsDocument.h"

@implementation StringsDocument

- (id)init {
	self = [super init];

	if (self) {
		_file = nil;
	}

	return self;
}

- (void)dealloc {
	[_file release];

	[super dealloc];
}

#pragma mark - Accessors

- (NSString *)windowNibName {
	return @"StringsDocument";
}

- (NSArray *)content {
	return [_file objects];
}

#pragma mark - Actions

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController {
	[super windowControllerDidLoadNib:windowController];

	// Update bindings
	contentController.leftLanguage = @"en";
	contentController.rightLanguage = @"de";
	contentController.rightLanguageEditable = YES;
	[contentController bind:@"objects" toObject:self withKeyPath:@"content" options:nil];
}

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError {
	BLFileInterpreter *interpreter;
	NSString *path;

	[self willChangeValueForKey:@"content"];

	path = [absoluteURL path];
	_file = [[BLFileObject fileObjectWithPath:path] retain];

	interpreter = [BLFileInterpreter interpreterForFileObject:_file];
	[interpreter activateOptions:BLFileInterpreterAllowChangesToKeyObjects];
	[interpreter interpreteFile:path intoObject:_file withLanguage:@"en" referenceLanguage:@"en"];

	interpreter = [BLFileInterpreter interpreterForFileObject:_file];
	[interpreter interpreteFile:path intoObject:_file withLanguage:@"de" referenceLanguage:nil];

	// Add some attachments
	if ([_file.objects count] >= 2) {
		NSString *path = [[NSBundle mainBundle] pathForResource:@"image" ofType:@"png"];
		NSFileWrapper *wrapper = [[[NSFileWrapper alloc] initWithPath:path] autorelease];

		[[_file.objects objectAtIndex:1] setAttachedMedia:wrapper];

		if ([_file.objects count] >= 4)
			[[_file.objects objectAtIndex:3] setAttachedMedia:wrapper];
	}

	[self didChangeValueForKey:@"content"];

	return YES;
}

@end
