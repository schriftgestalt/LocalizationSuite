/*!
 @header
 BLNibConverterStep.m
 Created by Max on 07.05.09.
 
 @copyright 2004-2009 the Localization Suite Foundation. All rights reserved.
 */

#import "BLNibConverterStep.h"

#import "BLNibFileObject.h"


/*!
 @abstract Internal methods of BLNibConverterStep.
 */
@interface BLNibConverterStep (BLNibConverterStepInternal)

- (id)initForConvertingObject:(BLNibFileObject *)object;

@end


@implementation BLNibConverterStep

+ (NSArray *)stepGroupForUpgradingObjects:(NSArray *)objects
{
	NSMutableArray *steps;
	
	objects = [BLObject fileObjectsFromArray: objects];
	objects = [BLObject proxiesForObjects: objects];
	
	steps = [NSMutableArray arrayWithCapacity: [objects count]];
	
	for (NSUInteger i=0; i<[objects count]; i++) {
		BLFileObject *object = [objects objectAtIndex: i];
		if ([object isKindOfClass: [BLNibFileObject class]])
			[steps addObject: [[self alloc] initForConvertingObject: (BLNibFileObject *)object]];
	}
	
	return steps;
}

- (id)initForConvertingObject:(BLNibFileObject *)object
{
	self = [super init];
	
	if (self) {
		_fileObject = object;
		_language = nil;
	}
	
	return self;
}



#pragma mark - Accessors

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
	if ([key isEqual: @"description"])
		return [NSSet setWithObject: @"language"];
	else
		return [super keyPathsForValuesAffectingValueForKey: key];
}


#pragma mark - Runtime

- (void)updateDescription
{
	self.action = NSLocalizedStringFromTableInBundle(@"Converting", @"BLProcessStep", [NSBundle bundleForClass: [self class]], nil);
}

- (void)perform
{
	NSDocument <BLDocumentProtocol> *document;
	BOOL success;
	
	// Init
	document = [[self manager] document];
	success = YES;
	
	// Upgrade files
	for (NSString *language in [self manager].document.languages) {
		self.description = [NSString stringWithFormat: NSLocalizedStringFromTableInBundle(@"ConvertingText", @"BLProcessStep", [NSBundle bundleForClass: [self class]], nil), [_fileObject name], [[_fileObject bundleObject] name], [BLLanguageTranslator descriptionForLanguage: language]];
		success = success && [BLNibFileConverter upgradeFileForObject:_fileObject fromDocument:document withLanguage:language];
	}
	
	// Update database
	if (success) {
		NSString *path = [_fileObject path];
		path = [[path stringByDeletingPathExtension] stringByAppendingPathExtension: @"xib"];
		[_fileObject setPath: path];
	}
}

@end
