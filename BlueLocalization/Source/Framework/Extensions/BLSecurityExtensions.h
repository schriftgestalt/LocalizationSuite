/*!
 @header
 BLSecurityExtensions.h
 Created by Max on 11.12.05.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

// These methodes simply catch nil and print an error

@interface NSArray (BLSecurityExtensions)

+ (id)secureArrayWithObject:(id)anObject;

@end

@interface NSMutableArray (BLSecurityExtensions)

- (void)secureAddObject:(id)anObject;

@end

@interface NSMutableDictionary (BLSecurityExtensions)

- (void)secureSetObject:(id)anObject forKey:(id)aKey;

@end

@interface NSUserDefaults (BLSecurityExtensions)

- (void)secureSetObject:(id)anObject forKey:(id)aKey;

@end

@interface NSDictionary (BLSecurityExtensions)

- (BOOL)secureWriteToFile:(NSString *)path atomically:(BOOL)flag;

@end