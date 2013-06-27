/*!
 @header
 NPPreview.h
 Created by max on 07.06.08.
 
 @copyright 2008-2009 Localization Suite. All rights reserved.
 */

@class NPDescriptionLoader, NPObject, NPPreviewBuilder;

/*!
 @abstract The owner of a nib preview.
 @discussion NPDescriptionLoader and NPPreviewBuilder are used as utilities to actually create the preview, which is then held by this owner.
 @see NPDescriptionLoader NPDescriptionLoader
 @see NPPreviewBuilder NPPreviewBuilder
 */
@interface NPPreview : NSObject
{
	NPPreviewBuilder		*_builder;
	BLFileObject			*_fileObject;
	NSString				*_language;
	NPDescriptionLoader	*_loader;
	NSString				*_path;
	BOOL					_snapshot;
}

/*!
 @abstract Default init method. Creates a preview with the file at the given path.
 */
- (id)initWithNibAtPath:(NSString *)aPath;

/*!
 @abstract Loads the nib file from disk and actually instantiates the preview.
 @discussion If called another time, the previous preview will be removed, and replaced by the new one. Returns YES on success, NO otherwise.
 */
- (BOOL)loadNib;

/*!
 @abstract The options that can (and should) be set when updating a nib file.
 
 @const NPPreviewWriteFrames	Write the current frames of all NSView's in the preview.
 @const NPPreviewWriteStrings	Write the current localizable string values of all preview elements - this requires the preview to have been associated with a file object beforehand. Otherwise nothing happens.
 @const NPPreviewUpdateFile		Instead of creating a copy of the original preview object, just update the file at the target path.
 */
typedef enum {
	NPPreviewWriteFrames	= 1<<0,
	NPPreviewWriteStrings	= 1<<1,
	
	NPPreviewUpdateFile		= 1<<16
} NPPreviewWriteActions;

/*!
 @abstract Writes chnages in the preview to a nib file at the given path.
 @discussion Depending on the options, this method can write view frames and localizable strings. See NPPreviewWriteActions for details.
 */
- (BOOL)writeToNibAtPath:(NSString *)target actions:(NSUInteger)actions;

/*!
 @abstract All root objects contained in the nib file.
 @discussion Instances are of the class NPObject.
 @see NPObject NPObject
 */
@property(strong, readonly) NSArray *rootObjects;

/*!
 @abstract Returns a preview object for a interface element with a given id.
 @see NPObject NPObject
 */
- (NPObject *)objectForNibObjectID:(NSString *)objectID;

/*!
 @abstract The file object associated with the preview.
 @discussion Changing this property will recursively associate contained key objects with NPObjects.
 */
@property(nonatomic, strong) BLFileObject *associatedFileObject;

/*!
 @abstract The language the preview is to be displayed in.
 @discussion Setting a language will load the localization of the associatedFileObject into the preview object tree.
 Defaults to nil.
 */
@property(nonatomic, strong) NSString *displayLanguage;

/*!
 @abstract Sets the display language as usual, but sets values from the snapshot instead.
 @discussion Setting snapshot values does not allow automatic update upon key object changes.
 */
- (void)setDisplayLanguage:(NSString *)language useSnapshot:(BOOL)snapshot;

@end

