/*!
 @header
 NPPreview.m
 Created by max on 07.06.08.

 @copyright 2008-2009 Localization Suite. All rights reserved.
 */

#import "NPPreview.h"

#import "NPBundleLoader.h"
#import "NPDescriptionLoader.h"
#import "NPPreviewBuilder.h"

/*!
 @abstract Internal methods of NPPreview.
 */
@interface NPPreview (NPPreviewInternal)

/*!
 @abstract Recursively associates key objects into the preview object tree.
 */
- (void)associateKeyObjects;

/*!
 @abstract Recursively changes the language in the preview object tree.
 */
- (void)changeDisplayLanguage;

@end

@implementation NPPreview

- (id)initWithNibAtPath:(NSString *)aPath {
	self = [super init];

	_builder = [[NPPreviewBuilder alloc] init];
	_fileObject = nil;
	_language = nil;
	_loader = [NPDescriptionLoader sharedInstance];
	_path = aPath;
	_snapshot = NO;

	return self;
}

- (void)dealloc {
	if (_fileObject)
		[_fileObject removeObserver:self forKeyPath:@"objects"];
}

#pragma mark - Accessors

- (NSArray *)rootObjects {
	return _builder.rootObjects;
}

- (NPObject *)objectForNibObjectID:(NSString *)objectID {
	return [_builder.previewObjects objectForKey:objectID];
}

@synthesize associatedFileObject = _fileObject;

- (void)setAssociatedFileObject:(BLFileObject *)fileObject {
	if (_fileObject)
		[_fileObject removeObserver:self forKeyPath:@"objects"];

	_fileObject = [fileObject _original];

	if (_fileObject)
		[_fileObject addObserver:self forKeyPath:@"objects" options:0 context:@"objects"];

	if (_builder.previewWasBuilt)
		[self associateKeyObjects];
}

@synthesize displayLanguage = _language;

- (void)setDisplayLanguage:(NSString *)language {
	[self setDisplayLanguage:language useSnapshot:NO];
}

- (void)setDisplayLanguage:(NSString *)language useSnapshot:(BOOL)snapshot {
	BOOL wasSnapshot = _snapshot;

	_language = language;
	_snapshot = snapshot;

	if (_builder.previewWasBuilt && _fileObject) {
		if (wasSnapshot == _snapshot)
			[self changeDisplayLanguage];
		else
			[self associateKeyObjects];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == @"objects") {
		if (_builder.previewWasBuilt)
			[self associateKeyObjects];
	}
	else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark - Actions

- (BOOL)loadNib {
	NSDictionary *dict;

	BLLogBeginGroup(@"Loading preview nib file at path: %@", _path);

	@try {
		dict = [_loader loadDescriptionFromPath:_path];
	}
	@catch (NSException *e) {
		BLLog(BLLogError, @"Uncaught exception while reading preview: %@", [e description]);
		BLLogEndGroup();
		return NO;
	}

	if (dict) {
		BLLog(BLLogInfo, @"Successfully read output if IBtool.");
	}
	else {
		BLLog(BLLogError, @"IBtool output cannot be parsed!");
		BLLogEndGroup();
		return NO;
	}

	@try {
		[_builder buildPreviewFromDescription:dict];
	}
	@catch (NSException *e) {
		BLLog(BLLogError, @"Uncaught exception while building preview: %@", [e description]);
		return NO;
	}
	@finally {
		BLLogEndGroup();
	}

	if (_fileObject)
		[self associateKeyObjects];

	return YES;
}

- (void)associateKeyObjects {
	NSArray *keyObjects, *objectIDs;

	// Sort object ids
	objectIDs = [_builder.previewObjects allKeys];
	objectIDs = [objectIDs sortedArrayUsingSelector:@selector(naturalCompare:)];

	// Sort key objects
	keyObjects = (!_snapshot) ? _fileObject.objects : [_fileObject snapshotForLanguage:_language];
	keyObjects = [keyObjects sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"nibObjectID" ascending:YES selector:@selector(naturalCompare:)]]];

	// Associate objects with keys
	for (NSUInteger o = 0, k = 0; o < [objectIDs count] && k < [keyObjects count]; o++) {
		BLKeyObject *keyObject;
		NSMutableArray *keys;
		NSString *objectID;
		NPObject *object;

		// Get id and object
		objectID = [objectIDs objectAtIndex:o];
		object = [_builder.previewObjects objectForKey:objectID];

		// Find matching key object
		keys = [NSMutableArray array];
		keyObject = [keyObjects objectAtIndex:k];

		while ([[keyObject nibObjectID] naturalCompare:objectID] == NSOrderedAscending && k < [keyObjects count] - 1)
			keyObject = [keyObjects objectAtIndex:++k];

		// List key objects
		while ([[keyObject nibObjectID] naturalCompare:objectID] == NSOrderedSame) {
			[keys addObject:keyObject];

			// Go to next object
			if (k < [keyObjects count] - 1)
				keyObject = [keyObjects objectAtIndex:++k];
			else
				break;
		}

		// Finally associate the keys
		[object setAssociatedKeyObjects:keys];
	}

	// Set the language if already set
	if (_language)
		[self changeDisplayLanguage];
}

- (void)changeDisplayLanguage {
	for (NPObject *object in [_builder.previewObjects allValues])
		[object setDisplayLanguage:_language useSnapshot:_snapshot];
}

#pragma mark - Writing

- (BOOL)writeToNibAtPath:(NSString *)target actions:(NSUInteger)actions {
	BLLogBeginGroup(@"Writing changes to nib file at path %@", target);

	// Build the description
	NSMutableDictionary *description = [NSMutableDictionary dictionary];

	// Find frames
	if (actions & NPPreviewWriteFrames)
		[description setDictionary:[_builder descriptionForObjectProperties:NPPreviewBuilderFrameObjectProperty]];

	// Other options
	for (NPObject *object in [_builder.previewObjects allValues]) {
		NSMutableDictionary *objectDict = [NSMutableDictionary dictionary];

		// Find existing descriptions
		if ([description objectForKey:object.nibObjectID])
			[objectDict setDictionary:[description objectForKey:object.nibObjectID]];

		// Write localizable values
		if (actions & NPPreviewWriteStrings) {
			for (BLKeyObject *keyObject in object.associatedKeyObjects) {
				NSString *value;

				if (!_snapshot)
					value = [keyObject stringForLanguage:_language];
				else
					value = [keyObject snapshotForLanguage:_language];

				if (!value || ![value isKindOfClass:[NSString class]])
					continue;

				[objectDict setObject:value forKey:keyObject.propertyName];
			}
		}

		// Store if dict contains something
		if ([objectDict count])
			[description setObject:objectDict forKey:object.nibObjectID];
	}

	// Do we need to write something?
	if (![description count]) {
		BLLog(BLLogWarning, @"Nothing to be written!");
		BLLogEndGroup();
		return YES;
	}

	// Write
	NSString *source = (actions & NPPreviewUpdateFile) ? target : _path;
	BOOL success = [_loader writeDescription:description fromPath:source toPath:target];
	if (!success) {
		BLLog(BLLogError, @"Were unable to write changes!");
	}

	BLLogEndGroup();
	return success;
}

@end
