/*!
 @header
 LICustomLanguageSelection.m
 Created by Max Seelemann on 26.01.10.

 @copyright 2004-2010 the Localization Suite. All rights reserved.
 */

#import "LICustomLanguageSelection.h"

NSString *LICustomLanguageSelectionNibName = @"LICustomLanguageSelection";

@implementation LICustomLanguageSelection

+ (LICustomLanguageSelection *)customLanguageSelection {
	return [[self alloc] init];
}

- (id)init {
	self = [super init];

	if (self != nil) {
		_language = nil;
	}

	return self;
}

@synthesize language = _language;

- (void)beginSheetModalForWindow:(NSWindow *)window modalDelegate:(id)delegate didEndSelector:(SEL)didEndSelector contextInfo:(void *)contextInfo {
	if (!view)
		[NSBundle loadNibNamed:LICustomLanguageSelectionNibName owner:self];
	[self setAccessoryView:view];

	[super beginSheetModalForWindow:window modalDelegate:delegate didEndSelector:didEndSelector contextInfo:contextInfo];
	[[self window] makeFirstResponder:textField];
}

@end
