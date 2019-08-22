/*!
 @header
 LTKeyMatch.m
 Created by max on 16.08.06.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "LTKeyMatch.h"

@implementation LTKeyMatch

- (id)initWithKeyObject:(BLKeyObject *)match matchPercentage:(float)percentage forTargetLanguage:(NSString *)language actualTargetLanguage:(NSString *)actualLanguage andMatchLanguage:(NSString *)matchLanguage
{
	self = [super init];
	
	if (self) {
		_actualTargetLanguage = actualLanguage;
		_targetLanguage = language;
		_object = match;
		_percentage = percentage;
		_matchLanguage = matchLanguage;
	}
	
	return self;
}



#pragma mark - Attribute Accessors

- (BLKeyObject *)keyObject
{
	return _object;
}

- (float)matchPercentage
{
	return _percentage;
}

- (NSString *)targetLanguage
{
	return _targetLanguage;
}

- (NSString *)actualTargetLanguage
{
	return _actualTargetLanguage;
}

- (NSString *)matchLanguage
{
	return _matchLanguage;
}


#pragma mark - Display Accessors

- (NSAttributedString *)percentageString
{
	NSAttributedString *result;
	NSColor *color;
	
	if (_percentage == 1.0)
		color = [NSColor colorWithDeviceRed:0 green:0.5 blue:0 alpha:1.0];
	else if (_percentage >= 0.75)
		color = [NSColor colorWithDeviceRed:0.9 green:0.6 blue:0 alpha:1.0];
	else if (_percentage >= 0.5)
		color = [NSColor colorWithDeviceRed:0.8 green:0 blue:0 alpha:1.0];
	else
		color = [NSColor textColor];
	
	result = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%0.0f%%", 100*[self matchPercentage]]
											 attributes:[NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName]];
	
	return result;
}

- (NSString *)matchedValue
{
	return [_object stringForLanguage: _matchLanguage];
}

- (NSString *)targetValue
{
	NSString *language = (_actualTargetLanguage) ? _actualTargetLanguage : _targetLanguage;
	return [_object stringForLanguage: language];
}


#pragma mark - Others

- (BOOL)isEqual:(id)object
{
	return ([[self matchedValue] isEqual: [object matchedValue]] && [[self targetValue] isEqual: [object targetValue]]);
}

@end
