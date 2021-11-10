/*!
 @header
 LICustomColumnTableView.m
 Created by max on 11.03.05.

 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "LICustomColumnTableView.h"
#import "LICustomColumnTableViewHeaderView.h"

NSString *LICustomColumnTableViewSettingsIdentifierKey = @"identifier";
NSString *LICustomColumnTableViewSettingsWidthKey = @"width";
NSString *LICustomColumnTableViewSettingsVisibleKey = @"visible";

@interface NSTableView (LICustomColumnTableViewNSTableViewAdditions)

- (void)_readPersistentTableColumns;
- (void)_writePersistentTableColumns;

@end

@implementation LICustomColumnTableView

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];

	[self setHeaderView:[[LICustomColumnTableViewHeaderView alloc] initWithFrame:[[self headerView] frame]]];

	return self;
}

#pragma mark - Accessors

- (NSArray *)persistentColumnSettings {
	NSMutableArray *settings = [NSMutableArray array];

	for (NSTableColumn *column in [self tableColumns]) {
		NSDictionary *setting = [NSDictionary dictionaryWithObjectsAndKeys:
												  [column identifier], LICustomColumnTableViewSettingsIdentifierKey,
												  [NSNumber numberWithFloat:[column width]], LICustomColumnTableViewSettingsWidthKey,
												  [NSNumber numberWithBool:![column isHidden]], LICustomColumnTableViewSettingsVisibleKey,
												  nil];
		[settings addObject:setting];
	}

	return settings;
}

- (void)setPersistentColumnSettings:(NSArray *)settings {
	for (NSDictionary *setting in settings) {
		NSTableColumn *column = [self tableColumnWithIdentifier:[setting objectForKey:LICustomColumnTableViewSettingsIdentifierKey]];
		[column setHidden:![[setting objectForKey:LICustomColumnTableViewSettingsVisibleKey] boolValue]];
	}
	for (NSDictionary *setting in settings) {
		NSTableColumn *column = [self tableColumnWithIdentifier:[setting objectForKey:LICustomColumnTableViewSettingsIdentifierKey]];
		[column setWidth:[[setting objectForKey:LICustomColumnTableViewSettingsWidthKey] floatValue]];
	}
}

@end
