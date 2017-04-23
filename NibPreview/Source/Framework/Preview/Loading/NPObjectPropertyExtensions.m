/*!
 @header
 NPObjectPropertyExtensions.m
 Created by max on 02.03.09.
 
 @copyright 2008-2009 Localization Suite. All rights reserved.
 */

#import "NPObjectPropertyExtensions.h"

#import "NPFontAdditions.h"
#import "NPPreview.h"

#import <objc/runtime.h>


@implementation NSObject (NPObjectPropertyExtensions)

- (void)setChildren:(NSArray *)childs
{
}

- (void)setMappedValue:(id)value forKey:(NSString *)key
{
	if ([key hasPrefix: @"ib"])
		return;
	if ([key hasPrefix: @"designable"])
		return;
	if ([key hasSuffix: @"Designable"])
		return;
		
	[self setValue:value forKey:key];
}

- (void)initialize
{
}

- (void)finished
{
}

@end

@implementation NSActionCell (NPObjectPropertyExtensions)

- (void)setMappedValue:(id)value forKey:(NSString *)key
{
	if ([key isEqual: @"gBorderType"]) {
		switch ([value intValue]) {
			case 1:
				[self setBordered: YES];
				break;
			case 2:
				[self setBezeled: YES];
				break;
			default:
				[self setBordered: NO];
		}
		return;
	}
	if ([key isEqual: @"ibShadowedBorderStyle"]) {
		switch ([value intValue]) {
			case 2:
				[self setBordered: YES];
				break;
			case 3:
				[self setBezeled: YES];
				break;
			default:
				[self setBordered: NO];
		}
		return;
	}
	
	[super setMappedValue:value forKey:key];
}

@end

@implementation NSBox (NPObjectPropertyExtensions)

- (void)setMappedValue:(id)value forKey:(NSString *)key
{
	if ([key isEqual: @"titleFont"])
		value = [NSFont fontFromIBToolDictionary: value];
	
	[super setMappedValue:value forKey:key];
}

@end

@implementation NSBrowser (NPObjectPropertyExtensions)

- (void)setMappedValue:(id)value forKey:(NSString *)key
{
	if ([key isEqual: @"defaultNewColumnWidth"]) {
		return;
	}
	
	[super setMappedValue:value forKey:key];
}

@end

@implementation NSButtonCell (NPObjectPropertyExtensions)

- (void)setMappedValue:(id)value forKey:(NSString *)key
{
	if ([key isEqual: @"gButtonCellType"] || [key isEqual: @"ibShadowedButtonCellType"]) {
		key = @"buttonType";
		
		NSUInteger type;
		
		type = [value intValue];
		switch (type)
		{
			case 2:
				type = NSSwitchButton;
				break;
			case 3:
				type = NSRadioButton;
				break;
			case 4:
				type = NSMomentaryPushInButton;
				break;
		}
		
		value = [NSNumber numberWithInt:(int)type];
	}
	
	if ([key isEqual: @"gButtonBehavior"])
		return;
	
	if ([key isEqual: @"inset"]) {
		_bcFlags.inset = [value unsignedIntValue];
		return;
	}
	
	if ([key isEqual: @"ibImagePosition"])
		key = @"imagePosition";
	
	[super setMappedValue:value forKey:key];
}

@end

@implementation NSCell (NPObjectPropertyExtensions)

- (void)setMappedValue:(id)value forKey:(NSString *)key
{
	if ([key isEqual: @"font"])
		value = [NSFont fontFromIBToolDictionary: value];
	
	[super setMappedValue:value forKey:key];
}

@end

@implementation NSCollectionView (NPObjectPropertyExtensions)

- (void)setMappedValue:(id)value forKey:(NSString *)key
{
	if ([key isEqual: @"primaryBackgroundColor"]) {
		NSMutableArray *colors = [self mutableArrayValueForKey: @"backgroundColors"];
		if ([colors count] >= 2 && !value)
			[colors removeObjectAtIndex: 0];
		else if ([colors count] >= 1 && value)
			[colors replaceObjectAtIndex:0 withObject:value];
		else if (value)
			[colors addObject: value];
		return;
	}
	if ([key isEqual: @"secondaryBackgroundColor"]) {
		NSMutableArray *colors = [self mutableArrayValueForKey: @"backgroundColors"];
		if ([colors count] >= 2 && !value)
			[colors removeObjectAtIndex: 1];
		else if ([colors count] >= 2 && value)
			[colors replaceObjectAtIndex:1 withObject:value];
		else if (value)
			[colors addObject: value];
		return;
	}
	if ([[NSArray arrayWithObjects: @"hasSecondaryBackgroundColor", nil] containsObject: key])
		return;
	
	[super setMappedValue:value forKey:key];
}

@end

@implementation NSComboBoxCell (NPObjectPropertyExtensions)

- (void)setMappedValue:(id)value forKey:(NSString *)key
{
	if ([key isEqual: @"allowsOnlyRomanCharacters"] || [key isEqual: @"objectValuesCopy"])
		return;
	
	[super setMappedValue:value forKey:key];
}

@end

@implementation NSControl (NPObjectPropertyExtensions)

- (void)setChildren:(NSArray *)childs
{
	if ([childs count])
		[self setCell: [childs objectAtIndex: 0]];
}

- (void)setMappedValue:(id)value forKey:(NSString *)key
{
	[super setMappedValue:value forKey:key];
}

@end

@implementation NSDatePicker (NPObjectPropertyExtensions)

- (void)setMappedValue:(id)value forKey:(NSString *)key
{
	if ([key isEqual: @"hasMinDate"] || [key isEqual: @"hasMaxDate"])
		return;
	
	[super setMappedValue:value forKey:key];
}

@end

@implementation NSDatePickerCell (NPObjectPropertyExtensions)

- (void)initialize
{
	self.drawsBackground = YES;
}

- (void)setMappedValue:(id)value forKey:(NSString *)key
{
	if ([key isEqual: @"bordered"] || [key isEqual: @"hasMinDate"] || [key isEqual: @"hasMaxDate"])
		return;
	
	[super setMappedValue:value forKey:key];
}

@end

@implementation NSForm (NPObjectPropertyExtensions)

- (void)finished
{
	[self setTitleFont: [NSFont systemFontOfSize: [NSFont systemFontSizeForControlSize: [self.cell controlSize]]]];
}

@end

@implementation NSFormatter (NPObjectPropertyExtensions)

- (void)setMappedValue:(id)value forKey:(NSString *)key
{
	if ([key isEqualToString: @"format"])
		return;
	[super setMappedValue:value forKey:key];
}

@end

@implementation NSImageView (NPObjectPropertyExtensions)

- (void)finished
{
	if (![self image])
		[self setImage: [NSImage imageNamed: @"NSApplicationIcon"]];
}

@end

@implementation NSMatrix (NPObjectPropertyExtensions)

- (void)setChildren:(NSArray *)childs
{
	float height;
	NSInteger rows, cols;
	
	height = [self cellSize].height;
	height += [self intercellSpacing].height;
	if (height == 0)
		return;
	
	rows = roundf([self bounds].size.height / height);
	if (rows == 0)
		return;
	
	cols = ([childs count]-1) / rows;
	[self renewRows:rows columns:cols];
	
	for (NSUInteger i=0; i<[childs count]-1; i++) {
		NSInteger row, col;
		
		row = i%rows;
		col = i/rows;
		
		[self putCell:[childs objectAtIndex: i+1] atRow:row column:col];
	}
}

@end

@implementation NSMenu (NPObjectPropertyExtensions)

- (void)setChildren:(NSArray *)childs
{
	while ([self numberOfItems])
		[self removeItemAtIndex: 0];
	
	for (NSMenuItem *item in childs.reverseObjectEnumerator)
		[self addItem: item];
}

@end

@implementation NSMenuItem (NPObjectPropertyExtensions)

- (void)setChildren:(NSArray *)childs
{
	if ([childs count])
		[self setMenu: [childs objectAtIndex: 0]];
}

@end

@implementation NSNumberFormatter (NPObjectPropertyExtensions)

- (void)setMappedValue:(id)value forKey:(NSString *)key
{	
	if ([key isEqual: @"ibNumberFormatterBehavior"])
		return;
	if ([key isEqual: @"ibLocalizesFormat"])
		key = @"localizesFormat";
	
	[super setMappedValue:value forKey:key];
}

@end

@implementation NSPathCell (NPObjectPropertyExtensions)

- (void)finished
{
	if (![self URL])
		[self setURL: [NSURL URLWithString: @"file:///Applications/Utilities/Terminal.app"]];
}

@end

@implementation NSPopUpButtonCell (NPObjectPropertyExtensions)

- (void)setMappedValue:(id)value forKey:(NSString *)key
{	
	if ([key isEqual: @"ibShadowedBorderStyle"]) {
		[self setBordered: ![value boolValue]];
		return;
	}
	
	[super setMappedValue:value forKey:key];
}

- (void)setChildren:(NSArray *)childs
{
	if ([childs count])
		[self setMenu: [childs objectAtIndex: 0]];
}

@end

@implementation NSPredicateEditor (NPObjectPropertyExtensions)

- (void)setChildren:(NSArray *)childs
{
	[self setRowTemplates: childs];
}

@end

@implementation NSScrollView (NPObjectPropertyExtensions)

- (void)setChildren:(NSArray *)childs
{
	//NSScroller *scroller;
	NSUInteger used = 0;
	
	if (childs.count > used) {
		[self setDocumentView: [childs objectAtIndex: used++]];
	}
	if (childs.count > used && [[childs objectAtIndex: used] isKindOfClass: [NSScroller class]]) {
		//scroller = [childs objectAtIndex: used];
		//[self setHorizontalScroller: scroller];
		used++;
	}
	if (childs.count > used && [[childs objectAtIndex: used] isKindOfClass: [NSScroller class]]) {
		//scroller = [childs objectAtIndex: used];
		//[self setVerticalScroller: scroller];
		used++;
	}
	while (used < childs.count) {
		NSView *child = [childs objectAtIndex: used++];
		[self.contentView addSubview: child];
	}
}

- (void)setMappedValue:(id)value forKey:(NSString *)key
{
	if ([key isEqual: @"contentView.copiesOnScroll"])
		return;
	
	[super setMappedValue:value forKey:key];
}

- (void)finished
{
	[self setNeedsLayout: YES];
	[self layoutSubtreeIfNeeded];
	
//	[self flashScrollers];
}

@end

@implementation NSSegmentedCell (NPObjectPropertyExtensions)

- (void)setMappedValue:(id)value forKey:(NSString *)key
{
	if ([value isKindOfClass: [NSArray class]]) {
		NSArray *values;
		NSUInteger i;
		
		values = value;
		if ([self segmentCount] < [values count])
			[self setSegmentCount: [values count]];
		
		if ([key isEqual: @"labels"] || [key isEqual: @"ibShadowedLabels"]) {
			for (i=0; i<[values count]; i++)
				[self setLabel:[values objectAtIndex: i] forSegment:i];
			return;
		}
		if ([key isEqual: @"selectedStates"] || [key isEqual: @"ibShadowedSelectedStates"]) {
			for (i=0; i<[values count]; i++)
				[self setSelected:[[values objectAtIndex: i] boolValue] forSegment:i];
			return;
		}
		if ([key isEqual: @"tags"] || [key isEqual: @"ibShadowedTags"]) {
			for (i=0; i<[values count]; i++)
				[self setTag:[[values objectAtIndex: i] intValue] forSegment:i];
			return;
		}
		if ([key isEqual: @"widths"] || [key isEqual: @"ibShadowedWidths"]) {
			for (i=0; i<[values count]; i++)
				[self setWidth:[[values objectAtIndex: i] floatValue] forSegment:i];
			return;
		}
		if ([key isEqual: @"enabledStates"] || [key isEqual: @"ibShadowedEnabledStates"]) {
			for (i=0; i<[values count]; i++)
				[self setEnabled:[[values objectAtIndex: i] boolValue] forSegment:i];
			return;
		}
		if ([key isEqual: @"imageScalings"] || [key isEqual: @"ibShadowedImageScalings"]) {
			for (i=0; i<[values count]; i++)
				[self setImageScaling:[[values objectAtIndex: i] intValue] forSegment:i];
			return;
		}
	}
	if ([key hasPrefix: @"labels"]) {
		// String has format "labels[index]"
		NSUInteger index = [[key substringWithRange: NSMakeRange(7, [key length]-8)] intValue];
		[self setLabel:value forSegment:index];
		return;
	}
	
	if ([key isEqual: @"numberOfSegments"])
		return;
	
	[super setMappedValue:value forKey:key];
}

@end

@implementation NSSlider (NPObjectPropertyExtensions)

- (void)setMappedValue:(id)value forKey:(NSString *)key
{
	if ([[NSArray arrayWithObjects: @"indicatorIndex", @"trackHeight", nil] containsObject: key])
		return;
	
	[super setMappedValue:value forKey:key];
}

@end

@implementation NSSliderCell (NPObjectPropertyExtensions)

- (void)setMappedValue:(id)value forKey:(NSString *)key
{
	if ([key isEqual: @"doubleValue"]) {
		double doubleValue = [value doubleValue];
		if ([self maxValue] < doubleValue)
			[self setMaxValue: doubleValue];
		if ([self minValue] > doubleValue)
			[self setMinValue: doubleValue];
	}
	
	[super setMappedValue:value forKey:key];
}

@end

@implementation NSSplitView (NPObjectPropertyExtensions)

- (void)setMappedValue:(id)value forKey:(NSString *)key
{
	if ([[NSArray arrayWithObjects: @"color", @"colorIsEnabled", @"maxValues", @"collapsiblePopupSelection", @"dividerCanCollapse", nil] containsObject: key])
		return;
	if ([key isEqual: @"ibShadowedVertical"]) {
		[self setVertical: [value boolValue]];
		return;
	}
	
	[super setMappedValue:value forKey:key];
}

@end

@implementation NSTableColumn (NPObjectPropertyExtensions)

- (void)initialize
{
	[[self headerCell] setBordered: YES];
}

- (void)setChildren:(NSArray *)childs
{
	if ([childs count] >= 1)
		[self setDataCell: [childs objectAtIndex: 0]];
}

- (void)setMappedValue:(id)value forKey:(NSString *)key
{
	if ([key hasPrefix: @"headerCell."]) {
		[[self headerCell] setMappedValue:value forKey:[[key componentsSeparatedByString: @"."] objectAtIndex: 1]];
		return;
	}
	if ([key isEqual: @"sortDescriptorAscending"]) {
		[[self sortDescriptorPrototype] setValue:value forKey:@"ascending"];
		return;
	}
	if ([key isEqual: @"sortDescriptorSelector"]) {
		//[[self sortDescriptorPrototype] __setSelector: NSSelectorFromString(value)];
		return;
	}
	
	[super setMappedValue:value forKey:key];
}

@end

@implementation NSTableView (NPObjectPropertyExtensions)

- (void)initialize
{
	// By default no header view
	self.headerView = nil;
}

- (void)setChildren:(NSArray *)childs
{	
	for (NSUInteger i=0; i<[childs count]; i++)
		[self addTableColumn: [childs objectAtIndex: i]];
}

- (void)finished
{
	// Find the according header view
	NSArray *views = self.superview.subviews;
	for (id view in views) {
		if ([view isKindOfClass: [NSTableHeaderView class]])
			[self setHeaderView: view];
	}
	
	// Fix Layout
	[[self enclosingScrollView] tile];
}

@end

@implementation NSTabView (NPObjectPropertyExtensions)

- (void)setChildren:(NSArray *)childs
{
	for (NSUInteger i=0; i<[childs count]; i++)
		[self addTabViewItem: [childs objectAtIndex: i]];
}

- (void)setMappedValue:(id)value forKey:(NSString *)key
{
	if ([key isEqual: @"font"])
		value = [NSFont fontFromIBToolDictionary: value];
	
	[super setMappedValue:value forKey:key];
}

@end

@implementation NSTabViewItem (NPObjectPropertyExtensions)

- (void)setChildren:(NSArray *)childs
{
	if ([childs count] >= 1)
		[self setView: [childs objectAtIndex: 0]];
}

@end

@implementation NSTextField (NPObjectPropertyExtensions)

- (void)setMappedValue:(id)value forKey:(NSString *)key
{
	if ([[NSArray arrayWithObjects: @"hasGradient", @"shadowColor", @"startingColor", @"solidColor", @"hasShadow", @"shadowIsBelow", @"endingColor", nil] containsObject: key])
		return;
	
	[super setMappedValue:value forKey:key];
}

@end

@implementation NSTextFieldCell (NPObjectPropertyExtensions)

- (void)setMappedValue:(id)value forKey:(NSString *)key
{
	if ([key isEqual: @"allowsOnlyRomanCharacters"])
		return;
	if ([key isEqual: @"gBorderType"] && [value intValue] == 3) {
		[self setBezeled: YES];
		[self setBezelStyle: NSTextFieldRoundedBezel];
		return;
	}
	
	[super setMappedValue:value forKey:key];
}

@end

@implementation NSTextView (NPObjectPropertyExtensions)

- (void)setMappedValue:(id)value forKey:(NSString *)key
{
	if ([key isEqual: @"allowsNonContiguousLayout"]) {
		[[self layoutManager] setValue:value forKey:key];
		return;
	}
	if ([[NSArray arrayWithObjects: @"minWidth", @"maxWidth", @"minHeight", @"maxHeight", @"allowsOnlyRomanCharacters", nil] containsObject: key])
		return;
	
	[super setMappedValue:value forKey:key];
}

- (void)finished
{
	if (!self.string.length) {
		NSAttributedString *str;
		
		str = [[NSAttributedString alloc] initWithPath:[[NSBundle bundleForClass: [NPPreview class]] pathForResource:@"Text" ofType:@"rtf"] documentAttributes:nil];
		
		if ([self isRichText]) {
			if (![NSThread isMainThread])
				[[self textStorage] performSelectorOnMainThread:@selector(setAttributedString:) withObject:str waitUntilDone:NO];
			else
				[[self textStorage] setAttributedString: str];
		} else {
			if (![NSThread isMainThread])
				[self performSelectorOnMainThread:@selector(setString:) withObject:[str string] waitUntilDone:NO];
			else
				[self setString: [str string]];
		}
	}
}

@end

@implementation NSView (NPObjectPropertyExtensions)

- (void)setMappedValue:(id)value forKey:(NSString *)key
{
	if ([key isEqual: @"gToolTip"]) {
		[self setToolTip: value];
		return;
	}
	
	[super setMappedValue:value forKey:key];
}

- (void)setChildren:(NSArray *)childs
{
	for (NSUInteger i=0; i<[childs count]; i++) {
		if ([[childs objectAtIndex: i] isKindOfClass: [NSView class]])
			[self addSubview: [childs objectAtIndex: i]];
	}
}

@end

@implementation NSWindow (NPObjectPropertyExtensions)

- (void)setChildren:(NSArray *)childs
{
	[self setContentView: [childs objectAtIndex: 0]];
}

- (void)setMappedValue:(id)value forKey:(NSString *)key
{
	NSArray *filteredKeys = [NSArray arrayWithObjects: @"gMinSize", @"gMaxSize", @"visibleAtLaunch", @"deferred", @"wantsToBeColor", @"screenRect", nil];
	if ([filteredKeys containsObject: key])
		return;
	
	if ([key isEqual: @"contentRectSize"]) {
		[self setContentSize: [value sizeValue]];
		return;
	}
	if ([key isEqual: @"contentRectOrigin"]) {
		NSRect rect = [self contentRectForFrameRect: [self frame]];
		rect.origin = [value pointValue];
		rect = [self frameRectForContentRect: rect];
		[self setFrameOrigin: rect.origin];
		return;
	}
	if ([key hasPrefix: @"autorecalculatesContentBorderThickness"]) {
		BOOL autocalc = [value boolValue];
		if ([key hasSuffix: @"MaxYEdge"])
			[self setAutorecalculatesContentBorderThickness:autocalc forEdge:NSMaxYEdge];
		if ([key hasSuffix: @"MinYEdge"])
			[self setAutorecalculatesContentBorderThickness:autocalc forEdge:NSMinYEdge];
		return;
	}
	if ([key hasPrefix: @"contentBorderThickness"]) {
		CGFloat thickness = [value floatValue];
		if ([key hasSuffix: @"MaxYEdge"])
			[self setContentBorderThickness:thickness forEdge:NSMaxYEdge];
		if ([key hasSuffix: @"MinYEdge"])
			[self setContentBorderThickness:thickness forEdge:NSMinYEdge];
		return;
	}
	
	[super setMappedValue:value forKey:key];
}

@end



