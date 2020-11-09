///////////////////////////////////////////////////////////////////////////////
//
// DESCRIPTION
// 	Header file, adds Proximity events to the App.
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

#import <AppKit/NSApplication.h>

@interface TabletApplication : NSApplication

- (void)handleProximityEvent:(NSEvent *)theEvent_I;
- (void)printInfoForTabletIndex:(UInt32)tabletIndex_I;
- (void)tabletInfo;

@end
