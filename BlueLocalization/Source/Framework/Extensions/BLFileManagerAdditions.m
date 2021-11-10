/*!
 @header
 BLFileManagerAdditions.m
 Created by Max on 29.11.04.

 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import <BlueLocalization/BLFileManagerAdditions.h>

@implementation NSFileManager (BLFileManagerAdditions)

- (BLFileManagerCompression)compressionOfFile:(NSString *)path {
	// Check extensions
	if ([[path pathExtension] isEqual:@"gz"])
		return BLFileManagerGzipCompression;
	if ([[path pathExtension] isEqual:@"tar"])
		return BLFileManagerTarCompression;
	if ([[path pathExtension] isEqual:@"tgz"])
		return BLFileManagerTarGzipCompression;
	if ([[path pathExtension] isEqual:@"tbz"])
		return BLFileManagerTarBzip2Compression;

	// Check content
	NSData *contents = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path] options:NSDataReadingUncached error:NULL];
	char sign[2];
	[contents getBytes:sign length:2];

	if (sign[0] == 'B' && sign[1] == 'Z')
		return BLFileManagerTarBzip2Compression;

	// Unable to further determine
	return BLFileManagerNoCompression;
}

- (NSString *)pathOfFile:(NSString *)path compressedUsing:(BLFileManagerCompression)compression {
	switch (compression) {
		case BLFileManagerNoCompression:
			return path;
		case BLFileManagerGzipCompression:
			return [path stringByAppendingPathExtension:@"gz"];
		case BLFileManagerTarCompression:
			return [path stringByAppendingPathExtension:@"tar"];
		case BLFileManagerTarGzipCompression:
			return [path stringByAppendingPathExtension:@"tgz"];
		case BLFileManagerTarBzip2Compression:
			return [path stringByAppendingPathExtension:@"tbz"];
		default:
			return path;
	}
}

- (BOOL)compressFileAtPath:(NSString *)path usingCompression:(BLFileManagerCompression)compression keepOriginal:(BOOL)keepOriginal {
	NSString *launchPath, *resultPath;
	NSArray *arguments;
	NSTask *task;

	resultPath = [self pathOfFile:path compressedUsing:compression];

	switch (compression) {
		case BLFileManagerNoCompression:
			return YES;
		case BLFileManagerGzipCompression:
			launchPath = @"/usr/bin/gzip";
			arguments = [NSArray arrayWithObject:path];
			break;
		case BLFileManagerTarCompression:
			launchPath = @"/usr/bin/tar";
			arguments = [NSArray arrayWithObjects:@"cf", [resultPath lastPathComponent], [path lastPathComponent], nil];
			break;
		case BLFileManagerTarGzipCompression:
			launchPath = @"/usr/bin/tar";
			arguments = [NSArray arrayWithObjects:@"czf", [resultPath lastPathComponent], [path lastPathComponent], nil];
			break;
		case BLFileManagerTarBzip2Compression:
			launchPath = @"/usr/bin/tar";
			arguments = [NSArray arrayWithObjects:@"cjf", [resultPath lastPathComponent], [path lastPathComponent], nil];
			break;
		default:
			return NO;
	}

	// Log
	BLLogBeginGroup(@"Compressing file at path: %@", path);
	BLLog(BLLogInfo, @"Result path: %@", resultPath);
	BLLog(BLLogInfo, @"Using tool: %@", launchPath);

	// Start task
	task = [[NSTask alloc] init];
	[task setLaunchPath:launchPath];
	[task setArguments:arguments];
	[task setCurrentDirectoryPath:[path stringByDeletingLastPathComponent]];

	[task launch];
	[task waitUntilExit];

	if (!keepOriginal)
		[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];

	// Log completion
	BOOL success = [self fileExistsAtPath:resultPath];

	if (success)
		BLLog(BLLogInfo, @"Process terminated. Success.");
	else
		BLLog(BLLogError, @"Compression failed, no compressed file created!");

	// Done
	return success;
}

- (NSString *)pathOfFile:(NSString *)path decompressedUsing:(BLFileManagerCompression)compression {
	if ([[NSArray arrayWithObjects:@"gz", @"tar", @"tgz", @"tbz", nil] containsObject:[path pathExtension]])
		return [path stringByDeletingPathExtension];

	// Expensive: need to look inside archive
	NSPipe *outPipe = [NSPipe pipe];

	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:@"/usr/bin/tar"];
	[task setArguments:[NSArray arrayWithObjects:@"tf", [path lastPathComponent], nil]];
	[task setCurrentDirectoryPath:[path stringByDeletingLastPathComponent]];
	[task setStandardOutput:outPipe];

	[task performSelectorOnMainThread:@selector(launch) withObject:nil waitUntilDone:YES];
	NSData *outData = [[outPipe fileHandleForReading] readDataToEndOfFile];
	[task performSelectorOnMainThread:@selector(waitUntilExit) withObject:nil waitUntilDone:YES];

	// Introspect data
	NSArray *paths = [[[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding] componentsSeparatedByString:@"\n"];
	NSMutableSet *filenames = [NSMutableSet set];

	for (NSString *filepath in paths) {
		if ([filepath length])
			[filenames addObject:[[filepath pathComponents] objectAtIndex:0]];
	}

	return [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:[filenames anyObject]];
}

- (BOOL)decompressFileAtPath:(NSString *)path usedCompression:(BLFileManagerCompression *)outCompression resultPath:(NSString **)outResultPath keepOriginal:(BOOL)keepOriginal {
	// Check compressed file and get compression
	BLFileManagerCompression compression = [self compressionOfFile:path];
	if (outCompression)
		*outCompression = compression;
	if (compression == BLFileManagerNoCompression)
		return NO;

	// Decompress
	NSString *launchPath, *resultPath;
	NSArray *arguments;
	NSTask *task;

	resultPath = [self pathOfFile:path decompressedUsing:compression];
	if ([resultPath isEqual:path]) {
		// Will have to overwrite result
		if (keepOriginal)
			return NO;

		// Move archive
		NSString *tmpPath = [path stringByAppendingPathExtension:@"tmp"];
		if (![[NSFileManager defaultManager] moveItemAtPath:path toPath:tmpPath error:NULL])
			return NO;
		path = tmpPath;
	}

	switch (compression) {
		case BLFileManagerNoCompression:
			return YES;
		case BLFileManagerGzipCompression:
			launchPath = @"/usr/bin/gunzip";
			arguments = [NSArray arrayWithObject:path];
			break;
		case BLFileManagerTarCompression:
			launchPath = @"/usr/bin/tar";
			arguments = [NSArray arrayWithObjects:@"xf", [path lastPathComponent], nil];
			break;
		case BLFileManagerTarGzipCompression:
			launchPath = @"/usr/bin/tar";
			arguments = [NSArray arrayWithObjects:@"xzf", [path lastPathComponent], nil];
			break;
		case BLFileManagerTarBzip2Compression:
			launchPath = @"/usr/bin/tar";
			arguments = [NSArray arrayWithObjects:@"xjf", [path lastPathComponent], nil];
			break;
		default:
			return NO;
	}

	task = [[NSTask alloc] init];
	[task setLaunchPath:launchPath];
	[task setArguments:arguments];
	[task setCurrentDirectoryPath:[path stringByDeletingLastPathComponent]];

	[task performSelectorOnMainThread:@selector(launch) withObject:nil waitUntilDone:YES];
	[task performSelectorOnMainThread:@selector(waitUntilExit) withObject:nil waitUntilDone:YES];

	if (!keepOriginal)
		[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];

	if (outResultPath)
		*outResultPath = resultPath;
	return [self fileExistsAtPath:resultPath];
}

@end
