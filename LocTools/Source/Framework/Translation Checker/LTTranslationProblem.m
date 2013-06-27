/*!
 @header
 LTTranslationProblem.m
 Created by max on 28.05.09.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "LTTranslationProblem.h"

@implementation LTTranslationProblem

- (id)initWithType:(LTTranslationProblemType)type description:(NSString *)description andFix:(NSString *)fixedValue
{
	self = [super init];
	
	if (self) {
		_keyObject = nil;
		_language = nil;
		_referenceLanguage = nil;
		_type = type;
		_description = description;
		_fix = fixedValue;
	}
	
	return self;
}

- (void)setKeyObject:(BLKeyObject *)keyObject language:(NSString *)language referenceLanguage:(NSString *)referenceLanguage
{
	_keyObject = keyObject;
	_language = language;
	_referenceLanguage = referenceLanguage;
}



#pragma mark - Accessors

- (BLKeyObject *)keyObject
{
	return _keyObject;
}

- (NSString *)language
{
	return _language;
}

- (NSString *)referenceLanguage
{
	return _referenceLanguage;
}

- (LTTranslationProblemType)type
{
	return _type;
}

- (NSString *)description
{
	return _description;
}

- (BOOL)hasFix
{
	return (_fix != nil);
}

- (NSString *)fixedValue
{
	return _fix;
}

#pragma mark - Actions

- (void)fix
{
	if ([[[_keyObject class] classOfObjects] isSubclassOfClass: [NSString class]])
		[_keyObject setObject:_fix forLanguage:_language];
}

@end
