//
//  BLToolPath.m
//  BlueLocalization
//
//  Created by max on 18.11.09.
//  Copyright 2009 The Soulmen. All rights reserved.
//

#import "BLToolPath.h"


NSString *__BLUsedDeveloperToolsPath		= nil;

NSString *__kDefaultDeveloperToolsPath	= @"/Applications/Xcode.app/Contents/Developer";
NSString *__kIBToolPath					= @"/usr/bin/ibtool";
NSString *__kIBToolAgentName			= @"LocSuite";

NSString *BLToolPathDeveloperDirectoryKeyPath	= @"developerToolsPath";


@implementation BLToolPath

+ (void)initialize
{
	[super initialize];
	
	[[NSUserDefaults standardUserDefaults] addObserver:[[self alloc] init] forKeyPath:BLToolPathDeveloperDirectoryKeyPath options:NSKeyValueObservingOptionInitial context:@"path"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == @"path") {
        __BLUsedDeveloperToolsPath = [object valueForKeyPath: keyPath];
		
		// Use default
		if (!__BLUsedDeveloperToolsPath && [NSFileManager.defaultManager fileExistsAtPath: __kDefaultDeveloperToolsPath])
			__BLUsedDeveloperToolsPath = __kDefaultDeveloperToolsPath;
		
		// Check path and fallback if needed
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDeveloperDirectory, NSSystemDomainMask, YES);
		if ((!__BLUsedDeveloperToolsPath || ![[NSFileManager defaultManager] fileExistsAtPath: __BLUsedDeveloperToolsPath]) && [paths count]) {
			NSString *path = [paths objectAtIndex: 0];
			if ([NSFileManager.defaultManager fileExistsAtPath:path]) {
				__BLUsedDeveloperToolsPath = path;
			} else {
				__BLUsedDeveloperToolsPath = @"";
			}
		}
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

+ (NSString *)developerDirectory
{
	return __BLUsedDeveloperToolsPath;
}

+ (NSString *)pathForTool:(BLToolIdentifier)tool
{
	switch (tool) {
		case BLToolIBTool:
			return [__BLUsedDeveloperToolsPath stringByAppendingPathComponent: __kIBToolPath];
		default:
			return nil;
	}
}

+ (NSArray *)defaultArgumentsForTool:(BLToolIdentifier)tool
{
	switch (tool) {
		case BLToolIBTool:
			return nil;//[NSArray arrayWithObjects: @"--agent-name", __kIBToolAgentName, nil];
		default:
			return nil;
	}
}

@end
