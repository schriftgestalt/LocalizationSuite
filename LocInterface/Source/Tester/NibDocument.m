//
//  NibDocument.m
//  LocInterface
//
//  Created by max on 06.04.09.
//  Copyright 2009 Blue Technologies Group. All rights reserved.
//

#import "NibDocument.h"

#import "CustomPathCreator.h"

@implementation NibDocument

- (id)init {
	self = [super init];

	if (self != nil) {
		_controller = nil;
		_fileObject = nil;
		_pathCreator = [[CustomPathCreator alloc] initWithDocument:(id)self];
	}

	return self;
}

#pragma mark - Setup

- (void)makeWindowControllers {
	_controller = [[LIPreviewController alloc] init];
	_controller.languages = self.languages;
	_controller.currentLanguage = self.referenceLanguage;
	_controller.fileObject = _fileObject;

	[self addWindowController:_controller];
	[_controller.window makeKeyAndOrderFront:self];
}

#pragma mark - BLDocumentProtocol

- (BLPathCreator *)pathCreator {
	return _pathCreator;
}

- (NSString *)referenceLanguage {
	return @"en";
}

- (NSArray *)languages {
	return [NSArray arrayWithObjects:@"en", nil];
}

#pragma mark - Persistence

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError {
	_fileObject = [[BLFileObject alloc] initWithPath:[absoluteURL path]];

	BLFileInterpreter *interpreter = [BLFileInterpreter interpreterForFileObject:_fileObject];
	[interpreter setOptions:BLFileInterpreterAllowChangesToKeyObjects];
	[interpreter interpreteFile:[absoluteURL path] intoObject:_fileObject withLanguage:@"en" referenceLanguage:nil];

	return (_fileObject != nil);
}

@end
