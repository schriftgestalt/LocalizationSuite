/*!
 @header
 NPDescriptionLoader.h
 Created by max on 02.03.09.

 @copyright 2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract Runs ibtool and extracts an plist output of nib files.
 */
@interface NPDescriptionLoader : NSObject
/*!
 @abstract Retruns the single shared instance.
 */
+ (id)sharedInstance;

/*!
 @abstract Runs ibtool and extracts an plist output of the given nib/xib file.
 @discussion IBtool is run with "--objects --hierarchy --classes" arguments and thus only has to return a minimal amount of data. This returned plist is then converted to a NSDictionary/NSArray structure and returned.
 */
- (NSDictionary *)loadDescriptionFromPath:(NSString *)path;

/*!
 @abstract Runs ibtool and writes change plist to the given nib/xib file.
 @discussion IBtool is run with "--import {plist}" arguments and thus only theoretically allows all possisble changes. FromPath and toPath might be the same file, updating the same file in-place.
 */
- (BOOL)writeDescription:(NSDictionary *)description fromPath:(NSString *)fromPath toPath:(NSString *)toPath;

@end
