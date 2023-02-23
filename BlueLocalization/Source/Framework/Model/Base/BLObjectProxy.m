/*!
 @header
 BLObjectProxy.m
 Created by Max Seelemann on 07.05.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLObjectProxy.h"

#include <objc/runtime.h>
#include <sys/time.h>
#include <time.h>

/*!
 @abstract Internal methods of BLFileObjectProxy.
 */
@interface BLObjectProxy (BLObjectProxyInternal)

- (void)_init;

- (BLObject *)_object;
- (void)_setObject:(BLObject *)object;

- (id)_unmaskObject:(id)object;
- (id)_maskObject:(id)object;

@end

@implementation BLObjectProxy

+ (id)proxyWithObject:(BLObject *)object {
	BLObjectProxy *proxy;

	if (!object)
		return nil;
	if (![object isKindOfClass:[BLObject class]])
		[[NSException exceptionWithName:NSInvalidArgumentException reason:@"Object must be a subclass of BLObject" userInfo:nil] raise];

	proxy = [self alloc];
	[proxy _setObject:object];

	return proxy;
}

#pragma mark - Actions

- (Class)class
{
	return [_object class];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@ %p>[%@]", NSStringFromClass(object_getClass(self)), self, NSStringFromClass([_object class])];
}

- (BLObject *)_object {
	return _object;
}

- (id)_original {
	return _object;
}

- (void)_setObject:(BLObject *)object {
	_object = object;
	_class = [object class];
}

- (id)_unmaskObject:(id)object {
	if ([object_getClass(object) isSubclassOfClass:[NSArray class]]) {
		NSMutableArray *unmaskedArray = [NSMutableArray arrayWithCapacity:[object count]];

		for (id item in object)
			[unmaskedArray addObject:[self _unmaskObject:item]];

		return unmaskedArray;
	}

	if (object_getClass(object) == [BLObjectProxy class])
		return [object _object];

	return object;
}

- (id)_maskObject:(id)object {
	if ([object_getClass(object) isSubclassOfClass:[NSArray class]]) {
		NSMutableArray *maskedArray = [NSMutableArray arrayWithCapacity:[object count]];

		for (id item in [object copy])
			[maskedArray addObject:[self _maskObject:item]];

		return maskedArray;
	}

	if (object_getClass(object) == [BLObjectProxy class])
		return object;
	if (![object_getClass(object) isSubclassOfClass:[BLObject class]])
		return object;

	if (!_cache) {
		_cache = [NSMapTable weakToWeakObjectsMapTable];
	}
	id proxy = [_cache objectForKey:object];
	if (!proxy) {
		proxy = [BLObjectProxy proxyWithObject:object];
		[_cache setObject:proxy forKey:object];
	}

	return proxy;
}

#pragma mark - Forwarding

- (void)forwardInvocation:(NSInvocation *)invocation {
	NSMethodSignature *signature;
	__unsafe_unretained id arg;
	const char *type;

	signature = [invocation methodSignature];

	// Preprocess Arguments, replacing proxies by real objects
	for (NSUInteger i = 2; i < [signature numberOfArguments]; i++) {
		// Filter object arguments
		type = [signature getArgumentTypeAtIndex:i];
		if (strcmp(type, @encode(id)) != 0)
			continue;

		[invocation getArgument:(void *)&arg atIndex:i];
		arg = [self _unmaskObject:arg];
		[invocation setArgument:&arg atIndex:i];
	}

	[invocation retainArguments];

	if (NSThread.isMainThread) {
		[invocation invokeWithTarget:_object];
	}
	else {
		dispatch_sync(dispatch_get_main_queue(), ^{
			[invocation invokeWithTarget:_object];
		});
	}

	// Postprocess return value, replacing blobjects by proxies
	type = [signature methodReturnType];
	if (strcmp(type, @encode(id)) == 0) {
		[invocation getReturnValue:&arg];
		BLObjectProxy *proxy = [self _maskObject:arg];
		[invocation setReturnValue:&proxy];
	}
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
	if (NSThread.isMainThread) {
		return [_class instanceMethodSignatureForSelector:sel];
	}
	else {
		__block NSMethodSignature *sig;
		dispatch_sync(dispatch_get_main_queue(), ^{
			sig = [_class instanceMethodSignatureForSelector:sel];
		});
		return sig;
	}
}

@end

@implementation NSObject (BLObjectProxy)

- (id)_original {
	return self;
}

@end
