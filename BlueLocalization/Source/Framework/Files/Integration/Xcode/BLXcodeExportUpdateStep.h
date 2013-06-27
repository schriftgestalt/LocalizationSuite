/*!
 @header
 BLXcodeExportUpdateStep.h
 Created by max on 24.11.10.
 
 @copyright 2004-2010 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLProcessStep.h>

/*!
 @abstract Internal class used by BLDatabaseDocument to automatically update associated Xcode projects.
 @discussion Do not use directly, use BLDatabaseDocument -synchronizeObjects:forLanguages:reinject: instead!
 */
@interface BLXcodeExportUpdateStep : BLProcessStep

/*!
 @abstract Designated initializer.
 */
- (id)initWithXcodeProjectsOfBundles:(NSArray *)bundles inProject:(BLDatabaseDocument *)document withOptions:(NSUInteger)options languageLimit:(float)languageLimit fileLimit:(float)fileLimit;

@end
