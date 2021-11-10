/*!
 @header
 BLCreationStep.h
 Created by Max on 29.04.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLProcessStep.h>

@class BLFileObject;

/*!
 @abstract Internal step class for performing a single creation.
 @discussion Do not use directly, use BLCreationStep instead!
 */
@interface BLCreationStep : BLProcessStep {
	BLFileObject *_fileObject;
	NSString *_language;
	NSString *_path;
	BOOL _reinject;
}

/*!
 @abstract Initializes a new step for creation.
 */
- (id)initForCreatingFile:(NSString *)path fromObject:(BLFileObject *)object withLanguage:(NSString *)language reinject:(BOOL)reinject;

@end
