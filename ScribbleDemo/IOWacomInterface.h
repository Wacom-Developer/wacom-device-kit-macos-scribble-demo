/*----------------------------------------------------------------------------

NAME

   IOWacomInterface.h -- Definition file for the Wacom CFPlugIn.


COPYRIGHT

   Copyright WACOM Technologies, Inc. 2001
   All rights reserved.

-----------------------------------------------------------------------------*/

#ifndef IOWACOMINTERFACE_H			
#define IOWACOMINTERFACE_H	//			{

#if __MWERKS__	//				{

#include <CFPlugInCOM.h>	

#else								//				}{

#include <CoreFoundation/CFPlugInCOM.h>
#include <CoreFoundation/CoreFoundation.h>

#endif							//				}

#if defined(__cplusplus)
extern "C" {
#endif


//////////////////////////////////////////////////////////////////////////////
// Define the UUID for the type, "324CF6E4-FBA1-11D4-9BE4-0030657CDFBE"
#define kWacomTabletDriverMachOTypeID (CFUUIDGetConstantUUIDWithBytes(NULL, 0x32, \
0x4C, 0xF6, 0xE4, 0xFB, 0xA1, 0x11, 0xD4, 0x9B, 0xE4, 0x00, 0x30, 0x65, 0x7C, \
0xDF, 0xBE))


// Define the UUID for the interface, "A13E09D8-FBA2-11D4-84C3-0030657CDFBE"
#define kWacomTabletDriverMachOInterfaceID (CFUUIDGetConstantUUIDWithBytes(NULL, 0xA1, \
0x3E, 0x09, 0xD8, 0xFB, 0xA2, 0x11, 0xD4, 0x84, 0xC3, 0x00, 0x30, 0x65, 0x7C, 0xDF,\
 0xBE))


//////////////////////////////////////////////////////////////////////////////
// Define the UUID for the type (for CFM), "07451A4C-5E9B-11D5-A745-0030657CDFBE"
#define kWacomTabletDriverCFMTypeID (CFUUIDGetConstantUUIDWithBytes(NULL, 0x07, \
	0x45, 0x1A, 0x4C, 0x5E, 0x9B, 0x11, 0xD5, 0xA7, 0x45, 0x00, 0x30, 0x65, 0x7C, \
	0xDF, 0xBE))

// Define the UUID for the interface (CFM), "7407F7C4-5E9B-11D5-BC4F-0030657CDFBE"
#define kWacomTabletDriverCFMInterfaceID (CFUUIDGetConstantUUIDWithBytes(NULL, 0x74, \
	0x07, 0xF7, 0xC4, 0x5E, 0x9B, 0x11, 0xD5, 0xBC, 0x4F, 0x00, 0x30, 0x65, 0x7C, \
	0xDF, 0xBE))


//////////////////////////////////////////////////////////////////////////////
//	Location of the plugin.
#define		kTabletPlugInPath		"/System/Library/Extensions/TabletDriverCFPlugin.bundle"


//////////////////////////////////////////////////////////////////////////////
typedef OSStatus WacomResult;

enum
{
	Wacom_Success 	=				noErr,		//	general success result
	Wacom_Failure	=				dsSysErr,	//	general failure result
	Wacom_CouldNotConnect	=	openErr,		//	Tablet Driver is not running
	Wacom_Unimplemented		=	unimpErr		//	Routine is not yet implemented
};



//////////////////////////////////////////////////////////////////////////////
typedef struct WacomStaticTabletData
{
	char	maxTransOnTablet;	//	maximum number of transducers on a tablet, should be "2"
	short	angleRes;			// metric bit & angular resolution
	short	spaceRes;			// spatial resolution of the tablet
} WacomStaticTabletData;


//////////////////////////////////////////////////////////////////////////////
typedef UInt32		TabletIndex;		// 1 based index


typedef struct UPoint32
{
	UInt32 y;
	UInt32 x;
} UPoint32;

struct SRect32 
{
	SInt32	top;
	SInt32	left;
	SInt32	bottom;
	SInt32	right;
};
typedef struct SRect32 SRect32;

#define MacRectTo32BitWacomRect( Rect16, Rect32 )	\
do	\
{	\
	Rect32.top = Rect16.top;Rect32.left = Rect16.left;	\
	Rect32.bottom = Rect16.bottom; Rect32.right = Rect16.right;	\
} while (0)	


//////////////////////////////////////////////////////////////////////////////
typedef enum EUnits
{
	ETabletUnits_Counts
} EUnits;


//////////////////////////////////////////////////////////////////////////////
typedef enum ETabletEventType
{
	ETabletEvent_Proximity = 0,
	ETabletEvent_Pointer
} ETabletEventType;

typedef struct ScaleInfo
{
	Fixed					scaleX;	// x scale factor for screen mapping
	SInt16				transX;	// x translation factor for screen

	Fixed					scaleY;	// x scale factor for screen mapping
	SInt16				transY;	// x translation factor for screen
	//	It is highly recommended that you use scale and trans but for
	//	legacy reasons the tablet and screen Rect are provided with the
	//	same field names as the old style TabletRecord.
	Rect					tabletBounds;
	Rect					screenBounds;
	
	UInt16					isInRelativeMode;		// always false for now...
	float					fScaleX;
	float					fScaleY;
} ScaleInfo;


//////////////////////////////////////////////////////////////////////////////
// The function table for the interface.
typedef struct WacomTabletInterfaceStruct 
{
	IUNKNOWN_C_GUTS;
	WacomResult (*Reserved)();

	WacomResult (*GetNumberOfTabletsAttached)(void *thisInterface, 
															TabletIndex *numTabletsAttachedOut );
	// GetTabletDimensions(), returns the Tablet Dimensions for <whichTablet> which 
	//	is a "1" based index units are specified in the <whichUnits> parameter, the 
	//	size is returned via <tabletSizeOut>
	WacomResult (*GetTabletDimensions)(	void *thisInstance, TabletIndex whichTablet, 
													EUnits whichUnits, UPoint32 *tabletSizeOut	);
													
	//	deviceID is from the deviceID field of the TabletPointerRec and TabletProximityRec 
	//	you get from the Carbon Events.
	//	Right now if reset the scale and call GetTransducerScaleInfo() the wrong scale
	//	info will be returned.  Stay tuned.
	WacomResult (*GetTransducerScaleInfo)(	void *thisInstance, UInt16 deviceID, 
														ScaleInfo *scaleInfo, void *extra	);

	WacomResult (*ResendLastTabletEvent)(	void *thisInstance, 
														ETabletEventType whichEvent	);		

	// deprecated, being replaced by the calls above.								
	WacomResult (*GetTabletInfo)(	void *thisInterface, 
											WacomStaticTabletData *pStaticDataOut	);
											
	//	deviceID is from the deviceID field of the TabletPointerRec and TabletProximityRec 
	//	Calculates the new screen to tablet mapping from the <screenMap> and <tabletMap>
	//	NULL values for <tabletMap> or <screenMap> will be taken to mean "full Tablet" and
	// "full Screen" respectively.
	WacomResult (*SetTransducerMapping)(	void *thisInstance, UInt16 deviceID,
														const SRect32 *screenMapIn, const SRect32 *tabletMapIn,
														float *newScaleOut	);
									

} WacomTabletInterfaceStruct;
//////////////////////////////////////////////////////////////////////////////


#if defined(__cplusplus)
}
#endif

#endif									//			}