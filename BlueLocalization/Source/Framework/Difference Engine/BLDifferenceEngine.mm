/*!
 @header
 LTDifferenceEngine.h
 Created by max on 20.03.05.
 
 @copyright 2009 Localization Suite. All rights reserved.
 */

#import "BLDifferenceEngine.h"
#import "BLDifference.h"
#import "diffEngine.h"

/*!
 @abstract Internal methodes of LTDifference used by LTDifferenceEngine.
 */
@interface BLDifference (DiffOperationInternal)

- (id)initWithDiffOp:(DiffOperation *)op;

@end

/*!
 @abstract Internal methodes of LTDifferenceEngine.
 */
@interface BLDifferenceEngine (LTDifferenceEngineInternal)

- (void)computeDifferencesDetailled:(BOOL)detail;
- (void)splitString:(NSString *)string intoParts:(char ***)parts count:(unsigned *)partCount;

@end


@implementation BLDifferenceEngine

- (id)init
{
    self = [super init];
    
    _segmentation = BLParagraphSegmentation;
    _differences = nil;
    _matchValue = 0;
	_newSegments = nil;
    _newString = [[NSString alloc] init];
	_oldSegments = nil;
    _oldString = [[NSString alloc] init];
    
    engine = new DiffEngine;
    
    return self;
}



#pragma mark - Accessors

@synthesize segmentation=_segmentation;

- (void)setSegmentation:(BLSegmentationType)seg
{
	_segmentation = seg;
	
	_newSegments = [_newString segmentsForType:_segmentation delimiters:NULL];
	_oldSegments = [_oldString segmentsForType:_segmentation delimiters:NULL];
}

- (NSString *)newString
{
	return _newString;
}

- (void)setNewString:(NSString *)string
{
	_newString = string;
	
	_newSegments = [_newString segmentsForType:_segmentation delimiters:NULL];
}

@synthesize oldString=_oldString;

- (void)setOldString:(NSString *)string
{
	_oldString = string;
	
	_oldSegments = [_oldString segmentsForType:_segmentation delimiters:NULL];
}


#pragma mark - Computation

- (void)computeDifferences
{
	[self computeDifferencesDetailled: YES];
}

- (void)computeMatchValueOnly
{
	[self computeDifferencesDetailled: NO];
}

- (void)computeDifferencesDetailled:(BOOL)detail
{
    vector<DiffOperation*> *diffs;
	vector<const char *> oldLines;
    vector<const char *> newLines;
	float a, b;
	
	// Init engine
	const char **newObjects = (const char **)malloc(sizeof(const char *) * [_newSegments count]);
	int index = 0;
	
	for (NSString *segment in _newSegments)
		newObjects[index++] = [segment UTF8String];
	((DiffEngine *)engine)->set_to(newObjects, (int)[_newSegments count]);
	
	const char **oldObjects = (const char **)malloc(sizeof(const char *) * [_oldSegments count]);
	index = 0;
	
	for (NSString *segment in _oldSegments)
		oldObjects[index++] = [segment UTF8String];
	((DiffEngine *)engine)->set_from(oldObjects, (int)[_oldSegments count]);
	
    // Run engine
    diffs = ((DiffEngine *)engine)->diff();
	
	free(newObjects);
	free(oldObjects);
    
	if (detail) {
		_differences = [[NSMutableArray alloc] init];
	}
	
    a = 0;
    b = 0;
    
    for (NSUInteger i=0; i<diffs->size(); i++) {
		if (detail)
			[_differences addObject: [[BLDifference alloc] initWithDiffOp: (*diffs)[i]]];
		
		oldLines = (*diffs)[i]->oldLines;
		newLines = (*diffs)[i]->newLines;
		
        if ((*diffs)[i]->type != DiffOpCopy) {
			// Values Differ
            b += newLines.size() + oldLines.size();
			
			// Check for case difference only
			if (newLines.size() == oldLines.size()) {
				NSUInteger k;
				
				for (k=0; k<newLines.size(); k++) {
					if (![[[NSString stringWithUTF8String: newLines[k]] lowercaseString] isEqual: [[NSString stringWithUTF8String: oldLines[k]] lowercaseString]])
						break;
				}
				
				if (k == newLines.size())
					a += (newLines.size() + oldLines.size()) / 2;
			}
		}
		else {
			// Same Values
			a += newLines.size();
		}
    }
    
	if (a > 0. || b > 0.)
		_matchValue = a / (a + b/2.);
	else
		_matchValue = 0.;
}

- (NSArray *)differences
{
    return _differences;
}

- (float)matchValue
{
    return _matchValue;
}

@end
