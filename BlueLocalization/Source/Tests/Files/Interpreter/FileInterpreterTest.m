//
//  FileInterpreterTest.m
//  BlueLocalization
//
//  Created by Max Seelemann on 18.04.09.
//  Copyright 2009 The Blue Technologies Group. All rights reserved.
//

#import "FileInterpreterTest.h"

#import <BlueLocalization/BLStringsFileInterpreter.h>
#import <BlueLocalization/BLNibFileInterpreter.h>
#import <BlueLocalization/BLPlistFileInterpreter.h>
#import <BlueLocalization/BLRTFFileInterpreter.h>
#import <BlueLocalization/BLTXTFileInterpreter.h>

#import <OCMock/OCMock.h>

@interface MyInterpreter : BLStringsFileInterpreter
@end

@implementation MyInterpreter
@end

@interface MyInterpreter2 : BLTXTFileInterpreter
@end

@implementation MyInterpreter2
@end


@implementation FileInterpreterTest

- (void)setUp
{
	path = [self pathForFile: @"simple"];
	path2 = [self pathForFile: @"simple2"];
	
	interpreter = [BLFileInterpreter interpreterForFileType: @"strings"];
	fileObject = [BLFileObject fileObjectWithPath: path];
}

- (NSString *)pathForFile:(NSString *)file
{
	return [[NSBundle bundleForClass: [self class]] pathForResource:file ofType:@"strings" inDirectory:@"Test Data/Strings/specific"];
}

- (NSString *)pathForCommentFile:(NSString *)file ofType:(NSString *)type
{
	return [[NSBundle bundleForClass: [self class]] pathForResource:file ofType:type inDirectory:@"Test Data/Strings/comment"];
}


#pragma mark - Class tests

- (void)testClassRegistration
{
	STAssertThrows([BLFileInterpreter registerInterpreterClass:[NSString class] forFileType:@"string"], @"Should not accept weird classes as interpreter");
	STAssertNoThrow([BLFileInterpreter registerInterpreterClass:[BLStringsFileInterpreter class] forFileType:@"xyz"], @"Should accept sublasses as interpreter");
	STAssertThrows([BLFileInterpreter registerInterpreterClass:[BLStringsFileInterpreter class] forFileType:@"txt"], @"Should not accept two interpreters for one extension");
	STAssertThrows([BLFileInterpreter registerInterpreterClass:[MyInterpreter class] forFileType:@"txt"], @"Should not accept two interpreters for one extension");
	STAssertNoThrow([BLFileInterpreter registerInterpreterClass:[MyInterpreter2 class] forFileType:@"txt"], @"Should accept two inherent interpreters for one extension");
}

- (void)testInterpeters
{
	STAssertNil([BLFileInterpreter interpreterForFileType: @"zyx"], @"Should return nil for a unknown file type.");
	
	STAssertTrue([[BLFileInterpreter interpreterForFileType: @"nib"] isKindOfClass: [BLNibFileInterpreter class]], @"Nib file interpreter is wrong");
	STAssertTrue([[BLFileInterpreter interpreterForFileType: @"xib"] isKindOfClass: [BLNibFileInterpreter class]], @"Xib file interpreter is wrong");
	STAssertTrue([[BLFileInterpreter interpreterForFileType: @"plist"] isKindOfClass: [BLPlistFileInterpreter class]], @"Plist file interpreter is wrong");
	STAssertTrue([[BLFileInterpreter interpreterForFileType: @"rtfd"] isKindOfClass: [BLRTFFileInterpreter class]], @"RTFD file interpreter is wrong");
	STAssertTrue([[BLFileInterpreter interpreterForFileType: @"rtf"] isKindOfClass: [BLRTFFileInterpreter class]], @"RTF file interpreter is wrong");
	STAssertTrue([[BLFileInterpreter interpreterForFileType: @"strings"] isKindOfClass: [BLStringsFileInterpreter class]], @"Strings file interpreter is wrong");
	STAssertTrue([[BLFileInterpreter interpreterForFileType: @"txt"] isKindOfClass: [BLTXTFileInterpreter class]], @"Txt file interpreter is wrong");
	
	STAssertTrue(![[BLFileInterpreter interpreterForFileType: @"strings"] isEqual: [BLFileInterpreter interpreterForFileType: @"strings"]], @"Multiple requests should return multiple interpreter");
}

- (void)testOptions
{
	[interpreter setOptions: 0];
	STAssertFalse([interpreter optionIsActive: 4], @"A option should be off if all are deactivated");
	
	[interpreter deactivateOptions: 4];
	STAssertFalse([interpreter optionIsActive: 4], @"A option should be off if deactivated");
	
	[interpreter activateOptions: 4];
	STAssertTrue([interpreter optionIsActive: 4], @"A option should be off if activated");
	
	[interpreter activateOptions: 2];
	STAssertTrue([interpreter optionIsActive: 4], @"A option should stay active if another setting is set");
	
	[interpreter deactivateOptions: 3];
	STAssertTrue([interpreter optionIsActive: 4], @"A option should stay active if another setting is unset");
	
	[interpreter activateOptions: 7];
	STAssertTrue([interpreter optionIsActive: 4], @"A option should stay active if set in a bigger set of settings");
	
	[interpreter deactivateOptions: 7];
	STAssertFalse([interpreter optionIsActive: 4], @"A option should be deactivated if unset in a bigger set of settings");
	
	STAssertEquals((NSUInteger)0, [interpreter options], @"After this test all options should be unset");
}

- (void)testErrorImport
{
	STAssertFalse([interpreter interpreteFile:@"any/nonexistent/path.strings" intoObject:fileObject withLanguage:@"en" referenceLanguage:nil], @"Should fail on not existing files");
	STAssertTrue([[fileObject errors] containsObject: BLObjectFileNotFoundError], @"Should have set an not found error");
	
	STAssertFalse([interpreter interpreteFile:[path stringByAppendingPathExtension: @"unknown"] intoObject:fileObject withLanguage:@"en" referenceLanguage:nil], @"Should fail on unknown file types");
	STAssertTrue([[fileObject errors] containsObject: BLObjectFiletypeUnknownError], @"Should have set an unknwon type error");
}


#pragma mark - Options test

- (void)testIgnoreChangeDate
{
	[interpreter activateOptions: BLFileInterpreterAllowChangesToKeyObjects];
	
	[interpreter deactivateOptions: BLFileInterpreterIgnoreFileChangeDates];
	STAssertTrue([interpreter willInterpreteFile:path intoObject:fileObject], @"Should want to import never imported files.");
	STAssertTrue([interpreter interpreteFile:path intoObject:fileObject withLanguage:@"en" referenceLanguage:@"en"], @"Initial import should not fail.");
	
	STAssertFalse([interpreter willInterpreteFile:path intoObject:fileObject], @"Should not want to import a just imported files.");
	STAssertFalse([interpreter interpreteFile:path intoObject:fileObject withLanguage:@"en" referenceLanguage:@"en"], @"Second import should fail.");
	
	[interpreter activateOptions: BLFileInterpreterIgnoreFileChangeDates];
	STAssertTrue([interpreter willInterpreteFile:path intoObject:fileObject], @"Should now want to import because its irgnoring dates.");
	STAssertTrue([interpreter interpreteFile:path intoObject:fileObject withLanguage:@"en" referenceLanguage:@"en"], @"Second import should not fail when ignoring dates.");
}

- (void)testChangesToKeyObjects
{
	[interpreter deactivateOptions: BLFileInterpreterAllowChangesToKeyObjects];
	[interpreter interpreteFile:path intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	STAssertTrue([[fileObject objects] count] == 0, @"Should not have added any keys");
	
	[interpreter activateOptions: BLFileInterpreterAllowChangesToKeyObjects];
	[interpreter interpreteFile:path intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	STAssertTrue([[fileObject objects] count] > 0, @"Should have added some keys");
}

- (void)testChangesTrackOfChangesAsUpdate
{
	[interpreter activateOptions: BLFileInterpreterAllowChangesToKeyObjects | BLFileInterpreterIgnoreFileChangeDates];
	
	// Import the file one, no updated flag should be set
	[interpreter deactivateOptions: BLFileInterpreterTrackValueChangesAsUpdate];
	[interpreter interpreteFile:path intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	for (BLKeyObject *key in [fileObject objects])
		STAssertFalse([key wasUpdated], @"No key object should have been set as updated");
	
	// Import the file again, still no updated flag should be set, as nothing changed
	[interpreter activateOptions: BLFileInterpreterTrackValueChangesAsUpdate];
	[interpreter interpreteFile:path intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	for (BLKeyObject *key in [fileObject objects])
		STAssertFalse([key wasUpdated], @"No key object should have been set as updated");
	
	// Import a "different version", updated flag should be set to some keys
	[interpreter interpreteFile:path2 intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	BOOL updated = NO;
	for (BLKeyObject *key in [fileObject objects])
		updated = updated || [key wasUpdated];
	STAssertTrue(updated, @"Some key objects should have been set as updated");
}

- (void)testValueChangesResetKeys
{
	[interpreter activateOptions: BLFileInterpreterAllowChangesToKeyObjects | BLFileInterpreterIgnoreFileChangeDates];
	
	// Import english version
	[interpreter deactivateOptions: BLFileInterpreterValueChangesResetKeys];
	[interpreter interpreteFile:path intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	
	// Import german version
	[interpreter deactivateOptions: BLFileInterpreterAllowChangesToKeyObjects];
	[interpreter interpreteFile:[self pathForFile: @"simple-de"] intoObject:fileObject withLanguage:@"de" referenceLanguage:nil];
	
	// Test for contents
	for (BLKeyObject *key in [fileObject objects]) {
		STAssertNotNil([key objectForLanguage: @"en"], @"No english value!");
		STAssertNotNil([key objectForLanguage: @"de"], @"No german value!");
	}
	
	// Import "new version"
	[interpreter activateOptions: BLFileInterpreterAllowChangesToKeyObjects | BLFileInterpreterValueChangesResetKeys];
	[interpreter interpreteFile:path2 intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	BOOL removed = NO;
	for (BLKeyObject *key in [fileObject objects])
		removed = removed || ([key objectForLanguage: @"de"] == nil);
	STAssertTrue(removed, @"No german values have been removed!");
}

- (void)testImportEmptyKeys
{
	[interpreter activateOptions: BLFileInterpreterAllowChangesToKeyObjects | BLFileInterpreterIgnoreFileChangeDates];
	
	[interpreter activateOptions: BLFileInterpreterImportEmptyKeys];
	[interpreter interpreteFile:[self pathForFile: @"emptyValues"] intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	
	NSUInteger oldCount = [[fileObject objects] count];
	STAssertTrue(oldCount > 0, @"Should have imported several items");
	
	[interpreter deactivateOptions: BLFileInterpreterImportEmptyKeys];
	[interpreter interpreteFile:[self pathForFile: @"emptyValues"] intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	STAssertTrue([[fileObject objects] count] < oldCount, @"Empty keys should have been omitted");
}

- (void)testDeactivateEmptyKeys
{
	[interpreter activateOptions: BLFileInterpreterAllowChangesToKeyObjects | BLFileInterpreterIgnoreFileChangeDates | BLFileInterpreterImportEmptyKeys];
	
	[interpreter deactivateOptions: BLFileInterpreterDeactivateEmptyKeys];
	[interpreter interpreteFile:[self pathForFile: @"emptyValues"] intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	for (BLKeyObject *key in [fileObject objects])
		STAssertTrue([key isActive], @"No key object should have been deactivated");
	
	[interpreter activateOptions: BLFileInterpreterDeactivateEmptyKeys];
	[interpreter interpreteFile:[self pathForFile: @"emptyValues"] intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	BOOL deactivated = NO;
	for (BLKeyObject *key in [fileObject objects])
		deactivated = deactivated || ![key isActive];
	STAssertTrue(deactivated, @"Some key objects should have been deactivated");
}

- (void)testCommentImport
{
	[interpreter activateOptions: BLFileInterpreterAllowChangesToKeyObjects | BLFileInterpreterIgnoreFileChangeDates];
	
	[interpreter deactivateOptions: BLFileInterpreterImportComments];
	[interpreter interpreteFile:[self pathForFile: @"simpleCommented"] intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	for (BLKeyObject *key in [fileObject objects])
		STAssertTrue([[key comment] length] == 0, @"No comment should have been imported");
	
	[interpreter activateOptions: BLFileInterpreterImportComments];
	[interpreter interpreteFile:[self pathForFile: @"simpleCommented"] intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	for (BLKeyObject *key in [fileObject objects])
		STAssertTrue([[key comment] length] != 0, @"All keys should have comments");
}

- (void)testShadowComments
{
	NSDictionary *dict;
	
	[interpreter activateOptions: BLFileInterpreterAllowChangesToKeyObjects | BLFileInterpreterIgnoreFileChangeDates | BLFileInterpreterImportComments];
	
	[interpreter deactivateOptions: BLFileInterpreterEnableShadowComments];
	[interpreter interpreteFile:[self pathForCommentFile:@"shadow" ofType:@"strings"] intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	dict = [NSDictionary dictionaryWithContentsOfFile: [self pathForCommentFile:@"shadow" ofType:@"comments"]];
	for (BLKeyObject *key in [fileObject objects])
		STAssertEqualObjects([key comment], [dict objectForKey: [key key]], @"Standard comment import does not match for key %@", [key key]);
	
	[interpreter activateOptions: BLFileInterpreterEnableShadowComments];
	[interpreter interpreteFile:[self pathForCommentFile:@"shadow" ofType:@"strings"] intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	dict = [NSDictionary dictionaryWithContentsOfFile: [self pathForCommentFile:@"shadow2" ofType:@"comments"]];
	for (BLKeyObject *key in [fileObject objects])
		STAssertEqualObjects([key comment], [dict objectForKey: [key key]], @"Shadowed comment import does not match for key %@", [key key]);
}

- (void)testAutotranslationWithoutReset
{
	NSDictionary *dict;
	
	[interpreter activateOptions: BLFileInterpreterAllowChangesToKeyObjects | BLFileInterpreterIgnoreFileChangeDates | BLFileInterpreterAutotranslateNewKeys];
	[interpreter deactivateOptions: BLFileInterpreterValueChangesResetKeys];
	
	// Initial import of localized file
	[interpreter interpreteFile:[self pathForFile: @"simple"] intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	[interpreter interpreteFile:[self pathForFile: @"simple-de"] intoObject:fileObject withLanguage:@"de" referenceLanguage:nil];
	dict = [NSDictionary dictionaryWithContentsOfFile: [self pathForFile: @"simple-de"]];
	for (BLKeyObject *key in [fileObject objects])
		STAssertEqualObjects([key objectForLanguage: @"de"], [dict objectForKey: [key key]], @"Wrong german strings for key %@", [key key]);
	
	// Overriding import of english
	[interpreter interpreteFile:[self pathForFile: @"simple2"] intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	for (BLKeyObject *key in [fileObject objects])
		STAssertEqualObjects([key objectForLanguage: @"de"], [dict objectForKey: [key key]], @"German strings should not have changed for key %@", [key key]);
	
	// Another overriding import of english
	[interpreter interpreteFile:[self pathForFile: @"simple"] intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	[interpreter interpreteFile:[self pathForFile: @"simple3"] intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	dict = [NSDictionary dictionaryWithContentsOfFile: [self pathForFile: @"simple3-de"]];
	for (BLKeyObject *key in [fileObject objects])
		STAssertEqualObjects([key objectForLanguage: @"de"], [dict objectForKey: [key key]], @"German strings should not have changed for key %@", [key key]);
}

- (void)testAutotranslationWithReset
{
	NSDictionary *dict;
	
	[interpreter activateOptions: BLFileInterpreterAllowChangesToKeyObjects | BLFileInterpreterIgnoreFileChangeDates | BLFileInterpreterAutotranslateNewKeys | BLFileInterpreterValueChangesResetKeys];
	
	// Initial import of localized file
	[interpreter interpreteFile:[self pathForFile: @"simple"] intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	[interpreter interpreteFile:[self pathForFile: @"simple-de"] intoObject:fileObject withLanguage:@"de" referenceLanguage:nil];
	dict = [NSDictionary dictionaryWithContentsOfFile: [self pathForFile: @"simple-de"]];
	for (BLKeyObject *key in [fileObject objects])
		STAssertEqualObjects([key objectForLanguage: @"de"], [dict objectForKey: [key key]], @"Wrong german strings for key %@", [key key]);
	
	// Overriding import of english
	[interpreter interpreteFile:[self pathForFile: @"simple2"] intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	dict = [NSDictionary dictionaryWithContentsOfFile: [self pathForFile: @"simple2-de"]];
	for (BLKeyObject *key in [fileObject objects])
		STAssertEqualObjects([key objectForLanguage: @"de"], [dict objectForKey: [key key]], @"German strings should not have changed for key %@", [key key]);
	
	// Another overriding import of english
	[interpreter interpreteFile:[self pathForFile: @"simple3"] intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	dict = [NSDictionary dictionaryWithContentsOfFile: [self pathForFile: @"simple3-de"]];
	for (BLKeyObject *key in [fileObject objects])
		STAssertEqualObjects([key objectForLanguage: @"de"], [dict objectForKey: [key key]], @"German strings should not have changed for key %@", [key key]);
}

- (void)testReferenceImport
{
	// Import english version as reference
	[interpreter activateOptions: BLFileInterpreterAllowChangesToKeyObjects | BLFileInterpreterIgnoreFileChangeDates];
	[interpreter deactivateOptions: BLFileInterpreterValueChangesResetKeys];
	[interpreter interpreteFile:path intoObject:fileObject withLanguage:@"en" referenceLanguage:@"en"];
	
	// Test file
	STAssertTrue([[fileObject objects] count] > 0, @"No keys imported!");
	NSArray *changedValues = [NSArray arrayWithObject: BLObjectReferenceChangedKey];
	STAssertEqualObjects([fileObject changedValues], changedValues, @"Wrong change values!");
	
	// Test contents and changes
	for (BLKeyObject *key in [fileObject objects]) {
		STAssertEqualObjects([key changedValues], changedValues, @"Wrong key change values!");
		STAssertNotNil([key objectForLanguage: @"en"], @"No english value!");
	}
	
	// Import german version
	[interpreter deactivateOptions: BLFileInterpreterAllowChangesToKeyObjects | BLFileInterpreterIgnoreFileChangeDates];
	[interpreter deactivateOptions: BLFileInterpreterAllowChangesToKeyObjects];
	[interpreter interpreteFile:[self pathForFile: @"simple-de"] intoObject:fileObject withLanguage:@"de" referenceLanguage:nil];
	
	// Test file
	STAssertTrue([[fileObject objects] count] > 0, @"No keys imported!");
	changedValues = [NSArray arrayWithObjects: BLObjectReferenceChangedKey, @"de", nil];
	STAssertEqualObjects([fileObject changedValues], changedValues, @"Wrong change values!");
	
	// Test for contents and changes
	for (BLKeyObject *key in [fileObject objects]) {
		STAssertEqualObjects([key changedValues], changedValues, @"Wrong key change values!");
		STAssertNotNil([key objectForLanguage: @"en"], @"No english value!");
		STAssertNotNil([key objectForLanguage: @"de"], @"No german value!");
	}
	
	// Import differen english version NOT as reference
	[interpreter deactivateOptions: BLFileInterpreterValueChangesResetKeys];
	[interpreter interpreteFile:[self pathForFile: @"simple-de"] intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	
	// Test file
	STAssertTrue([[fileObject objects] count] > 0, @"No keys imported!");
	changedValues = [NSArray arrayWithObjects: BLObjectReferenceChangedKey, @"de", @"en", nil];
	STAssertEqualObjects([fileObject changedValues], changedValues, @"Wrong change values!");
	
	// Test contents and changes
	for (BLKeyObject *key in [fileObject objects]) {
		STAssertEqualObjects([key changedValues], changedValues, @"Wrong key change values!");
	}
}

- (void)testBackupCreation
{
	[interpreter activateOptions: BLFileInterpreterAllowChangesToKeyObjects | BLFileInterpreterReferenceImportCreatesBackup];
	
	// Import w/o reference should not create backup
	[interpreter interpreteFile:path intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	STAssertTrue([fileObject versionForLanguage: @"en"] == 0, @"No version should be present");
	STAssertNil([fileObject attachedObjectForKey:BLBackupAttachmentKey version:[fileObject versionForLanguage: @"en"]], @"No backup should be present");
	
	// Nothing should change -> file didn't change
	[interpreter interpreteFile:path intoObject:fileObject withLanguage:@"en" referenceLanguage:nil];
	STAssertTrue([fileObject versionForLanguage: @"en"] == 0, @"No version should be present");
	STAssertNil([fileObject attachedObjectForKey:BLBackupAttachmentKey version:[fileObject versionForLanguage: @"en"]], @"No backup should be present");
	
	// Ignore change dates, import as reference
	[interpreter interpreteFile:path intoObject:fileObject withLanguage:@"en" referenceLanguage:@"en"];
	STAssertTrue([fileObject versionForLanguage: @"en"] == 1, @"Version not updated!");
	STAssertNotNil([fileObject attachedObjectForKey:BLBackupAttachmentKey version:[fileObject versionForLanguage: @"en"]], @"backup missing");
	
	// Reference from other versions
	id backup1 = [fileObject attachedObjectForKey:BLBackupAttachmentKey version:[fileObject versionForLanguage: @"en"]];
	[fileObject setVersion:1 forLanguage:@"de"];
	STAssertEquals(backup1, [fileObject attachedObjectForKey:BLBackupAttachmentKey version:[fileObject versionForLanguage: @"de"]], @"Reference broken");
	
	// Import new version
	[interpreter interpreteFile:path2 intoObject:fileObject withLanguage:@"en" referenceLanguage:@"en"];
	STAssertTrue([fileObject versionForLanguage: @"en"] == 2, @"Version not updated!");
	STAssertNotNil([fileObject attachedObjectForKey:BLBackupAttachmentKey version:[fileObject versionForLanguage: @"en"]], @"backup missing");
	
	STAssertTrue([fileObject versionForLanguage: @"de"] == 1, @"Version should not change!");
	STAssertEquals(backup1, [fileObject attachedObjectForKey:BLBackupAttachmentKey version:1], @"Reference broken");
	STAssertFalse(backup1 == [fileObject attachedObjectForKey:BLBackupAttachmentKey version:2], @"Wrong backup");
}

- (void)testNonReferenceSameValues
{
	// Import non reference values
	[interpreter deactivateOptions: BLFileInterpreterImportNonReferenceValuesOnly];
	
	[interpreter interpreteFile:[self pathForFile: @"simple"] intoObject:fileObject withLanguage:@"en" referenceLanguage:@"en"];
	[interpreter interpreteFile:[self pathForFile: @"simple-de"] intoObject:fileObject withLanguage:@"de" referenceLanguage:@"en"];
	
	BLKeyObject *key = [fileObject objectForKey: @"first"];
	STAssertEqualObjects([key objectForLanguage: @"en"], [key objectForLanguage: @"de"], @"Equal values should be imported");
	key = [fileObject objectForKey: @"key"];
	STAssertFalse([[key objectForLanguage: @"en"] isEqual: [key objectForLanguage: @"de"]], @"Values should be different");
	key = [fileObject objectForKey: @"key2"];
	STAssertEqualObjects([key objectForLanguage: @"en"], [key objectForLanguage: @"de"], @"Equal values should be imported");
	
	// Disable non reference value import
	[interpreter activateOptions: BLFileInterpreterImportNonReferenceValuesOnly];
	
	for (key in fileObject.objects)
		STAssertEqualObjects([key objectForLanguage: @"en"], [key objectForLanguage: @"de"], @"Equal values should not be imported");
}

@end



