//
//  BLXcodeImportUpdateStep.h
//  BlueLocalization
//
//  Created by Max Seelemann on 01.09.11.
//  Copyright (c) 2011 Localization Suite. All rights reserved.
//

#import <BlueLocalization/BLProcessStep.h>

/*!
 @abstract Internal class used by BLDatabaseDocument to automatically import associated Xcode projects.
 @discussion Do not use directly, use BLDatabaseDocument -rescan: instead!
 */
@interface BLXcodeImportUpdateStep : BLProcessStep

/*!
 @abstract Designated initializer.
 */
- (id)initWithXcodeProjectsOfBundles:(NSArray *)bundles inProject:(BLDatabaseDocument *)document;

@end
