/*!
 @header
 BLBundleObject.h
 Created by Max Seelemann on 24.07.06.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLObject.h>

@class BLFileObject;

/*!
 @abstract Possible referencing styles for bundle objects.
 
 @const BLAbsoluteReferencingStyle	The bundle object is referenced using a full path.
 @const BLRelativeReferencingStyle	The bundle object is referenced using a path relative to the localization database.
 */
typedef enum {
    BLAbsoluteReferencingStyle,
    BLRelativeReferencingStyle
} BLReferencingStyle;


/*!
 @abstract Possible naming styles for bundle objects.
 @discussion The naming style determines the name of language folders created and maintained.
 
 @const BLIdentifiersAndDescriptionsNamingStyle	Language folders should be named by their ISO codes if the natural language name would contain any special characters like spaces or brackets. Example: English.lproj, pt_BR.lproj
 @const BLIdentifiersNamingStyle				(recommended) Language folders should be named by their ISO codes. Example: en.lproj, pt_BR.lproj
 @const BLDescriptionsNamingStyle				Language folders should be named by their natural language names. Example: English.lproj, Portuguese (Brazil).lproj
 */
typedef enum {
    BLIdentifiersAndDescriptionsNamingStyle,
    BLIdentifiersNamingStyle,
    BLDescriptionsNamingStyle
} BLNamingStyle;

/*!
 @abstract A object representing a bundle (like a application or a plugin) containing multiple files for localization.
 @discussion This is the most coarse-granular object available.
 */
@interface BLBundleObject : BLObject
{
    NSArray				*_files;
    NSString            *_name;
    BLNamingStyle       _namingStyle;
    NSString            *_path;
    BLReferencingStyle  _referencingStyle;
    NSArray				*_xcodeProjects;
}

/*!
 @abstract Creates a bundle object with no path.
 */
+ (id)bundleObject;

/*!
 @abstract Creates a bundle object with for given path.
 @discussion See -initWithPath: for details.
 */
+ (id)bundleObjectWithPath:(NSString *)path;

/*!
 @abstract Designed initializer.
 @discussion This creates a new autoreleased bundle object, set the path to path and the name to the last path component of the path.
 */
- (id)initWithPath:(NSString *)path;

/*!
 @abstract The path of the bundle.
 @discussion This can be either a full path or a path relative to the localization database file. This is determined by the referencing style.
 */
@property(strong) NSString *path;

/*!
 @abstract The style with which the bundle is referenced.
 @discussion See BLReferencingStyle for possible values.
 */
@property(assign) BLReferencingStyle referencingStyle;

/*!
 @abstract The style with which newly created localization folders will be created.
 @discussion See BLNamingStyle for details.
 */
@property(assign) BLNamingStyle namingStyle;

/*!
 @abstract A possible user given name describing the bundle.
 */
@property(strong) NSString *name;

/*!
 @abstract The files in the bundle.
 @discussion Represented by a array of BLFileObjects.
 */
@property(strong) NSArray *files;

/*!
 @abstract Convenience for adding a file to the bundle's files.
 */
- (void)addFile:(BLFileObject *)object;

/*!
 @abstract Convenience for removing a file from the bundle's files.
 */
- (void)removeFile:(BLFileObject *)object;

/*!
 @abstract Finds a file in the bundle.
 @abstract Iterates over all files and tries to find one with an exact macht of the name.
 */
- (BLFileObject *)fileWithName:(NSString *)name;

/*!
 @abstract The associated xcode projects of the bundle.
 @discussion Represented by a array of NSStrings, which are relative paths to the project from the bundle.
 */
@property(strong) NSArray *associatedXcodeProjects;

/*!
 @abstract Adds a Xcode project with the given path.
 @discussion The passed path must be relative to the bundle.
 */
- (void)addAssociatedXcodeProject:(NSString *)relativePath;

@end
