//
//  NSString+DiffTooles.m
//  DiffTester
//
//  Created by Peter Kraml on 09.07.13.
//  Copyright (c) 2013 Boinx Software Ltd. All rights reserved.
//

#import "NSString+DiffTools.h"

@implementation NSString (DiffTools)

- (NSArray *)diffToString:(NSString *)secondString
{
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:100];
	[self generateDiffFromLCS:[self calculateLCS:secondString] forSecondString:secondString toLengthA:self.length lengthB:secondString.length intoResult:&result];
		
	return result;
}

- (NSAttributedString *)coloredDiffToString:(NSString *)secondString
{
	//Generate a new Diff...
    NSArray * result = [self diffToString:secondString];

    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:@""];

    [attrString beginEditing];

    // make the text appear in blue
    for (NSDictionary *dict in result)
	{
        [attrString appendAttributedString:[[NSAttributedString alloc] initWithString:[dict objectForKey:@"value"]]];

        NSColor *color = [NSColor blackColor];
        if ([[dict objectForKey:@"sign"] integerValue] == LTDiffSignAdded)
        {
            color = [NSColor greenColor];
        }
        else if ([[dict objectForKey:@"sign"] integerValue] == LTDiffSignRemoved)
        {
            color = [NSColor redColor];
        }


        [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(attrString.length-1, 1)];
    }

    [attrString endEditing];

    return [[NSAttributedString alloc] initWithAttributedString:attrString];
}

- (void)generateDiffFromLCS:(NSArray *)C forSecondString:(NSString *)secondString toLengthA:(NSInteger)i lengthB:(NSInteger)j intoResult:(NSMutableArray **)result
{
	if (i > 0 && j > 0 &&  [self characterAtIndex:i - 1] == [secondString characterAtIndex:j -1 ])
	{
		[self generateDiffFromLCS:C forSecondString:secondString toLengthA:i - 1 lengthB:j - 1 intoResult:result];
		
		[*result addObject:
				[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:LTDiffSignUnchanged], [self substringWithRange:NSMakeRange(i - 1, 1)], nil]
											forKeys:[NSArray arrayWithObjects:@"sign", @"value", nil]]
		 ];

    }
    else
	{
		if (j > 0 && (i == 0 || [[[C objectAtIndex:i] objectAtIndex:j-1] intValue] >= [[[C objectAtIndex:i - 1] objectAtIndex:j] intValue]))
		{
			[self generateDiffFromLCS:C forSecondString:secondString toLengthA:i lengthB:j-1 intoResult:result];
			
			[*result addObject:
			 [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:LTDiffSignAdded], [secondString substringWithRange:NSMakeRange(j - 1, 1)], nil]
										 forKeys:[NSArray arrayWithObjects:@"sign", @"value", nil]]
			 ];
		}
		else if (i > 0 && (j == 0 || [[[C objectAtIndex:i] objectAtIndex:j-1] intValue] < [[[C objectAtIndex:i-1] objectAtIndex:j] intValue]))
		{
			[self generateDiffFromLCS:C forSecondString:secondString toLengthA:i-1 lengthB:j intoResult:result];
			
			[*result addObject:
			 [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:LTDiffSignRemoved], [self substringWithRange:NSMakeRange(i - 1, 1)], nil]
										 forKeys:[NSArray arrayWithObjects:@"sign", @"value", nil]]
			 ];
		}
    }
}

- (NSArray *)calculateLCS:(NSString *)secondString
{
	NSInteger m = self.length;
    NSInteger n = secondString.length;
    NSMutableArray *C = [NSMutableArray arrayWithCapacity:100];
    
	for (NSInteger i = 0; i < m+1; i++)
	{
		NSMutableArray *inner = [NSMutableArray arrayWithCapacity:n];
		
		for (NSInteger j=0; j < n+1; j++)
		{
			[inner addObject:[NSNumber numberWithInt:0]];
		}
		[C addObject:inner];
    }
	
    for (NSInteger i = 1; i < m+1; i++)
	{
		for (NSInteger j = 1; j < n+1; j++)
		{
			if ([self characterAtIndex:i-1] == [secondString characterAtIndex:j - 1])
			{
				[[C objectAtIndex:i] replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:[[[C objectAtIndex:i -1] objectAtIndex:j -1] intValue] +1]];
			}
			else
			{
				[[C objectAtIndex:i] replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:MAX([[[C objectAtIndex:i] objectAtIndex:j-1] intValue], [[[C objectAtIndex:i-1] objectAtIndex:j] intValue])]];
			}
		}
    }
    return C;
}

@end
