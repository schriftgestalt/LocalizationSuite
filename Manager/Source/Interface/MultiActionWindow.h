//
//  MultiActionWindow.h
//  Localization Manager
//
//  Created by max on 09.09.09.
//  Copyright 2009 Localization Foundation. All rights reserved.
//

@interface MultiActionWindow : NSWindow {
	NSMutableArray *_flagResponders;
}

/*!
 @abstract Registered responders will receive all flags changed events.
 */
- (void)registerResponderForFlagsChangedEvents:(id)responder;
- (void)deregisterResponderForFlagsChangedEvents:(id)responder;

@end
