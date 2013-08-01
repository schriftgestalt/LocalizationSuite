/*!
 @header
 NSString+DiffTools.h
 Created by piets on 17.07.13.

 @copyright 2013 Localization Suite. All rights reserved.
 */

/*!
 @abstract Category on NSString for generating colored diffs on two strings
 */

#import <Foundation/Foundation.h>

@interface NSString (DiffTools)

/*!
 @abstract Colored Diff between two strings
 */
- (NSAttributedString *)coloredDiffToString:(NSString *)secondString;

@end
