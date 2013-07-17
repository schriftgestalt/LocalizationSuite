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

typedef enum {
	LTDiffSignAdded,
	LTDiffSignRemoved,
	LTDiffSignUnchanged
} LTDiffSign;

@interface NSString (DiffTools)

/*!
 @abstract raw difference between two strings
 @discussion This method returns an array, each char is inside a NSDictionary with the information if it was added, removed or unchanged
 */
- (NSArray *)diffToString:(NSString *)secondString;

/*!
 @abstract Colored Diff between two strings
 */
- (NSAttributedString *)coloredDiffToString:(NSString *)secondString;

@end
