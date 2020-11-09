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

#import <Cocoa/Cocoa.h>

@interface NSEvent (TabletEvents)

- (BOOL)isEventClassTablet;
- (BOOL)isEventClassMouse;
- (BOOL)isTabletPointerEvent;
- (BOOL)isTabletProximityEvent;
- (float)rawTabletPressure;
- (float)rotationInRadians;

@end

///////////////////////////////////////////////////////////////////////////
// This is the name of the Notification sent when a proximity event is
//   captured by the application
extern NSString *kProximityNotification;   

// vendor-defined ID - typically will be USB vendor ID
extern NSString *kVendorID; 

// vendor-defined tablet ID
extern NSString *kTabletID;

// vendor-defined ID of the specific pointing device
extern NSString *kPointerID; 

// unique device ID - matches to deviceID field in tablet event
extern NSString *kDeviceID;

// unique tablet ID
extern NSString *kSystemTabletID;

// vendor-defined pointer type
extern NSString *kVendorPointerType;      

// vendor-defined serial number of the specific pointing device
extern NSString *kPointerSerialNumber;

// vendor-defined unique ID for this pointer
extern NSString *kUniqueID;

// mask representing the capabilities of the device
extern NSString *kCapabilityMask;

// type of pointing device - enum to be defined
extern NSString *kPointerType;

// non-zero = entering; zero = leaving
extern NSString *kEnterProximity;  
