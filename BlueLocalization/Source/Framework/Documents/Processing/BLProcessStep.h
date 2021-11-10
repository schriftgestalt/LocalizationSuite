/*!
 @header
 BLProcessStep.h
 Created by Max on 27.04.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

@class BLProcessManager;

/*!
 @abstract The basic atomic unit of processing in an localization document.
 @discussion This is an subclass of NSOperation, which is always concurrent and handles all operation stuff. Subclasses normally only need to override the -perfrom and -description methods.
 */
@interface BLProcessStep : NSOperation

/*!
 @abstract The process manager the operation is performed by.
 */
@property (unsafe_unretained) BLProcessManager *manager;

/*!
 @abstract Perform the desired action.
 @discussion Has to be overridden, default implementation just throws. A call to this method is always encapsulated by a separate NSAutoreleasePool, so no custom memory needs to be performed in most cases.
 */
- (void)perform;

/*!
 @abstract Returns a user-presentable general action description of the step.
 @discussion Will be shown to the user once the step has started processing.
 */
@property (nonatomic, copy) NSString *action;

/*!
 @abstract Returns a user-presentable description of the step.
 @discussion Will be shown to the user once the step has started processing.
 */
@property (nonatomic, copy) NSString *description;

/*!
 @abstract Designated override point to update the steps description if needed.
 */
- (void)updateDescription;

@end
