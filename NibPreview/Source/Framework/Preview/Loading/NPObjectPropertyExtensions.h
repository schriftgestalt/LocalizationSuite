/*!
 @header
 NPObjectPropertyExtensions.h
 Created by max on 02.03.09.

 @copyright 2008-2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract Extensions to NSObject for setting properties a common way.
 @discussion These extensions are heavily used by NSPreviewBuilder, which uses these methods to build the view hierarchy from the ibtool output. Subclasses override some or all to modify the default behaviour, convert values or to catch invalid keys.
 However, all methodes defined here are optional.
 */
@interface NSObject (NPObjectPropertyExtensions)

/*!
 @abstract Sets the children of an object.
 @discussion Given the ibtool hierarchy output, this array may have a concrete order, with special indices assigned to special roles. It is upon the subclasser to determine the correct behaviour. In NPPreviewBuilder's implementation, this method is called after all properties have been set using setMappedValue:forKey:. The default implementation does nothing.
 */
- (void)setChildren:(NSArray *)childs;

/*!
 @abstract Sets a value for a given key.
 @discussion Very similar to setValue:forKey: in AppKit's KVC protocol (which is simply called by the default implementation), this method sets a value for a given string identifier. It can and should be used to convert keys, values and maybe set depending properties.
 */
- (void)setMappedValue:(id)value forKey:(NSString *)key;

/*!
 @abstract Sets up the object for initialization.
 @discussion In NPPreviewBuilder's implementation, this method is called directly after creating to object using alloc/init. It can be used to set some default properties and likewise. The default implementation does nothing.
 */
- (void)initialize;

/*!
 @abstract Notifies that the initialization was completed.
 @discussion In NPPreviewBuilder's implementation, this method is called after all properties have been set using setMappedValue:forKey: and after the object hierarchy has been established using setChildren:. It can be used to fix some layout issues, set some pretty-look attributes and likewise. The default implementation does nothing.
 */
- (void)finished;

@end
