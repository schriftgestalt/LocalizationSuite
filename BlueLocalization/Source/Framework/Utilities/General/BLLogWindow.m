/*!
 @header
 BLLogWindow.m
 Created by Max Seelemann on 03.09.06.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLLogWindow.h>

NSString *BLLogWindowNibName  = @"BLLogWindow";

@implementation BLLogWindow

id __sharedLogWindow;

- (id)init
{
    NSData *data;
    
    self = [super init];
    
    _cache = [[NSTextStorage alloc] init];
    _error = [NSFileHandle fileHandleWithStandardOutput];
    _readTimer = nil;
    
    if ((data = [[[BLProcessLog currentLog] readHandle] availableData]))
        [[_cache mutableString] appendString: [[[NSString alloc] initWithData:data encoding:BLProcessLogStringEncoding] autorelease]];
    [_cache setFont: [NSFont systemFontOfSize: [NSFont systemFontSizeForControlSize: NSMiniControlSize]]];
    
    __sharedLogWindow = self;
    [NSBundle loadNibNamed:BLLogWindowNibName owner:self];
    
    [_cache addLayoutManager: [textView layoutManager]];
    [_cache setFont: [NSFont systemFontOfSize: [NSFont systemFontSizeForControlSize: NSMiniControlSize]]];
    
    return self;
}

- (void)dealloc
{
    __sharedLogWindow = nil;
    
	[_readTimer invalidate];
    [_cache release];
    [window release];
    
    [super dealloc];
}

+ (id)logWindow
{
    if (!__sharedLogWindow)
        [[self alloc] init];
    
    return __sharedLogWindow;
}


#pragma mark -
#pragma mark Accessors

- (NSString *)logString
{
    return [_cache string];
}

- (NSMutableAttributedString *)displayString
{
    return _cache;
}


#pragma mark -
#pragma mark Actions

- (void)show
{
    _readTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(read:) userInfo:NULL repeats:YES];
    [window makeKeyAndOrderFront: self];
}

- (void)read:(NSTimer *)timer
{
    NSData *data;
	
    data = [[[BLProcessLog currentLog] readHandle] readDataToEndOfFile];
    if (data && [data length])
        [_cache replaceCharactersInRange:NSMakeRange([_cache length], 0) withString:[[[NSString alloc] initWithData:data encoding:BLProcessLogStringEncoding] autorelease]];
}


#pragma mark -
#pragma mark Delegates

- (void)windowWillClose:(NSNotification *)notification
{
	[_readTimer invalidate];
	_readTimer = nil;
}

@end
