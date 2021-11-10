//
//  StringsDocument.h
//  LocInterface
//
//  Created by max on 27.08.09.
//  Copyright 2009 Localization Suite. All rights reserved.
//

@interface StringsDocument : NSDocument {
	IBOutlet LIContentController *contentController;
	IBOutlet NSView *contentView;

	BLFileObject *_file;
}

@property (readonly) NSArray *content;

@end
