/*!
 @header
 BLInterpretationStep.h
 Created by Max on 27.04.09.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLProcessStep.h>

@class BLFileObject;

/*!
 @abstract The key for the parameter setting which defines the ignored placeholder strings.
 @discussion The value will be passed on to BLFileInterpreter's ignoredPlaceholderStrings property.
 */
extern NSString *BLInterpretationStepIgnoredPlaceholderStringsKey;

/*!
 @abstract Internal step class for performing a single interpretation.
 @discussion Do not use directly, use BLInterpreterStep instead!
 */
@interface BLInterpretationStep : BLProcessStep

/*!
 @abstract Initializes a new step for interpretation.
 */
- (id)initForInterpretingFile:(NSString *)path toObject:(BLFileObject *)object withLanguage:(NSString *)language andOptions:(NSUInteger)options parameters:(NSDictionary *)parameters;

@end
