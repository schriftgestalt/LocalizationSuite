//
//  LanguageNameMatrix.m
//  Localization Manager
//
//  Created by Max Seelemann on 21.01.07.
//  Copyright 2007 The Blue Technologies Group. All rights reserved.
//

#import "LanguageNameMatrix.h"

#import "LanguageNameButtonCell.h"

@implementation LanguageNameMatrix

- (void)bind:(NSString *)binding toObject:(id)observable withKeyPath:(NSString *)keyPath options:(NSDictionary *)options {
	if (![[self prototype] isKindOfClass:[LanguageNameButtonCell class]]) {
		NSButtonCell *prototype;
		prototype = [[LanguageNameButtonCell alloc] init];
		[prototype setButtonType:NSSwitchButton];
		[prototype setControlSize:NSControlSizeSmall];
		[prototype setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSControlSizeSmall]]];
		[prototype setLineBreakMode:NSLineBreakByTruncatingTail];
		[self setPrototype:prototype];
	}

	[super bind:binding toObject:observable withKeyPath:keyPath options:options];
}

@end
