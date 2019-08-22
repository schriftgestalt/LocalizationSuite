//
//  EditorController.m
//  Localizer
//
//  Created by Max on 04.12.04.
//  Copyright 2004 The Blue Technologies Group. All rights reserved.
//

#import "Editor.h"

#import "Document.h"

#import <BlueLocalization/BLRTFDKeyObject.h>


// Constants
NSColor *BackgroundColorEditable;
NSColor *BackgroundColorNotEditable;

// Implemantation
@interface Editor (EditorControllerInternal)

- (void)updateMatches;

- (void)updateTranslationErrors;
- (void)notifyUpdateTranslationErrors;

- (NSAttributedString *)valueForObject:(id)object;
- (id)objectFromString:(NSAttributedString *)string withClass:(Class)class;

@end

@implementation Editor

+ (void)initialize
{
	[super initialize];
	
	BackgroundColorEditable = [NSColor textBackgroundColor];
	BackgroundColorNotEditable = [NSColor controlBackgroundColor];
}

- (id)init
{
	self = [super init];
	
	matchesTableView = nil;
	
	_errorsCache = nil;
	_errorsTimer = nil;
	_matchingEnabled = YES;
	_matchesCache = nil;
	
	_matcher = [[LTSingleKeyMatcher alloc] init];
	[_matcher setDelegate: self];
	
	return self;
}

- (void)dealloc
{
	if (_errorsTimer) [_errorsTimer invalidate];
	
}


#pragma mark - Implementation Overrides

- (void)setUp
{
	[document addObserver:self forKeyPath:@"selectedObject" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
	[document addObserver:self forKeyPath:@"preferences.showTranslationProblems" options:0 context:@"ERROR"];
	
	[[BLDictionaryController sharedInstance] addObserver:self forKeyPath:@"useDocuments" options:0 context:@"MATCH"];
	[[BLDictionaryController sharedInstance] addObserver:self forKeyPath:@"availableKeys" options:0 context:@"MATCH"];
	
	[leftEditor bind:@"backgroundColor" toObject:self withKeyPath:@"leftBackgroundColor" options:nil];
	[rightEditor bind:@"backgroundColor" toObject:self withKeyPath:@"rightBackgroundColor" options:nil];
	
	[leftEditor setTextContainerInset:NSMakeSize(25, 6)];
	[rightEditor setTextContainerInset:NSMakeSize(10, 6)];
	NSRect scrollerFrame = [[leftEditor enclosingScrollView] frame];
	NSRect textFrame = [leftEditor frame];
	textFrame.size.width = NSWidth(scrollerFrame);
	[leftEditor setFrame:textFrame];
	
	scrollerFrame = [[rightEditor enclosingScrollView] frame];
	textFrame = [rightEditor frame];
	textFrame.size.width = NSWidth(scrollerFrame);
	[rightEditor setFrame:textFrame];
}

- (void)cleanUp
{
	[document removeObserver:self forKeyPath:@"selectedObject"];
	[document removeObserver:self forKeyPath:@"preferences.showTranslationProblems"];
	
	[[BLDictionaryController sharedInstance] removeObserver:self forKeyPath:@"useDocuments"];
	[[BLDictionaryController sharedInstance] removeObserver:self forKeyPath:@"availableKeys"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (object == document && [keyPath isEqual: @"selectedObject"]) {
		// Remove observation
		id oldObject = [change objectForKey: NSKeyValueChangeOldKey];
		if (oldObject != [NSNull null]) {
			@try {
				[oldObject removeObserver:self forKeyPath:[[document preferences] objectForKey: DocumentViewOptionLeftLanguage]];
				[oldObject removeObserver:self forKeyPath:[[document preferences] objectForKey: DocumentViewOptionRightLanguage]];
			}
			@catch (NSException *e) {}
		}
		
		// Save changes
		NSWindow *window = [leftEditor window];
		if ([window firstResponder] == leftEditor)
			[window endEditingFor: leftEditor];
		if ([window firstResponder] == rightEditor)
			[window endEditingFor: rightEditor];
		
		// Update contents
		[self willChangeValueForKey: @"selectedObject"];
		[self didChangeValueForKey: @"selectedObject"];
		
		// Set rich text
		BOOL richText = [[document selectedObject] isKindOfClass: [BLRTFDKeyObject class]];
		[leftEditor setUsesFontPanel: richText];
		[rightEditor setUsesFontPanel: richText];
		
		// Add observation
		id newObject = [change objectForKey: NSKeyValueChangeNewKey];
		if (newObject != [NSNull null]) {
			[newObject addObserver:self forKeyPath:[[document preferences] objectForKey: DocumentViewOptionLeftLanguage] options:0 context:@"content"];
			[newObject addObserver:self forKeyPath:[[document preferences] objectForKey: DocumentViewOptionRightLanguage] options:0 context:@"content"];
		}
	}
	
	if (context == nil || context == @"MATCH")
		[self updateMatches];
	if (context == nil)
		[self updateTranslationErrors];
	if (context == @"ERROR" || context == @"content")
		[self notifyUpdateTranslationErrors];
	if (context == @"content") {
		[self willChangeValueForKey: @"selectedObject"];
		[self didChangeValueForKey: @"selectedObject"];
	}
	
	[leftEditor updateCurrentObjects];
	[rightEditor updateCurrentObjects];
}

#pragma mark - Content

- (Document *)document
{
	return document;
}

- (NSString *)comment
{
	if ([document selectedObject] != nil)
		return [[document selectedObject] comment];
	else
		return @"";
}

- (void)setComment:(NSString *)aComment
{
	if ([document selectedObject] != nil) {
		[[document selectedObject] setComment: aComment];
		[document updateChangeCount: NSChangeDone];
	}
}

+ (NSSet *)keyPathsForValuesAffectingComment
{
	return [NSSet setWithObjects: @"selectedObject", nil];
}

- (id)valueForLeftLanguage
{
	if ([document selectedObject] != nil)
		return [self valueForObject: [[document selectedObject] objectForLanguage: [[document preferences] objectForKey: DocumentViewOptionLeftLanguage]]];
	else
		return NSNoSelectionMarker;
}

- (void)setValueForLeftLanguage:(id)newValue
{
	id value;
	
	value = [self objectFromString:newValue withClass:[[[document selectedObject] class] classOfObjects]];
	
	if ([document selectedObject] != nil && ![[[document selectedObject] objectForLanguage: [[document preferences] objectForKey: DocumentViewOptionLeftLanguage]] isEqual: value]) {
		[[document selectedObject] setObject:value forLanguage:[[document preferences] objectForKey: DocumentViewOptionLeftLanguage]];
		[document updateChangeCount: NSChangeDone];
		
		[self notifyUpdateTranslationErrors];
	}
}

+ (NSSet *)keyPathsForValuesAffectingValueForLeftLanguage
{
	return [NSSet setWithObjects: @"selectedObject", @"document.preferences.leftLanguage", @"valueForRightLanguage", nil];
}

- (id)valueForRightLanguage
{
	if ([document selectedObject] != nil)
		return [self valueForObject: [[document selectedObject] objectForLanguage: [[document preferences] objectForKey: DocumentViewOptionRightLanguage]]];
	else
		return NSNoSelectionMarker;
}

- (void)setValueForRightLanguage:(id)newValue
{
	id value;
	
	value = [self objectFromString:newValue withClass:[[[document selectedObject] class] classOfObjects]];
	
	if ([document selectedObject] != nil && ![[[document selectedObject] objectForLanguage: [[document preferences] objectForKey: DocumentViewOptionRightLanguage]] isEqual: value]) {
		[[document selectedObject] setObject:value forLanguage:[[document preferences] objectForKey: DocumentViewOptionRightLanguage]];
		[document updateChangeCount: NSChangeDone];
		[self notifyUpdateTranslationErrors];
	}
}

+ (NSSet *)keyPathsForValuesAffectingValueForRightLanguage
{
	return [NSSet setWithObjects: @"selectedObject", @"document.preferences.rightLanguage", @"valueForLeftLanguage", nil];
}

#pragma mark - Matches

- (void)updateMatches
{
	NSString *language, *refLanguage;
	
	// Stop matcher
	if ([_matcher isRunning])
		[_matcher stop];
	
	// Only update of enabled
	if (!_matchingEnabled)
		return;
	
	// Get the languages
	if ([self leftFieldEditable]) {
		language = [[document preferences] objectForKey: DocumentViewOptionLeftLanguage];
		refLanguage = [[document preferences] objectForKey: DocumentViewOptionRightLanguage];
	} else {
		language = [[document preferences] objectForKey: DocumentViewOptionRightLanguage];
		refLanguage = [[document preferences] objectForKey: DocumentViewOptionLeftLanguage];
	}
	
	// Reset results and restart matcher
	[self setMatches: nil];
	
	[_matcher setMatchingKeyObjects: [[BLDictionaryController sharedInstance] availableKeys]];
	[_matcher setMatchLanguage: refLanguage];
	[_matcher setTargetKeyObject: [document selectedObject]];
	[_matcher setTargetLanguage: language];
	
	[_matcher start];
}

- (NSArray *)matches
{
	return _matchesCache;
}

@synthesize matches=_matchesCache;

- (void)addMatch:(LTKeyMatch *)match
{
	NSArray *matches = self.matches;
	
	if (![matches containsObject: match]) {
		if (matches)
			matches = [matches arrayByAddingObject: match];
		else
			matches = [NSArray arrayWithObject: match];
		
		self.matches = [matches sortedArrayUsingDescriptors:
						[NSArray arrayWithObject: [[NSSortDescriptor alloc] initWithKey:@"matchPercentage" ascending:NO]]];
	}
}

- (void)keyMatcher:(LTKeyMatcher *)matcher foundMatch:(LTKeyMatch *)match forKeyObject:(BLKeyObject *)target
{
	[self performSelectorOnMainThread:@selector(addMatch:) withObject:match waitUntilDone:NO];
}

- (IBAction)useMatch:(id)sender
{
	LTKeyMatch *match;
	
	match = [[matchesArrayController arrangedObjects] objectAtIndex: [sender clickedRow]];
	[self useKeyMatch: match];
}

- (void)useMatchAtIndex:(NSUInteger)index
{
	[self useKeyMatch: [self.matches objectAtIndex: index]];
}

- (void)useKeyMatch:(LTKeyMatch *)match
{
	if ([match matchPercentage] == 1.0) {
		BLKeyObject *object = document.selectedObject;
		[document selectNext: nil];
		
		if ([self rightFieldEditable])
			[object setObject:[match targetValue] forLanguage: [document.preferences objectForKey: DocumentViewOptionRightLanguage]];
		else
			[object setObject:[match targetValue] forLanguage: [document.preferences objectForKey: DocumentViewOptionLeftLanguage]];
		
		if ([self isEditing])
			[self beginEditing];
	}
	else {
		[self beginEditing];
		
		NSAttributedString *attrString = [[NSAttributedString alloc] initWithString: [match targetValue]];
		if ([self rightFieldEditable])
			[self setValueForRightLanguage: attrString];
		else
			[self setValueForLeftLanguage: attrString];
	}
}

- (BOOL)matchingEnabled
{
	return _matchingEnabled;
}

- (void)setMatchingEnabled:(BOOL)enabled
{
	if (_matchingEnabled != enabled) {
		_matchingEnabled = enabled;
		[self updateMatches];
	}
}

- (BOOL)guessingEnabled
{
	return [_matcher guessingIsEnabled];
}

- (void)setGuessingEnabled:(BOOL)enabled
{
	if ([_matcher guessingIsEnabled] != enabled) {
		[_matcher setGuessingIsEnabled: enabled];
		[self updateMatches];
	}
}

- (BOOL)useDocuments
{
	return [[BLDictionaryController sharedInstance] useDocuments];
}

- (void)setUseDocuments:(BOOL)enabled
{
	[[BLDictionaryController sharedInstance] setUseDocuments: enabled];
}


#pragma mark - Translation Errors

@synthesize translationErrors=_errorsCache;

- (void)updateTranslationErrors
{
	NSString *language, *refLanguage;
	
	if (_errorsTimer)
		_errorsTimer = nil;
	
	if ([self leftFieldEditable]) {
		language = [[document preferences] objectForKey: DocumentViewOptionLeftLanguage];
		refLanguage = [[document preferences] objectForKey: DocumentViewOptionRightLanguage];
	} else {
		language = [[document preferences] objectForKey: DocumentViewOptionRightLanguage];
		refLanguage = [[document preferences] objectForKey: DocumentViewOptionLeftLanguage];
	}
	
	if ([document selectedObject] && [[[document preferences] objectForKey: DocumentViewOptionShowProblems] boolValue])
		[self setTranslationErrors: [LTTranslationChecker calculateTranslationErrorsForKeyObject:[document selectedObject] forLanguage:language withReference:refLanguage]];
	else
		[self setTranslationErrors: nil];
}

- (void)notifyUpdateTranslationErrors
{
	if (!_errorsTimer)
		_errorsTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updateTranslationErrors) userInfo:nil repeats:NO];
}

- (IBAction)fixError:(id)sender
{
	LTTranslationProblem *problem;
	
	problem = [[errorsArrayController arrangedObjects] objectAtIndex: [sender clickedRow]];
	[problem fix];
	
	[self beginEditing];
	[self updateTranslationErrors];
}


#pragma mark - Interface Accessors

- (BOOL)leftFieldEditable
{
	return ![[[document preferences] objectForKey: DocumentViewOptionLeftLanguage] isEqual: [document referenceLanguage]];
}

+ (NSSet *)keyPathsForValuesAffectingLeftFieldEditable
{
	return [NSSet setWithObjects: @"document.preferences.leftLanguage", nil];
}

- (BOOL)rightFieldEditable
{
	return ![[[document preferences] objectForKey: DocumentViewOptionRightLanguage] isEqual: [document referenceLanguage]];
}

+ (NSSet *)keyPathsForValuesAffectingRightFieldEditable
{
	return [NSSet setWithObjects: @"document.preferences.rightLanguage", nil];
}

- (NSColor *)leftBackgroundColor
{
	if ([self leftFieldEditable])
		return BackgroundColorEditable;
	else
		return BackgroundColorNotEditable;
}

+ (NSSet *)keyPathsForValuesAffectingLeftBackgroundColor
{
	return [NSSet setWithObjects: @"document.preferences.leftLanguage", nil];
}

- (NSColor *)rightBackgroundColor
{
	if ([self rightFieldEditable])
		return BackgroundColorEditable;
	else
		return BackgroundColorNotEditable;
}

+ (NSSet *)keyPathsForValuesAffectingRightBackgroundColor
{
	return [NSSet setWithObjects: @"document.preferences.rightLanguage", nil];
}

- (BOOL)isEditing
{
	return ([[leftEditor window] firstResponder] == leftEditor) || ([[rightEditor window] firstResponder] == rightEditor);
}

- (void)beginEditing
{
	if ([self leftFieldEditable])
		[[leftEditor window] makeFirstResponder: leftEditor];
	else
		[[rightEditor window] makeFirstResponder: rightEditor];
}

#pragma mark - Value Transformers

- (NSAttributedString *)valueForObject:(id)object
{
	NSAttributedString *string = nil;
	
	if ([object isKindOfClass: [NSString class]])
		string = [[NSAttributedString alloc] initWithString: object];
	else if ([object isKindOfClass: [NSAttributedString class]])
		string = object;
	
	return string;
}

- (id)objectFromString:(NSAttributedString *)string withClass:(Class)class
{
	id object = nil;
	
	if ([class isSubclassOfClass: [NSString class]]) {
		if (![string isKindOfClass:class]) {
			object = [string string];
		}
		else {
			object = string;
		}
	}
	else if (class == [NSAttributedString class])
		object = string;
	
	return object;
}

#pragma mark - Statistics

- (NSArray *)currentObjectsInTextView:(StatisticsTextView *)textView
{
	return [NSArray arrayWithObject: [document selectedObject]];
}

- (NSArray *)currentLanguagesInTextView:(StatisticsTextView *)textView
{
	return [NSArray arrayWithObjects: [[document preferences] objectForKey: DocumentViewOptionLeftLanguage], [[document preferences] objectForKey:DocumentViewOptionRightLanguage], nil];
}

@end
