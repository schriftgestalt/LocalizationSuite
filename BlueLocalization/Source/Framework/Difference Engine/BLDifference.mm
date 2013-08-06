/*!
 @header
 LTDifference.m
 Created by max on 20.03.05.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "BLDifference.h"
#import "diffEngine.h"


@implementation BLDifference

- (id)initWithDiffOp:(DiffOperation *)op
{
    self = [super init];
    
	vector<const char *> *lines;
    unsigned i;
    
    _newValue = @"";
    lines = &(op->newLines);
    for (i=0; i<lines->size(); i++)
        _newValue = [_newValue stringByAppendingFormat: @"%@ ", [NSString stringWithUTF8String: (*lines)[i]]];
    if (i) _newValue = [_newValue substringToIndex: [_newValue length] - 1];
    
    _oldValue = @"";
    lines = &(op->oldLines);
    for (i=0; i<lines->size(); i++)
        _oldValue = [_oldValue stringByAppendingFormat: @"%@ ", [NSString stringWithUTF8String: (*lines)[i]]];
    if (i) _oldValue = [_oldValue substringToIndex: [_oldValue length] - 1];
    
    _type = (BLDifferenceType) op->type;
    
    return self;
}


- (NSString *)newValue
{
    return _newValue;
}

- (NSString *)oldValue
{
    return _oldValue;
}

- (BLDifferenceType)type
{
    return _type;
}

@end
