/*!
 @header
 BLXcodeProjectParser.h
 Created by max on 01.07.09.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

@class BLXcodeProjectItem;

/*!
 @abstract Simple parser object that imports a Xcode project and parses it into a object tree.
 */
@interface BLXcodeProjectParser : NSObject

/*!
 @abstract The possible path extensions of Xcode projects.
 */
+ (NSArray *)pathExtensions;

/*!
 @abstract Creates a new project parser for a project.
 */
+ (id)parserWithProjectFileAtPath:(NSString *)path;

/*!
 @abstract The path of the project used by the parser.
 */
- (NSString *)projectPath;

/*!
 @abstract The name of the project file inside the project path.
 */
- (NSString *)projectName;

/*!
 @abstract When the project is loaded, this returns the root of the file tree.
 */
- (BLXcodeProjectItem *)mainGroup;

/*!
 @abstract Makes the parser import the project data.
 @discussion Overwrites any previously stored contents.
 */
- (void)loadProject;

/*!
 @abstract Returns whether the project has already been loaded or not.
 */
@property (readonly) BOOL projectIsLoaded;

/*!
 @abstract Returns whether the project was modified after loading.
 */
@property (readonly) BOOL projectWasChanged;

/*!
 @abstract Writes the optionally changed project back to disk.
 @discussion Returns YES upon success, NO otherwise.
 */
- (BOOL)writeProject;

@end
