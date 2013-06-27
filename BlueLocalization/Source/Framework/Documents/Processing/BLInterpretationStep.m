//
//  BLInterpretationStep.m
//  BlueLocalization
//
//  Created by Max Seelemann on 27.04.09.
//  Copyright 2009 The Blue Technologies Group. All rights reserved.
//

#import "BLInterpretationStep.h"

#import "BLNibFileObject.h"


NSString *BLInterpretationStepIgnoredPlaceholderStringsKey	= @"ignoredPlaceholderStrings";


@interface BLInterpretationStep ()
{
	BLFileObject	*_fileObject;
	NSString		*_language;
	NSDictionary	*_parameters;
	NSUInteger		_options;
	NSString		*_path;
}
@end

@implementation BLInterpretationStep

- (id)initForInterpretingFile:(NSString *)path toObject:(BLFileObject *)object withLanguage:(NSString *)language andOptions:(NSUInteger)options parameters:(NSDictionary *)parameters
{
	self = [super init];
	
	if (self) {
		_path = path;
		_fileObject = object;
		_language = language;
		_options = options;
		_parameters = parameters;
	}
	
	return self;
}



#pragma mark - Processing

- (void)updateDescription
{
	self.action = NSLocalizedStringFromTableInBundle(@"Interpreting", @"BLProcessStep", [NSBundle bundleForClass: [self class]], nil);
	self.description = [NSString stringWithFormat: NSLocalizedStringFromTableInBundle(@"InterpretingText", @"BLProcessStep", [NSBundle bundleForClass: [self class]], nil), [_fileObject name], [[_fileObject bundleObject] name], [BLLanguageTranslator descriptionForLanguage: _language]];
}

- (void)perform
{
	NSDocument <BLDocumentProtocol> *document;
	BLFileInterpreter *interpreter;
	BOOL success;
	
	document = [[self manager] document];
	
	// Create a file object if it does not yet exist
	if (!_fileObject) {
		// Check the document
		if (![document respondsToSelector: @selector(fileObjectWithPath:)])
			[[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Document does not support addition of file objects!" userInfo:nil] raise];
		if (![document respondsToSelector: @selector(existingFileObjectWithPath:)])
			[[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Document does not support access to existing file objects!" userInfo:nil] raise];
		
		@synchronized(document) {
			if ([_language isEqual: [document referenceLanguage]])
				_fileObject = [document fileObjectWithPath: _path];
			else
				_fileObject = [document existingFileObjectWithPath: _path];
		}
		
		if (!_fileObject)
			return;
		
		_fileObject = [BLObjectProxy proxyWithObject: _fileObject];
		[self updateDescription];
	}
	
	BLLogBeginGroup(@"Interpreting file \"%@\" for language \"%@\"", [_fileObject name], _language);
	
	// Set Up
	interpreter = [BLFileInterpreter interpreterForFileObject: _fileObject];
	[interpreter activateOptions: _options];
	interpreter.ignoredPlaceholderStrings = [_parameters objectForKey: BLInterpretationStepIgnoredPlaceholderStringsKey];
	
	// Interprete
	success = [interpreter interpreteFile:_path intoObject:_fileObject withLanguage:_language referenceLanguage:[document referenceLanguage]];
	
	// Update the object status
	if (success)
		[_fileObject setWasUpdated: YES];
	
	// Notify changes
	if (success && [document respondsToSelector: @selector(fileObjectChanged:)])
		[document fileObjectChanged: _fileObject];
	if (success && [document respondsToSelector: @selector(languageChanged:)])
		[document languageChanged: _language];
	
	BLLogEndGroup();
}

@end
