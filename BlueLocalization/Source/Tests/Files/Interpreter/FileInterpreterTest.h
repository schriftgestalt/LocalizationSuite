//
//  FileInterpreterTest.h
//  BlueLocalization
//
//  Created by Max Seelemann on 18.04.09.
//  Copyright 2009 The Blue Technologies Group. All rights reserved.
//

@interface FileInterpreterTest : XCTestCase {
	BLFileObject *fileObject;
	BLFileInterpreter *interpreter;
	NSString *path;
	NSString *path2;
}

- (NSString *)pathForFile:(NSString *)file;
- (NSString *)pathForCommentFile:(NSString *)file ofType:(NSString *)type;

@end
