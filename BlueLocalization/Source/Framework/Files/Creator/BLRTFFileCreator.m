/*!
 @header
 BLRTFFileCreator.m
 Created by Max on 29.11.04.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLRTFFileCreator.h>
#import <BlueLocalization/BLRTFFileInterpreter.h>

#import <BlueLocalization/BLFileObject.h>
#import <BlueLocalization/BLFileManagerAdditions.h>
#import <BlueLocalization/BLKeyObject.h>

@implementation BLRTFFileCreator

+ (void)load
{
	[super registerCreatorClass:self forFileType:@"rtf"];
	[super registerCreatorClass:self forFileType:@"rtfd"];
}

#pragma mark -

- (BOOL)_writeFileToPath:(NSString *)path fromObject:(BLFileObject *)object withLanguage:(NSString *)language referenceLanguage:(NSString *)defaultLanguage
{
    NSAttributedString *string;
    BLKeyObject *keyObject;
    
    BLLog(BLLogInfo, @"Creating .rtf file \"%@\"", path);
    
    keyObject = [object objectForKey: BLRTFFileContentKeyName];
    
    if (![keyObject isEmptyForLanguage: language])
        string = [keyObject objectForLanguage: language];
    else if (![keyObject isEmptyForLanguage: defaultLanguage])
        string = [keyObject objectForLanguage: defaultLanguage];
	else
		return NO;
    
    [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:NULL];
    
	if ([[path pathExtension] isEqual: @"rtfd"])
		return [[string RTFDFileWrapperFromRange:NSMakeRange(0, [string length]) documentAttributes:nil] writeToFile:path atomically:YES updateFilenames:NO];
	else
		return [[string RTFFromRange:NSMakeRange(0, [string length]) documentAttributes:nil] writeToFile:path atomically:YES];
}

@end
