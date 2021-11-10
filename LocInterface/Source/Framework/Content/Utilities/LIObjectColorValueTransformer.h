/*!
 @header
 LIObjectColorValueTransformer.h
 Created by max on 09.05.09.

 @copyright 2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract The name the LIObjectColorValueTransformer is registered to. Currently @"LIObjectColor".
 */
extern NSString *LIObjectColorValueTransformerName;

/*!
 @abstract A value transformer that returns a color for a file object according to its state.
 @discussion Currently if the object contains any errors, the returned color is red. BLBundleObjects without errors are a shade of gray. Otherwise, also if the object is no BLKeyObject, the returned color is black. This transformer will automatically register itself for the name LIObjectColorValueTransformerName;
 */
@interface LIObjectColorValueTransformer : NSValueTransformer {
}

@end
