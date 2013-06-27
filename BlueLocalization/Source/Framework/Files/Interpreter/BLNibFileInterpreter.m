/*!
 @header
 BLNibFileInterpreter.m
 Created by Max on 13.12.04.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLNibFileInterpreter.h"
#import "BLNibFileCreator.h"

#import "BLToolPath.h"


NSString *kNibHashSubpath		= @"keyedobjects.nib";
NSString *kOldNibHashSubpath	= @"objects.nib";


@implementation BLNibFileInterpreter

+ (void)load
{
	[super registerInterpreterClass:self forFileType:@"nib"];
	[super registerInterpreterClass:self forFileType:@"xib"];
}

+ (NSUInteger)defaultOptions
{
	return BLFileInterpreterImportComments | BLFileInterpreterReferenceImportCreatesBackup | BLFileInterpreterImportNonReferenceValuesOnly;
}

#pragma mark -

- (NSString *)actualPathForHashValueGeneration:(NSString *)path
{
	NSString *hashPath;
	
	if ([[path pathExtension] isEqual: @"xib"])
		return path;
	
	hashPath = [path stringByAppendingPathComponent: kNibHashSubpath];
	if (![[NSFileManager defaultManager] fileExistsAtPath: hashPath])
		hashPath = [path stringByAppendingPathComponent: kOldNibHashSubpath];
	
	return hashPath;
}

#pragma mark -

- (BOOL)_interpreteFile:(NSString *)path
{
    // We'll export the strings to a temporary file
    NSString *stringsPath = [[path.stringByDeletingPathExtension stringByAppendingPathExtension: [NSString stringWithFormat: @"%lX", random()]] stringByAppendingPathExtension: @"strings"];
    [[NSFileManager defaultManager] createFileAtPath:stringsPath contents:nil attributes:nil];
    
    // Setup arguments
	NSMutableArray *arguments = [NSMutableArray array];
	[arguments addObjectsFromArray: [BLToolPath defaultArgumentsForTool: BLToolIBTool]];
	[arguments addObjectsFromArray: [NSArray arrayWithObjects: @"--generate-stringsfile", stringsPath, path, nil]];
	
    // Log some info
	BLLogBeginGroup(@"Starting ibtool from path \"%@\"", [BLToolPath pathForTool: BLToolIBTool]);
	BLLog(BLLogInfo, @"Arguments: %@", arguments);
	BLLogEndGroup();
	
	NSPipe *pipe = BLLogOpenPipe(@"Running ibtool…");
	
    // Setup ibtool
    NSTask *ibtool = [[NSTask alloc] init];
	[ibtool setLaunchPath: [BLToolPath pathForTool: BLToolIBTool]];
	[ibtool setArguments: arguments];
	[ibtool setStandardOutput: pipe];
    [ibtool setStandardError: pipe];
    
    // Run...
	[ibtool launch];
	[ibtool waitUntilExit];
    
    // Use the strings file interpreter to get the contents
	BLFileInterpreter *stringsInterpreter = [BLFileInterpreter interpreterForFileType: @"strings"];
	[stringsInterpreter _setForwardsToInterpreter: self];
	
	BOOL success = [stringsInterpreter _interpreteFile: stringsPath];
    
    // Remove the temporary file
    [[NSFileManager defaultManager] removeItemAtPath:stringsPath error:NULL];
    
    return success;
}

@end
