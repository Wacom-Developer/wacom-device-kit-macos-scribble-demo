/*----------------------------------------------------------------------------

NAME

	WacomPlugIn.m -- Implementation file, provides an interface to the Wacom
                    PlugIn.
                    This file is based of off "LoadPlugIn.c" found in the
                    Carbon "TabletEventSample" sample code.
	

COPYRIGHT

	Copyright WACOM Technologies, Inc. 2001
	All rights reserved.

-----------------------------------------------------------------------------*/

#import "WacomPlugIn.h" 

WacomPlugin *gMasterPlugin = NULL;

@implementation WacomPlugin
//////////////////////////////////////////////////////////////////////////////
+ (WacomPlugin *) defaultPlugin
{
   if ( gMasterPlugin == NULL )
   {
      gMasterPlugin = [[WacomPlugin alloc] init];
   }
   return gMasterPlugin;
}



//////////////////////////////////////////////////////////////////////////////
- (WacomPlugin *) init
{
   WacomResult	wacResult = Wacom_Failure;
   
   if( self == [super init] )
   {
      mWacomPlugInRef = NULL;
      mWacomInterface = NULL;
      
      wacResult = LoadWacomPlugIn(	kWacomTabletDriverMachOTypeID, 
												kWacomTabletDriverMachOInterfaceID, 
												&mWacomPlugInRef,
												&mWacomInterface	);
                                    
      if (wacResult != Wacom_Success )
      {
      	mWacomPlugInRef = NULL;
         mWacomInterface = NULL;
      }
   }
   
   return self;
}



//////////////////////////////////////////////////////////////////////////////
- (void) dealoc
{
   ReleaseWacomPlugIn( &mWacomPlugInRef, &mWacomInterface);
   [super dealloc];
}



//////////////////////////////////////////////////////////////////////////////
- (WacomResult) GetNumberOfTabletsAttached:(TabletIndex *)numTabletsAttachedOut
{
   WacomResult	wacResult = Wacom_Failure;
   
   if( mWacomPlugInRef == NULL || mWacomInterface == NULL)
   {
      return Wacom_CouldNotConnect;
   }
   
   wacResult = (*mWacomInterface)->GetNumberOfTabletsAttached( mWacomInterface,
                                       numTabletsAttachedOut );
   
   return wacResult;
}


                                          
//////////////////////////////////////////////////////////////////////////////
- (WacomResult) GetTabletDimensionsForTablet:(TabletIndex) whichTablet
													units:(EUnits) whichUnits
                                       sizeOut:(UPoint32 *) tabletSizeOut
{
   WacomResult	wacResult = Wacom_Failure;
   
   if( mWacomPlugInRef == NULL || mWacomInterface == NULL)
   {
      return Wacom_CouldNotConnect;
   }
   
   wacResult = (*mWacomInterface)->GetTabletDimensions( mWacomInterface,
                                       whichTablet, whichUnits, 
                                       tabletSizeOut );
   
   return wacResult;
}


                                          
//////////////////////////////////////////////////////////////////////////////
- (WacomResult) GetScaleInfoForTransducerID:(UInt16) deviceID 
														scale:(ScaleInfo *) scaleInfo
{
   WacomResult	wacResult = Wacom_Failure;
   
   if( mWacomPlugInRef == NULL || mWacomInterface == NULL)
   {
      return Wacom_CouldNotConnect;
   }
   
   wacResult = (*mWacomInterface)->GetTransducerScaleInfo( mWacomInterface,
                                       deviceID, scaleInfo, NULL);
   
   return wacResult;
}


                                          
//////////////////////////////////////////////////////////////////////////////
- (WacomResult) ResendLastTabletEventOfType:(ETabletEventType) whichEvent
{
   WacomResult	wacResult = Wacom_Failure;
    
   if( mWacomPlugInRef == NULL || mWacomInterface == NULL)
   {
      return Wacom_CouldNotConnect;
   }
   
   wacResult = (*mWacomInterface)->ResendLastTabletEvent( mWacomInterface,
                                       whichEvent );

   return wacResult;
}


                                          
//////////////////////////////////////////////////////////////////////////////
- (WacomResult) GetTabletInfo:(WacomStaticTabletData *)pStaticDataOut
{
   WacomResult	wacResult = Wacom_Failure;
   
   if( mWacomPlugInRef == NULL || mWacomInterface == NULL)
   {
      return Wacom_CouldNotConnect;
   }
   
   wacResult = (*mWacomInterface)->GetTabletInfo( mWacomInterface,
                                       pStaticDataOut );
   
   return wacResult;
}


                                          
//////////////////////////////////////////////////////////////////////////////
- (WacomResult) SetMappingForTransducerID:(UInt16) deviceID
                                       screenMap:(const SRect32 *)screenMapIn
                                       tabletMap:(const SRect32 *)tabletMapIn
                                       newScale:(float *)newScaleOut
{
   WacomResult	wacResult = Wacom_Failure;
   
   if( mWacomPlugInRef == NULL || mWacomInterface == NULL)
   {
      return Wacom_CouldNotConnect;
   }
   
   wacResult = (*mWacomInterface)->SetTransducerMapping( mWacomInterface,
                                       deviceID, screenMapIn,  tabletMapIn,
                                       newScaleOut);
   
   return wacResult;
}
                                       
@end // @implementation WacomPlugin                                    
                                       
//////////////////////////////////////////////////////////////////////////////
WacomResult LoadWacomPlugIn(	CFUUIDRef plugInTypeRef, 
                        CFUUIDRef interfaceRef, 
                        CFPlugInRef *pWacomPlugInRefOut,
                        WacomTabletInterfaceStruct ***pIOWacomInterfaceOut )
{
	WacomResult				wacResult = Wacom_Failure;
	
	// Create a URL that points to the plug-in using a hard-coded path.
	CFURLRef url = CFURLCreateWithFileSystemPath( NULL, 
			CFSTR( kTabletPlugInPath ),
			kCFURLPOSIXPathStyle, TRUE );
	
	// Create a CFPlugin using the URL.
	// This step causes the plug-in's types and factories to be
	// registered with the system.
	// Note that the plug-in's code is not loaded unless the plug-in
	// is using dynamic registration.
	CFPlugInRef plugin = CFPlugInCreate( NULL, url );
	
	*pIOWacomInterfaceOut = NULL;
	*pWacomPlugInRefOut = NULL;
	
	if (!plugin) 
	{
		printf( "Could not create CFPluginRef, from path %s.\n", kTabletPlugInPath );
	} 
	else 
	{
		// See if this plug-in implements the <plugInTypeRef> type.
		CFArrayRef factories =
			CFPlugInFindFactoriesForPlugInType( plugInTypeRef );
	
		// If there are factories for the requested type, attempt to
		// get the IUnknown interface.
		if ((factories != NULL) && (CFArrayGetCount(factories) > 0)) 
		{
			IUnknownVTbl 				**iunknown;
			// Get the factory ID for the first location in the array of IDs.
			CFUUIDRef factoryID = (CFUUIDRef)CFArrayGetValueAtIndex( factories, 0 );
	
			// Use the factory ID to get an IUnknown interface.
			// Here the code for the PlugIn is loaded.
			iunknown = (IUnknownVTbl **)CFPlugInInstanceCreate( NULL,
													factoryID, plugInTypeRef );
	
			// If this is an IUnknown interface, query for the interface.
			if (iunknown) 
			{
				CFUUIDBytes				uuidBytes;
				WacomTabletInterfaceStruct **interface = NULL;
				
				uuidBytes = CFUUIDGetUUIDBytes(interfaceRef);
				
				(*iunknown)->QueryInterface( iunknown, uuidBytes, (LPVOID *)(&interface) );

				// Done with IUnknown.
				(*iunknown)->Release( iunknown );
				// If this is a Test interface, try to call its function.
				
				*pIOWacomInterfaceOut = interface;
				
				if (interface) 
				{
					wacResult = Wacom_Success;
				} 
				else 
				{
					printf( "Failed to get interface.\n" );
				}
			} 
			else 
			{
				printf( "Failed to create instance.\n" );
			}
		} 
		else 
		{
			printf( "Could not find any factories.\n" );
		}
		if ( wacResult != Wacom_Success )
		{
			// Release the CFPlugin.
			// Memory for the plug-in is deallocated here.
			CFRelease( plugin );
		}
		else
		{
			*pWacomPlugInRefOut = plugin;
		}
	}
	return	wacResult;
}



//////////////////////////////////////////////////////////////////////////////
void ReleaseWacomPlugIn( CFPlugInRef *pWacomPlugInRefInOut,
                     WacomTabletInterfaceStruct ***pIOWacomInterfaceInOut )
{
	if ( pIOWacomInterfaceInOut && *pIOWacomInterfaceInOut )
	{
		(**pIOWacomInterfaceInOut)->Release( *pIOWacomInterfaceInOut );
		*pIOWacomInterfaceInOut = NULL;
	}
	
	if ( pWacomPlugInRefInOut && *pWacomPlugInRefInOut )
	{
		CFRelease( *pWacomPlugInRefInOut );
		*pWacomPlugInRefInOut = NULL;
	}
}
