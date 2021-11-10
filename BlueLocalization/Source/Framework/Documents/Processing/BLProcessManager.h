/*!
 @header
 BLProcessManager.h
 Created by Max on 27.04.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

@class BLProcessStep;

/*!
 @abstract Manages all long duration processings.
 @discussion Basically this is a wrapper around a processing queue for BLProcessStep objects.
 */
@interface BLProcessManager : NSObject {
	BLProcessStep *_currentStep;
	NSDocument<BLDocumentProtocol> *_document;
	NSMutableArray *_groups;
	BOOL _running;
	NSOperationQueue *_queue;
	NSUInteger _steps;
	NSUInteger _stepsCompleted;
}

/*!
 @abstract Designated initializer.
 */
- (id)initWithDocument:(NSDocument<BLDocumentProtocol> *)document;

/*!
 @abstract Returns the document the process manager belongs to.
 @discussion Due to the importance of this method to most steps, this one throws if no document has been set beforehand!
 */
@property (weak) NSDocument<BLDocumentProtocol> *document;

/*!
 @abstract Start the processing queue.
 @discussion The queue is automatically stopped when all actions have been processed. Resets the number of performed and pending steps.
 */
- (void)start;

/*!
 @abstract Start the processing queue.
 @discussion This is the same as -start, but in addition it allows you to speciffy a name for the process log item.
 */
- (void)startWithName:(NSString *)name;

/*!
 @abstract Stop the processing queue immediatelly.
 @discussion Running operations might be finsihed, however no pending operations will be started. This also clears the queue.
 */
- (void)stop;

/*!
 @abstract Returns whether the queue is currently running.
 */
@property (readonly, getter=isRunning) BOOL running;

/*!
 @abstract Enqueues a new step.
 @discussion This method is thread-safe, as it just forwards to enqueueStepGroup:!
 */
- (void)enqueueStep:(BLProcessStep *)step;

/*!
 @abstract Enqueues a new step.
 @discussion This method is thread-safe, as it just forwards to enqueueStepGroup:afterGroup:, passing NSNull for the other group!
 */
- (void)enqueueStepAtFront:(BLProcessStep *)step;

/*!
 @abstract Enqueues a new group steps.
 @discussion Convenience for -enqueueStepGroup:afterGroup:, passing nil als the other group.
 */
- (void)enqueueStepGroup:(NSArray *)steps;

/*!
 @abstract Enqueues a new group steps.
 @discussion The steps must be independent, concurrent and thread-safe. They might and probably will be executed in parallel. However, groups are performed in the order they were added and are not concurrent. Steps in groups may also add new groups as the they are being performed!
 This method is thread-safe!
 The step will be enqued after the group that has been passed to "other". Requires the caller to know that group already. Passing nil will enqueue the group at the end. Passing an NSNull object will enque it at the front -- the group will then be executed before all other enqueued groups.
 */
- (void)enqueueStepGroup:(NSArray *)steps afterGroup:(id)other;

/*!
 @abstract Returns the number of steps in the current run.
 @discussion Updates only happen on the main thread so it's save to bind to this property for interface updates.
 */
@property (readonly) NSUInteger steps;

/*!
 @abstract Returns the number of steps completed in the current run.
 @discussion Updates only happen on the main thread so it's save to bind to this property for interface updates.
 */
@property (readonly) NSUInteger completedSteps;

/*!
 @abstract Returns any of the currently running steps.
 @discussion Can be used to display some interface status information or likewise.
 */
@property (strong, readonly) BLProcessStep *currentStep;

@end
