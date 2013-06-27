/*!
 @header
 NPDescriptionLoader.m
 Created by max on 02.03.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "NPDescriptionLoader.h"

#import "NPBundleLoader.h"


NSString *IBToolWarningsKey	= @"com.apple.ibtool.warnings";
NSString *IBToolErrorsKey	= @"com.apple.ibtool.errors";


@implementation NPDescriptionLoader

id __sharedDescriptionLoader = nil;

- (id)init
{
	self = [super init];
	
	if (self != nil) {
		__sharedDescriptionLoader = self;
	}
	
	return self;
}

- (void)dealloc
{
	__sharedDescriptionLoader = nil;
}

+ (id)sharedInstance
{
	if (!__sharedDescriptionLoader)
		__sharedDescriptionLoader = [[self alloc] init];
	
	return __sharedDescriptionLoader;
}


#pragma mark - Actions

- (NSDictionary *)loadDescriptionFromPath:(NSString *)path
{
	NSString *ibtoolPath = [BLToolPath pathForTool: BLToolIBTool];
	
	// Check for ibtool
	if (![[NSFileManager defaultManager] fileExistsAtPath: ibtoolPath]) {
		BLLog(BLLogError, @"Cannot load preview: ibtool not found!");
		return nil;
	}
	
	// Configure arguments
	NSMutableArray *arguments = [NSMutableArray array];
	[arguments addObjectsFromArray: [BLToolPath defaultArgumentsForTool: BLToolIBTool]];
	[arguments addObjectsFromArray: [NSArray arrayWithObjects: @"--objects", @"--hierarchy", @"--classes", path, nil]];
	
	// Set up ibtool
	NSTask *ibtool = [[NSTask alloc] init];
	[ibtool setLaunchPath: ibtoolPath];
	[ibtool setArguments: arguments];
	
	// Setup output reading
	NSPipe *pipe = [NSPipe pipe];
	NSFileHandle *readHandle = [pipe fileHandleForReading];
	[ibtool setStandardOutput: pipe];
	
	// Run
	[ibtool launch];
	
	// Capture output
	NSMutableData *fullData = [[NSMutableData alloc] init];
	NSData *data;
	@try {
		while ((data = [readHandle availableData]) && [data length])
			[fullData appendData: data];
	} @catch (NSException *e) {
		BLLog(BLLogError, @"Failed reading ibtool output!");
		return nil;
	}
	
	// Parse output
	NSDictionary *dict = [NSPropertyListSerialization propertyListFromData:fullData mutabilityOption:NSPropertyListImmutable format:nil errorDescription:nil];

	// Check for errors
	if ([dict objectForKey: IBToolWarningsKey] || [dict objectForKey: IBToolErrorsKey]) {
		BLLogData(fullData, @"Loading preview");
		if ([dict objectForKey: IBToolErrorsKey])
			return nil;
	}
	
	return dict;
}

- (BOOL)writeDescription:(NSDictionary *)description fromPath:(NSString *)fromPath toPath:(NSString *)toPath
{
	NSString *ibtoolPath = [BLToolPath pathForTool: BLToolIBTool];
	
	// Check for ibtool
	if (![[NSFileManager defaultManager] fileExistsAtPath: ibtoolPath]) {
		BLLog(BLLogError, @"Cannot write preview: ibtool not found!");
		return NO;
	}
	
	// Write the description
	NSString *plistPath = [toPath stringByAppendingPathExtension: @"plist"];
	if (![description writeToFile:plistPath atomically:YES]) {
		BLLog(BLLogError, @"Cannot create temporary file at path %@", plistPath);
		return NO;
	}
	
	// Set up ibtool
	NSMutableArray *arguments = [NSMutableArray array];
	[arguments addObjectsFromArray: [BLToolPath defaultArgumentsForTool: BLToolIBTool]];
	[arguments addObjectsFromArray: [NSArray arrayWithObjects: @"--import", plistPath, @"--write", toPath, fromPath, nil]];
	
	NSTask *ibtool = [[NSTask alloc] init];
	[ibtool setLaunchPath: ibtoolPath];
	[ibtool setArguments: arguments];
	
	// Setup output readind
	NSPipe *pipe = [NSPipe pipe];
	NSFileHandle *readHandle = [pipe fileHandleForReading];
	[ibtool setStandardOutput: pipe];
	
	// Run
	[ibtool launch];
	
	// Capture output
	NSMutableData *fullData = [[NSMutableData alloc] init];
	NSData *data;
	while ((data = [readHandle availableData]) && [data length])
        [fullData appendData: data];
	
	// Clean up
	if (![[NSFileManager defaultManager] removeItemAtPath:plistPath error:NULL]) {
		BLLog(BLLogWarning, @"Cannot remove temporary file at path %@", plistPath);
	}
	
	// Parse output
	NSDictionary *dict = [NSPropertyListSerialization propertyListFromData:fullData mutabilityOption:NSPropertyListImmutable format:nil errorDescription:nil];
	
	// Check for errors
	if ([dict objectForKey: IBToolWarningsKey] || [dict objectForKey: IBToolErrorsKey]) {
		BLLogData(fullData, @"Loading preview");
		if ([dict objectForKey: IBToolErrorsKey])
			return NO;
	}
	
	return YES;
}

@end



