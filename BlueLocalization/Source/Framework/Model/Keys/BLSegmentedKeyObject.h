/*!
 @header
 BLSegmentedKeyObject.h
 Created by Max on 17.02.10.
 
 @copyright 2010 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLStringSegmentation.h>

/*!
 @abstract A transparent class that adds segmentation to key objects.
 */
@interface BLSegmentedKeyObject : BLKeyObject
{
	NSArray				*_delimiters;
	NSMutableDictionary	*_languages;
	NSArray				*_keyObjects;
	BLKeyObject			*_original;
}

/*!
 @abstract Splits a key object into multiple key objects representing the segments.
 @discussion This only happens, if the object needs to be split (i.e. has multiple segments) and can be split. Especially the last point is important - if the segemtnations between all localizations do not match, splitting is not possible. In this case, this method returns only the array containing the original. Also the key object must be a BLStringKeyObject or similar, storing NSString objects.
 */
+ (NSArray *)segmentKeyObject:(BLKeyObject *)original byType:(BLSegmentationType)type;

@end
