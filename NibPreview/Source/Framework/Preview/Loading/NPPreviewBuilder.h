/*!
 @header
 NPPreviewBuilder.h
 Created by max on 02.03.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

/*!
 @abstract Loads and instanciates all objects from a given ibtool output.
 */
@interface NPPreviewBuilder : NSObject
{
	NSDictionary		*_classes;
	NSDictionary		*_objects;
	NSMutableDictionary	*_previewObjects;
	NSDictionary		*_rootObjects;
}

/*!
 @abstract Returns whether the preview has already been built or not.
 */
@property(readonly) BOOL previewWasBuilt;

/*!
 @abstract Creates the preview from the given description.
 @discussion After finishing
 1. the classes dict contains a mapping of all classes,
 2. the objects dict contains a mapping from object ids to a instanciated version of the description,
 3. the rootObjects array contains the complete hierary of all rootObjects encapsulated in @link //apple_ref/occ/instm/NPObject NPObject @/link's.
 */
- (void)buildPreviewFromDescription:(NSDictionary *)dictionary;

/*!
 @abstract All classes contained in the nib file.
 @discussion A dictionary mapping the name of the class as NSString to the actual loaded class. Unknown classes might have been mapped to a known superclass.
 */
@property(readonly) NSDictionary *classes;

/*!
 @abstract All objects contained in the nib file.
 @discussion A dictionary mapping from object id as string to the actually loaded object. This is the same as ib NPObject's original property.
 @see NPObject:original NPObject
 */
@property(readonly) NSDictionary *objects;

/*!
 @abstract All preview objects created while loading the nib file.
 @discussion A dictionary mapping from object id as string to an object of class NPObject.
 */
@property(readonly) NSDictionary *previewObjects;

/*!
 @abstract The root preview objects.
 @discussion An array containing all root objects contained in a NPObject tree hierarchy.
 */
@property(strong, readonly) NSArray *rootObjects;

/*!
 @abstract Property masks for all possible properties that can be exported.
 
 @const NPPreviewBuilderFrameObjectProperty		The frame of an object. Be it a NSView or a NSWindow (and of course subclasses) instance.
 */
typedef enum {
	NPPreviewBuilderFrameObjectProperty	= 1<<0
} NPPreviewBuilderProperties;

/*!
 @abstract Creates a writable description from all objects for the given properties.
 @discussion For properties that can currently be exported, see NPPreviewBuilderProperties.
 */
- (NSDictionary *)descriptionForObjectProperties:(NSUInteger)properties;

@end

