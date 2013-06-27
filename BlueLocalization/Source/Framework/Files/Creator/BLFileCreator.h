/*!
 @header
 BLFileCreator.h
 Created by Max on 29.11.04.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

@class BLFileObject;
@protocol BLDocumentProtocol;

/*!
 @enum BLFileCreator options
 @abstract The flags that can be set for the BLFileCreator's options.
 
 @const BLFileCreatorNoOptions					Setting options to this constant will disable all options.
 @const BLFileCreatorReinject					If set, files will be recreated freshly from the reference language.
 @const BLFileCreatorWriteActiveKeysOnly		If set, only active keys will be written. Inactive keys will be simply omitted.
													Overrides BLFileCreatorInactiveKeysAsReference.
 @const BLFileCreatorInactiveKeysAsReference	Keys marked as inactive will be written in the reference language.
													Overridden by BLFileCreatorWriteActiveKeysOnly.

 @const BLFileCreatorSlaveMode					File creator is used by a other creator and might adjust it's behavior, like not print any warnings.
 */
enum {
	BLFileCreatorNoOptions					= 0,
	
	BLFileCreatorReinject					= 1<<0,
	BLFileCreatorWriteActiveKeysOnly		= 1<<1,
	BLFileCreatorInactiveKeysAsReference	= 1<<2,
	
	BLFileCreatorSlaveMode					= 1<<10
};

/*!
 @abstract The primitive abstract superclass for all file creations.
 @discussion A file creator is a one-shot object. You have it created, set it up and use it - afterwards it is gone. Subclasses should override the _writeFileToPath:fromObject:withLanguage:referenceLanguage: method to actually do the heavy lifting.
 */ 
@interface BLFileCreator : NSObject
{
	NSUInteger	_options;
}

/*!
 @abstract Register a subclass for a specific file type.
 @discussion The given class must be a subclass of BLFileCreator, otherwise an exception will be thrown. If a extension is to be registered twice, the classes are checked for inheritance and the one with the deepest level is taken. If this is conflicting, an exception is thrown as well.
 */
+ (void)registerCreatorClass:(Class)creatorClass forFileType:(NSString *)extension;

/*!
 @abstract Initializes and returns an autoreleased creator for the given file type.
 */
+ (id)creatorForFileType:(NSString *)extension;

/*!
 @abstract Initializes and returns an autoreleased creator for interpretaion into the given file object.
 */
+ (id)creatorForFileObject:(BLFileObject *)object;

/*!
 @abstract Designated initializer for subclasses.
 @discussion Subclasses should override this if they need to make changes other than to the default set of options, e.g. if you need some internal structure.
 */
- (id)init;

/*!
 @abstract The default options for a new interpreter instance.
 @discussion Use this method to override the options for newly instanciated interpreters, which are by default BLFileInterpreterNoOptions.
 */
+ (NSUInteger)defaultOptions;

/*!
 @abstract The options currently set for the interpreter.
 @discussion This is an logical or of contants defined above under BLFileInterpreter options.
 */
- (NSUInteger)options;

/*!
 @abstract Set the active options.
 */
- (void)setOptions:(NSUInteger)options;

/*!
 @abstract Returns whether a given option flag is set or not.
 */
- (BOOL)optionIsActive:(NSUInteger)option;

/*!
 @abstract Activates a set of options.
 @discussion This is the preferred way for users to set specific settings without overwriting the classes' default values. The options available are defined above under BLFileInterpreter options.
 */
- (void)activateOptions:(NSUInteger)options;

/*!
 @abstract Deactivates a set of options.
 @discussion This is the preferred way for users to set specific settings without overwriting the classes' default values. The options available are defined above under BLFileInterpreter options.
 */
- (void)deactivateOptions:(NSUInteger)options;

/*!
 @abstract Writes a file object to a given path.
 @discussion Creates a new file at the given path, taking localization data from object for language language, replacing missing values with the values of the reference language. The reference language might have bigger influence on the final result than just replacing missing data. The reference file might be used and just modified to create a localized variant.
 @return YES if the file was successfully created, NO otherwise. 
 */
- (BOOL)writeFileToPath:(NSString *)path fromObject:(BLFileObject *)object withLanguage:(NSString *)language referenceLanguage:(NSString *)reference;


@end

/*!
 @abstract Methods to be used or overridden by the subclasses of BLFileCreator but make no sense in public usages.
 */
@interface BLFileCreator (BLFileCreatorInternal)

/*!
 @abstract Prepares a reinjection creation.
 @discussion Default implementation just deletes the file, which might not be appropriate for everyone.
 */
- (BOOL)_prepareReinjectAtPath:(NSString *)path;

/*!
 @abstract Actually create the file here.
 @discussion This is the major override point. Do not call directly.
 */
- (BOOL)_writeFileToPath:(NSString *)path fromObject:(BLFileObject *)object withLanguage:(NSString *)language referenceLanguage:(NSString *)reference;

@end

