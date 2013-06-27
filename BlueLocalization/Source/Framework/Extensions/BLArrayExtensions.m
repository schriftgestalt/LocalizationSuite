/*!
 @header
 BLArrayExtensions.m
 Created by Max on 11.12.05.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLArrayExtensions.h>


@implementation NSArray (BTArraySearch)

- (NSArray *)objectsContainingValue:(id)value forKeyPath:(NSString *)keyPath
{
    NSMutableArray *matches;
    unsigned i;
    
    matches = [NSMutableArray array];
    
    for (i=0; i<[self count]; i++) {
        if ([[[self objectAtIndex: i] valueForKeyPath: keyPath] isEqual: value])
            [matches addObject: [self objectAtIndex: i]];
    }
    
    return matches;
}

- (NSArray *)objectsContainingValues:(NSArray *)values forKeyPath:(NSString *)keyPath
{
    NSMutableArray *matches;
    unsigned i;
    
    matches = [NSMutableArray array];
    
    for (i=0; i<[values count]; i++)
        [matches addObjectsFromArray: [self objectsContainingValue:[values objectAtIndex: i] forKeyPath:keyPath]];
    
    return matches;
}

- (NSArray *)arrayWithAllValuesForKeyPath:(NSString *)keyPath
{
    NSMutableArray *array;
    unsigned i;
    
    array = [NSMutableArray arrayWithCapacity: [self count]];
    
    for (i=0; i<[self count]; i++) {
        if ([[self objectAtIndex: i] valueForKeyPath: keyPath])
            [array addObject: [[self objectAtIndex: i] valueForKeyPath: keyPath]];
    }
    
    return array;
}

- (NSArray *)arrayWithAllDifferentValuesForKeyPath:(NSString *)keyPath
{
    NSMutableArray *array;
    unsigned i;
    
    array = [NSMutableArray arrayWithCapacity: [self count]];
    
    for (i=0; i<[self count]; i++) {
        id value = [[self objectAtIndex: i] valueForKeyPath: keyPath];
        if (value && ![array containsObject: value])
            [array addObject: value];
    }
    
    return array;
}

@end


