//
//  NSString+DiffTooles.m
//  DiffTester
//
//  Created by Peter Kraml on 09.07.13.
//  Copyright (c) 2013 Boinx Software Ltd. All rights reserved.
//

#import "NSString+DiffTools.h"
#import <LocTools/LocTools.h>

@implementation NSString (DiffTools)

- (NSAttributedString *)coloredDiffToString:(NSString *)secondString
{
	LTDifferenceEngine *engine = [[LTDifferenceEngine alloc] init];
	engine.segmentation = BLDetailedSegmentation;
	engine.newString = secondString;
	engine.oldString = self;
	[engine computeDifferences];
	
	NSArray *differences = [engine differences];
	
	NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:@""];
    [attrString beginEditing];
	
    // make the text appear in blue
    for (LTDifference *diff in differences)
	{
		NSString *stringToAppend = diff.newValue;
		
		if (diff.type == LTDifferenceDelete)
		{
			stringToAppend = diff.oldValue;
		}
		
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:stringToAppend]];
		
		NSRange currentRange = NSMakeRange(attrString.length-stringToAppend.length, stringToAppend.length);
		
        NSColor *color = [NSColor blackColor];
		NSColor *backgroundColor = [NSColor clearColor];
		
		
        if (diff.type == LTDifferenceAdd)
        {
            color = [NSColor colorWithCalibratedRed:0.f green:0.6f blue:0.f alpha:1.000];
			backgroundColor = [NSColor colorWithCalibratedRed:0.72f green:1.f blue:0.72f alpha:1];
        }
        else if (diff.type == LTDifferenceDelete)
        {
            color = [NSColor colorWithCalibratedRed:0.6f green:0.f blue:0.f alpha:1.000];
			backgroundColor = [NSColor colorWithCalibratedRed:1.f green:0.72f blue:0.72f alpha:1];
			
			[attrString addAttribute:NSStrikethroughStyleAttributeName
							   value:[NSNumber numberWithInt:1]
							   range:currentRange];
        }
		else if (diff.type == LTDifferenceChange)
		{
			color = [NSColor colorWithCalibratedRed:0.f green:0.f blue:0.6f alpha:1.000];
			backgroundColor = [NSColor colorWithCalibratedRed:0.72f green:0.72f blue:1.f alpha:1];
		}
		
        [attrString addAttribute:NSForegroundColorAttributeName value:color range:currentRange];
		[attrString addAttribute:NSBackgroundColorAttributeName value:backgroundColor range:currentRange];
		
		//Append space
		[attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
    }
	
    [attrString endEditing];
	
    return [[NSAttributedString alloc] initWithAttributedString:attrString];
}


@end
