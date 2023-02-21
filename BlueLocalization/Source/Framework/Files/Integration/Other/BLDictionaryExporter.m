/*!
 @header
 BLDictionaryExporter.m
 Created by max on 20.02.10.

 @copyright 2004-2010 the Localization Suite. All rights reserved.
 */

#import "BLDictionaryExporter.h"

NSString *BLDictionaryExporterNibName = @"BLDictionaryExporter";

NSString *BLDictionaryExporterNormalizeKeyPath = @"dictionaryExporter.normalize";
NSString *BLDictionaryExporterNormLanguageKeyPath = @"dictionaryExporter.normLanguage";
NSString *BLDictionaryExporterLimitLanguagesKeyPath = @"dictionaryExporter.limitLanguages";

@interface BLDictionaryExporter () {
	NSArray *_languages;
}

@property (nonatomic, strong) NSArray *languages;

+ (id)_sharedInstance;

- (void)exportDictionaryFromObjects:(NSArray *)objects forLanguages:(NSArray *)languages inDocument:(NSDocument<BLDocumentProtocol> *)document updatingDictionary:(BOOL)updating;

@end

@implementation BLDictionaryExporter

id __sharedDictionaryExporter;

- (void)dealloc {
	__sharedDictionaryExporter = nil;
}

+ (id)_sharedInstance {
	if (__sharedDictionaryExporter == nil)
		__sharedDictionaryExporter = [[self alloc] init];

	return __sharedDictionaryExporter;
}

#pragma mark - Public Access

+ (void)exportDictionaryFromObjects:(NSArray *)objects forLanguages:(NSArray *)languages inDocument:(NSDocument<BLDocumentProtocol> *)document updatingDictionary:(BOOL)updating {
	[[self _sharedInstance] exportDictionaryFromObjects:objects forLanguages:languages inDocument:document updatingDictionary:updating];
}

#pragma mark - User Interaction

- (void)exportDictionaryFromObjects:(NSArray *)objects forLanguages:(NSArray *)languages inDocument:(NSDocument<BLDocumentProtocol> *)document updatingDictionary:(BOOL)updating {
	// Find the right languages
	if ([languages count] < 2) {
		if (![languages containsObject:[document referenceLanguage]])
			languages = [languages arrayByAddingObject:[document referenceLanguage]];
		else
			languages = [document languages];
	}

	// Remember the objects
	self.languages = languages;

	// Set some defaults
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (![defaults objectForKey:BLDictionaryExporterNormalizeKeyPath])
		[defaults setBool:YES forKey:BLDictionaryExporterNormalizeKeyPath];
	if (![defaults objectForKey:BLDictionaryExporterLimitLanguagesKeyPath])
		[defaults setBool:YES forKey:BLDictionaryExporterLimitLanguagesKeyPath];

	if (![languages containsObject:[defaults objectForKey:BLDictionaryExporterNormLanguageKeyPath]]) {
		if ([languages containsObject:[document referenceLanguage]])
			[defaults setObject:[document referenceLanguage] forKey:BLDictionaryExporterNormLanguageKeyPath];
		else
			[defaults setObject:[languages objectAtIndex:0] forKey:BLDictionaryExporterNormLanguageKeyPath];
	}

	// Prepare panel
	NSSavePanel *panel;

	if (updating) {
		NSOpenPanel *openPanel = [NSOpenPanel openPanel];
		panel = openPanel;

		[openPanel setAllowedFileTypes:[NSArray arrayWithObject:[BLDictionaryFile pathExtension]]];
		[[openPanel defaultButtonCell] setTitle:NSLocalizedStringFromTableInBundle(@"Export", @"Localizable", [NSBundle bundleForClass:[self class]], nil)];
	}
	else {
		panel = [NSSavePanel savePanel];

		if (!optionsView)
			[NSBundle loadNibNamed:BLDictionaryExporterNibName owner:self];

		[panel setCanCreateDirectories:YES];
		[panel setAccessoryView:optionsView];
		[panel setAllowedFileTypes:[NSArray arrayWithObject:[BLDictionaryFile pathExtension]]];

		[[panel defaultButtonCell] setTitle:NSLocalizedStringFromTableInBundle(@"Export", @"Localizable", [NSBundle bundleForClass:[self class]], nil)];
	}

	// Present panel
	[panel beginSheetModalForWindow:[document windowForSheet]
				  completionHandler:^(NSInteger result) {
		if (result != NSModalResponseOK)
			return;

		// Create/open dictionary
		BLDictionaryDocument *dictionary = [[BLDictionaryDocument alloc] init];

		if (updating) {
			// Open the existing file
			[dictionary readFromURL:[panel URL] ofType:@"" error:NULL];
			[dictionary addLanguages:self->_languages ignoreFilter:NO];
		}
		else {
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

			// Set the language
			if ([defaults boolForKey:BLDictionaryExporterLimitLanguagesKeyPath])
				[dictionary addLanguages:self->_languages ignoreFilter:YES];
			else
				[dictionary addLanguages:[document languages] ignoreFilter:YES];

			// Set the filter settings
			NSDictionary *filter = [NSDictionary dictionaryWithObjectsAndKeys:
									[defaults objectForKey:BLDictionaryExporterNormalizeKeyPath], BLDictionaryNormalizeFilterSetting,
									[defaults objectForKey:BLDictionaryExporterNormLanguageKeyPath], BLDictionaryNormLanguageFilterSetting,
									[defaults objectForKey:BLDictionaryExporterLimitLanguagesKeyPath], BLDictionaryLimitLanguagesFilterSetting,
									nil];
			dictionary.filterSettings = filter;
		}

		// Add keys and save
		[dictionary addKeys:[BLObject keyObjectsFromArray:objects]];
		[dictionary writeToURL:[panel URL] ofType:@"" error:NULL];
	}];
}

#pragma mark - Interface

@synthesize languages = _languages;

- (NSString *)languageList {
	return [[self.languages valueForKey:@"languageDescription"] componentsJoinedByString:@", "];
}

+ (NSSet *)keyPathsForValuesAffectingLanguageList {
	return [NSSet setWithObject:@"languages"];
}

@end
