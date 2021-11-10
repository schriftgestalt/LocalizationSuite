//
//  TableViewAdditions.m
//  Localization Manager
//
//  Created by Max Seelemann on 21.01.07.
//  Copyright 2007 The Blue Technologies Group. All rights reserved.
//

#import "TableViewAdditions.h"

NSString *NSTableViewSortingKeyFormat = @"NSTableView Sorting %@";

@implementation NSTableView (TableViewAdditions)

- (void)saveSortDescriptors {
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:[self sortDescriptors]] forKey:[NSString stringWithFormat:NSTableViewSortingKeyFormat, [self autosaveName]]];
}

- (void)loadSortDescriptors {
	NSData *data;

	data = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:NSTableViewSortingKeyFormat, [self autosaveName]]];
	if (data)
		[self setSortDescriptors:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
}

@end
