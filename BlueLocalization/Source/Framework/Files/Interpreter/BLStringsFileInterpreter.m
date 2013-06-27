/*!
 @header
 BLStringsFileInterpreter.m
 Created by Max on 13.11.04.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLStringsFileInterpreter.h"

#import "BLStringsFileObject.h"

/*!
 @abstract An implementation of a file interpreter to scan strings files.
 */
@implementation BLStringsFileInterpreter

+ (void)load
{
	[super registerInterpreterClass:self forFileType:@"strings"];
}

+ (NSUInteger)defaultOptions
{
	return BLFileInterpreterImportComments | BLFileInterpreterEnableShadowComments | BLFileInterpreterReferenceImportCreatesBackup | BLFileInterpreterImportNonReferenceValuesOnly;
}

#pragma mark -

/*!
 @discussion If the file turns out to be a plist file, it is passed on to a plist file interpreter to do the heavy lifting.
 */
- (BOOL)_interpreteFile:(NSString *)path
{
    NSDictionary *contents, *comments;
    BOOL isPlistFile;
    NSArray *keys;
    
    // Check for plist string files
    isPlistFile = [[NSString stringWithContentsOfFile:path usedEncoding:NULL error:NULL] hasPrefix: @"<?xml"];
    if ([_fileObject isKindOfClass: [BLStringsFileObject class]])
        [(BLStringsFileObject *)_fileObject setIsPlistStringsFile: isPlistFile];
	
	// Plist strings-files will be imported by a plist interpreter
    if (isPlistFile) {
		BLFileInterpreter *interpreter;
		
		interpreter = [BLFileInterpreter interpreterForFileType: @"plist"];
		[interpreter _setForwardsToInterpreter: self];
		
		return [interpreter _interpreteFile: path];
	}
    
	// Import the strings file
	contents = [NSDictionary dictionaryWithStringsAtPath:path scannedComments:&comments scannedKeyOrder:&keys];
	
	// The file can't be imported, there was an error
	if (!contents)
		return NO;
	
	// Process all keys
	for (NSUInteger i=0; i<[keys count]; i++) {
		NSString *key = [keys objectAtIndex: i];
		[self _emitKey:key value:[contents objectForKey: key] comment:[comments objectForKey: key]];
	}
	
	return YES;
}

@end
