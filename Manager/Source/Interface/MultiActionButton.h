//
//  MultiActionButton.h
//  Localization Manager
//
//  Created by max on 08.09.09.
//  Copyright 2009 Localization Foundation. All rights reserved.
//

@interface MultiActionButton : NSButton {
	SEL _altAction;
	NSString *_altTitle;
	NSUInteger _lastFlags;
	SEL _shiftAction;
	NSString *_shiftTitle;
}

@property (assign) SEL altAction;
@property (strong) NSString *altTitle;

@property (assign) SEL shiftAction;
@property (strong) NSString *shiftTitle;

@end
