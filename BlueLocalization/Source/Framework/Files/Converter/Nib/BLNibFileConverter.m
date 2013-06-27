/*!
 @header
 BLNibFileConverter.m
 Created by Max Seelemann on 29.10.08.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLNibFileConverter.h"

#import "BLNibFileObject.h"
#import "BLToolPath.h"


@implementation BLNibFileConverter

+ (BOOL)upgradeFileForObject:(BLNibFileObject *)object fromDocument:(NSDocument <BLDocumentProtocol> *)document withLanguages:(NSArray *)languages
{
	BOOL result;
	
	result = YES;
	
	for (NSUInteger i=0; i<[languages count]; i++)
		result = result && [self upgradeFileForObject:object fromDocument:document withLanguage:[languages objectAtIndex: i]];
	
	return result;
}

+ (BOOL)upgradeFileForObject:(BLNibFileObject *)object fromDocument:(NSDocument <BLDocumentProtocol> *)document withLanguage:(NSString *)language
{
	// Only convert nib files
	if ([[[object path] pathExtension] isEqual: @"xib"])
		return YES;
	
	
	// Check the file
    NSString *oldPath = [[document pathCreator] absolutePathForFile:object andLanguage:language];
    NSString *newPath = [[oldPath stringByDeletingPathExtension] stringByAppendingPathExtension: @"xib"];
	
	BLLogBeginGroup(@"Upgrading nib file at path %@", oldPath);
	
	if (![[NSFileManager defaultManager] fileExistsAtPath: oldPath]) {
		BLLog(BLLogError, @"File not found");
		BLLogEndGroup();
		return NO;
	}
	
	
	// Create arguments
	NSMutableArray *arguments = [NSMutableArray array];
	[arguments addObjectsFromArray: [BLToolPath defaultArgumentsForTool: BLToolIBTool]];
	[arguments addObjectsFromArray: [NSArray arrayWithObjects: @"--upgrade", @"--write", newPath, oldPath, nil]];
	
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
	
	// Run it
	[ibtool launch];
	[ibtool waitUntilExit];
	
	// Check result
	BOOL success = [[NSFileManager defaultManager] fileExistsAtPath: newPath];
	if (!success)
		BLLog(BLLogError, @"Upgrade failed");
	BLLogEndGroup();
	
	return success;
}

@end
