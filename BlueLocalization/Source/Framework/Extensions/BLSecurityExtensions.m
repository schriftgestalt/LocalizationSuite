/*!
 @header
 BLSecurityExtensions.m
 Created by Max on 11.12.05.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLSecurityExtensions.h"

@implementation NSArray (BLSecurityExtensions)

+ (id)secureArrayWithObject:(id)anObject {
	if (anObject != nil)
		return [self arrayWithObject:anObject];
	else
		return [NSArray array];
}

@end

@implementation NSMutableArray (BLSecurityExtensions)

- (void)secureAddObject:(id)anObject {
	if (anObject != nil) {
		[self addObject:anObject];
	}
	else {
		// NSLog(@"Error caught: tried to add \"%@\"", anObject);
	}
}

@end

@implementation NSMutableDictionary (BLSecurityExtensions)

- (void)secureSetObject:(id)anObject forKey:(id)aKey {
	if (anObject != nil && aKey != nil) {
		[self setObject:anObject forKey:aKey];
	}
	else
		NSLog(@"Error caught: tried to set \"%@\" for key \"%@\"", anObject, aKey);
}

@end

@implementation NSUserDefaults (BLSecurityExtensions)

- (void)secureSetObject:(id)anObject forKey:(id)aKey {
	if (anObject != nil && aKey != nil)
		[self setObject:anObject forKey:aKey];
	else
		NSLog(@"Error caught: tried to set \"%@\" for key \"%@\"", anObject, aKey);
}

@end

@implementation NSDictionary (BLSecurityExtensions)

- (BOOL)secureWriteToFile:(NSString *)path atomically:(BOOL)flag {
	if ([[NSFileManager defaultManager] fileExistsAtPath:[path stringByDeletingLastPathComponent]] && self != nil)
		return [self writeToFile:path atomically:flag];
	else
		return YES;
}

@end
