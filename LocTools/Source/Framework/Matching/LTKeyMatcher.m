/*!
 @header
 LTKeyMatcher.m
 Created by max on 06.06.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "LTKeyMatcher.h"


@implementation LTKeyMatcher

+ (NSString *)baseLanguageForLanguage:(NSString *)language
{
	NSCharacterSet *splitter = [NSCharacterSet characterSetWithCharactersInString: @"-_"];
	return [[language componentsSeparatedByCharactersInSet: splitter] firstObject];
}

- (id)init
{
	self = [super init];
	
	if (self != nil) {
		_matchLanguage = nil;
		_targetLanguage = nil;
		_matchingObjects = nil;
		_delegate = nil;
		_abort = NO;
		_running = NO;
	}
	
	return self;
}



#pragma mark - Accessors

@synthesize matchLanguage=_matchLanguage;
@synthesize targetLanguage=_targetLanguage;
@synthesize matchingKeyObjects=_matchingObjects;
@synthesize delegate=_delegate;

- (BOOL)isRunning
{
	return _running;
}

- (void)waitUntilFinished
{
	while (_running)
		[NSThread sleepUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.001]];
}

#pragma mark - Actions

- (void)start
{
	if (_running)
		[self stop];
	
	_running = YES;
	_abort = NO;
	[NSThread detachNewThreadSelector:@selector(matchingThread) toTarget:self withObject:nil];
}

- (void)stop
{
	_abort = YES;
	[self waitUntilFinished];
}

- (void)matchingThread
{
	[NSException raise:NSInternalInconsistencyException format:@"Started matching on abstract superclass!!"];
}



@end


