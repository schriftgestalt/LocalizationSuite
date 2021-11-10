//
//  KeyValueMatcher.h
//  LocTools
//
//  Created by max on 07.06.09.
//  Copyright 2009 Blue Technologies Group. All rights reserved.
//

#import <hamcrest/HCBaseMatcher.h>

@interface KeyValueMatcher : HCBaseMatcher {
	NSString *key;
	id<HCMatcher> matcher;
}

+ (KeyValueMatcher *)valueForKey:(NSString *)key matches:(id<HCMatcher>)theMatcher;
- (id)initWithKey:(NSString *)key andMatcher:(id<HCMatcher>)theMatcher;

@end

#ifdef __cplusplus
extern "C" {
#endif

/**
 Evaluates whether [item valueForKey: key] satisfies a given matcher.

 Example: valueForKey(@"key", equalTo(result))
 */
id<HCMatcher> HC_valueForKey(NSString *key, id item);

#ifdef __cplusplus
}
#endif

#ifdef HC_SHORTHAND

/**
 Shorthand for HC_valueForKey, available if HC_SHORTHAND is defined.
 */
#define valueForKey HC_valueForKey

#endif
