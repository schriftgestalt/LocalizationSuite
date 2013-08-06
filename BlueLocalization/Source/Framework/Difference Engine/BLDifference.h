/*!
 @header
 LTDifference.h
 Created by max on 20.03.05.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract The types of a difference between two strings.
 
 @const LTDifferenceCopy	The part are the same in the old and the new string.
 @const LTDifferenceChange	The part were changed between the old and the new version.
 @const LTDifferenceDelete	The part has been removed in the new string.
 @const LTDifferenceAdd		The part has been added in the new string.
 */
typedef enum {
    BLDifferenceCopy	= 0,
    BLDifferenceChange	= 1,
    BLDifferenceDelete	= 2,
    BLDifferenceAdd		= 3
} BLDifferenceType;

/*!
 @abstract Basic result object returned by LTDifferenceEngine.
 @discussion Represents a part of both matched strings and 
 */
@interface BLDifference : NSObject
{
    NSString			*_newValue;
    NSString			*_oldValue;
    BLDifferenceType	_type;
}

/*!
 @abstract The value of the difference in the new string.
 */
- (NSString *)newValue;

/*!
 @abstract The value of the difference in the old string.
 */
- (NSString *)oldValue;

/*!
 @abstract The type of the difference.
 @discussion The result is type of the difference between oldValue and newValue only. See LTDifferenceType for possible values.
 */
- (BLDifferenceType)type;

@end

