//
//  BLKeyObject+Difference.h
//  LocTools
//
//  Created by Peter Kraml on 30.11.13.
//  Copyright (c) 2013 Localization Suite. All rights reserved.
//

#import <BlueLocalization/BlueLocalization.h>

@interface BLKeyObject (Difference)

/*!
 @abstract Returns the difference between the current and the previous version for the specified language
 @discussion if no previous version is found, the current version will be returned without any changes to it
 */
- (NSAttributedString *)differenceForLanguage:(NSString *)language;

@end
