/*----------------------------------------------------------------------------

NAME

	WacomPlugIn.m -- Header file, provides an interface to the Wacom PlugIn.
                    This file is based of off "LoadPlugIn.h" found in the
                    Carbon "TabletEventSample" sample code.
	

COPYRIGHT

	Copyright WACOM Technologies, Inc. 2001
	All rights reserved.

-----------------------------------------------------------------------------*/

#ifndef WACOMPLUGIN_H 
#define WACOMPLUGIN_H

#import "IOWacomInterface.h"
#import <Cocoa/Cocoa.h>

@interface WacomPlugin : NSObject {
   CFPlugInRef							mWacomPlugInRef;
   WacomTabletInterfaceStruct		**mWacomInterface;
}

+ (WacomPlugin *) defaultPlugin;

- (WacomResult) GetNumberOfTabletsAttached:(TabletIndex *)numTabletsAttachedOut;

- (WacomResult) GetTabletDimensionsForTablet:(TabletIndex) whichTablet
													units:(EUnits) whichUnits
                                       sizeOut:(UPoint32 *) tabletSizeOut;

- (WacomResult) GetScaleInfoForTransducerID:(UInt16) deviceID 
														scale:(ScaleInfo *) scaleInfo;

- (WacomResult) ResendLastTabletEventOfType:(ETabletEventType) whichEvent;		
							
- (WacomResult) GetTabletInfo:(WacomStaticTabletData *)pStaticDataOut;

- (WacomResult) SetMappingForTransducerID:(UInt16) deviceID
														screenMap:(const SRect32 *)screenMapIn
                                          tabletMap:(const SRect32 *)tabletMapIn
														newScale:(float *)newScaleOut;
@end

WacomResult LoadWacomPlugIn(	CFUUIDRef plugInTypeRef, 
										CFUUIDRef interfaceRef, 
										CFPlugInRef *pWacomPlugInRef,
										WacomTabletInterfaceStruct ***pIOWacomInterfaceOut );


void ReleaseWacomPlugIn(	CFPlugInRef *pWacomPlugInRefInOut,
									WacomTabletInterfaceStruct ***pIOWacomInterfaceInOut	);

#endif			//	WACOMPLUGIN_H
