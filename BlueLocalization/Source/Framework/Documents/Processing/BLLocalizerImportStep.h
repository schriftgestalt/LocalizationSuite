/*!
 @header
 BLLocalizerImportStep.h
 Created by Max on 09.05.09.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLProcessStep.h>

/*!
 @enum BLLocalizerImportStep options
 
 @const BLLocalizerImportStepChangesOnlyOption		If set, only key objects that have been markes as changed will be considered.
 @const BLLocalizerImportStepMissingOnlyOption		If set, only keys that are missing in the document will be imported.
 @const BLLocalizerImportStepMatchKeysByValueOption	If set, key objects will be matched by their values of the reference language and not by keys
 */
enum {
	BLLocalizerImportStepChangesOnlyOption		= 1<<0,
	BLLocalizerImportStepMissingOnlyOption		= 1<<1,
	BLLocalizerImportStepMatchKeysByValueOption	= 1<<2
};

/*!
 @abstract A step that imports Localizer files to a document.
 */
@interface BLLocalizerImportStep : BLProcessStep
{
	NSArray		*_languages;
	NSUInteger	_options;
	NSString	*_path;
}

/*!
 @abstract Creates a step group for importing localized values from a set of Localizer files.
 @discussion The options are BLLocalizerImportStep options, combined by logical or (|). The given paths are not checked whether the files actually are 
 */
+ (NSArray *)stepGroupForImportingLocalizerFiles:(NSArray *)filenames withOptions:(NSUInteger)options;

@end
