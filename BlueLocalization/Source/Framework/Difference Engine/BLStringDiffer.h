//
//  LTStringDiffer.h
//  LocTools
//
//  Created by Peter Kraml on 06.08.13.
//  Copyright (c) 2013 Localization Suite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLStringDiffer : NSObject

//Returns a colored diff between two strings.
+ (NSAttributedString *)diffBetween:(NSString *)inAStr and:(NSString *)inBStr;

@end
