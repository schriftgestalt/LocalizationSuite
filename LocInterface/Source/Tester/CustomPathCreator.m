//
//  CustomPathCreator.m
//  LocInterface
//
//  Created by max on 06.04.09.
//  Copyright 2009 Blue Technologies Group. All rights reserved.
//

#import "CustomPathCreator.h"


@implementation CustomPathCreator

- (NSString *)absolutePathForFile:(BLFileObject *)file andLanguage:(NSString *)language
{
	return [[_document fileURL] path];
}

@end
