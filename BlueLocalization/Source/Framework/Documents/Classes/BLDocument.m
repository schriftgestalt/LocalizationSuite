/*!
 @header
 BLDocument.m
 Created by Max Seelemann on 07.05.10.

 @copyright 2010 the Localization Suite Foundation. All rights reserved.
 */

#import "BLDocument.h"

#import "BLDocumentFileWrapper.h"
#import "BLDocumentPreferences.h"

NSString *BLDocumentLastSavePathKey = @"lastDocumentSavePath";
NSString *BLDocumentOpenFolderKey = @"lastOpenedFolder";
NSString *BLDocumentSaveCompressedKey = @"saveCompressed";

@implementation BLDocument

- (id)init {
	self = [super init];

	if (self != nil) {
		_preferences = [[NSMutableDictionary alloc] init];
		_userPreferences = [[NSMutableDictionary alloc] init];
		_preferencesProxy = nil;

		[self.preferences setDictionary:[[self class] defaultPreferences]];
	}

	return self;
}

#pragma mark - Preferences

- (NSMutableDictionary *)preferences {
	if (!_preferencesProxy)
		_preferencesProxy = [[BLDocumentPreferences alloc] initWithDictionary:_preferences userDictionary:_userPreferences andUserKeys:[[self class] userPreferenceKeys]];
	return _preferencesProxy;
}

+ (NSDictionary *)defaultPreferences {
	return [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:NO], BLDocumentSaveCompressedKey, nil];
}

+ (NSArray *)userPreferenceKeys {
	return [NSArray arrayWithObjects:BLDocumentOpenFolderKey, BLDocumentLastSavePathKey, nil];
}

#pragma mark - Persistence

- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError {
	BLDocumentFileWrapper *wrapper;

	if (NSAppKitVersionNumber < NSAppKitVersionNumber10_6)
		wrapper = [[BLDocumentFileWrapper alloc] initWithPath:[absoluteURL path]];
	else
		wrapper = [[BLDocumentFileWrapper alloc] initWithURL:absoluteURL options:0 error:outError];

	if (wrapper) {
		BOOL result = [self readFromFileWrapper:wrapper ofType:typeName error:outError];

		// Determine if compression was used
		BOOL isDirectory;
		[[NSFileManager defaultManager] fileExistsAtPath:[absoluteURL path] isDirectory:&isDirectory];
		[self.preferences setObject:[NSNumber numberWithBool:!isDirectory] forKey:BLDocumentSaveCompressedKey];

		return result;
	}
	else {
		return NO;
	}
}

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError {
	return [self writeSafelyToURL:absoluteURL ofType:typeName forSaveOperation:NSSaveOperation error:outError];
}

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation originalContentsURL:(NSURL *)absoluteOriginalContentsURL error:(NSError **)outError {
	return [self writeSafelyToURL:absoluteURL ofType:typeName forSaveOperation:saveOperation error:outError];
}

- (BOOL)canAsynchronouslyWriteToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation {
	return YES;
}

- (BOOL)writeSafelyToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation error:(NSError **)outError {
	if ([self respondsToSelector:@selector(fileWrapperOfType:error:)]) {
		BLLogBeginGroup(@"Saving file %@", [absoluteURL lastPathComponent]);

		// Store save path
		[self.preferences setObject:[absoluteURL path] forKey:BLDocumentLastSavePathKey];

		// Get the content file wrapper
		NSFileWrapper *wrapper = [self fileWrapperOfType:typeName error:outError];
		if (!wrapper)
			return NO;

		if (NSAppKitVersionNumber >= NSAppKitVersionNumber10_7)
			[self unblockUserInteraction];

		// Create a special document wrapper out of it
		BLDocumentFileWrapper *documentWrapper = [[BLDocumentFileWrapper alloc] initWithFileWrapper:wrapper];

		// Save
		BOOL success = NO;

		if (NSAppKitVersionNumber < NSAppKitVersionNumber10_6) {
			if (outError)
				*outError = nil;
			success = [documentWrapper writeToFile:[absoluteURL path] atomically:YES updateFilenames:YES];
		}
		else {
			// Save compressed or not
			NSUInteger options = ([[self.preferences objectForKey:BLDocumentSaveCompressedKey] boolValue]) ? BLDocumentFileWrapperSaveCompressedOption : 0;
			success = [documentWrapper writeToURL:absoluteURL options:options originalContentsURL:nil error:outError];
		}

		// Done
		BLLogEndGroup();
		return success;
	}
	else {
		return [super writeSafelyToURL:absoluteURL ofType:typeName forSaveOperation:saveOperation error:outError];
	}
}

#pragma mark - Dummy Implementation of BLDocumentProtocol

- (BLPathCreator *)pathCreator {
	return nil;
}

- (NSString *)referenceLanguage {
	return nil;
}

- (NSArray *)languages {
	return nil;
}

@end
