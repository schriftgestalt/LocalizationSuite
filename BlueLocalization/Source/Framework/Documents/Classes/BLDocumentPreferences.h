/*!
 @header
 BLDocumentPreferences.h
 Created by Max Seelemann on 28.10.2010.
 
 @copyright 2010 the Localization Suite Foundation. All rights reserved.
 */

/*!
 @abstract An internal proxy dictionary mapping the project preferences and user preferences of a document into a single dictionary for easier use.
 */
@interface BLDocumentPreferences : NSMutableDictionary
{
	NSMutableDictionary *_preferences;
	NSArray				*_userKeys;
	NSMutableDictionary *_userPreferences;
}

- (id)initWithDictionary:(NSMutableDictionary *)preferences userDictionary:(NSMutableDictionary *)userPreferences andUserKeys:(NSArray *)userKeys;

@end
