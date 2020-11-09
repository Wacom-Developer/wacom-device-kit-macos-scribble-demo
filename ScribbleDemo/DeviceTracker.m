///////////////////////////////////////////////////////////////////////////////
//
// DESCRIPTION
// 	Implamentation file for the DeviceTracker and Transducer classes.
//
// COPYRIGHT
//    Copyright (c) 2001 - 2020 Wacom Co., Ltd.
//    All rights reserved
//
///////////////////////////////////////////////////////////////////////////////

#import "DeviceTracker.h"

#pragma mark -
#pragma mark Transducer
#pragma mark -

@implementation Transducer

///////////////////////////////////////////////////////////////////////////////

- (Transducer *) init
{
   if (self = [super init])
   {
      mColor = [NSColor blackColor];
   }
   
   return self;
}

///////////////////////////////////////////////////////////////////////////////

- (Transducer *) initWithIdent:(UInt16)newIdent_I color:(NSColor *) newColor_I
{
   if (self = [super init])
   {
      mIdent = newIdent_I;
      mColor = [newColor_I copy];
   }
   
   return self;
}

///////////////////////////////////////////////////////////////////////////////

- (UInt16) ident
{
   return mIdent;
}

///////////////////////////////////////////////////////////////////////////////

- (NSColor *) color
{
   return mColor;
}

///////////////////////////////////////////////////////////////////////////////

- (void) setColor:(NSColor *)newColor_I
{
   mColor = nil;
   mColor = [newColor_I copy];
}

@end

#pragma mark -
#pragma mark DeviceTracker
#pragma mark -

///////////////////////////////////////////////////////////////////////////////

@implementation DeviceTracker

- (DeviceTracker *) init
{
   if(self = [super init])
   {
      currentDevice = NULL;
      deviceList = [[NSMutableArray alloc] init];
   }
   return self;
}

///////////////////////////////////////////////////////////////////////////////

- (bool) setCurrentDeviceByID:(UInt16) deviceIdent_I
{
   NSEnumerator	*enumerator = [deviceList objectEnumerator];
   id					anObject;
	
   while ((anObject = [enumerator nextObject]))
   {
      if ([anObject ident] == deviceIdent_I)
      {
         currentDevice = anObject;
         return YES;
      }
   }
   
   return NO;
}

///////////////////////////////////////////////////////////////////////////////

- (Transducer *) currentDevice
{
   return currentDevice;
}

///////////////////////////////////////////////////////////////////////////////

- (void) addDevice:(Transducer *) newDevice_I
{
   if (newDevice_I != nil)
   {
      [deviceList addObject: newDevice_I];
   }
}

@end
