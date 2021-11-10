/*!
 @header
 BLPreparationStep.h
 Created by Max on 27.04.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLProcessStep.h>

/*!
 @abstract A step that determines the work to do on agiven set of objects for interpreation and enqueues groups to the manager accordingly.
 */
@interface BLInterpreterStep : BLProcessStep

/*!
 @abstract Creates a step for interpreting the given set of objects.
 @discussion Options can be set with BLFileInterpreter options. The options are additive, which means you can only enable additional options! The options are always modified, i.e. reference language files are imported enabling the modification of keys, whereas other languages are not allowed to.
 */
+ (id)stepForInterpertingObjects:(NSArray *)objects withOptions:(NSUInteger)options parameters:(NSDictionary *)parameters andLanguages:(NSArray *)languages;

/*!
 @abstract Creates a step for interpreting the given files.
 @discussion Leaving options empty will use the default settings. The options are always modified, i.e. reference language files are imported enabling the modification of keys, whereas other languages are not allowed to.
 */
+ (id)stepForInterpretingFiles:(NSArray *)files withOptions:(NSUInteger)options parameters:(NSDictionary *)parameters;

/*!
 @abstract The options that will be set additionally for all interpretations of reference files.
 @discussion By default this method returns BLFileInterpreterAllowChangesToKeyObjects | BLFileInterpreterTrackValueChangesAsUpdate.
 */
+ (NSUInteger)optionsForReferenceFiles;

/*!
 @abstract The options that will be set additionally for all interpretations of non-reference or regular files.
 @discussion By default this method returns BLFileInterpreterNoOptions.
 */
+ (NSUInteger)optionsForRegularFiles;

@end
