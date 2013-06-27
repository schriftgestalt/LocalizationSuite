/*!
 @header
 BLStringsFileObject.m
 Created by Max on 27.10.04.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLStringsFileObject.h"

#import "BLFileInternal.h"
#import "BLStringKeyObject.h"

@implementation BLStringsFileObject

+ (void)load
{
	[super registerClass:self forPathExtension:@"strings"];
}

+ (Class)classOfStoredKeys
{
    return [BLStringKeyObject class];
}

#pragma mark - Initializers

- (id)init
{
    self = [super init];
    
    _isPlistFile = NO;
    
    return self;
}


#pragma mark - Serialization

- (id)initWithPropertyList:(NSDictionary *)plist
{
    self = [super initWithPropertyList: plist];
    
    [self setIsPlistStringsFile: [[plist objectForKey: BLFileIsPlistFileKey] boolValue]];
    
    return self;
}

- (NSDictionary *)propertyListWithAttributes:(NSDictionary *)attributes
{
    NSMutableDictionary *dict;
    
    dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithBool: [self isPlistStringsFile]], BLFileIsPlistFileKey, nil];
    [dict addEntriesFromDictionary: [super propertyListWithAttributes: attributes]];
        
    return dict;
}


#pragma mark - Accessors

- (BOOL)isPlistStringsFile
{
    return _isPlistFile;
}

- (void)setIsPlistStringsFile:(BOOL)flag
{
    _isPlistFile = flag;
}

- (NSString *)fileFormatInfo
{
    return NSLocalizedStringFromTableInBundle(([self isPlistStringsFile]) ? @"BLStringFileObjectFileFormatXML" : @"BLStringFileObjectFileFormatClassic", @"Localizable", [NSBundle bundleForClass: [self class]], nil);
}

@end


