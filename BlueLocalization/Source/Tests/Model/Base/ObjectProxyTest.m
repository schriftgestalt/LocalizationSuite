//
//  FileObjectProxyTest.m
//  BlueLocalization
//
//  Created by Max Seelemann on 07.05.09.
//  Copyright 2009 The Blue Technologies Group. All rights reserved.
//

#import "ObjectProxyTest.h"

#import <BlueLocalization/BLStringKeyObject.h>
#import <BlueLocalization/BLStringsFileObject.h>
#import <OCMock/OCMock.h>
#import <objc/runtime.h>

#define HC_SHORTHAND
#import <hamcrest/hamcrest.h>

@implementation ObjectProxyTest

- (void)setUp {
	object1 = [BLFileObject fileObjectWithPathExtension:@"strings"];
	object2 = [BLFileObject fileObjectWithPathExtension:@"strings"];
	proxy = [BLObjectProxy proxyWithObject:object1];
	pObject = (BLFileObject *)proxy;

	path = [self pathForFile:@"simple"];
}

- (NSString *)pathForFile:(NSString *)file {
	return [[NSBundle bundleForClass:[self class]] pathForResource:file ofType:@"strings" inDirectory:@"Test Data/Strings/specific"];
}

- (void)testCreation {
	XCTAssertTrue([proxy class] == [BLStringsFileObject class], @"Direct question should NOT reveal identity");
	XCTAssertTrue(object_getClass(proxy) == [BLObjectProxy class], @"Only runtime should reveal identity");
	XCTAssertTrue([proxy isKindOfClass:[BLFileObject class]], @"Should pose as a file object");
	XCTAssertFalse([proxy isKindOfClass:[BLKeyObject class]], @"Should not pose as a key object");
}

- (void)testAccessors {
	[pObject setBundleObject:[BLBundleObject bundleObject]];
	[pObject setFlags:0];

	XCTAssertTrue([[pObject bundleObject] isKindOfClass:[BLBundleObject class]], @"returned bundle of wrong class");
	XCTAssertTrue(object_getClass([pObject bundleObject]) == [BLObjectProxy class], @"returned bundle should actually be a proxy again");

	for (NSUInteger i = 0; i < 4; i++) {
		id object = [pObject objectForKey:[NSString stringWithFormat:@"blah%lu", i] createIfNeeded:YES];
		XCTAssertTrue([object isKindOfClass:[BLKeyObject class]], @"key of wrong class");
		XCTAssertTrue(object_getClass(object) == [BLObjectProxy class], @"key should actually be a proxy again");
	}

	for (id object in [pObject objects]) {
		XCTAssertTrue([object isKindOfClass:[BLKeyObject class]], @"key of wrong class");
		XCTAssertTrue(object_getClass(object) == [BLObjectProxy class], @"key should actually be a proxy again");
	}
}

- (void)testInterpetation {
	[[BLFileInterpreter interpreterForFileType:@"string"] interpreteFile:path intoObject:object2 withLanguage:@"en" referenceLanguage:nil];
	[[BLFileInterpreter interpreterForFileType:@"string"] interpreteFile:path intoObject:pObject withLanguage:@"en" referenceLanguage:nil];

	for (BLKeyObject *keyObject in [object2 objects]) {
		XCTAssertNotNil([pObject objectForKey:[keyObject key]], @"Key object does not exist");
		XCTAssertEqual([[pObject objectForKey:[keyObject key]] objectForLanguage:@"en"], [keyObject objectForLanguage:@"en"], @"String values don't match");
	}
}

/*
- (void)testArguments
{
	BLKeyObject *keyObject;
	BLObjectProxy *proxy2;
	BOOL yes = YES;
	id mock;

	// Set up environment
	mock = [OCMockObject mockForClass: [BLFileObject class]];
	[[[mock stub] andReturnValue: [NSValue value:&yes withObjCType:@encode(BOOL)]] isKindOfClass: OCMOCK_ANY];

	proxy2 = [BLObjectProxy proxyWithObject: mock];
	keyObject = [BLStringKeyObject keyObjectWithKey: @"hallo"];

	// Make a plan
	[[[mock stub] andReturn: keyObject] objectForKey: OCMOCK_ANY];

	[[mock expect] addObject: keyObject];
	[[mock expect] addObject: keyObject];
	[[mock expect] setObjects: (id)equalTo([NSArray arrayWithObject: keyObject])];

	// Run the plan
	[(id)proxy2 addObject: keyObject];
	keyObject = [(id)proxy2 objectForKey: nil];
	[(id)proxy2 addObject: keyObject];
	[(id)proxy2 setObjects: [NSArray arrayWithObject: keyObject]];

	// Verify
	[mock verify];
}
 */

- (void)testChains {
	[[BLBundleObject bundleObject] setFiles:[NSArray arrayWithObject:object1]];
	[object1 objectForKey:@"hups" createIfNeeded:YES];

	XCTAssertTrue(object_getClass(pObject) == [BLObjectProxy class], @"object should be a proxy");
	XCTAssertTrue(object_getClass([pObject bundleObject]) == [BLObjectProxy class], @"object should actually be a proxy again");
	XCTAssertTrue(object_getClass([[pObject bundleObject] files].lastObject) == [BLObjectProxy class], @"object should actually be a proxy again");
	XCTAssertTrue(object_getClass(((BLKeyObject *)pObject.objects.lastObject).fileObject) == [BLObjectProxy class], @"object should actually be a proxy again");
	XCTAssertTrue(object_getClass(((BLObject *)pObject.bundleObject.files.lastObject).objects.lastObject) == [BLObjectProxy class], @"object should actually be a proxy again");
	XCTAssertTrue(object_getClass(((BLKeyObject *)((BLObject *)pObject.bundleObject.files.lastObject).objects.lastObject).fileObject) == [BLObjectProxy class], @"object should actually be a proxy again");
}

- (void)testOrdinaryObjects {
	XCTAssertNil([BLObjectProxy proxyWithObject:nil], @"No proxy for no object");
	XCTAssertThrows([BLObjectProxy proxyWithObject:(BLObject *)@"hallo"], @"Should throw for non-BLObject arguments");
}

@end
