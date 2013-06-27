/*!
 @header
 BLGenericProcessStep.h
 Created by Max on 09.05.09.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLProcessStep.h>

typedef void (^BLGenericBlock)(void);

/*!
 @abstract A very simple generic step performaing a NSInvocation on an object on main thread, blocking until it is done.
 @discussion This step just display a action "Processing" and no detail description. However, you have the ability to customize this display to your needs.
 */
@interface BLGenericProcessStep : BLProcessStep
{
	BLGenericBlock	_block;
}

/*!
 @abstract Creates a new generic process step.
 */
+ (id)genericStepWithBlock:(BLGenericBlock)block;

@end
