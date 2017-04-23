/*!
 @header
 BLFileInterpreter.m
 Created by Max on 13.11.04.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLFileInterpreter.h"

// Constants
NSString *kMD5LaunchPath        = @"/sbin/md5";

// Globals
NSMutableDictionary *__fileInterpreterClasses	= nil;

// Implementation
@implementation BLFileInterpreter

+ (void)registerInterpreterClass:(Class)interpreterClass forFileType:(NSString *)extension
{
	if (!__fileInterpreterClasses)
		__fileInterpreterClasses = [[NSMutableDictionary alloc] init];
	
	if (![interpreterClass isSubclassOfClass: [BLFileInterpreter class]])
		[NSException raise:NSInvalidArgumentException format:@"interpreterClass is no subclass of BLFileInterpreter"];
	if ([__fileInterpreterClasses objectForKey: extension]) {
		Class class = [__fileInterpreterClasses objectForKey: extension];
		
		// Ignore late superclasses
		if ([class isSubclassOfClass: interpreterClass])
			return;
		// Throw on inheritance conflict
		if (![interpreterClass isSubclassOfClass: class])
			[NSException raise:NSInvalidArgumentException format:@"there is already an interpreter for this extension"];
	}
	
	[__fileInterpreterClasses setObject:interpreterClass forKey:extension];
}

+ (id)interpreterForFileType:(NSString *)extension
{
	Class interpreterClass;
	
	interpreterClass = [__fileInterpreterClasses objectForKey: extension];
	if (interpreterClass == Nil)
		return nil;
	
	return [[interpreterClass alloc] init];
}

+ (id)interpreterForFileObject:(BLFileObject *)object
{
    return [self interpreterForFileType: ([object customFileType]) ? [object customFileType] : [[object path] pathExtension]];
}

- (id)init
{
	self = [super init];
	
	if (self != nil) {
		_autoreleaseCycles = 0;
		_forward = nil;
		_options = [[self class] defaultOptions];
	}
	
	return self;
}



#pragma mark - Utilites

+ (NSArray *)filePathsFromPaths:(NSArray *)paths
{
	NSMutableArray *filenames = [NSMutableArray arrayWithArray: paths];
	
	for (NSUInteger i=0; i < [filenames count]; i++) {
		NSString *path;
		BOOL directory;
		
		path = [filenames objectAtIndex: i];
		
		// Skip matching files
		if ([[BLFileObject availablePathExtensions] containsObject: [path pathExtension]])
			continue;
		
		// Remove object from list
		[[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory];
		[filenames removeObjectAtIndex: i];
		i--;
		
		// Include folder contents in search
		if (directory) {
			NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
			for (NSUInteger j=0; j<[contents count]; j++)
				[filenames addObject: [path stringByAppendingPathComponent: [contents objectAtIndex: j]]];
		}
	}
	
	return filenames;
}


#pragma mark - Options

- (NSUInteger)options
{
	return _options;
}

- (void)setOptions:(NSUInteger)options
{
	_options = options;
}

- (BOOL)optionIsActive:(NSUInteger)option
{
	return (_options & option) != 0;
}

- (void)activateOptions:(NSUInteger)options
{
	_options |= options;
}

- (void)deactivateOptions:(NSUInteger)options
{
	_options = _options & ~options;
}

+ (NSUInteger)defaultOptions
{
	return BLFileInterpreterNoOptions;
}

@synthesize ignoredPlaceholderStrings;



#pragma mark - Hash Value Generation

- (NSString *)hashValueForFile:(NSString *)path
{
    NSString *hashValue;
    NSPipe *output;
    NSTask *md5;
    
    path = [self actualPathForHashValueGeneration: path];
    output = [NSPipe pipe];
	
	if (!output)
		output = [NSPipe pipe];
	if (!output)
		return nil;
    
    md5 = [[NSTask alloc] init];
    
    [md5 setLaunchPath: kMD5LaunchPath];
    [md5 setArguments: [NSArray arrayWithObjects: @"-q", path, nil]];
    [md5 setStandardOutput: output];
    [md5 setStandardError: BLLogOpenPipe(@"Creating hash using md5. Path: \"%@\"", path)];
    
	[md5 launch];
	[md5 waitUntilExit];
    
    hashValue = [[NSString alloc] initWithData:[[output fileHandleForReading] readDataToEndOfFile] encoding:NSASCIIStringEncoding];
    return hashValue;
}

- (NSString *)actualPathForHashValueGeneration:(NSString *)path
{
    return path;
}

#pragma mark - Common Implementations

- (BOOL)interpreteFileObject:(BLFileObject *)object inDocument:(NSDocument <BLDocumentProtocol> *)document withLanguage:(NSString *)language
{
    NSString *path = [[document pathCreator] absolutePathForFile:object andLanguage:language];
    return [self interpreteFile:path intoObject:object withLanguage:language referenceLanguage:[document referenceLanguage]];
}

#pragma mark -

- (BOOL)willInterpreteFile:(NSString *)path intoObject:(BLFileObject *)object
{
	NSString *hash;
	
	// Import no matter what's coming
    if ([self optionIsActive: BLFileInterpreterIgnoreFileChangeDates])
        return YES;
	
	// We've had problems last time
	if ([[object errors] count])
		return YES;
	
	// File never imported
    if (![[object hashValue] length] || ![object changeDate])
		return YES;
	
	// Otherwise only if the hash changed...
	hash = [self hashValueForFile: path];
    return !hash || ![hash isEqualToString: [object hashValue]];
}

- (BOOL)willInterpreteFileObject:(BLFileObject *)object inDocument:(NSDocument <BLDocumentProtocol> *)document withLanguage:(NSString *)language
{
    NSString *path;
    
    path = [[document pathCreator] absolutePathForFile:object andLanguage:language];
    return [self willInterpreteFile:path intoObject:object];
}

#pragma mark - Interpretation

- (BOOL)interpreteFile:(NSString *)path intoObject:(BLFileObject *)object withLanguage:(NSString *)language referenceLanguage:(NSString *)reference
{
	BOOL success;
	
	_fileObject = object;
	_language = language;
	_lastComment = nil;
	_changed = NO;
	_reference = reference;
	_asReference = [language isEqual: reference];
	
	// Test file type
	NSString *extension = ([object customFileType]) ? [object customFileType] : [path pathExtension];
	if (![self isKindOfClass: [__fileInterpreterClasses objectForKey: extension]]) {
		BLLog(BLLogError, @"File path \"%@\" has incompatible file type \"%@\".", path, extension);
		[_fileObject setErrors: [NSArray arrayWithObject: BLObjectFiletypeUnknownError]];
		return NO;
	}
	
	// File should exist
	if (![[NSFileManager defaultManager] fileExistsAtPath: path]) {
		BLLog(BLLogError, @"File has not been found at path \"%@\".", path);
		[_fileObject setErrors: [NSArray arrayWithObject: BLObjectFileNotFoundError]];
		return NO;
	}
	
	// Only import if a change was done or we never imported
	if (![self willInterpreteFile:path intoObject:_fileObject])
        return NO;
	
	// Init the keys array, it will probably be about the same size as before
	_emittedKeys = [NSMutableArray arrayWithCapacity: [[object objects] count]];
	
	// The heavy work is done here...
    BLLogBeginGroup(@"Importing %@ file at path \"%@\"", [path pathExtension], path);
	success = [self _interpreteFile: path];
	
	// Abort on failure
	if (!success) {
		BLLog(BLLogError, @"Import failed!");
		[_fileObject setErrors: [NSArray arrayWithObject: BLObjectFileUnimportableError]];
		
		BLLogEndGroup();
		return NO;
	}
	
	// Remove no longer present keys
	if ([self optionIsActive: BLFileInterpreterAllowChangesToKeyObjects]) {
		NSUInteger count = [_fileObject removeObjectsWithKeyNotInArray: _emittedKeys];
		_changed = _changed || (count > 0);
	}
	
	// Run the autotranslation
	if ([self optionIsActive: BLFileInterpreterAutotranslateNewKeys]) {
		[self autotranslateUsingObjects: [_fileObject objects]];
		[self autotranslateUsingObjects: [_fileObject oldObjects]];
	}
	
	// Sort key objects like the keys
	_fileObject.objects = [_fileObject.objects sortedArrayUsingComparator:^NSComparisonResult(BLFileObject *obj1, BLFileObject *obj2) {
		NSUInteger v1 = [_emittedKeys indexOfObject: obj1.key];
		NSUInteger v2 = [_emittedKeys indexOfObject: obj2.key];
		
		if (v1 < v2)
			return NSOrderedAscending;
		else if (v1 > v2)
			return NSOrderedDescending;
		else
			return NSOrderedSame;
	}];
	
	// Update the change date and hash value
	if (_asReference && [self optionIsActive: BLFileInterpreterAllowChangesToKeyObjects]) {
		NSDate *modificationDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:NULL] objectForKey: NSFileModificationDate];
		[_fileObject setChangeDate: modificationDate];
		
		NSString *oldHash = [_fileObject hashValue];
		NSString *newHash = [self hashValueForFile: path];
		[_fileObject setHashValue: newHash];
		
		// The actual file changed
		if (![newHash isEqual: oldHash]) {
			// Enforce changed state
			_changed = YES;
			_fileObject.referenceChanged = YES;
		}
		
		
		if ([self optionIsActive: BLFileInterpreterReferenceImportCreatesBackup]
			&& (![newHash isEqual: oldHash] || ![_fileObject attachedObjectForKey:BLBackupAttachmentKey])) {
			NSFileWrapper *wrapper = [[NSFileWrapper alloc] initWithPath: path];
			
			[_fileObject setAttachedObject:wrapper forKey:BLBackupAttachmentKey];
		}
	}
	
	// Update the file object status
	[_fileObject setErrors: nil];
	if (_changed) {
		if (_asReference) {
			for (BLKeyObject *keyObject in [_fileObject objects]) {
				[keyObject setValue:_language didChange:NO];
				keyObject.referenceChanged = YES;
			}
		} else {
			[_fileObject setValue:_language didChange:YES];
		}
	}
	
	BLLogEndGroup();
	return YES;
}

- (BOOL)_interpreteFile:(NSString *)path
{
	// Default implementation just throws an exception
	[[NSException exceptionWithName:NSInternalInconsistencyException reason:@"Method should have been overridden by a subclass!" userInfo:nil] raise];

	return NO;
}

- (void)_setForwardsToInterpreter:(BLFileInterpreter *)aInterpreter
{
	_forward = aInterpreter;
}

- (void)_emitKey:(NSString *)key value:(id)value comment:(NSString *)comment
{
	// Interpreter forwarding implementation
	if (_forward) {
		[_forward _emitKey:key value:value comment:comment];
		return;
	}
	
	@autoreleasepool {
		// Find an existing key object
		BLKeyObject *keyObject = [_fileObject objectForKey:key createIfNeeded:NO];
		BOOL isNew = (keyObject == nil);
		
		// Create key object if option is active
		if (!keyObject && [self optionIsActive: BLFileInterpreterAllowChangesToKeyObjects])
			keyObject = [_fileObject objectForKey:key createIfNeeded:YES];
		if (!keyObject)
			return;
		
		// Remember the key and the old value
		[_emittedKeys addObject: key];
		id oldValue = [keyObject objectForLanguage: _language];
		
		// Check for non-reference changes that are for deactivated keys or that are equal to the reference value and as such will not get imported
		if (!_asReference && [self optionIsActive: BLFileInterpreterImportNonReferenceValuesOnly]
			&& (![keyObject isActive] || [value isEqual: [keyObject objectForLanguage: _reference]]))
			return;
		
		// Reset key if value changed
		if ([self optionIsActive: BLFileInterpreterValueChangesResetKeys] && [self optionIsActive: BLFileInterpreterAllowChangesToKeyObjects] && oldValue && ![value isEqual: oldValue]) {
			[_fileObject removeObject: keyObject];
			keyObject = [_fileObject objectForKey:key createIfNeeded:YES];
		}
		
		// Set new value
		[keyObject setObject:value forLanguage:_language];
		
		// Track any changes
		value = [keyObject objectForLanguage: _language];
		_changed = _changed || (value && ![value isEqual: oldValue]) || (!value && oldValue);
		
		// Ignore empty keys
		if (![self optionIsActive: BLFileInterpreterImportEmptyKeys] && [keyObject isEmpty]) {
			// We first always create empty key objects but remove them afterwards if the are to be ignored
			// The major benefit of this is that the key object itself is responsible to determine when it's empty or not
			[_emittedKeys removeLastObject];
			return;
		}
		
		// Deactivate empty keys
		if ([self optionIsActive: BLFileInterpreterDeactivateEmptyKeys] && [keyObject isEmpty])
			[keyObject setIsActive: NO];
		
		// Deactivate ignored placeholders
		if (_asReference && [self optionIsActive: BLFileInterpreterDeactivatePlaceholderStrings]
			&& [self.ignoredPlaceholderStrings containsObject: [keyObject stringForLanguage: _language]])
			[keyObject setIsActive: NO];
		
		// Set comment
		if ([self optionIsActive: BLFileInterpreterImportComments] && [self optionIsActive: BLFileInterpreterAllowChangesToKeyObjects]) {
			if (comment && [comment length]) {
				[keyObject setComment: comment];
				_lastComment = comment;
			} else if ([self optionIsActive: BLFileInterpreterEnableShadowComments] && _lastComment && [_lastComment length]) {
				[keyObject setComment: _lastComment];
			}
		}
		
		// Set updated flag
		if ([self optionIsActive: BLFileInterpreterTrackValueChangesAsUpdate] && !isNew && ![value isEqual: oldValue])
			[keyObject setWasUpdated: YES];
	}
}

- (void)autotranslateUsingObjects:(NSArray *)translations
{
	NSArray *sorting, *objects;
	NSUInteger i, j;
	BOOL update;
	
	// Init
	update = ![self optionIsActive: BLFileInterpreterTrackAutotranslationAsNoUpdate];
	
	// Sort the input
	sorting = [NSArray arrayWithObject: [[NSSortDescriptor alloc] initWithKey:_language ascending:YES selector:@selector(compareAsString:)]];
	objects = [[_fileObject objects] sortedArrayUsingDescriptors: sorting];
	translations = [translations sortedArrayUsingDescriptors: sorting];
	
	// Translation loop
	for (i=0, j=0; i<[objects count] && j<[translations count]; i++) {
		BLKeyObject *original, *translation;
		id origValue;
		
		original = [objects objectAtIndex: i];
		translation = [translations objectAtIndex: j];
		origValue = [original objectForLanguage: _language];
		
		// Skip keys without the reference
		if ([original isEmptyForLanguage: _language])
			continue;
		
		// Search for a matching translation
		while ([origValue compareAsString: [translation objectForLanguage: _language]] == NSOrderedDescending
			   && j < [translations count]-1)
			translation = [translations objectAtIndex: ++j];
		
		// Look at the next objects that also match
		NSUInteger k=0;
		
		while (j+k < [translations count]) {
			// Get the translation object
			translation = [translations objectAtIndex: j+k];
			k++;
			
			// Skip keys with not matching values
			if (![origValue isEqual: [translation objectForLanguage: _language]])
				break;
			
			// Copy the translations
			NSArray *languages = [translation languages];
			
			for (NSUInteger l=0; l<[languages count]; l++) {
				NSString *aLanguage = [languages objectAtIndex: l];
				if (![original isEmptyForLanguage: aLanguage])
					continue;
				
				id newObject = [translation objectForLanguage: aLanguage];
				if ([[original class] isEmptyValue: newObject])
					continue;
				
				[original setObject:newObject forLanguage:aLanguage];
				_changed = YES;
				
				if (update)
					[original setWasUpdated: YES];
			}
		}
	}
}

@end


