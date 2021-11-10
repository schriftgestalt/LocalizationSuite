/*!
 @header
 BLObjectProxy.h
 Created by Max Seelemann on 07.05.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

/*!
 @abstract A simple proxy object for a BLObject that performs all actions on the main thread.
 */
@interface BLObjectProxy : NSProxy {
	NSMapTable *_cache;
	Class _class;
	BLObject *_object;
}

/*!
 @abstract Returns a new proxy for the given file object.
 */
+ (id)proxyWithObject:(BLObject *)object;

@end

/*!
 @abstract Proxy methods for all objects.
 */
@interface NSObject (BLObjectProxy)

/*!
 @abstract If an object is enclosed by a BLObjectProxy it is unboxed, otherwise the objec is retuned.
 */
- (id)_original;

@end