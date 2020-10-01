/*!
 @header
 BLDocumentFileWrapper.m
 Created by Max Seelemann on 07.05.10.
 
 @copyright 2010 the Localization Suite Foundation. All rights reserved.
 */

#import "BLDocumentFileWrapper.h"


NSArray *BLDocumentFileWrapperIgnoredNames = nil;


@interface BLDocumentFileWrapper ()
{
	NSString	*_temporaryPath;
}

- (NSFileWrapper *)decompressedFileWrapperFromPath:(NSString *)path;

@end

@implementation BLDocumentFileWrapper

+ (void)initialize
{
	[super initialize];
	BLDocumentFileWrapperIgnoredNames = [NSArray arrayWithObjects: @".svn", nil];
}

#pragma mark -

- (id)initWithPath:(NSString *)path
{
	if ([[NSFileManager defaultManager] compressionOfFile: path] != BLFileManagerNoCompression) {
		return (id)[self decompressedFileWrapperFromPath: path];
	} else {
		return [super initWithPath: path];
	}
}

- (id)initWithURL:(NSURL *)url options:(NSFileWrapperReadingOptions)options error:(NSError **)outError
{
	if ([[NSFileManager defaultManager] compressionOfFile: [url path]] != BLFileManagerNoCompression) {
		return (id)[self decompressedFileWrapperFromPath: [url path]];
	} else {
		return [super initWithURL:url options:options error:outError];
	}
}

- (id)initWithFileWrapper:(NSFileWrapper *)fileWrapper
{
	if ([fileWrapper isRegularFile])
		return [super initRegularFileWithContents: [fileWrapper regularFileContents]];
	else
		return [super initDirectoryWithFileWrappers: [fileWrapper fileWrappers]];
}
			 
#pragma mark - Reading

- (NSString *)temporaryPath
{
	if (!_temporaryPath) {
		_temporaryPath = [NSTemporaryDirectory() stringByAppendingPathComponent: @"LocalizationSuite"];
		_temporaryPath = [_temporaryPath stringByAppendingPathExtension: [NSString stringWithFormat: @"%lx", random()]];
		
		if (![[NSFileManager defaultManager] createDirectoryAtPath:_temporaryPath withIntermediateDirectories:YES attributes:nil error:NULL])
			_temporaryPath = nil;
	}
	
	return _temporaryPath;
}


#pragma mark - Reading

- (NSFileWrapper *)decompressedFileWrapperFromPath:(NSString *)path
{
	NSString *tmpPath = [self temporaryPath];
	tmpPath = [tmpPath stringByAppendingPathComponent: [path lastPathComponent]];
	
	[[NSFileManager defaultManager] copyItemAtPath:path toPath:tmpPath error:NULL];
	
	NSString *outPath = nil;
	if ([[NSFileManager defaultManager] decompressFileAtPath:tmpPath usedCompression:NULL resultPath:&outPath keepOriginal:NO]) {
		NSFileWrapper *wrapper = [[NSFileWrapper alloc] initWithPath: outPath];
		[[NSFileManager defaultManager] removeItemAtPath:outPath error:NULL];
		
		return wrapper;
	} else {
		[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
		return nil;
	}
}


#pragma mark - Writing

- (BOOL)writeFileWrapper:(NSFileWrapper *)wrapper toURL:(NSURL *)url withOptions:(NSFileWrapperWritingOptions)options error:(NSError **)outError
{
	// Clear error
	if (outError)
		*outError = nil;
	
	// Regular files are written as usual
	if (![wrapper isDirectory]) {
		if (![wrapper writeToURL:url options:options originalContentsURL:url error:outError]) {
			BLLog(BLLogWarning, @"Error during saving. Could not write file at path: %@", [url path]);
			return NO;
		} else {
			return YES;
		}
	}
	
	// Delete files that are overwritten by folders
	NSFileManager *mgr = [NSFileManager defaultManager];
	BOOL directory;
	
	if ([mgr fileExistsAtPath:[url path] isDirectory:&directory] && !directory) {
		if (![mgr removeItemAtPath:[url path] error:outError]) {
			BLLog(BLLogWarning, @"Error during saving. Could not remove file at path: %@", [url path]);
			return NO;
		}
	}
	if (![mgr fileExistsAtPath:[url path]]) {
		if (![mgr createDirectoryAtPath:[url path] withIntermediateDirectories:YES attributes:nil error:outError]) {
			BLLog(BLLogWarning, @"Error during saving. Could not create directory at path: %@", [url path]);
			return NO;
		}
	}
	else {
		NSDictionary* attr = @{NSFileModificationDate: [NSDate date]};
		[mgr setAttributes:attr ofItemAtPath:[url path] error: NULL];
	}
	
	// Get the sub-wrappers
	NSDictionary *wrappers = [wrapper fileWrappers];
	NSArray *names = [wrappers allKeys];
	
	// Delete removed items
	NSArray *currentNames = [mgr contentsOfDirectoryAtPath:[url path] error:outError];
	if (!currentNames)
		return NO;
	
	for (NSString *name in currentNames) {
		if (![names containsObject: name] && ![BLDocumentFileWrapperIgnoredNames containsObject: name]) {
			NSString *path = [[url path] stringByAppendingPathComponent: name];
			
			if (![mgr removeItemAtPath:path error:outError]) {
				BLLog(BLLogWarning, @"Error during saving. Could not remove item at path: %@", path);
				return NO;
			}
		}
	}
	
	// Write items
	for (NSString *name in names) {
		if (![BLDocumentFileWrapperIgnoredNames containsObject: name]) {
			if (![self writeFileWrapper:[wrappers objectForKey: name] toURL:[url URLByAppendingPathComponent: name] withOptions:options error:outError])
				return NO;
		}
	}
	
	return YES;
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)atomicFlag updateFilenames:(BOOL)updateFilenamesFlag
{
	NSFileWrapperWritingOptions options = 0;
	options |= (atomicFlag) ? NSFileWrapperWritingAtomic : 0;
	options |= (updateFilenamesFlag) ? NSFileWrapperWritingWithNameUpdating : 0;
	
	return [self writeFileWrapper:self toURL:[NSURL fileURLWithPath: path] withOptions:options error:NULL];
}

- (BOOL)writeToURL:(NSURL *)url options:(NSFileWrapperWritingOptions)options originalContentsURL:(NSURL *)originalContentsURL error:(NSError **)outError
{
	BOOL compress = ((options & BLDocumentFileWrapperSaveCompressedOption) != 0);
	options = options & ~BLDocumentFileWrapperSaveCompressedOption;
	
	if (compress) {
		// Write to temporary path
		NSString *tmpPath = [[self temporaryPath] stringByAppendingPathComponent: [[url path] lastPathComponent]];
		NSURL *tmpURL = [NSURL fileURLWithPath: tmpPath];
		if (![self writeFileWrapper:self toURL:tmpURL withOptions:options error:outError])
			return NO;
		
		// Compress
		if (![[NSFileManager defaultManager] compressFileAtPath:tmpPath usingCompression:BLFileManagerTarBzip2Compression keepOriginal:NO]) {
			if (outError)
				*outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteUnknownError userInfo:nil];
			return NO;
		}
		
		NSURL *outURL = [NSURL fileURLWithPath: [[NSFileManager defaultManager] pathOfFile:tmpPath compressedUsing:BLFileManagerTarBzip2Compression]];
		
		// Move to original destination
		[[NSFileManager defaultManager] removeItemAtURL:url error:NULL];
		return [[NSFileManager defaultManager] moveItemAtURL:outURL toURL:url error:outError];
	} else {
		if ([self isDirectory])
			return [self writeFileWrapper:self toURL:url withOptions:options error:outError];
		else
			return [super writeToURL:url options:options originalContentsURL:originalContentsURL error:outError];
	}
}

@end



