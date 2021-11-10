/*!
 @header
 BLObjectExtensions.h
 Created by max on 27.02.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLObject.h>

/*!
 @abstract Several methods for convenience use.
 */
@interface BLObject (BLObjectExtensions)

/*!
 @abstract Returns all bundle objects contained in the array.
 @discussion This is a pure filter method.
 */
+ (NSArray *)bundleObjectsFromArray:(NSArray *)array;

/*!
 @abstract Returns all bundle objects that contain objects in the array.
 @discussion Bundle objects are passed through. Other objects are checked for their bundle and that one is returned then.
 */
+ (NSArray *)containingBundleObjectsFromArray:(NSArray *)array;

/*!
 @abstract Returns all file objects contained in the array.
 @discussion If a bundle is found, it's files are returned instead.
 */
+ (NSArray *)fileObjectsFromArray:(NSArray *)array;

/*!
 @abstract Returns all key objects contained in the array.
 @discussion First applies +fileObjectsFromArray: and then returns the key objects of these files.
 */
+ (NSArray *)keyObjectsFromArray:(NSArray *)array;

/*!
 @abstract Filters bundles from an array.
 @discussion Checks all objects in the array whether they are of class BLBundleObject and have the passed name and returns only these objects.
 */
+ (NSArray *)bundleObjectsWithName:(NSString *)name inArray:(NSArray *)array;

/*!
 @abstract Filters bundles from an array.
 @discussion Checks all objects in the array whether they are of class BLFileObject and have the passed name and returns only these objects.
 */
+ (NSArray *)fileObjectsWithName:(NSString *)name inArray:(NSArray *)array;

/*!
 @abstract Creates proxied for a set of objects.
 @discussion For each object in the array, calls BLObjectProxy's proxyWithObject: and returns these proxy objects.
 */
+ (NSArray *)proxiesForObjects:(NSArray *)array;

@end

@interface BLObject (BLObjectKeyNumbers)

/*!
 @abstract Convenience to numberOfKeys for an array of objects.
 */
+ (NSUInteger)numberOfKeysInObjects:(NSArray *)array;

/*!
 @abstract Convenience to numberOfMissingKeysForLanguage for an array of objects.
 */
+ (NSUInteger)numberOfKeysMissingForLanguage:(NSString *)language inObjects:(NSArray *)array;

/*!
 @abstract The number of key objects hosted by an object.
 */
- (NSUInteger)numberOfKeys;

/*!
 @abstract The number of key objects not localized for a given language.
 @discussion A missing key is defined as an key empty for the passed language that is active and contained in an active file.
 1-(numberOfMissingKeysForLanguage/numberOfKeys) is the completion percentage.
 */
- (NSUInteger)numberOfMissingKeysForLanguage:(NSString *)language;

@end

@interface BLObject (BLObjectStatistics)

/*!
 @abstract Types of counters for the statistics methods.

 @const BLObjectStatisticsSentences		Count the number of sentences in a set of key objects.
 @const BLObjectStatisticsWords			Count the number of words in a set of key objects.
 @const BLObjectStatisticsCharacters	Count the number of characters including whitespace in a set of key objects.
 */
typedef enum {
	BLObjectStatisticsSentences,
	BLObjectStatisticsWords,
	BLObjectStatisticsCharacters
} BLObjectStatisticsType;

/*!
 @abstract Convenience to countForStatistic:forLanguage: for an array of objects.
 @discussion This method only returns the cumulated statistics of active objects from the array.
 */
+ (NSUInteger)countForStatistic:(BLObjectStatisticsType)type forLanguage:(NSString *)language inObjects:(NSArray *)objects;

/*!
 @abstract Calculates a statistical value for a language in a object, including child objects.
 @discussion If not applied directly on a key object, this method only returns the cumulated statistics of active objects.
 */
- (NSUInteger)countForStatistic:(BLObjectStatisticsType)type forLanguage:(NSString *)language;

@end
