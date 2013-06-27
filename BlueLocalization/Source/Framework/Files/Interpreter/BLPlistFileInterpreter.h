/*!
 @header
 BLPlistFileInterpreter.h
 Created by Max Seelemann on 04.09.06.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLFileInterpreter.h>

/*!
 @abstract A file interpreter implementation for property list files.
 */
@interface BLPlistFileInterpreter : BLFileInterpreter
{
}

@end

@interface NSDictionary (BLPlistLocalization)

- (NSDictionary *)localizationDictionary;

@end

@interface NSMutableDictionary (BLPlistLocalization)

- (void)localizeUsingDictionary:(NSDictionary *)translation;

@end

@interface NSArray (BLPlistLocalization)

- (NSDictionary *)localizationDictionary;

@end

@interface NSMutableArray (BLPlistLocalization)

- (void)localizeUsingDictionary:(NSDictionary *)translation;

@end