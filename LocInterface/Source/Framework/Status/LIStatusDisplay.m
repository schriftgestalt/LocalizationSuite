//
//  LIStatusDisplay.m
//  LocInterface
//
//  Created by max on 18.11.09.
//  Copyright 2009 Localization Suite. All rights reserved.
//

#import "LIStatusDisplay.h"

NSString *LIStatusDisplayNibName = @"LIStatusDisplay";

NSString *LIStatusDisplayVisibilityPreferencesKey = @"LIStatusDisplayVsibility";
NSString *LIStatusDisplayVisibilityInfoKey = @"info";
NSString *LIStatusDisplayVisibilityCountersKey = @"counters";
NSString *LIStatusDisplayVisibilityStatisticsKey = @"statistics";

/*!
 @abstract Internal interface of LIStatusDisplay.
 */
@interface LIStatusDisplay ()

@property (nonatomic, readwrite, assign) BOOL isCalculatingStatistics;
@property (nonatomic, readwrite, assign) NSUInteger statisticsCalculationProgress;

/*!
 @abstract Notification when statistics calculation is finished.
 */
- (void)statisticsCalculationFinished:(NSDictionary *)newStatistics;

/*!
 @abstract Loads the panel and initializes the interface.
 */
- (void)loadPanel;

@end

@implementation LIStatusDisplay

id __sharedStatusDisplay;

- (id)init {
	self = [super init];

	_calculating = NO;
	_calculationProgress = 0;
	_currentResponder = nil;
	_counters = nil;
	_statistics = nil;
	_selectionInfo = nil;
	_visibility = [[NSMutableDictionary alloc] init];

	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	__sharedStatusDisplay = nil;
}

+ (id)statusDisplay {
	if (!__sharedStatusDisplay)
		__sharedStatusDisplay = [[self alloc] init];

	return __sharedStatusDisplay;
}

#pragma mark - Languages

- (NSString *)firstLanguage {
	NSArray *languages = nil;
	if ([_currentResponder respondsToSelector:@selector(currentLanguages)])
		languages = [_currentResponder currentLanguages];
	if ([languages count] > 0)
		return [languages objectAtIndex:0];
	else
		return nil;
}

+ (NSSet *)keyPathsForValuesAffectingFirstLanguage {
	return [NSSet setWithObject:@"currentResponder"];
}

- (NSString *)secondLanguage {
	NSArray *languages = nil;
	if ([_currentResponder respondsToSelector:@selector(currentLanguages)])
		languages = [_currentResponder currentLanguages];
	if ([languages count] > 1)
		return [languages objectAtIndex:1];
	else
		return nil;
}

+ (NSSet *)keyPathsForValuesAffectingSecondLanguage {
	return [NSSet setWithObject:@"currentResponder"];
}

#pragma mark - Selection Info

@synthesize selectionInfo = _selectionInfo;

- (void)updateSelectionInfo {

	// Get the objects
	NSArray *objects = nil;
	if ([_currentResponder respondsToSelector:@selector(currentObjects)])
		objects = [_currentResponder currentObjects];
	if (!objects) {
		_selectionInfo = nil;
		return;
	}

	// Count
	NSUInteger bundles = 0;
	NSUInteger files = 0;
	NSUInteger keys = 0;

	for (BLObject *object in objects) {
		if ([object isKindOfClass:[BLBundleObject class]])
			bundles++;
	}

	files = [[BLObject fileObjectsFromArray:objects] count];
	keys = [BLObject numberOfKeysInObjects:objects];

	// Create info
	_selectionInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
					  @(bundles), @"bundles",
					  @(files), @"files",
					  @(keys), @"keys", nil];
}

+ (NSSet *)keyPathsForValuesAffectingSelectionInfo {
	return [NSSet setWithObject:@"currentResponder"];
}

#pragma mark - Counters

@synthesize counters = _counters;

+ (NSSet *)keyPathsForValuesAffectingCounters {
	return [NSSet setWithObjects:@"currentResponder", @"firstLanguage", @"secondLanguage", nil];
}

- (void)updateCounters {
	NSMutableDictionary *newCounters = [NSMutableDictionary dictionary];
	NSString *language;

	// Get the objects
	NSArray *objects = nil;
	if ([_currentResponder respondsToSelector:@selector(currentObjects)])
		objects = [_currentResponder currentObjects];
	if (!objects)
		return;

	// First statistic
	if ((language = self.firstLanguage)) {
		NSDictionary *counter = [[NSDictionary alloc] initWithObjectsAndKeys:
								 @([BLObject countForStatistic:BLObjectStatisticsSentences forLanguage:language inObjects:objects]), @"sentences",
								 @([BLObject countForStatistic:BLObjectStatisticsWords forLanguage:language inObjects:objects]), @"words",
								 @([BLObject countForStatistic:BLObjectStatisticsCharacters forLanguage:language inObjects:objects]), @"characters",
								 nil];
		[newCounters setObject:counter forKey:@"first"];
	}

	// Second statistic
	if ((language = self.secondLanguage)) {
		NSDictionary *counter = [[NSDictionary alloc] initWithObjectsAndKeys:
								 @([BLObject countForStatistic:BLObjectStatisticsSentences forLanguage:language inObjects:objects]), @"sentences",
								 @([BLObject countForStatistic:BLObjectStatisticsWords forLanguage:language inObjects:objects]), @"words",
								 @([BLObject countForStatistic:BLObjectStatisticsCharacters forLanguage:language inObjects:objects]), @"characters",
								 nil];
		[newCounters setObject:counter forKey:@"second"];
	}

	// Update counters
	_counters = newCounters;
}

#pragma mark - Statistics

@synthesize statistics = _statistics;
@synthesize isCalculatingStatistics = _calculating;
@synthesize statisticsCalculationProgress = _calculationProgress;

- (void)updateStatistics {
	// Abort any calculation
	_abortCalculation = YES;

	// Update state
	[self willChangeValueForKey:@"statistics"];
	_statistics = nil;
	[self didChangeValueForKey:@"statistics"];
}

- (IBAction)calculateStatistics:(id)sender {
	// Check languages
	if (!self.firstLanguage || !self.secondLanguage) {
		[self statisticsCalculationFinished:nil];
		return;
	}

	// Start calculation
	self.statisticsCalculationProgress = 0;
	self.isCalculatingStatistics = YES;
	_abortCalculation = NO;

	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
											  [_currentResponder currentObjects], @"objects",
											  self.firstLanguage, @"sourceLanguage",
											  self.secondLanguage, @"targetLanguage", nil];
	[NSThread detachNewThreadSelector:@selector(calculateStatisticsThread:) toTarget:self withObject:options];
}

- (void)statisticsCalculationFinished:(NSDictionary *)newStatistics {
	// Update state
	[self willChangeValueForKey:@"statistics"];
	_statistics = newStatistics;
	[self didChangeValueForKey:@"statistics"];

	self.isCalculatingStatistics = NO;
	self.statisticsCalculationProgress = 0;
}

- (void)calculateStatisticsThread:(NSDictionary *)options {
	@autoreleasepool {
		// Init new statistics
		NSMutableDictionary *newStats = [NSMutableDictionary dictionary];
		[newStats setObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
							 @0, @"translated",
							 @0, @"exact",
							 @0, @"above75",
							 @0, @"above50",
							 @0, @"noMatch",
							 nil]
					 forKey:@"keys"];
		[newStats setObject:[NSMutableDictionary dictionaryWithDictionary:[newStats objectForKey:@"keys"]] forKey:@"words"];

		// Get objects
		NSArray *objects = [options objectForKey:@"objects"];
		objects = [objects objectsContainingValue:@YES forKeyPath:@"isActive"];
		objects = [BLObject keyObjectsFromArray:objects];
		objects = [objects objectsContainingValue:@YES forKeyPath:@"isActive"];

		NSString *sourceLang = [options objectForKey:@"sourceLanguage"];
		NSString *targetLang = [options objectForKey:@"targetLanguage"];

		// Create the collector
		LTKeyMatchCollector *collector = [LTKeyMatchCollector collector];

		// Set up matching engine
		LTSingleKeyMatcher *matcher = [[LTSingleKeyMatcher alloc] init];
		matcher.matchLanguage = sourceLang;
		matcher.targetLanguage = targetLang;
		matcher.matchingKeyObjects = [[BLDictionaryController sharedInstance] availableKeys];
		matcher.guessingIsEnabled = YES;
		matcher.delegate = collector;

		// Process
		NSUInteger done = 0;
		for (BLKeyObject *keyObject in objects) {
			@autoreleasepool {
				NSString *statKey = nil;

				// Already translated objects
				if (![keyObject isEmptyForLanguage:targetLang]) {
					statKey = @"translated";
				}
				// Missing translation
				else {
					// Find matching keys
					matcher.targetKeyObject = keyObject;
					[matcher start];
					[matcher waitUntilFinished];

					// Find the match percentage
					CGFloat matchPct = 0.0;
					for (LTKeyMatch *match in [collector matches])
						matchPct = fmax(matchPct, [match matchPercentage]);
					if (matchPct == 1.0)
						statKey = @"exact";
					else if (matchPct >= 0.75)
						statKey = @"above75";
					else if (matchPct >= 0.5)
						statKey = @"above50";
					else
						statKey = @"noMatch";

					// Reset the collector
					[collector reset];
				}

				// Update keys
				NSNumber *keyCount = [[newStats objectForKey:@"keys"] objectForKey:statKey];
				keyCount = @([keyCount intValue] + 1);
				[[newStats objectForKey:@"keys"] setObject:keyCount forKey:statKey];

				// Update Words
				NSUInteger words = [keyObject countForStatistic:BLObjectStatisticsWords forLanguage:sourceLang];

				NSNumber *wordCount = [[newStats objectForKey:@"words"] objectForKey:statKey];
				wordCount = @([wordCount intValue] + words);
				[[newStats objectForKey:@"words"] setObject:wordCount forKey:statKey];

				// Update status
				if (done % 10 == 0) {
					NSUInteger progess = (done * 100) / [objects count];
					[self performSelectorOnMainThread:@selector(statsCalculationProgress:) withObject:@(progess) waitUntilDone:NO];
				}

				done++;
			}

			if (_abortCalculation)
				break;
		}

		// Finished
		[self performSelectorOnMainThread:@selector(statisticsCalculationFinished:)
							   withObject:(_abortCalculation) ? nil : newStats
							waitUntilDone:NO];
	}
}

- (void)statsCalculationProgress:(NSNumber *)number {
	self.statisticsCalculationProgress = [number intValue];
}

#pragma mark - Interface

- (void)loadPanel {
	// Load Prefs
	NSMutableDictionary *visi = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:LIStatusDisplayVisibilityPreferencesKey]];

	if (![visi objectForKey:LIStatusDisplayVisibilityInfoKey])
		[visi setObject:@YES forKey:LIStatusDisplayVisibilityInfoKey];
	if (![visi objectForKey:LIStatusDisplayVisibilityCountersKey])
		[visi setObject:@YES forKey:LIStatusDisplayVisibilityCountersKey];
	if (![visi objectForKey:LIStatusDisplayVisibilityStatisticsKey])
		[visi setObject:@NO forKey:LIStatusDisplayVisibilityStatisticsKey];

	self.visibility = visi;

	// Load Panel
	[NSBundle loadNibNamed:LIStatusDisplayNibName owner:self];
}

@synthesize visibility = _visibility;

- (void)setVisibility:(NSDictionary *)newVisibility {
	[_visibility setDictionary:newVisibility];
}

#pragma mark - Actions, Delegates

- (void)show {
	if (!panel)
		[self loadPanel];

	// Closing
	if ([panel isKeyWindow]) {
		[panel close];
		return;
	}

	// Opening
	if (![panel isVisible]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidBecomeMain:) name:NSWindowDidBecomeMainNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowDidResignMain:) name:NSWindowDidResignMainNotification object:nil];

		[[NSApp mainWindow] addObserver:self forKeyPath:@"firstResponder" options:NSKeyValueObservingOptionInitial context:@"firstResponder"];
	}

	// Bring to front
	[panel makeKeyAndOrderFront:self];
}

- (void)windowWillClose:(NSNotification *)notification {
	// Can only be statistics window
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidBecomeMainNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResignMainNotification object:nil];
	[[NSApp mainWindow] removeObserver:self forKeyPath:@"firstResponder"];

	// Save visibility
	[[NSUserDefaults standardUserDefaults] setObject:_visibility forKey:LIStatusDisplayVisibilityPreferencesKey];
}

- (void)windowDidBecomeMain:(NSNotification *)notification {
	[[notification object] addObserver:self forKeyPath:@"firstResponder" options:NSKeyValueObservingOptionInitial context:@"firstResponder"];
}

- (void)windowDidResignMain:(NSNotification *)notification {
	[[notification object] removeObserver:self forKeyPath:@"firstResponder"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == @"firstResponder") {
		// Find the new current responder
		id responder = [object firstResponder];
		while (responder && ![responder conformsToProtocol:@protocol(LIStatusObjects)])
			responder = [responder nextResponder];

		// Begin notify
		[self willChangeValueForKey:@"currentResponder"];

		// Forget old responder
		[_currentResponder removeObserver:self forKeyPath:@"currentObjects"];

		// Update responder
		_currentResponder = responder;
		[_currentResponder addObserver:self forKeyPath:@"currentObjects" options:0 context:@"currentObjects"];

		// Update counters
		[self updateSelectionInfo];
		[self updateCounters];
		[self updateStatistics];

		// End notify
		[self didChangeValueForKey:@"currentResponder"];
	}
	else if (context == @"currentObjects") {
		// Just update statistics
		[self willChangeValueForKey:@"currentResponder"];
		[self updateSelectionInfo];
		[self updateCounters];
		[self updateStatistics];
		[self didChangeValueForKey:@"currentResponder"];
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

@end

@implementation NSTableView (LIStatusObjects)

- (void)updateCurrentObjects {
	[self willChangeValueForKey:@"currentObjects"];
	[self didChangeValueForKey:@"currentObjects"];
}

- (NSArray *)currentObjects {
	if ([[self delegate] respondsToSelector:@selector(currentObjectsInTableView:)])
		return [(id)[self delegate] currentObjectsInTableView:self];
	else
		return nil;
}

- (NSArray *)currentLanguages {
	if ([[self delegate] respondsToSelector:@selector(currentLanguagesInTableView:)])
		return [(id)[self delegate] currentLanguagesInTableView:self];
	else
		return nil;
}

@end
