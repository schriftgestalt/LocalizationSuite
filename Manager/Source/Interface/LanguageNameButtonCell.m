//
//  LanguageNameButtonCell.m
//  Localization Manager
//
//  Created by Max Seelemann on 20.01.07.
//  Copyright 2007 The Blue Technologies Group. All rights reserved.
//

#import "LanguageNameButtonCell.h"

@implementation LanguageNameButtonCell

- (void)setTitle:(id)value
{
    [super setTitle: [BLLanguageTranslator descriptionForLanguage: value]];
}

- (NSString *)title
{
    return [BLLanguageTranslator identifierForLanguage: [super title]];
}

@end
