/*!
 @header
 BLProcessManager.m
 Created by Max on 27.04.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLProcessManager.h"

#import "BLProcessStep.h"

/*!
 @abstract Internal methods of BLProcessManager.
 */
@interface BLProcessManager ()

/*!
 @abstract Dequeue the first group of BLProcessSteps from the queue.
 @discussion This is thread-safe.
 */
- (NSArray *)dequeueStepGroup;

/*!
 @abstract Dequeues the next group and performs it. Stopps if nothing left.
 */
- (void)runNextStepGroup;

@property (readwrite) NSUInteger steps;
@property (readwrite) NSUInteger completedSteps;
@property (readwrite, getter=isRunning) BOOL running;
@property (strong, readwrite) BLProcessStep *currentStep;

@end

@implementation BLProcessManager

- (id)initWithDocument:(NSDocument<BLDocumentProtocol> *)document {
	self = [super init];

	if (self != nil) {
		_currentStep = nil;
		_document = document;
		_groups = [[NSMutableArray alloc] init];
		_queue = [NSOperationQueue mainQueue];
		//		_queue.maxConcurrentOperationCount = 1;
		_steps = 0;
		_stepsCompleted = 0;

		//		[_queue setMaxConcurrentOperationCount: 1];
		[_queue setMaxConcurrentOperationCount:[NSProcessInfo processInfo].processorCount];
		[_queue addObserver:self forKeyPath:@"operations" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
	}

	return self;
}

- (void)dealloc {
	[_queue removeObserver:self forKeyPath:@"operations"];
}

#pragma mark - Accessors

- (NSDocument<BLDocumentProtocol> *)document {
	if (!_document)
		[[NSException exceptionWithName:NSInternalInconsistencyException reason:@"No document was set before calling -document!" userInfo:nil] raise];

	return _document;
}

- (void)setDocument:(NSDocument<BLDocumentProtocol> *)aDocument {
	_document = aDocument;
}

#pragma mark - Run controls

- (void)start {
	[self startWithName:@"Processing..."];
}

- (void)startWithName:(NSString *)name {
	if ([self isRunning])
		return;

	[[BLProcessLog sharedLog] openRootGroup:name];

	self.running = YES;
	[self runNextStepGroup];
}

- (void)stop {
	if ([self isRunning])
		[[BLProcessLog sharedLog] closeRootGroup];

	[_queue cancelAllOperations];
	self.running = NO;

	_steps = 0;
	_stepsCompleted = 0;
}

@synthesize running = _running;

- (void)runNextStepGroup {
	NSArray *group;

	// Add the next group
	group = [self dequeueStepGroup];

	// Terminate if finished (nothing to be added)
	if ([group count] == 0) {
		dispatch_async(dispatch_get_main_queue(), ^{ [self stop]; });
	}
	else {
		for (BLProcessStep *step in group) {
			[_queue addOperation:step];
		}
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	// Update displayed Operation
	NSArray *allOperations = [_queue operations];
	NSArray *executingOperations = [allOperations objectsContainingValue:@YES forKeyPath:@"isExecuting"];
	BLProcessStep *currentStep = nil;

	if ([executingOperations count])
		currentStep = [executingOperations objectAtIndex:0];
	else if ([allOperations count])
		currentStep = [allOperations objectAtIndex:0];
	if ([currentStep respondsToSelector:@selector(action)]) {
		dispatch_async(dispatch_get_main_queue(), ^{ self.currentStep = currentStep; });
	}
	// Update the UI
	NSMutableArray *stepsDone = [NSMutableArray arrayWithArray:[change valueForKey:NSKeyValueChangeOldKey]];
	[stepsDone removeObjectsInArray:[change valueForKey:NSKeyValueChangeNewKey]];
	if ([stepsDone count])
		dispatch_async(dispatch_get_main_queue(), ^{ self.completedSteps += [stepsDone count]; });

	// Enqueue new operations if possible
	if ([allOperations count] == 0)
		[self runNextStepGroup];
}

#pragma mark -

@synthesize steps = _steps;
@synthesize completedSteps = _stepsCompleted;
@synthesize currentStep = _currentStep;

#pragma mark - Queue management

- (NSArray *)dequeueStepGroup {
	NSArray *group = nil;

	@synchronized(_groups) {
		if ([_groups count]) {
			group = [_groups objectAtIndex:0];
			[_groups removeObjectAtIndex:0];
		}
	}

	return group;
}

- (void)enqueueStep:(BLProcessStep *)step {
	[self enqueueStepGroup:[NSArray arrayWithObject:step]];
}

- (void)enqueueStepAtFront:(BLProcessStep *)step {
	[self enqueueStepGroup:[NSArray arrayWithObject:step] afterGroup:[NSNull null]];
}

- (void)enqueueStepGroup:(NSArray *)steps {
	[self enqueueStepGroup:steps afterGroup:nil];
}

- (void)enqueueStepGroup:(NSArray *)steps afterGroup:(id)other {
	[steps makeObjectsPerformSelector:@selector(setManager:) withObject:self];

	@synchronized(_groups) {
		if (!other)
			[_groups addObject:steps];
		else if ([other isKindOfClass:[NSNull class]])
			[_groups insertObject:steps atIndex:0];
		else
			[_groups insertObject:steps atIndex:[_groups indexOfObject:other] + 1];
	}

	dispatch_async(dispatch_get_main_queue(), ^{ self.steps += [steps count]; });
}

@end
