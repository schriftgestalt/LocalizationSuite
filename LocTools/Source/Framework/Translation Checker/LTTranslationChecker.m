/*!
 @header
 LTTranslationChecker.m
 Created by max on 24.02.05.

 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "LTTranslationChecker.h"
#import "LTTranslationProblem.h"

NSString *LTTranslationCheckerQuotesFileName = @"LTTranslationCheckerQuotes.plist";

// Global variables holding the working data of the checker
NSArray *LTTranslationCheckerDefaultPlaceholders;
NSArray *LTTranslationCheckerDoubleQuoteCharacters;
NSArray *LTTranslationCheckerIgnorePlaceholders;
NSDictionary *LTTranslationCheckerStandardQuotes;
NSArray *LTTranslationCheckerSingleQuoteCharacters;
NSArray *LTTranslationCheckerStringEndingCharacters;
NSDictionary *LTTranslationCheckerWhitespaceReplacements;

NSUInteger LTTranslationCheckerMinDeviationLength = 10;
CGFloat LTTranslationCheckerMaxLengthDeviation = 50;

/*!
 @abstract Internal methods of LTTranslationChecker.
 */
@interface LTTranslationChecker (LTTranslationCheckerInternal)

/*!
 @abstract Calculates placeholder mismatchs.
 */
+ (NSArray *)getPlaceholderErrorsFromOrginal:(NSString *)original andTranslation:(NSString *)translated;

/*!
 @abstract Calculates warnings for significant length differences (>25%)
 */
+ (NSArray *)getLengthWarningsFromOrginal:(NSString *)original andTranslation:(NSString *)translated;

/*!
 @abstract Calculates problems with trailing and leading whitespace.
 */
+ (NSArray *)getWhitespaceErrorsFromOrginal:(NSString *)original andTranslation:(NSString *)translated;

/*!
 @abstract Calculates mismatchs of the last non-whitespace character like "..."
 */
+ (NSArray *)getLineEndingErrorsFromOrginal:(NSString *)original andTranslation:(NSString *)translated;

/*!
 @abstract Calculates problems with the quotes used in the translation.
 */
+ (NSArray *)getQuoteErrorsFromTranslation:(NSString *)translated andLanguage:(NSString *)language;

/*!
 @abstract Replaces all whitespace characters in a given string by human-readable placeholders.
 @discussion See the initialization LTTranslationCheckerWhitespaceReplacements for details.
 */
+ (NSString *)replaceWhitespaceCharactersInString:(NSString *)string;

@end

/*!
 @abstract Internal methods of LTTranslationProblem used by LTTranslationChecker
 */
@interface LTTranslationProblem (LTTranslationProblemInternal)

- (id)initWithType:(LTTranslationProblemType)type description:(NSString *)description andFix:(NSString *)fixedValue;
- (void)setKeyObject:(BLKeyObject *)keyObject language:(NSString *)language referenceLanguage:(NSString *)referenceLanguage;

@end

@implementation LTTranslationChecker

+ (void)initialize {
	[super initialize];

	LTTranslationCheckerDefaultPlaceholders = [NSArray arrayWithObjects:@"%*@", @"^C", @"%*d", @"%*f", @"%*s", @"%c", @"%*x", @"%*i", @"%*u", nil];
	LTTranslationCheckerIgnorePlaceholders = [NSArray arrayWithObjects:@"%%", @"%_", nil];

	LTTranslationCheckerStringEndingCharacters = [NSArray arrayWithObjects:@":", @";", @".", @"…", @"!", @"?", @")", @"]", @"}", @">", @"。", nil];

	LTTranslationCheckerWhitespaceReplacements = [NSDictionary dictionaryWithObjectsAndKeys:@"<return>", @"\n", @"<tab>", @"\t", @"<space>", @" ", nil];

	LTTranslationCheckerStandardQuotes = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[LTTranslationCheckerQuotesFileName stringByDeletingPathExtension] ofType:[LTTranslationCheckerQuotesFileName pathExtension]]];
	LTTranslationCheckerSingleQuoteCharacters = [NSArray arrayWithObjects:@"'", @"\u201A", @"’", @"‘", @"´", @"`", @"‹", @"›", @"「", @"」", nil];
	LTTranslationCheckerDoubleQuoteCharacters = [NSArray arrayWithObjects:@"\"", @"„", @"”", @"“", @"«", @"»", @"『", @"』", nil];
}

#pragma mark - Main

+ (NSArray *)calculateTranslationErrorsForKeyObject:(BLKeyObject *)object forLanguage:(NSString *)language withReference:(NSString *)refLanguage {
	NSString *original, *translated;
	NSMutableArray *problems;

	// Init
	problems = [NSMutableArray array];
	original = [object stringForLanguage:refLanguage];
	translated = [object stringForLanguage:language];

	if (![original length] || ![translated length])
		return problems;

	// Calculate
	[problems addObjectsFromArray:[self getPlaceholderErrorsFromOrginal:original andTranslation:translated]];
	[problems addObjectsFromArray:[self getLengthWarningsFromOrginal:original andTranslation:translated]];
	[problems addObjectsFromArray:[self getWhitespaceErrorsFromOrginal:original andTranslation:translated]];
	[problems addObjectsFromArray:[self getLineEndingErrorsFromOrginal:original andTranslation:translated]];
	[problems addObjectsFromArray:[self getQuoteErrorsFromTranslation:translated andLanguage:language]];

	// Additional information
	for (NSUInteger i = 0; i < [problems count]; i++)
		[[problems objectAtIndex:i] setKeyObject:object language:language referenceLanguage:refLanguage];

	// Finished
	return problems;
}

#pragma mark - Steps

+ (NSArray *)getPlaceholderErrorsFromOrginal:(NSString *)original andTranslation:(NSString *)translated {
	NSArray *origPlaceholders, *transPlaceholders;
	LTTranslationProblem *problem;
	NSString *description, *fix;
	NSMutableArray *problems;
	NSUInteger i, max;
	NSRange range;

	origPlaceholders = [self extractPlaceholdersFromString:original];
	transPlaceholders = [self extractPlaceholdersFromString:translated];
	problems = [NSMutableArray array];

	// count
	if ([transPlaceholders count] != [origPlaceholders count]) {
		description = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Wrong placeholder count", @"LTTranslationChecker", [NSBundle bundleForClass:[self class]], nil), [origPlaceholders count], [transPlaceholders count]];
		problem = [[LTTranslationProblem alloc] initWithType:LTTranslationProblemError description:description andFix:nil];
		[problems addObject:problem];
	}

	// elements
	max = fmin([transPlaceholders count], [origPlaceholders count]);

	for (i = 0; i < max; i++) {
		NSDictionary *placeholderObject, *origPlaceholderObject;
		NSString *placeholder, *origPlaceholder;

		placeholderObject = [transPlaceholders objectAtIndex:i];
		placeholder = [placeholderObject objectForKey:@"placeholder"];
		range = [[placeholderObject objectForKey:@"range"] rangeValue];

		origPlaceholderObject = [origPlaceholders objectAtIndex:i];
		origPlaceholder = [origPlaceholderObject objectForKey:@"placeholder"];

		if (![placeholder isEqual:origPlaceholder]) {
			description = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Wrong placeholder at index", @"LTTranslationChecker", [NSBundle bundleForClass:[self class]], nil), i + 1, origPlaceholder, placeholder];
			fix = [NSString stringWithFormat:@"%@%@%@", [translated substringToIndex:range.location], origPlaceholder, [translated substringFromIndex:NSMaxRange(range)]];

			problem = [[LTTranslationProblem alloc] initWithType:LTTranslationProblemError description:description andFix:fix];
			[problems addObject:problem];
		}
	}

	return problems;
}

+ (NSArray *)getLengthWarningsFromOrginal:(NSString *)original andTranslation:(NSString *)translated {
	CGFloat origLength = [original length];
	CGFloat transLength = [translated length];

	if (transLength - origLength > LTTranslationCheckerMinDeviationLength && transLength > origLength * (1. + LTTranslationCheckerMaxLengthDeviation / 100)) {
		NSString *description = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Significant length difference", @"LTTranslationChecker", [NSBundle bundleForClass:[self class]], nil), (NSUInteger)LTTranslationCheckerMaxLengthDeviation];
		return [NSArray arrayWithObject:[[LTTranslationProblem alloc] initWithType:LTTranslationProblemWarning description:description andFix:nil]];
	}

	return [NSArray array];
}

+ (NSArray *)getWhitespaceErrorsFromOrginal:(NSString *)original andTranslation:(NSString *)translated {
	NSString *origWhitespace, *transWhitespace;
	LTTranslationProblem *problem;
	NSString *description, *fix;
	NSMutableArray *problems;
	NSCharacterSet *set;

	set = [[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
	problems = [NSMutableArray array];

	// front
	origWhitespace = [original substringToIndex:[original rangeOfCharacterFromSet:set].location];
	transWhitespace = [translated substringToIndex:[translated rangeOfCharacterFromSet:set].location];

	if (![origWhitespace isEqual:transWhitespace]) {
		description = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Mismatching leading whitespace", @"LTTranslationChecker", [NSBundle bundleForClass:[self class]], nil), [self replaceWhitespaceCharactersInString:origWhitespace], [self replaceWhitespaceCharactersInString:transWhitespace]];
		fix = [origWhitespace stringByAppendingString:[translated substringFromIndex:[transWhitespace length]]];

		problem = [[LTTranslationProblem alloc] initWithType:LTTranslationProblemWarning description:description andFix:fix];
		[problems addObject:problem];
	}

	// back
	origWhitespace = [original substringFromIndex:NSMaxRange([original rangeOfCharacterFromSet:set options:NSBackwardsSearch])];
	transWhitespace = [translated substringFromIndex:NSMaxRange([translated rangeOfCharacterFromSet:set options:NSBackwardsSearch])];

	if (![origWhitespace isEqual:transWhitespace]) {
		description = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Mismatching trailing whitespace", @"LTTranslationChecker", [NSBundle bundleForClass:[self class]], nil), [self replaceWhitespaceCharactersInString:origWhitespace], [self replaceWhitespaceCharactersInString:transWhitespace]];
		fix = [[translated substringToIndex:[translated length] - [transWhitespace length]] stringByAppendingString:origWhitespace];

		problem = [[LTTranslationProblem alloc] initWithType:LTTranslationProblemWarning description:description andFix:fix];
		[problems addObject:problem];
	}

	return problems;
}

+ (NSArray *)getLineEndingErrorsFromOrginal:(NSString *)original andTranslation:(NSString *)translated {
	NSString *origEnding, *transEnding;
	NSRange origRange, transRange;
	NSString *description, *fix;
	NSString *transWhitespace;
	NSCharacterSet *whiteSet;
	NSMutableCharacterSet *endSet;
	NSUInteger origEnd, transEnd;

	whiteSet = [[NSCharacterSet whitespaceAndNewlineCharacterSet] invertedSet];
	endSet = [NSMutableCharacterSet characterSetWithCharactersInString:[LTTranslationCheckerStringEndingCharacters objectAtIndex:0]];
	for (NSUInteger i = 1; i < [LTTranslationCheckerStringEndingCharacters count]; i++)
		[endSet addCharactersInString:[LTTranslationCheckerStringEndingCharacters objectAtIndex:i]];
	[endSet invert];

	origEnd = NSMaxRange([original rangeOfCharacterFromSet:whiteSet options:NSBackwardsSearch]);
	origRange.location = NSMaxRange([original rangeOfCharacterFromSet:endSet options:NSBackwardsSearch range:NSMakeRange(0, origEnd)]);
	origRange.length = origEnd - origRange.location;

	transEnd = NSMaxRange([translated rangeOfCharacterFromSet:whiteSet options:NSBackwardsSearch]);
	transRange.location = NSMaxRange([translated rangeOfCharacterFromSet:endSet options:NSBackwardsSearch range:NSMakeRange(0, transEnd)]);
	transRange.length = transEnd - transRange.location;

	transWhitespace = [translated substringFromIndex:transEnd];
	origEnding = [original substringWithRange:origRange];
	transEnding = [translated substringWithRange:transRange];
	if ([origEnding isEqualToString:@"。"]) {
		origEnding = @".";
	}
	if ([transEnding isEqualToString:@"。"]) {
		transEnding = @".";
	}
	if (![origEnding isEqual:transEnding]) {
		description = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Mismatching string ending", @"LTTranslationChecker", [NSBundle bundleForClass:[self class]], nil), origEnding, transEnding];
		fix = [NSString stringWithFormat:@"%@%@%@", [translated substringToIndex:[translated length] - [transWhitespace length] - [transEnding length]], origEnding, transWhitespace];

		return [NSArray arrayWithObject:[[LTTranslationProblem alloc] initWithType:LTTranslationProblemWarning description:description andFix:fix]];
	}
	else {
		return [NSArray array];
	}
}

+ (NSArray *)getQuoteErrorsFromTranslation:(NSString *)translated andLanguage:(NSString *)language {
	NSMutableArray *quoteChars, *quotes, *problems;
	LTTranslationProblem *problem;
	NSString *description, *fix;
	NSArray *quotingStyles;
	NSUInteger i, j;

	// Init
	problems = [NSMutableArray array];

	// Get styles
	quotingStyles = [LTTranslationCheckerStandardQuotes objectForKey:language];

	if (quotingStyles == nil) {
		NSArray *keys;
		NSString *key;

		keys = [LTTranslationCheckerStandardQuotes allKeys];

		for (i = 0; i < [keys count]; i++) {
			key = [keys objectAtIndex:i];

			if ([[language substringToIndex:[key length]] isEqual:key]) {
				quotingStyles = [LTTranslationCheckerStandardQuotes objectForKey:key];
				break;
			}
		}
	}

	// Style unknown
	if (quotingStyles == nil)
		return problems;

	// Extract all quote characters
	quoteChars = [NSMutableArray array];
	for (i = 0; i < [translated length]; i++) {
		NSString *character;
		character = [translated substringWithRange:NSMakeRange(i, 1)];

		if ([LTTranslationCheckerSingleQuoteCharacters containsObject:character] || [LTTranslationCheckerDoubleQuoteCharacters containsObject:character])
			[quoteChars addObject:[NSDictionary dictionaryWithObjectsAndKeys:character, @"character", [NSNumber numberWithInt:i], @"index", nil]];
	}

	// No quotes
	if (![quoteChars count])
		return problems;

	// Find quotes
	NSMutableArray *stack;

	stack = [NSMutableArray array];
	quotes = [NSMutableArray array];

	for (i = 0; i < [quoteChars count]; i++) {
		NSString *character;
		character = [[quoteChars objectAtIndex:i] objectForKey:@"character"];

		if (![stack count] || [LTTranslationCheckerDoubleQuoteCharacters containsObject:[[stack lastObject] objectForKey:@"character"]] != [LTTranslationCheckerDoubleQuoteCharacters containsObject:character]) {
			// Quote started
			[stack addObject:[quoteChars objectAtIndex:i]];
		}
		else {
			// Quote ended
			[quotes addObject:[NSDictionary dictionaryWithObjectsAndKeys:[stack lastObject], @"begin", [quoteChars objectAtIndex:i], @"end", [NSNumber numberWithInt:[stack count]], @"level", nil]];
			[stack removeLastObject];
		}
	}

	// No quotes
	if (![quotes count])
		return problems;

	// Check quotes
	for (i = 0; i < [quotes count]; i++) {
		NSString *begin, *end, *fixBegin, *fixEnd;
		NSUInteger beginIndex, endIndex, level;
		NSDictionary *quote, *style;

		quote = [quotes objectAtIndex:i];
		begin = [quote valueForKeyPath:@"begin.character"];
		end = [quote valueForKeyPath:@"end.character"];
		beginIndex = [[quote valueForKeyPath:@"begin.index"] intValue];
		endIndex = [[quote valueForKeyPath:@"end.index"] intValue];
		level = [[quote valueForKey:@"level"] intValue];

		// Look for matching style
		for (j = 0; j < [quotingStyles count]; j++) {
			style = [quotingStyles objectAtIndex:j];

			if ((level % 2 == 1 && [begin isEqual:[style objectForKey:@"begin"]] && [end isEqual:[style objectForKey:@"end"]]) || (level % 2 == 0 && [begin isEqual:[style objectForKey:@"sndBegin"]] && [end isEqual:[style objectForKey:@"sndEnd"]]))
				break;
		}
		if (j != [quotingStyles count] || ![quotingStyles count])
			continue;

		// Otherwise produce error
		style = [quotingStyles objectAtIndex:0];

		if (level % 2 == 1) {
			fixBegin = [style objectForKey:@"begin"];
			fixEnd = [style objectForKey:@"end"];
		}
		else {
			fixBegin = [style objectForKey:@"sndBegin"];
			fixEnd = [style objectForKey:@"sndEnd"];
		}

		description = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"Mismatching quoting style", @"LTTranslationChecker", [NSBundle bundleForClass:[self class]], nil), fixBegin, fixEnd, begin, end];
		fix = [NSString stringWithFormat:@"%@%@%@%@%@", [translated substringToIndex:beginIndex], fixBegin, [translated substringWithRange:NSMakeRange(beginIndex + 1, endIndex - beginIndex - 1)], fixEnd, [translated substringFromIndex:endIndex + 1]];

		problem = [[LTTranslationProblem alloc] initWithType:LTTranslationProblemWarning description:description andFix:fix];
		[problems addObject:problem];
	}

	return problems;
}

#pragma mark - Utilites

+ (NSArray *)extractPlaceholdersFromString:(NSString *)string {
	NSMutableArray *placeholders = [NSMutableArray array];

	// Init
	NSMutableCharacterSet *startSet = [NSMutableCharacterSet characterSetWithCharactersInString:@""];
	NSCharacterSet *whitespaceSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];

	for (NSString *str in LTTranslationCheckerDefaultPlaceholders)
		[startSet addCharactersInString:[str substringToIndex:1]];
	for (NSString *str in LTTranslationCheckerIgnorePlaceholders)
		[startSet addCharactersInString:[str substringToIndex:1]];

	// Search
	NSUInteger index = 0;
	while (index < [string length]) {
		unichar character = [string characterAtIndex:index];

		// Run through the string to a possible match
		if (![startSet characterIsMember:character]) {
			index++;
			continue;
		}

		// Calculate the initial possibilities
		NSMutableArray *remaining = [NSMutableArray array];
		NSUInteger length = 1;

		for (NSString *str in LTTranslationCheckerDefaultPlaceholders) {
			if ([str characterAtIndex:0] == [string characterAtIndex:index])
				[remaining addObject:str];
		}
		for (NSString *str in LTTranslationCheckerIgnorePlaceholders) {
			if ([str characterAtIndex:0] == [string characterAtIndex:index])
				[remaining addObject:str];
		}

		// Find static matches
		BOOL match = NO;

		for (NSUInteger i = 0; i < [remaining count]; i++) {
			NSString *target = [remaining objectAtIndex:i];

			if ([target rangeOfString:@"*"].location != NSNotFound)
				continue;

			if (([string length] >= index + [target length]) && [[string substringWithRange:NSMakeRange(index, [target length])] isEqual:target]) {
				match = YES;
				length = [target length];
				index += length;

				break;
			}
			else {
				[remaining removeObjectAtIndex:i--];
				continue;
			}
		}

		// Go to the next character and check for matches
		while (!match && [remaining count] && index + 1 < [string length]) {
			index++;
			length++;

			unichar character = [string characterAtIndex:index];

			// Whitespace ends a placeholder - if not yet found we have none
			if ([whitespaceSet characterIsMember:character])
				break;

			for (NSUInteger i = 0; i < [remaining count]; i++) {
				NSString *target = [remaining objectAtIndex:i];
				NSUInteger asterisk = [target rangeOfString:@"*"].location;

				if (asterisk >= length) {
					if (character != [target characterAtIndex:length - 1])
						[remaining removeObjectAtIndex:i--];
					continue;
				}
				if (asterisk == length - 1) {
					target = [target substringFromIndex:asterisk];
					[remaining replaceObjectAtIndex:i withObject:target];
				}
				target = [target substringFromIndex:1];

				if ([[string substringWithRange:NSMakeRange(index, [target length])] isEqual:target]) {
					match = YES;
					length += [target length] - 1;
					index += [target length];
					break;
				}
			}
		}

		if (match)
			[placeholders addObject:[NSDictionary dictionaryWithObjectsAndKeys:[string substringWithRange:NSMakeRange(index - length, length)], @"placeholder", [NSValue valueWithRange:NSMakeRange(index - length, length)], @"range", nil]];
		else
			index++;
	}

	// Resort placeholders, if they contain positional information
	BOOL match = YES;

	for (NSUInteger i = 0; i < [placeholders count]; i++) {
		NSDictionary *placeholder = [placeholders objectAtIndex:i];

		if ([LTTranslationCheckerIgnorePlaceholders containsObject:[placeholder objectForKey:@"placeholder"]]) {
			[placeholders removeObjectAtIndex:i--];
			continue;
		}

		if ([[placeholder objectForKey:@"placeholder"] rangeOfString:@"$"].location == NSNotFound) {
			match = NO;
			break;
		}
	}

	if (match) {
		// All placeholders are positional, so resort them
		NSMutableArray *remaining = placeholders;
		placeholders = [NSMutableArray array];
		NSUInteger i = 1;

		while ([remaining count] && i <= [remaining count] + [placeholders count]) {

			for (NSUInteger j = 0; j < [remaining count]; j++) {
				NSDictionary *placeholder = [remaining objectAtIndex:j];
				NSString *tmp = [placeholder objectForKey:@"placeholder"];

				index = [[tmp substringWithRange:NSMakeRange(1, [tmp rangeOfString:@"$"].location - 1)] intValue];

				if (index == i) {
					[placeholders addObject:placeholder];
					[remaining removeObjectAtIndex:j];
					break;
				}
			}

			i++;
		}

		[placeholders addObjectsFromArray:remaining];
	}

	return placeholders;
}

+ (NSString *)replaceWhitespaceCharactersInString:(NSString *)string {
	NSMutableString *newString;
	NSString *character;
	unsigned index;

	newString = [NSMutableString string];

	for (index = 0; index < [string length]; index++) {
		character = [string substringWithRange:NSMakeRange(index, 1)];

		if ([LTTranslationCheckerWhitespaceReplacements objectForKey:character])
			[newString appendString:[LTTranslationCheckerWhitespaceReplacements objectForKey:character]];
		else
			[newString appendString:character];
	}

	return newString;
}

@end
