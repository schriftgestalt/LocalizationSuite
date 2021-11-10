//
//  StatisticsTextView.m
//  Localizer
//
//  Created by max on 19.11.09.
//  Copyright 2009 The Soulmen. All rights reserved.
//

#import "StatisticsTextView.h"

@implementation StatisticsTextView

- (void)updateCurrentObjects {
	[self willChangeValueForKey:@"currentObjects"];
	[self didChangeValueForKey:@"currentObjects"];
}

- (NSArray *)currentObjects {
	if ([[self delegate] respondsToSelector:@selector(currentObjectsInTextView:)])
		return [(id)[self delegate] currentObjectsInTextView:self];
	else
		return nil;
}

- (NSArray *)currentLanguages {
	if ([[self delegate] respondsToSelector:@selector(currentLanguagesInTextView:)])
		return [(id)[self delegate] currentLanguagesInTextView:self];
	else
		return nil;
}

@end
