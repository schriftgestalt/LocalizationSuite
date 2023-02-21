//
//  GSSplitViewWindowController.h
//  GlyphsKit
//
//  Created by Georg Seifert on 01.01.22.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface GSSplitViewWindowController : NSWindowController

@property (strong) NSSplitViewController *splitViewController;
@property (weak) IBOutlet NSView *sidebarView;
@property (weak) IBOutlet NSView *contentView;

@end

NS_ASSUME_NONNULL_END
