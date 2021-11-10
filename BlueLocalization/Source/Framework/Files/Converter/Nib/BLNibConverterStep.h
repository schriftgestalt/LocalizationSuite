/*!
 @header
 BLNibConverterStep.h
 Created by Max on 07.05.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLProcessStep.h>

@class BLNibFileObject;

/*!
 @abstract A step that upgrades nib files to a newer format. Currently (Leopard & Snow Leopard) this converts nib files to the new xib format, updating the database.
 */
@interface BLNibConverterStep : BLProcessStep {
	BLNibFileObject *_fileObject;
	NSString *_language;
}

/*!
 @abstract Creates a step group for upgrading all languages in the given set of objects.
 @discussion Basically, this is just a frontend for BLNibFileConverter. First all BLNibFileObject's will be filtered from objects, then the returned steps will upgrade the files for all languages in the host document.
 */
+ (NSArray *)stepGroupForUpgradingObjects:(NSArray *)objects;

@end
