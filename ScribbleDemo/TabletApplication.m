///////////////////////////////////////////////////////////////////////////////
//
// DESCRIPTION
// 	Adds Proximity events to the App.
// 	This is a subclass of NSApplication. It's purpose is to
// 	catch Proximity events and Post a kProximityNotification
// 	to any object that is listening for them. This is
// 	preferable than sending a proximity event, because more
// 	than one object may need to know about each proximity
// 	event. Furthermore, if an object is not in the current
// 	event chain, it would also miss the proximity event.
//
// COPYRIGHT
//    Copyright (c) 2001 - 2020 Wacom Co., Ltd.
//    All rights reserved
//
///////////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>

#import "TabletApplication.h"
#import "TabletEvents.h"
#import "Wacom.h"
#import "WacomTabletDriver.h"

@implementation TabletApplication

///////////////////////////////////////////////////////////////////////////////

- (id)init
{
   if (self = [super init])
   {
      [self tabletInfo];
   }
   
   return self;
}

///////////////////////////////////////////////////////////////////////////////

- (void)sendEvent:(NSEvent *)theEvent_I
{
	if ([theEvent_I isEventClassTablet])
	{
		if ([theEvent_I isTabletProximityEvent])
		{
			[self handleProximityEvent:theEvent_I];
		}
		else
		{
			// Pure tablet event? Probably from a second concurrent device.
		}

		return;
	}

	[super sendEvent:theEvent_I];
}

///////////////////////////////////////////////////////////////////////////////

- (void)handleProximityEvent:(NSEvent *)theEvent_I
{
	NSUInteger vendorID = theEvent_I.vendorID;
	NSUInteger tabletID = theEvent_I.tabletID;
	NSUInteger pointingDeviceID = theEvent_I.pointingDeviceID;
	NSUInteger deviceID = theEvent_I.deviceID;
	NSUInteger systemTabletID = theEvent_I.systemTabletID;
	NSUInteger vendorPointingDeviceType = theEvent_I.vendorPointingDeviceType;
	NSUInteger pointingDeviceSerialNumber = theEvent_I.pointingDeviceSerialNumber;
	unsigned long long uniqueID = theEvent_I.uniqueID;
	NSUInteger capabilityMask = theEvent_I.capabilityMask;
	NSPointingDeviceType pointingDeviceType = theEvent_I.pointingDeviceType;
	BOOL enteringProximity = theEvent_I.enteringProximity;

	// Set up the keys that are used to extract the data from the Dictionary we provided with the Proximity Notification
	NSArray *keys = [NSArray arrayWithObjects:
		kVendorID,
		kTabletID,
		kPointerID,
		kDeviceID,
		kSystemTabletID,
		kVendorPointerType,
		kPointerSerialNumber,
		kUniqueID,
		kCapabilityMask,
		kPointerType,
		kEnterProximity,
		nil];

	// Setup the data aligned with the keys above to easily create the Dictionary
	NSArray *values = [NSArray arrayWithObjects:
		[NSValue valueWithBytes:&vendorID objCType:@encode(UInt16)],
		[NSValue valueWithBytes:&tabletID objCType:@encode(UInt16)],
		[NSValue valueWithBytes:&pointingDeviceID objCType:@encode(UInt16)],
		[NSValue valueWithBytes:&deviceID objCType:@encode(UInt16)],
		[NSValue valueWithBytes:&systemTabletID objCType:@encode(UInt16)],
		[NSValue valueWithBytes:&vendorPointingDeviceType objCType:@encode(UInt16)],
		[NSValue valueWithBytes:&pointingDeviceSerialNumber objCType:@encode(UInt32)],
		[NSValue valueWithBytes:&uniqueID objCType:@encode(UInt64)],
		[NSValue valueWithBytes:&capabilityMask objCType:@encode(UInt32)],
		[NSValue valueWithBytes:&pointingDeviceType objCType:@encode(UInt8)],
		[NSValue valueWithBytes:&enteringProximity objCType:@encode(UInt8)],
		nil];

	// Create the dictionary
	NSDictionary *proximityDict = [NSDictionary dictionaryWithObjects:values forKeys:keys];

	// Send the Procimity Notification
	[[NSNotificationCenter defaultCenter] postNotificationName:kProximityNotification object:self userInfo:proximityDict];
}

///////////////////////////////////////////////////////////////////////////////

- (void)tabletInfo
{
	UInt32 numTablets	= [WacomTabletDriver tabletCount];
	if (numTablets)
	{
		printf( "I see %d tablets attached\n", (int)numTablets );
		
		for (int index = 1; index <= numTablets; index++ )
		{
			[self printInfoForTabletIndex:index];
		}
	}
}

///////////////////////////////////////////////////////////////////////////////

- (void)printInfoForTabletIndex:(UInt32)tabletIndex_I
{
   LongRect	tabletSizeOut = {};

	NSAppleEventDescriptor *nameResponse = nil;
	NSAppleEventDescriptor *sizeResponse = nil;
	
	nameResponse = [WacomTabletDriver dataForAttribute:pName
															  ofType:typeUTF8Text
													  routingTable:[WacomTabletDriver routingTableForTablet:tabletIndex_I]];
	
	sizeResponse = [WacomTabletDriver dataForAttribute:pTabletSize
															  ofType:typeLongRectangle
													  routingTable:[WacomTabletDriver routingTableForTablet:tabletIndex_I]];

	if (nameResponse != nil && sizeResponse != nil)
	{
		NSString *tabletName = [nameResponse stringValue];
		[[sizeResponse data] getBytes:&tabletSizeOut length:sizeof(tabletSizeOut)];
		
		NSLog(@"Tablet %d [%@] is %d by %d\n", (int)tabletIndex_I, tabletName, (int)tabletSizeOut.bottom, (int)tabletSizeOut.right );
	}
	else
	{
		NSLog(@"Couldn't get tablet dimensions");
	}
}

@end
