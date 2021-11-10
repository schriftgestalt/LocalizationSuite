/*!
 @header
 BLCreatorStep.h
 Created by Max on 29.04.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLProcessStep.h>

/*!
 @abstract A step that determines the work to do on a given set of objects for creation and enqueues a group to the manager accordingly.
 */
@interface BLCreatorStep : BLProcessStep {
	NSArray *_languages;
	NSArray *_objects;
	BOOL _reinject;
}

/*!
 @abstract Creates a step for creating the given set of objects to a set of languages.
 */
+ (id)stepForCreatingObjects:(NSArray *)objects inLanguages:(NSArray *)languages reinject:(BOOL)reinject;

@end