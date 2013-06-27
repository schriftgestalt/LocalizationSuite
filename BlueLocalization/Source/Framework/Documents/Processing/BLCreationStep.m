//
//  BLCreationStep.m
//  BlueLocalization
//
//  Created by Max Seelemann on 29.04.09.
//  Copyright 2009 The Blue Technologies Group. All rights reserved.
//

#import "BLCreationStep.h"


@implementation BLCreationStep

- (id)initForCreatingFile:(NSString *)path fromObject:(BLFileObject *)object withLanguage:(NSString *)language reinject:(BOOL)reinject
{
	self = [super init];
	
	if (self) {
		_path = path;
		_fileObject = object;
		_language = language;
		_reinject = reinject;
	}
	
	return self;
}



#pragma mark - Processing

- (void)perform
{
	NSDocument <BLDocumentProtocol> *document;
	BLFileCreator *creator;
	BOOL success;
	
	document = [[self manager] document];
	
	BLLogBeginGroup(@"%@ file \"%@\" for language \"%@\"", (_reinject) ? @"Reinjecting" : @"Creating", [_fileObject name], _language);
	
	// Create and init creator
	creator = [BLFileCreator creatorForFileObject: _fileObject];
	if (_reinject)
		[creator activateOptions: BLFileCreatorReinject];

	// Create the file
	success = [creator writeFileToPath:_path fromObject:_fileObject withLanguage:_language referenceLanguage:[document referenceLanguage]];
	if (!success)
		BLLog(BLLogWarning, @"Failed creating file for object %@ in language %@ (full path: %@)", [_fileObject name], _language, _path);
	
	// Update the object status
	if (success) {
		[_fileObject setValue:_language didChange:NO];
		
		if ([[_fileObject changedValues] count] == 0)
			[_fileObject setWasUpdated: NO];
	}
	
	// Notify changes
	if (success && [document respondsToSelector: @selector(fileObjectChanged:)])
		[document fileObjectChanged: _fileObject];
	if (success && [document respondsToSelector: @selector(languageChanged:)])
		[document languageChanged: _language];
	
	BLLogEndGroup();
}

- (NSString *)action
{
	return NSLocalizedStringFromTableInBundle(@"Creating", @"BLProcessStep", [NSBundle bundleForClass: [self class]], nil);
}

- (NSString *)description
{
	return [NSString stringWithFormat: NSLocalizedStringFromTableInBundle(@"CreatingText", @"BLProcessStep", [NSBundle bundleForClass: [self class]], nil), [_fileObject name], [[_fileObject bundleObject] name], [BLLanguageTranslator descriptionForLanguage: _language]];
}

@end
