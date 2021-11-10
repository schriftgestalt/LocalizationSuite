/*!
 @header
 BLNibFileConverter.h
 Created by Max Seelemann on 29.10.08.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

@class BLNibFileObject, BLDocumentProtocol;

@interface BLNibFileConverter : NSObject {
}

+ (BOOL)upgradeFileForObject:(BLNibFileObject *)object fromDocument:(NSDocument<BLDocumentProtocol> *)document withLanguages:(NSArray *)languages;
+ (BOOL)upgradeFileForObject:(BLNibFileObject *)object fromDocument:(NSDocument<BLDocumentProtocol> *)document withLanguage:(NSString *)language;

@end
