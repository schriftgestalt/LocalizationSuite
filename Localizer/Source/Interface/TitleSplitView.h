//
//  TitleSplitView.h
//  Localizer
//
//  Created by Max Seelemann on 07.10.07.
//  Copyright 2007 The Blue Technologies Group. All rights reserved.
//

#import <RBSplitView/RBSplitView.h>

@interface TitleSplitView : RBSplitView
{
}

@end

@interface NSObject (TitleSplitViewDelegate)

- (NSString *)splitView:(TitleSplitView *)splitView userInfoForSubviewWithIdentifier:(NSString *)identifier;

@end