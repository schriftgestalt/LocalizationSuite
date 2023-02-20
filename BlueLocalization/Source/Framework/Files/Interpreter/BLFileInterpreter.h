/*!
 @header
 BLFileInterpreter.h
 Created by Max on 13.11.04.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <Cocoa/Cocoa.h>

@class BLFileObject;
@protocol BLDocumentProtocol;

/*!
 @enum BLFileInterpreter options
 @abstract The flags that can be set for the BLFileInterpreter's options.

 @const BLFileInterpreterNoOptions						Setting options to this constant will disable all options.

 @const BLFileInterpreterIgnoreFileChangeDates			This will always interprete the file, independent from the change date or hash value. However, if dates are ignored, the file objects date and hash value won't get updated either.
 @const BLFileInterpreterAllowChangesToKeyObjects		When a file is imported and some keys are no longer there or new keys are added and this option is active, the requested key objects will be added resp. the no longer present key objects will be deleted. Thus this option allows structural changes, activating it makes only sense when importing a reference language. This flag also enables the update of both the change date and file hash.
 @const BLFileInterpreterReferenceImportCreatesBackup	When importing a file as reference, the option BLFileInterpreterAllowChangesToKeyObjects is enabled and the content of the file has changed, a backup will be created and stored for a new version as an attached object with the key BLBackupAttachmentKey.

 @const BLFileInterpreterTrackValueChangesAsUpdate		If the value of a key object changed over it's earlier version and this option is active, the key object will be marked as updated.
 @const BLFileInterpreterValueChangesResetKeys			If the value of a key object changed over it's earlier version and this option is active, all other localized versions will be discarded. Ths option only works if BLFileInterpreterAllowChangesToKeyObjects is set!
 @const BLFileInterpreterImportEmptyKeys				Empty keys (this is strings of zero length) will get imported as well, otherwise they will be ignored.
 @const BLFileInterpreterDeactivateEmptyKeys			When BLFileInterpreterImportEmptyKeys is set, this option can mark empty keys as not active. In effect, they should be presented to the developer as present but should not be given to a localizer.
 @const BLFileInterpreterDeactivateIgnoredPlaceholders	Upon reference import, this option marks keys in the ignored placeholders list as not active. They will be presented to the developer but will not be given to a localizer.
 @const BLFileInterpreterAutotranslateNewKeys			If set and a new (previously unknown) key appears or a previously existing key is being reset because BLFileInterpreterValueChangesResetKeys is active, other languages will be filled with previous localizations. This is restricted to the same file. Basically, other strings are being checked and deleted (old) keys are consulted. This is especially usefull when refactoring or changing identifiers.
 @const BLFileInterpreterTrackAutotranslationAsNoUpdate	Keys that were translated automatically using BLFileInterpreterAutotranslateNewKeys will get marked as not updated, as their contents are known.
 @const BLFileInterpreterImportComments					Comments will be imported if set and BLFileInterpreterAllowChangesToKeyObjects is also activated, otherwise they will be just ignored.
 @const BLFileInterpreterEnableShadowComments			When a key object has no comment and this option is active, the last comment found will be used. This will only work, if BLFileInterpreterImportComments has been activated.
 @const BLFileInterpreterImportNonReferenceValuesOnly	When a non-reference language is being imported, only values that are not equal to the value in the reference language will be imported.
 */
enum {
	BLFileInterpreterNoOptions = 0,

	// File related options
	BLFileInterpreterIgnoreFileChangeDates = 1 << 0,
	BLFileInterpreterAllowChangesToKeyObjects = 1 << 6,
	BLFileInterpreterReferenceImportCreatesBackup = 1 << 1,

	// Key related options
	BLFileInterpreterTrackValueChangesAsUpdate = 1 << 7,
	BLFileInterpreterValueChangesResetKeys = 1 << 8,
	BLFileInterpreterImportEmptyKeys = 1 << 9,
	BLFileInterpreterDeactivateEmptyKeys = 1 << 10,
	BLFileInterpreterDeactivatePlaceholderStrings = 1 << 16,
	BLFileInterpreterAutotranslateNewKeys = 1 << 11,
	BLFileInterpreterTrackAutotranslationAsNoUpdate = 1 << 12,
	BLFileInterpreterImportComments = 1 << 13,
	BLFileInterpreterEnableShadowComments = 1 << 14,
	BLFileInterpreterImportNonReferenceValuesOnly = 1 << 15
};

/*!
 @abstract The primitive abstract superclass for all file interpretations.
 @discussion Basically, a file interpreter is a one-shot object. You have it created, set it up and use it - afterwards it is gone. Subclasses should override the _interpreteFile: method to actually do the heavy lifting.

 A technique sometimes needed is <b>interpreter forwarding</b>: If an interpreter needs to use a different one, it can just instantiate it and have it's contents forwarded. A reason for this might be that the data has only been converted to a different format, which is then to be interpreted. The procedure is simple as follows: In the overridden _interpreteFile: you should instantiate the different interpreter of the needed type and then send it a _setForwardsToInterpreter: message with self as argument. After that the others _interpreteFile: should be called directly.
 */
@interface BLFileInterpreter : NSObject {
	BOOL _asReference;
	NSUInteger _autoreleaseCycles;
	BOOL _changed;
	NSMutableArray *_emittedKeys;
	BLFileObject *_fileObject;
	BLFileInterpreter *_forward;
	NSString *_language;
	NSString *_lastComment;
	NSUInteger _options;
	NSString *_reference;
}

/*!
 @abstract Register a subclass for a specific file type.
 @discussion The given class must be a subclass of BLFileInterpreter, otherwise an exception will be thrown. If a extension is to be registered twice, the classes are checked for inheritance and the one with the deepest level is taken. If this is conflicting, an exception is thrown as well.
 */
+ (void)registerInterpreterClass:(Class)interpreterClass forFileType:(NSString *)extension;

/*!
 @abstract Initializes and returns an autoreleased interpreter for the given file type.
 */
+ (id)interpreterForFileType:(NSString *)extension;

/*!
 @abstract Initializes and returns an autoreleased interpreter for interpretaion into the given file object.
 @discussion Unlike interpreterForFileType:, this method is able to account the custom file type of the passed file object.
 */
+ (id)interpreterForFileObject:(BLFileObject *)object;

/*!
 @abstract Returns all importable file paths from the given array of paths.
 */
+ (NSArray *)filePathsFromPaths:(NSArray *)paths;

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
 @abstract The placeholder strings that will be marked as inactive.
 @discussion If the option BLFileInterpreterDeactivatePlaceholders is not set, this setting will be ignored.
 */
@property (nonatomic, strong) NSArray *ignoredPlaceholderStrings;

/*!
 @abstract Calculates the hash for a given file path.
 @discussion The result should be a string that always changes if the contents of a file change. The change date should be ignored, as only content changes should be relevant. Default uses the MD5 hash algorithm to generate the hash.
 */
- (NSString *)hashValueForFile:(NSString *)path;

/*!
 @abstract Return the subpath of a path to be used for hash generation.
 @discussion This allows subclasses to specify a different path for hash generation. This is especially needed if the file path is a bundle, because hash values can only be calsulated for files. The default implementation returns the given path, which should be fine for most implementations.
 */
- (NSString *)actualPathForHashValueGeneration:(NSString *)path;

/*!
 @abstract In an document context, this importes a localized version of a file object.
 @discussion The documents path creator is consulted for the full path of the given file object, then this method forwards to interpreteFile:intoObject:withLanguage:.
 @return YES if the file was imported, NO if no import is required or an error happened.
 */
- (BOOL)interpreteFileObject:(BLFileObject *)object inDocument:(NSDocument<BLDocumentProtocol> *)document withLanguage:(NSString *)language;

/*!
 @abstract Determines whether an import is needed or not.
 @discussion The default implementation compares the change date with the last import and also checks whether the file hash, which is computed using hashValueForFile:, has changed. If a date and a hash change is detected, YES is returned, NO otherwise.
 @return YES if the file will be imported, NO if an import call will have no change.
 */
- (BOOL)willInterpreteFile:(NSString *)path intoObject:(BLFileObject *)object;

/*!
 @abstract Determines whether an import is needed or not.
 @discussion As a convenience method, this consults the document's path creator and then returns the result of willInterpreteFile:intoObject:.
 */
- (BOOL)willInterpreteFileObject:(BLFileObject *)object inDocument:(NSDocument<BLDocumentProtocol> *)document withLanguage:(NSString *)language;

/*!
 @abstract Primitive. Interpretes a file for a given language into a given file object.
 @discussion This method first checks whether the file will be imported and then sets up the import environment, calling _interpreteFile: in the subclass'es implementation. This is the central method that is called by the methods above and might be an major entry point for external callers. However, it should not be overridden by subclassers as a lot of setup and teardown happens here. _interpreteFile: is the way to do this. If you need to internally use a different interpreter, see the class description on how to do interpreter forwarding.
 The parameter reference determines whether the given language is the reference language of the containing document or not. Reference language imports will result in a slightly different behavior, namely a changed value of BLObjectReferenceChangedKey!
 */
- (BOOL)interpreteFile:(NSString *)path intoObject:(BLFileObject *)object withLanguage:(NSString *)language referenceLanguage:(NSString *)reference;

/*!
 @abstract Autotranslate the given key object.
 @discussion By running through the given objects, which must be an array of BLKeyObjects, the file's object's value for the import language is compared. If a exact match is found, all localized values that keyObject has not a value for, will be copied. The result might be a key object merged from multiple key objects. This method is for internal use only.
 */
- (void)autotranslateUsingObjects:(NSArray *)objects;

@end

/*!
 @abstract Methods to be used or overridden by the subclasses of BLFileInterpreter but make no sense in public usages.
 */
@interface BLFileInterpreter (FileInterpreterInternal)

/*!
 @abstract The actual file interpretation happens here.
 @discussion This is the primary method to be overridden by subclasses. Whenever a key/value pair is found, _emitKey:value:comment: should be called. The default implementation just throws.
 @return YES on success, NO on error.
 */
- (BOOL)_interpreteFile:(NSString *)path;

/*!
 @abstract Notify the interpreter that is should forward it's emitted keys
 @discussion This is to be used out of an interpretation session only. See class description for details about interpreter forwarding. If aInterpreter is nil, it returns to the standard behaviour.
 */
- (void)_setForwardsToInterpreter:(BLFileInterpreter *)aInterpreter;

/*!
 @abstract The primitive method to be used by subclasses to emit scanned values.
 @discussion The order in which this method will be called and in which the keys are being returned is the order in the final file object.
 */
- (void)_emitKey:(NSString *)key value:(id)value leadingComment:(NSString *)leadingComment inlineComment:(NSString *)inlineComment;

@end
