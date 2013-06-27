//
//  Controller.m
//  LocInterface
//
//  Created by max on 05.04.09.
//  Copyright 2009 Blue Technologies Group. All rights reserved.
//

#import "Controller.h"

@implementation Controller

- (IBAction)showLog:(id)sender
{
	[[LILogWindow logWindow] show];
}

- (IBAction)showStats:(id)sender
{
	[[LIStatusDisplay statusDisplay] show];
}

@end
