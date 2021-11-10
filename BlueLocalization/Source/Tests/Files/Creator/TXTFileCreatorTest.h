//
//  TXTFileCreatorTest.h
//  BlueLocalization
//
//  Created by Max Seelemann on 25.08.11.
//  Copyright (c) 2011 Localization Suite. All rights reserved.
//

//  Logic unit tests contain unit test code that is designed to be linked into an independent test executable.

@interface TXTFileCreatorTest : SenTestCase {
	BLFileCreator *creator;
	BLFileInterpreter *interpreter;
	NSString *tmpRootPath;
}

@end
