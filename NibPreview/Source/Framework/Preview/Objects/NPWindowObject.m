/*!
 @header
 NPWindowObject.m
 Created by max on 07.08.09.

 @copyright 2008-2009 Localization Suite. All rights reserved.
 */

#import "NPWindowObject.h"

#import "NPWindowView.h"

@implementation NPWindowObject

- (id)init {
	self = [super init];

	if (self) {
		_displayView = nil;
	}

	return self;
}

#pragma mark - Accessors

- (NSView *)displayView {
	if (!_displayView) {
		dispatch_sync(dispatch_get_main_queue(), ^(void) {
			_displayView = [[NPWindowView alloc] initWithWindow:_original];
		});
	}

	return _displayView;
}

@end
