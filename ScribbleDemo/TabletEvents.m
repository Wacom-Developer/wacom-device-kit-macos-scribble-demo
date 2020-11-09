///////////////////////////////////////////////////////////////////////////////
//
// DESCRIPTION
// 	Header file for TabletEvent Category.
//    This is an extension to the NSEvent class.
//
// COPYRIGHT
//    Copyright (c) 2001 - 2020 Wacom Co., Ltd.
//    All rights reserved
//
///////////////////////////////////////////////////////////////////////////////

#import "TabletEvents.h"

NSString *kProximityNotification = @"Proximity Event Notification"; 

NSString *kVendorID = @"vendorID";
NSString *kTabletID = @"tabletID";
NSString *kPointerID = @"pointerID";
NSString *kDeviceID = @"deviceID";
NSString *kSystemTabletID = @"systemTabletID";
NSString *kVendorPointerType = @"vendorPointerType";
NSString *kPointerSerialNumber = @"pointerSerialNumber";
NSString *kUniqueID = @"uniqueID";
NSString *kCapabilityMask = @"capabilityMask";
NSString *kPointerType = @"pointerType";
NSString *kEnterProximity = @"enterProximity"; 

@implementation NSEvent (TabletEvents) 

///////////////////////////////////////////////////////////////////////////////

- (BOOL)isEventClassTablet
{
	NSEventType eventType = [self type];
	if (	eventType == NSEventTypeTabletPoint
		 || eventType == NSEventTypeTabletProximity)
	{
		return YES;
	}
	
	return NO;
}

///////////////////////////////////////////////////////////////////////////////

- (BOOL)isEventClassMouse
{
	NSEventType eventType = [self type];
	if (	eventType == NSEventTypeMouseMoved
		 ||	eventType == NSEventTypeLeftMouseDragged
		 ||	eventType == NSEventTypeRightMouseDragged
		 ||	eventType == NSEventTypeOtherMouseDragged

		 ||	eventType == NSEventTypeLeftMouseDown
		 ||	eventType == NSEventTypeRightMouseDown
		 ||	eventType == NSEventTypeOtherMouseDown

		 ||	eventType == NSEventTypeLeftMouseUp
		 ||	eventType == NSEventTypeRightMouseUp
		 ||	eventType == NSEventTypeOtherMouseUp)
	{
		return YES;
	}

	return NO;
}

///////////////////////////////////////////////////////////////////////////////

- (BOOL)isTabletPointerEvent
{
	if ([self isEventClassMouse])
	{
		if ([self subtype] == NSEventSubtypeTabletPoint)
		{
			return YES;
		}
	}

	if ([self type] == NSEventTypeTabletPoint)
	{
		return YES;
	}

	return NO;
}

///////////////////////////////////////////////////////////////////////////////

- (BOOL)isTabletProximityEvent
{
	if ([self isEventClassMouse])
	{
		if ([self subtype] == NSEventSubtypeTabletProximity)
		{
			return YES;
		}
	}

	if ([self type] == NSEventTypeTabletProximity)
	{
		return YES;
	}

	return NO;
}

///////////////////////////////////////////////////////////////////////////////

- (float)rawTabletPressure
{
   return [self pressure] * 65535.0f;
}

///////////////////////////////////////////////////////////////////////////////

- (float)rotationInRadians
{
   return [self rotation] * (float)(M_PI/180.0);
}

@end
