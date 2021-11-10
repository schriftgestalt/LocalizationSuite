//
//  BLToolPath.h
//  BlueLocalization
//
//  Created by max on 18.11.09.
//  Copyright 2009 The Soulmen. All rights reserved.
//

/*!
 @abstract Available constants for tools.

 @const BLToolIBTool		The ibtool command line utility.
 */
typedef enum {
	BLToolIBTool
} BLToolIdentifier;

/*!
 @abstract Generates callable paths for standard tools.
 */
@interface BLToolPath : NSObject

/*!
 @abstract The developer directory used by the framework.
 */
+ (NSString *)developerDirectory;

/*!
 @abstract Returns the launch path for the given tool.
 */
+ (NSString *)pathForTool:(BLToolIdentifier)tool;

/*!
 @abstract Arguments that should always be passed to a tool.
 */
+ (NSArray *)defaultArgumentsForTool:(BLToolIdentifier)tool;

@end
