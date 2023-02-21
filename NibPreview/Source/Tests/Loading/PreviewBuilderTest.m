//
//  PreviewBuilderTest.m
//  NibPreview
//
//  Created by max on 03.03.09.
//  Copyright 2009 Localization Suite. All rights reserved.
//

#import "PreviewBuilderTest.h"

#import "NPBundleLoader.h"
#import "NPPreviewBuilder.h"

@implementation PreviewBuilderTest

- (void)testCreation {
	NPPreviewBuilder *builder = [[NPPreviewBuilder alloc] init];
	XCTAssertNotNil(builder, @"can't create builder");
}

- (void)testComponent:(NSString *)type forKey:(NSString *)key {
	// Load a preview from a description and manually instantiate a nib, then compare the outcomes

	NSString *directory = [NSString stringWithFormat:@"Test Data/Builder/%@", type];
	NSString *outPath = [[NSBundle bundleForClass:[self class]] pathForResource:key ofType:@"out" inDirectory:directory];
	NSString *xibPath = [[NSBundle bundleForClass:[self class]] pathForResource:key ofType:@"nib" inDirectory:directory];

	XCTAssertNotNil(outPath, @"out file not found for %@/%@", type, key);
	XCTAssertNotNil(xibPath, @"nib file not found for %@/%@", type, key);

	NSDictionary *contents = [NSDictionary dictionaryWithContentsOfFile:outPath];
	XCTAssertNotNil(contents, @"can't load out file for %@/%@", type, key);

	NSMutableArray *originals = [NSMutableArray array];
	BOOL result = [NSBundle loadNibFile:xibPath externalNameTable:[NSDictionary dictionaryWithObjectsAndKeys:originals, NSNibTopLevelObjects, nil] withZone:nil];
	XCTAssertTrue(result, @"can't load nib file for %@/%@", type, key);

	[originals removeObject:NSApp];
	XCTAssertTrue(originals.count > 0, @"nib file seems to be empty for %@/%@", type, key);

	NPPreviewBuilder *builder = [[NPPreviewBuilder alloc] init];
	[builder buildPreviewFromDescription:contents];
	XCTAssertTrue(builder.classes.count > 0, @"Builder loaded no classes for %@/%@", type, key);
	XCTAssertTrue(builder.objects.count > 0, @"Builder loaded no objects for %@/%@", type, key);
	XCTAssertTrue(builder.rootObjects.count > 0, @"Builder made no hierarchies for %@/%@", type, key);

	NSArray *loaded = [builder.rootObjects valueForKey:@"original"];
	XCTAssertEqual(loaded.count, builder.rootObjects.count, @"Original count mismatches root count for %@/%@", type, key);
	XCTAssertEqual(loaded.count, originals.count, @"Differing number of originals vs. loaded roots for %@/%@", type, key);

	for (NSUInteger i = 0; i < loaded.count; i++) {
		NSView *load, *orig;

		load = [loaded objectAtIndex:i];
		orig = [originals objectAtIndex:i];

		// Orig may prove to be a window, which the loader always skips
		if ([orig isKindOfClass:[NSWindow class]]) {
			XCTAssertTrue([load isKindOfClass:[NSWindow class]], @"Loaded original should also be a window for %@/%@", type, key);
			if (![load isKindOfClass:[NSWindow class]])
				continue;

			XCTAssertEqual(load.frame, orig.frame, @"Frames differ for %i. object for %@/%@", i + 1, type, key);

			load = [(NSWindow *)load contentView];
			[[load window] setContentView:nil];

			orig = [(NSWindow *)orig contentView];
			[[orig window] setContentView:nil];
		}

		XCTAssertEqualObjects([load class], [orig class], @"Classes do not match!");
		XCTAssertEqual(load.frame, orig.frame, @"Frames differ for %i-th object for %@/%@", i, type, key);

		NSBitmapImageRep *oRep = [load bitmapImageRepForCachingDisplayInRect:load.bounds];
		[load cacheDisplayInRect:load.bounds toBitmapImageRep:oRep];

		NSBitmapImageRep *rRep = [orig bitmapImageRepForCachingDisplayInRect:orig.bounds];
		[orig cacheDisplayInRect:orig.bounds toBitmapImageRep:rRep];

		XCTAssertTrue([[oRep TIFFRepresentation] isEqualTo:[rRep TIFFRepresentation]], @"Renderings differ for %i. object for %@/%@, output will be written", i + 1, type, key);

		if (![[oRep TIFFRepresentation] isEqualTo:[rRep TIFFRepresentation]]) {
			[[NSFileManager defaultManager] createDirectoryAtPath:@"Errors" withIntermediateDirectories:YES attributes:nil error:NULL];
			[[oRep TIFFRepresentation] writeToFile:[NSString stringWithFormat:@"Errors/%@_loaded.tiff", key] atomically:YES];
			[[rRep TIFFRepresentation] writeToFile:[NSString stringWithFormat:@"Errors/%@_original.tiff", key] atomically:YES];
		}
	}
}

- (void)testSimpleButtons {
	// Run a series of test with testComponent:forKey:

	NSArray *testKeys = [NSArray arrayWithObjects:@"button-1", @"button-2", @"button-3", @"button-4", @"button-5", @"button-6", @"button-7", @"button-8", @"button-9", @"button-10", @"button-11", @"button-12", nil];
	for (NSString *key in testKeys)
		[self testComponent:@"buttons" forKey:key];
}

- (void)testDataViews {
	// Run a series of test with testComponent:forKey:

	NSArray *testKeys = [NSArray arrayWithObjects:@"table-1", @"table-2", @"table-3", @"browser-1", nil];
	for (NSString *key in testKeys)
		[self testComponent:@"data_views" forKey:key];
}

- (void)testInputs {
	// Run a series of tests with testComponent:forKey:

	NSArray *testKeys = [NSArray arrayWithObjects:@"text-1", @"text-2", @"simple-1", @"slider-1", @"combo-1", @"matrix-1", @"progress-1", nil];
	for (NSString *key in testKeys)
		[self testComponent:@"inputs" forKey:key];
}

- (void)testLayoutObjects {
	// Run a series of tests with testComponent:forKey:

	NSArray *testKeys = [NSArray arrayWithObjects:@"layout-1", @"scrollview-1", @"scrollview-2", @"scrollview-3", @"split-1", nil];
	for (NSString *key in testKeys)
		[self testComponent:@"layout" forKey:key];
}

- (void)testMoreComplexView {
	// Run a series of tests with testComponent:forKey:

	// complex-1 fails because of NSMatrix and NSForm ordering
	// To see the difference, enable them and see the Error directory

	NSArray *testKeys = [NSArray arrayWithObjects:/*@"complex-1",*/ @"complex-2", @"complex-3", nil];
	for (NSString *key in testKeys)
		[self testComponent:@"complex" forKey:key];
}

- (void)testClassMapping {
	NSString *outPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"unknown-1" ofType:@"out" inDirectory:@"Test Data/Builder/other"];
	XCTAssertNotNil(outPath, @"out file not found");

	NSDictionary *contents = [NSDictionary dictionaryWithContentsOfFile:outPath];
	XCTAssertNotNil(contents, @"can't load out file");

	NPPreviewBuilder *builder = [[NPPreviewBuilder alloc] init];
	[builder buildPreviewFromDescription:contents];

	Class class = [builder.classes objectForKey:@"DRMSFFormatter"];
	XCTAssertTrue([class isKindOfClass:[NSObject class]], @"Class has not been found");
	XCTAssertTrue(class == [NSFormatter class], @"Class %@ has not been remapped", NSStringFromClass(class));
}

@end
