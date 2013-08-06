//
//  LTStringDiffer.m
//  LocTools
//
//  Created by Peter Kraml on 06.08.13.
//  Copyright (c) 2013 Localization Suite. All rights reserved.
//

#import "BLStringDiffer.h"
#import "BLDifferenceEngine.h"
#import "BLDifference.h"

@interface BLStringDiffer ()

+ (void)addGreenString:(NSString *)newString toAttributedString:(NSMutableAttributedString *)attrString;
+ (void)addRedString:(NSString *)oldString toAttributedString:(NSMutableAttributedString *)attrString;

@end

@implementation BLStringDiffer

+ (NSAttributedString *)diffBetween:(NSString *)inAStr and:(NSString *)inBStr
{
	BLDifferenceEngine *engine = [[BLDifferenceEngine alloc] init];
	engine.segmentation = BLDetailedSegmentation;
	engine.newString = inBStr;
	engine.oldString = inAStr;
	[engine computeDifferences];
	
	NSArray *differences = [engine differences];
	
	NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:@""];
    [attrString beginEditing];
	
    // make the text appear in blue
    for (BLDifference *diff in differences)
	{
		if (diff.type == BLDifferenceAdd)
        {
			//String was added, append it, color it green
			[self addGreenString:diff.newValue toAttributedString:attrString];
		}
		else if (diff.type == BLDifferenceDelete)
		{
			//String was removed, append the old value and color it red
			[self addRedString:diff.oldValue toAttributedString:attrString];
		}
		else if (diff.type == BLDifferenceChange)
		{
			//string was changed, append the old and the new one, color accordingly
			[self addRedString:diff.oldValue toAttributedString:attrString];
			[self addGreenString:diff.newValue toAttributedString:attrString];
		}
		else
		{
			//no change, simply append it.
			[attrString appendAttributedString:[[NSAttributedString alloc] initWithString:diff.newValue]];
			[attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
		}
    }
	
    [attrString endEditing];
	
    return [[NSAttributedString alloc] initWithAttributedString:attrString];
}

+ (void)addGreenString:(NSString *)newString toAttributedString:(NSMutableAttributedString *)attrString
{
	[attrString appendAttributedString:[[NSAttributedString alloc] initWithString:newString]];
	
	NSRange currentRange = NSMakeRange(attrString.length-newString.length, newString.length);
	
	NSColor *color = [NSColor colorWithCalibratedRed:0.f green:0.6f blue:0.f alpha:1.000];
	NSColor *backgroundColor = [NSColor colorWithCalibratedRed:0.72f green:1.f blue:0.72f alpha:1];
	
	[attrString addAttribute:NSForegroundColorAttributeName value:color range:currentRange];
	[attrString addAttribute:NSBackgroundColorAttributeName value:backgroundColor range:currentRange];
	
	[attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
}

+ (void)addRedString:(NSString *)oldString toAttributedString:(NSMutableAttributedString *)attrString
{
	[attrString appendAttributedString:[[NSAttributedString alloc] initWithString:oldString]];
	
	NSRange currentRange = NSMakeRange(attrString.length-oldString.length, oldString.length);
	
	NSColor *color = [NSColor colorWithCalibratedRed:0.6f green:0.f blue:0.f alpha:1.000];
	NSColor *backgroundColor = [NSColor colorWithCalibratedRed:1.f green:0.72f blue:0.72f alpha:1];
	
	//strikethrough
	[attrString addAttribute:NSStrikethroughStyleAttributeName
					   value:[NSNumber numberWithInt:1]
					   range:currentRange];
	
	[attrString addAttribute:NSForegroundColorAttributeName value:color range:currentRange];
	[attrString addAttribute:NSBackgroundColorAttributeName value:backgroundColor range:currentRange];
	
	[attrString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
}

@end
