//
//  NibDocument.h
//  LocInterface
//
//  Created by max on 06.04.09.
//  Copyright 2009 Blue Technologies Group. All rights reserved.
//

@class CustomPathCreator;

@interface NibDocument : NSDocument <BLDocumentProtocol> {
	LIPreviewController *_controller;
	BLFileObject *_fileObject;
	CustomPathCreator *_pathCreator;
}

@end
