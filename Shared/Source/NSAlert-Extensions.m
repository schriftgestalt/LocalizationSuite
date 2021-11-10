// Copyright 1997-2009 Omni Development, Inc.  All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// <http://www.omnigroup.com/developer/sourcecode/sourcelicense/>.

#import "NSAlert-Extensions.h"

#import <objc/runtime.h>

@interface _NSAlertSheetCompletionHandlerRunner : NSObject {
	NSWindow *_window;
	NSAlert *_alert;
	NSAlertSheetCompletionHandler _completionHandler;
}
@end

@implementation _NSAlertSheetCompletionHandlerRunner

- initWithAlert:(NSAlert *)alert completionHandler:(NSAlertSheetCompletionHandler)completionHandler;
{
	if (!(self = [super init]))
		return nil;

	_alert = alert;
	_completionHandler = [completionHandler copy];
	return self;
}

- (void)startOnWindow:(NSWindow *)parentWindow;
{
	_window = parentWindow;
	objc_setAssociatedObject(_window, @"__retained_alertCompletionHandler", self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

	[_alert beginSheetModalForWindow:parentWindow modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
	NSAssert(alert == _alert, @"Got a alert different from what I expected -- This should never happen");
	[_alert.window close];

	if (_completionHandler)
		_completionHandler(returnCode);

	objc_setAssociatedObject(_window, @"__retained_alertCompletionHandler", nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
/*
@implementation NSAlert (Extensions)

- (void)beginSheetModalForWindow:(NSWindow *)window completionHandler:(NSAlertSheetCompletionHandler)completionHandler;
{
	_NSAlertSheetCompletionHandlerRunner *runner = [[_NSAlertSheetCompletionHandlerRunner alloc] initWithAlert:self completionHandler:completionHandler];
	[runner startOnWindow:window];
}

@end
*/

void NSBeginAlertSheetWithBlock(NSString *title, NSString *defaultButton, NSString *alternateButton, NSString *otherButton, NSWindow *docWindow, NSAlertSheetCompletionHandler completionHandler, NSString *msgFormat, ...) {
	NSAlert *alert = [[NSAlert alloc] init];
	[alert setMessageText:title];

	if (msgFormat) {
		va_list args;
		va_start(args, msgFormat);
		NSString *informationalText = [[NSString alloc] initWithFormat:msgFormat arguments:args];
		va_end(args);

		[alert setInformativeText:informationalText];
	}

	if (defaultButton)
		[alert addButtonWithTitle:defaultButton];
	if (alternateButton)
		[alert addButtonWithTitle:alternateButton];
	if (otherButton)
		[alert addButtonWithTitle:otherButton];

	[alert beginSheetModalForWindow:docWindow completionHandler:completionHandler];
	// retained by the runner while the sheet is up
}
