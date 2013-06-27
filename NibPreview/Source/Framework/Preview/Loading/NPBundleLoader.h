/*!
 @header
 NPBundleLoader.h
 Created by max on 09.03.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract Loads all bundles in Interface Builder's (IB) default path.
 */
@interface NPBundleLoader : NSObject
{
}

/*!
 @abstract Retruns the single shared instance.
 */
+ (id)sharedInstance;

/*!
 @abstract Returns an array of NSString's holding all known PlugIn paths from IB
 */
+ (NSArray *)interfaceBuilderKnownPluginPaths;

/*!
 @abstract Returns the path of the InterfaceBuilderKit Framework.
 */
+ (NSString *)interfaceBuilderFrameworkPath;

/*!
 @abstract Loads all bundles in array using @see loadBundle:
 @discussion As opposed to loadBundle: this method does not throw if anything went wrong during loading, instead the error is logged.
 */
- (void)loadBundles:(NSArray *)array;

/*!
 @abstract Loads the bundle at the given path.
 @discussion First, tries to find the bundle, throwing an NSInvalidArgumentException if not found. A preflight is done and - if it succeedes - the bundle is loaded. Otherwise it is tried to load the InterfaceBuilderKit Framework, as chances are high that this is a missing dependency. Then the load is attempted again, throwing if it can't. After finishing all classes from the bundle will be accessible from the application. The outcome is undefined however, if Class names intersect.
 */
- (void)loadBundle:(NSString *)path;

/*!
 @abstract Loads the InterfaceBuilderKit Framework and all its dependencies.
 This method will work only once, repeated calls are ignored. Either the load succeedes at the first time or it won't ever after.
 For this method to work it is ESSENTIAL that you include an rpath option with the value "/Developer/Library/PrivateFrameworks". The "-rpath" option must be added to your linker flags, in order to find required dependencies in the inner IB frameworks workings.
 */
- (void)loadInterfaceBuilderFrameworks;

@end
