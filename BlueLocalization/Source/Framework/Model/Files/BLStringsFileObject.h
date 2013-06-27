/*!
 @header
 BLStringsFileObject.h
 Created by Max on 27.10.04.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLFileObject.h>

@interface BLStringsFileObject : BLFileObject
{
    BOOL _isPlistFile;
}

@property(assign) BOOL isPlistStringsFile;

@end
