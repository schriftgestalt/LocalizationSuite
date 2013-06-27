/*!
 @header
 NPColorAdditions.m
 Created by max on 18.07.08.
 
 @copyright 2008-2009 Localization Suite. All rights reserved.
 */

#import "NPColorAdditions.h"


@implementation NSColor (NPColorAdditions)

+ (NSColor *)colorFromIBToolString:(NSString *)string
{
	NSString *colorSpaceName;
	NSColorSpace *colorSpace;
	NSArray *parts;
	
	parts = [string componentsSeparatedByString: @" "];
	colorSpaceName = [parts objectAtIndex: 0];
	colorSpace = nil;
	
	// Handle special cases
	if ([colorSpaceName isEqual: @"NSNamedColorSpace"]) {
		return [NSColor colorWithCatalogName:[parts objectAtIndex: 1] colorName:[parts objectAtIndex: 2]];
	}
	if ([colorSpaceName isEqual: @"NSCustomColorSpace"]) {
		// Get the actual color space
		colorSpaceName = [[parts subarrayWithRange: NSMakeRange(1, 3)] componentsJoinedByString: @""];
		// Remove double color space name
		parts = [parts subarrayWithRange: NSMakeRange(3, [parts count]-3)];
	}
	
	// Handle general cases
	if ([colorSpaceName isEqual: @"NSCalibratedRGBColorSpace"] || [colorSpaceName isEqual: @"GenericRGBcolorspace"])
		colorSpace = [NSColorSpace genericRGBColorSpace];
	if ([colorSpaceName isEqual: @"NSCalibratedWhiteColorSpace"] || [colorSpaceName isEqual: @"GenericWhitecolorspace"] || [colorSpaceName isEqual: @"GenericGraycolorspace"])
		colorSpace = [NSColorSpace genericGrayColorSpace];
	if ([colorSpaceName isEqual: @"NSCalibratedCMYKColorSpace"] || [colorSpaceName isEqual: @"GenericCMYKcolorspace"])
		colorSpace = [NSColorSpace genericCMYKColorSpace];
	if ([colorSpaceName isEqual: @"NSDeviceRGBColorSpace"] || [colorSpaceName isEqual: @"DeviceRGBcolorspace"])
		colorSpace = [NSColorSpace deviceRGBColorSpace];
	if ([colorSpaceName isEqual: @"NSDeviceWhiteColorSpace"] || [colorSpaceName isEqual: @"DeviceWhitecolorspace"] || [colorSpaceName isEqual: @"DeviceGraycolorspace"])
		colorSpace = [NSColorSpace deviceGrayColorSpace];
	if ([colorSpaceName isEqual: @"NSDeviceCMYKColorSpace"] || [colorSpaceName isEqual: @"DeviceCMYKcolorspace"])
		colorSpace = [NSColorSpace deviceCMYKColorSpace];
	
	// Create the color
	if (colorSpace) {
		CGFloat *components;
		NSColor *color;
		
		components = (CGFloat *)malloc(sizeof(CGFloat) * ([parts count] - 1));
		for (NSUInteger i=1; i<[parts count]; i++)
			components[i-1] = [[parts objectAtIndex: i] floatValue];
		
		color = [NSColor colorWithColorSpace:colorSpace components:components count:[parts count]-1];
		free(components);
		
		return color;
	}
	
	return nil;
}

@end
