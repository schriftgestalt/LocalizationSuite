//
//  main.m
//  Localization Dictionary
//
//  Created by Max on 14.03.05.
//  Copyright 2005 The Blue Technologies Group. All rights reserved.
//

#import "Controller.h"

int main(int argc, char *argv[]) {
#ifdef DEBUG
	NSZombiesEnabled = YES;
#endif
	return NSApplicationMain(argc, (const char **)argv);
}
