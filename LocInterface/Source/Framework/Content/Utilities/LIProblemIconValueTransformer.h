/*!
 @header
 LIProblemIconValueTransformer.h
 Created by max on 30.08.09.

 @copyright 2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract The name the LIProblemIconValueTransformer is registered to. Currently @"LIProblemIcon".
 */
extern NSString *LIProblemIconValueTransformerName;

/*!
 @abstract A value transformer that returns an image according to a translation problem type (LTTranslationProblemType).
 @discussion Currently this is a LIError image for LTTranslationProblemError and a LIWarning image forLTTranslationProblemWarning.
 */
@interface LIProblemIconValueTransformer : NSValueTransformer

@end
