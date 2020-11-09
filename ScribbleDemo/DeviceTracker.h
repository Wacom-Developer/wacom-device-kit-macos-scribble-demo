///////////////////////////////////////////////////////////////////////////////
//
// DESCRIPTION
// 	Header file for the DeviceTracker and Transducer classes.
//
// COPYRIGHT
//    Copyright (c) 2001 - 2020 Wacom Co., Ltd.
//    All rights reserved
//
///////////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>

@interface Transducer : NSObject
{
   UInt16	mIdent;
   NSColor	*mColor;
}

- (Transducer *) initWithIdent:(UInt16)newIdent_I color:(NSColor *) newColor_I;
- (UInt16) ident;
- (NSColor *) color;
- (void) setColor:(NSColor *) newColor_I;

@end

@interface DeviceTracker : NSObject
{
   Transducer *currentDevice;
   NSMutableArray *deviceList;
}

- (bool) setCurrentDeviceByID:(UInt16) deviceIdent_I;
- (Transducer *) currentDevice;
- (void) addDevice:(Transducer *) newDevice_I;

@end
