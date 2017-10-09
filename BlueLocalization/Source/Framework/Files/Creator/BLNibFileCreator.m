/*!
 @header
 BLNibFileCreator.m
 Created by Max on 13.12.04.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLNibFileCreator.h>

#import "BLFileObject.h"
#import "BLFileManagerAdditions.h"
#import "BLKeyObject.h"
#import "BLNibFileObject.h"
#import "BLPathCreator.h"
#import "BLStringsFileCreator.h"
#import "BLToolPath.h"


NSString *BLNibFileCreatorPreferencesFolderName			= @"Preferences";
NSString *BLNibFileCreatorIBIdentifier					= @"com.apple.InterfaceBuilder3.plist";
NSString *BLNibFileCreatorIBKnownPluginPathsKey			= @"IBKnownPluginPaths";
NSString *BLNibFileCreatorIBLoadedPluginIdentifiersKey	= @"IBLoadedPluginIdentifiers";


@implementation BLNibFileCreator

+ (void)load
{
	[super registerCreatorClass:self forFileType:@"nib"];
	[super registerCreatorClass:self forFileType:@"xib"];
}

+ (NSUInteger)defaultOptions
{
	return BLFileCreatorInactiveKeysAsReference;
}


#pragma mark - Actions

- (BOOL)_prepareReinjectAtPath:(NSString *)path
{
	/* Do nothing, we handle it separately */
	return YES;
}

- (BOOL)_writeFileToPath:(NSString *)targetPath fromObject:(BLFileObject *)object withLanguage:(NSString *)language referenceLanguage:(NSString *)referenceLanguage
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
	
    
	BLLogBeginGroup(@"Creating nib file \"%@\"", targetPath);
    
	
    // Export the Strings to a temporary File
    NSString *stringsPath = [targetPath stringByAppendingPathExtension: @"strings"];
	
	BLStringsFileCreator *stringsCreator = [BLFileCreator creatorForFileType: @"strings"];
	[stringsCreator setOptions: [self options] | BLFileCreatorSlaveMode];
    [stringsCreator _writeFileToPath:stringsPath fromObject:object withLanguage:language referenceLanguage:referenceLanguage usingEncoding:NSUnicodeStringEncoding];
	
	
	// REFERENCE FILE
    // Version and path of the original file
	NSString *referencePath = [[targetPath stringByDeletingPathExtension] stringByAppendingFormat: @".r.%@", [targetPath pathExtension]];
	
	NSFileWrapper *reference = [object attachedObjectForKey:BLBackupAttachmentKey];
	[reference writeToFile:referencePath atomically:YES updateFilenames:NO];
	
	if (![fileManager fileExistsAtPath: referencePath]) {
		// Copy original if no reference version available
		NSString *originalPath = [BLPathCreator replaceLanguage:language inPath:targetPath withLanguage:@"en" bundle:[object bundleObject]];
		[fileManager copyItemAtPath:originalPath toPath:referencePath error:NULL];
	}
	
	// PREVIOUS
    // Version and path of the previous original file
	NSString *previousPath = [[targetPath stringByDeletingPathExtension] stringByAppendingFormat: @".p.%@", [targetPath pathExtension]];
    
    // Temporary path for the result file
    NSString *tempPath = [[targetPath stringByDeletingPathExtension] stringByAppendingFormat: @".new.%@", [targetPath pathExtension]];
	
	
    // Arguments for ibtool
	NSMutableArray *arguments = [NSMutableArray array];
	[arguments addObjectsFromArray: [BLToolPath defaultArgumentsForTool: BLToolIBTool]];
	
	// Incremental localization
	if (![self optionIsActive: BLFileCreatorReinject] && ![language isEqual: referenceLanguage] && [fileManager fileExistsAtPath: targetPath]) {
		// Write previous file
		NSFileWrapper *previous = [object attachedObjectForKey:BLBackupAttachmentKey];
		[previous writeToFile:previousPath atomically:YES updateFilenames:NO];
		
		if (![fileManager fileExistsAtPath: previousPath])
			[fileManager copyItemAtPath:referencePath toPath:previousPath error:NULL];
		
		[arguments addObjectsFromArray: [NSArray arrayWithObjects:
										 @"--localize-incremental",
										 @"--previous-file", previousPath,
										 @"--incremental-file", targetPath,
										 nil]];
	}
	
	[arguments addObjectsFromArray: [NSArray arrayWithObjects:
									 @"--import-strings-file", stringsPath,
									 @"--write", tempPath,
									 referencePath, nil]];
	
	// Log some info
	BLLogBeginGroup(@"Starting ibtool from path \"%@\"", [BLToolPath pathForTool: BLToolIBTool]);
	BLLog(BLLogInfo, @"Arguments: %@", arguments);
	BLLogEndGroup();
	
	NSPipe *pipe = BLLogOpenPipe(@"Running ibtool…");
	
	// Set up ibtool
    NSTask *ibtool = [[NSTask alloc] init];
	[ibtool setLaunchPath: [BLToolPath pathForTool: BLToolIBTool]];
	[ibtool setArguments: arguments];
    [ibtool setStandardError: pipe];
    [ibtool setStandardOutput: pipe];
    
    // run...
	[ibtool launch];
	[ibtool waitUntilExit];
	
	if (![fileManager fileExistsAtPath: tempPath]) {
		BLLog(BLLogError, @"Nib file was not created!");
		BLLogEndGroup();
		return NO;
	}
    
    // move contents from new one to old
    if ([[targetPath pathExtension] isEqual: @"nib"]) {
		[fileManager createDirectoryAtPath:targetPath withIntermediateDirectories:YES attributes:nil error:NULL];
		
		for (NSString *file in [fileManager contentsOfDirectoryAtPath:tempPath error:NULL]) {
			if (![[file pathExtension] isEqual: @"nib"])
				continue;
			
			[fileManager removeItemAtPath:[targetPath stringByAppendingPathComponent: file] error:NULL];
			[fileManager moveItemAtPath:[tempPath stringByAppendingPathComponent: file] toPath:[targetPath stringByAppendingPathComponent: file] error:NULL];
		}
		
		// Remove the empty resulting nib
		[fileManager removeItemAtPath:tempPath error:NULL];
	}
	else {
		[fileManager removeItemAtPath:targetPath error:NULL];
		[fileManager moveItemAtPath:tempPath toPath:targetPath error:NULL];
	}
    
    // remove the temporary files
    [fileManager removeItemAtPath:stringsPath error:NULL];
	[fileManager removeItemAtPath:previousPath error:NULL];
	[fileManager removeItemAtPath:referencePath error:NULL];
	
	// update version number
	//[object setVersion:referenceVersion forLanguage:language];
    
	BLLogEndGroup();
    return YES;
}

@end


