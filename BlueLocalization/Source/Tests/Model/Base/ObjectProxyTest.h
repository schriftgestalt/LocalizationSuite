//
//  FileObjectProxyTest.h
//  BlueLocalization
//
//  Created by Max Seelemann on 07.05.09.
//  Copyright 2009 The Blue Technologies Group. All rights reserved.
//

#import <BlueLocalization/BLObjectProxy.h>

@interface ObjectProxyTest : SenTestCase {
	BLFileObject *object1, *object2, *pObject;
	BLObjectProxy *proxy;
	NSString *path;
}

- (NSString *)pathForFile:(NSString *)file;

@end
