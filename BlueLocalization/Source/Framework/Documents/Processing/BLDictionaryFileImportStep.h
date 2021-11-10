/*!
 @header
 BLDictionaryFileImportStep.h
 Created by Max Seelemann on 24.01.10.

 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */

@interface BLDictionaryFileImportStep : BLProcessStep {
	NSString *_path;
}

/*!
 @abstract The path extensions the step can import.
 */
+ (NSArray *)availablePathExtensions;

/*!
 @abstract Creates a step group for importing the given files.
 */
+ (NSArray *)stepGroupForImportingFiles:(NSArray *)files;

@end
