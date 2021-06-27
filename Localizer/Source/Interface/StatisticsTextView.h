//
//  StatisticsTextView.h
//  Localizer
//
//  Created by max on 19.11.09.
//  Copyright 2009 The Soulmen. All rights reserved.
//

@interface StatisticsTextView : NSTextView <LIStatusObjects> {
}

- (void)updateCurrentObjects;

@end

@protocol StatisticsTextViewDelegate
@optional

- (NSArray *)currentObjectsInTextView:(StatisticsTextView *)textView;
- (NSArray *)currentLanguagesInTextView:(StatisticsTextView *)textView;

@end
