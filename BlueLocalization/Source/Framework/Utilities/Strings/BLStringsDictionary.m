/*!
 @header
 BLStringsDictionary.m
 Created by Max on 30.12.05.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLStringsDictionary.h"

@implementation NSDictionary (BLStringsDictionary)


#pragma mark - Import

+ (NSDictionary *)dictionaryWithStringsAtPath:(NSString *)path
{
	return [self dictionaryWithStringsAtPath:path scannedComments:NULL scannedKeyOrder:NULL];
}

+ (NSDictionary *)dictionaryWithStringsAtPath:(NSString *)path scannedComments:(NSDictionary **)outComments scannedKeyOrder:(NSArray **)keyOrder
{
	NSMutableDictionary *strings, *comments;
	NSMutableArray *keys;
	NSString *content;
	
	// Initialize
	keys = [NSMutableArray array];
	strings = [NSMutableDictionary dictionary];
	comments = [NSMutableDictionary dictionary];
	
	// Load file
	content = [NSString stringWithContentsOfFile:path usedEncoding:NULL error:NULL];
	if (!content)
		return nil;
	
	// The heavy work
	if (![BLStringsScanner scanString:content toDictionary:strings withComments:comments andKeyOrder:keys])
		return nil;
	
	// Return values
	if (outComments)
		*outComments = comments;
	if (keyOrder)
		*keyOrder = keys;
	return strings;
}



#pragma mark - Export

- (BOOL)writeAsStringsToPath:(NSString *)path usingEncoding:(NSStringEncoding)encoding
{
    return [self writeAsStringsWithComments:[NSDictionary dictionary] toPath:path usingEncoding:encoding];
}

- (BOOL)writeAsStringsWithComments:(NSDictionary *)comments toPath:(NSString *)path usingEncoding:(NSStringEncoding)encoding
{
	return [self writeKeysAsStrings:[[self allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)] withComments:comments toPath:path usingEncoding:encoding];
}

- (BOOL)writeKeysAsStrings:(NSArray *)keys withComments:(NSDictionary *)comments toPath:(NSString *)path usingEncoding:(NSStringEncoding)encoding;
{
    NSMutableString *contents = [NSMutableString string];
    
    for (NSString *origKey in keys) {
        NSMutableString *key, *value;
		
		// Get the key
		key = [NSMutableString stringWithString: origKey];
        
        // Get Comment
        if ([comments objectForKey: key] != nil) {
			value = [NSMutableString stringWithString: [comments objectForKey: key]];
			
			// Check for multiline comments
            if ([value rangeOfString: @"\n"].length > 0) {
				[value replaceOccurrencesOfString:@"\n" withString:@"\n " options:NSLiteralSearch range:NSMakeRange(0, [value length])];
				[contents appendFormat: @"\n/*\n %@\n */\n", value];
			}
			// Single line comment
			else {
				[contents appendFormat: @"\n// %@\n", value];
			}
        }
        
        // Get Content Value
        value = [NSMutableString stringWithString: [self objectForKey: key]];
		
		// Apply standard replacements
        [value applyReplacementDictionary:BLStandardStringReplacements reverseDirection:YES];
        [key applyReplacementDictionary:BLStandardStringReplacements reverseDirection:YES];
		[key replaceUnescapedComposedCharacters];
        
        [contents appendFormat: @"\"%@\" = \"%@\";\n", key, value];
	}
	
	// Create the directory if necessary
    [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:NULL];
	
	// Write File
    return [[contents dataUsingEncoding: encoding] writeToFile:path atomically:YES];
}

- (BOOL)writeToPath:(NSString *)path mimicingFileAtPath:(NSString *)originalPath
{
	// Check for original file
	if (![[NSFileManager defaultManager] fileExistsAtPath: originalPath])
		return NO;
	
	// Process keys and values
	NSMutableDictionary *replacements = [NSMutableDictionary dictionaryWithCapacity: [self count]];
	for (NSString *key in [self allKeys])
		[replacements setObject:[self objectForKey: key] forKey:key];
	
	// Replace sting file contents
	NSStringEncoding encoding;
	NSString *original = [NSString stringWithContentsOfFile:originalPath usedEncoding:&encoding error:NULL];
	NSString *contents = [BLStringsScanner scanAndUpdateString:original withReplacementDictionary:replacements];
	
	// Create the directory if necessary
    [[NSFileManager defaultManager] createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:NULL];
	
	// Write File
    return [[contents dataUsingEncoding: encoding] writeToFile:path atomically:YES];
}

@end

