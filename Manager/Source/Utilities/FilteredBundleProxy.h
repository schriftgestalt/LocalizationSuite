//
//  FilteredBundleProxy.h
//  Localization Manager
//
//  Created by Max on 08.05.10.
//  Copyright 2010 Localization Foundation. All rights reserved.
//

@interface FilteredBundleProxy : NSProxy
{
	BLBundleObject	*_bundle;
	NSArray			*_files;
	NSArray			*_languages;
	NSString		*_search;
}

- (id)initWithBundle:(BLBundleObject *)bundle andSearchString:(NSString *)string forLanguages:(NSArray *)languages;

- (BLBundleObject *)original;

@end