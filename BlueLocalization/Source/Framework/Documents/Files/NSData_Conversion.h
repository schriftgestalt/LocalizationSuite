//
//	NSData_Conversion.h
//  Glyphs
//
//  Created by Georg Seifert on 17.04.12.
//  Copyright (c) 2012 schriftgestaltung.de. All rights reserved.
//

@interface NSString (Hex_Data)

- (NSData *)hexadecimalData;

- (NSString *)hexDescription;
@end

@interface NSData (HexString)

- (NSString *)hexadecimalString;

@end
