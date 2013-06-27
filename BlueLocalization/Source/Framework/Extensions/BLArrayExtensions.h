/*!
 @header
 BLArrayExtensions.h
 Created by Max on 11.12.05.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

@interface NSArray (BTArraySearch)

- (NSArray *)objectsContainingValue:(id)value forKeyPath:(NSString *)keyPath;
- (NSArray *)objectsContainingValues:(NSArray *)values forKeyPath:(NSString *)keyPath;

- (NSArray *)arrayWithAllValuesForKeyPath:(NSString *)keyPath;
- (NSArray *)arrayWithAllDifferentValuesForKeyPath:(NSString *)keyPath;

@end