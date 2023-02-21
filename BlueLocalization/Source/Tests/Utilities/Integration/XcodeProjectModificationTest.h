//
//  XcodeProjectModificationTest.h
//  BlueLocalization
//
//  Created by max on 03.07.09.
//  Copyright 2009 Blue Technologies Group. All rights reserved.
//

@interface XcodeProjectModificationTest : XCTestCase {
	BLXcodeProjectItem *mainGroup;
	NSMutableDictionary *objectsDict;
	BLXcodeProjectParser *parser;
}

@end
