// /////////////////////////////////////////////////////////////////////////////
//
// DESCRIPTION
// 	Implementation file for WTView class.
//
//		This is not intended to be production code. Please do not copy directly
//		from this sample.
//
// COPYRIGHT
//    Copyright (c) 2001 - 2021 Wacom Co., Ltd.
//    All rights reserved
//
// /////////////////////////////////////////////////////////////////////////////

#import "WTView.h"

#import "TabletApplication.h"
#import "TabletEvents.h"
#import "Wacom.h"
#import "WacomTabletDriver.h"

NSString *WTViewUpdatedNotification = @"WTViewStatsUpdatedNotification";

#define maxBrushSize 50.0

@implementation WTView

- (id) initWithFrame:(NSRect)frame_I
{
    self = [super initWithFrame:frame_I];
    if (self)
    {
        // Initialization code here.
        mAdjustOpacity = YES;
        mAdjustSize = NO;
        mCaptureMouseMoves = NO;
        mUpdateStatsDuringDrag = YES;
        knownDevices = [[DeviceTracker alloc] init];
		  self.image = nil;
    }
    return self;
}

// /////////////////////////////////////////////////////////////////////////////

- (void) awakeFromNib
{
   //Must register to be notified when device goes in and out of Prox
   [[NSNotificationCenter defaultCenter] addObserver:self
                                          selector:@selector(handleProximity:)
                                          name:kProximityNotification
                                          object:nil];
}

// /////////////////////////////////////////////////////////////////////////////

- (void) mouseDown:(NSEvent *)theEvent_I
{
   [self handleMouseEvent:theEvent_I];
   
   // Save the location the mouse down occurred at. This will be used by the
   // Drawing code during a Drag event to follow.
   mLastLoc = [self convertPoint:[theEvent_I locationInWindow]
                  fromView:nil];

	if ([theEvent_I type] == NSEventTypeLeftMouseDown)
	{
		BOOL keepOn = YES;
		[NSEvent setMouseCoalescingEnabled:NO];

		NSMutableArray *eventQueue = [NSMutableArray array];
		[eventQueue addObject:[theEvent_I copy]];
		while (keepOn)
		{
			theEvent_I = [[self window] nextEventMatchingMask:NSEventMaskLeftMouseUp |
							  NSEventMaskLeftMouseDragged];

			switch ([theEvent_I type])
			{
				case NSEventTypeLeftMouseDragged:
				{
					// Add the event to the queue
					[eventQueue addObject:[theEvent_I copy]];
					if (eventQueue.count >= 10)
					{
						// We want to give the user some feedback, so every ten events
						// we'll update the screen
						if(mUpdateStatsDuringDrag)
						{
							[self handleMouseEvent:theEvent_I];
						}
						[self drawDataFromQueue:eventQueue];
					}
					break;
				}

				case NSEventTypeLeftMouseUp:
				{
					if (eventQueue.count != 0)
					{
						// All done, make sure we update the screen with anything left in the queue
						[self drawDataFromQueue:eventQueue];
					}
					if(mUpdateStatsDuringDrag)
					{
						[self handleMouseEvent:theEvent_I];
					}

					[NSEvent setMouseCoalescingEnabled:YES];

					keepOn = NO;

					break;
				}

				default:
				{
					/* Ignore any other kind of event. */
					break;
				}
			}
		}
	}
}

// /////////////////////////////////////////////////////////////////////////////

- (void)mouseMoved:(NSEvent *)theEvent_I
{
	if ([theEvent_I isTabletPointerEvent])
	{
		if ([theEvent_I deviceID] != [[knownDevices currentDevice] ident])
		{
			// The deviceID the event came from does not match the deviceID of
			// the device that was thought to be on the Tablet. Must have
			// missed a Proximity Notification. Get the Tablet to resend it.
			
			[WacomTabletDriver resendLastTabletEventOfType:eEventProximity];
			return;
		}
	}
   
   [self handleMouseEvent:theEvent_I];
}

// /////////////////////////////////////////////////////////////////////////////

- (void)mouseUp:(NSEvent *)theEvent_I
{
    [NSEvent setMouseCoalescingEnabled:YES];

    [self handleMouseEvent:theEvent_I];
}

// /////////////////////////////////////////////////////////////////////////////

// All of the Mouse Events are funneled through this function so that we
// do not have to duplicate this code. If you do something like this,
// you must be careful because certain fields are only valid for particular
// events. For example, [NSEvent pressure] is not valid for Mouse Moves!

- (void)handleMouseEvent:(NSEvent *)theEvent_I
{
   mEventType = (int)[theEvent_I type];

   NSPoint loc = [theEvent_I locationInWindow];
   mMouseX = loc.x;
   mMouseY = loc.y;

   mSubX	= 0.0; //loc.x;
   mSubY	= 0.0; //loc.y;

   // Pressure is not valid for MouseMove events
	if (mEventType != NSEventTypeMouseMoved)
   {
      mPressure = [theEvent_I pressure];
   }
   else
   {
      mPressure = 0.0;
   }

   mTabletRawPressure = [theEvent_I rawTabletPressure];
   mTabletScaledPressure = [theEvent_I pressure];

	mAbsX = (SInt32)[theEvent_I absoluteX];
	mAbsY = (SInt32)[theEvent_I absoluteY];

   NSPoint tilt = [theEvent_I tilt];
   mTiltX = tilt.x;
   mTiltY = tilt.y;

   mRotDeg = [theEvent_I rotation];
   mRotRad = [theEvent_I rotationInRadians];

   mDeviceID = [theEvent_I deviceID];

   // Notify objects that care that this object's stats have been updated
	[[NSNotificationCenter defaultCenter] postNotificationName:WTViewUpdatedNotification object: self];
}

// /////////////////////////////////////////////////////////////////////////////

// The proximity notification is based on the Proximity Event.
// The proximity notification will give you detailed
// information about the device that was either just placed on, or just
// taken off of the tablet.
// 
// In this sample code, the Proximity notification is used to determine if
// the pen TIP or ERASER is being used. This information is not provided in
// the embedded tablet event.
//
// Also, on the Intous line of tablets, each trasducer has a unique ID,
// even when different transducers are of the same type. We get that
// information here so we can keep track of the Color assigned to each
// transducer.

- (void) handleProximity:(NSNotification *)proxNotice_I
{
   NSDictionary *proxDict = [proxNotice_I userInfo];
   UInt8	enterProximity;
   UInt8 pointerType;
   UInt16 deviceID;
   UInt16 pointerID;

   [[proxDict objectForKey:kEnterProximity] getValue:&enterProximity];
   [[proxDict objectForKey:kPointerID] getValue:&pointerID];

	// Only interested in Enter Proximity for 1st concurrent device
   if(enterProximity != 0 && pointerID == 0)
   {
      [[proxDict objectForKey:kPointerType] getValue:&pointerType];
      mErasing = (pointerType == eEraser);
   
      [[proxDict objectForKey:kDeviceID] getValue:&deviceID];

      if ([knownDevices setCurrentDeviceByID: deviceID] == NO)
      {
         //must be a new device
         Transducer *newDevice = [[Transducer alloc]
                                    initWithIdent: deviceID
                                    color: [NSColor blackColor]];
         
         [knownDevices addDevice:newDevice];
         newDevice = nil;
         [knownDevices setCurrentDeviceByID: deviceID];
      }
      
      [[NSNotificationCenter defaultCenter]
            postNotificationName:WTViewUpdatedNotification
            object: self];
   }
}

// /////////////////////////////////////////////////////////////////////////////

// This is where the pretty colors are drawn to the screen!
// A 'Real' app would probably keep track of this information so that the
// - (void) drawRect; function can properly re-draw it.

- (void) drawDataFromQueue:(NSMutableArray*)eventQueue_IO
{
    Transducer *currentDevice = [knownDevices currentDevice];
    CGFloat    bounds[4];
    
    bounds[NSRectEdgeMinX] = mLastLoc.x;
    bounds[NSRectEdgeMinY] = mLastLoc.y;
    bounds[NSRectEdgeMaxX] = mLastLoc.x;
    bounds[NSRectEdgeMaxY] = mLastLoc.y;

    [self.image lockFocus];
    {
		NSBezierPath *path = [NSBezierPath bezierPath];
		[path setLineCapStyle:NSRoundLineCapStyle];
		[path setLineJoinStyle:NSLineJoinStyleRound];
		[path moveToPoint:mLastLoc];

        while (eventQueue_IO.count > 0)
        {
            NSEvent    *theEvent = eventQueue_IO.firstObject;
            NSPoint    currentLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
            double pressure = round([theEvent pressure] * 1000.0) / 1000.0;
            
            double opacity = mAdjustOpacity ? pressure : 1.0;
            double brushSize = mAdjustSize ? (pressure * maxBrushSize) : (0.5 * maxBrushSize);

            if (mErasing)
            {
                [[[NSColor whiteColor] colorWithAlphaComponent:opacity] set];
            }
            else
            {
                if (currentDevice != NULL)
                {
                    [[[currentDevice color] colorWithAlphaComponent:opacity] set];
                }
                else
                {
                    [[[NSColor blackColor] colorWithAlphaComponent:opacity] set];
                }
            }

            [path setLineWidth:brushSize];
            [path lineToPoint:currentLoc];
            
            bounds[NSRectEdgeMinX] = MIN(bounds[NSRectEdgeMinX], currentLoc.x);
            bounds[NSRectEdgeMinY] = MIN(bounds[NSRectEdgeMinY], currentLoc.y);
            bounds[NSRectEdgeMaxX] = MAX(bounds[NSRectEdgeMaxX], currentLoc.x);
            bounds[NSRectEdgeMaxY] = MAX(bounds[NSRectEdgeMaxY], currentLoc.y);

            mLastLoc = currentLoc;
            [eventQueue_IO removeObjectAtIndex:0];
        }
        [path stroke];
    }
    [self.image unlockFocus];

    NSRect rectDraw = NSMakeRect(bounds[NSRectEdgeMinX] - (maxBrushSize / 2.0), bounds[NSRectEdgeMinY] - (maxBrushSize / 2.0),
                                          bounds[NSRectEdgeMaxX] - bounds[NSRectEdgeMinX] + maxBrushSize, bounds[NSRectEdgeMaxY] - bounds[NSRectEdgeMinY] + maxBrushSize);
    [self setNeedsDisplayInRect:rectDraw];
}

// /////////////////////////////////////////////////////////////////////////////

// A 'Real' app would probably keep track of the drawing information done
// during Mouse Drags so that it can properly be re-drawn here. I just
// clear the drawing region. (Resize the window and all the drawing is
// erased!)

- (void)drawRect:(NSRect)rect_I
{
	NSSize sizeView = [self bounds].size;
	if (!self.image || (self.image.size.width != sizeView.width || self.image.size.height != sizeView.height))
	{
		self.image = [[NSImage alloc] initWithSize:sizeView];
		[self.image lockFocus];
		{
			[[NSColor whiteColor] set];
			NSRectFill([self bounds]);
		}
		[self.image unlockFocus];
	}

	[super drawRect:rect_I];
}

// /////////////////////////////////////////////////////////////////////////////

- (BOOL)isOpaque
{
    // Makes sure that this view is not Transparant!
    return YES;
}

// /////////////////////////////////////////////////////////////////////////////

- (BOOL)acceptsFirstResponder
{
    // The view only gets MouseMoved events when the view is the First
    // Responder in the Responder event chain
    return YES;
}

// /////////////////////////////////////////////////////////////////////////////

- (BOOL)becomeFirstResponder
{
	// If do not use the notification method to send proximity events to
	// all objects then you will need to ask the Tablet Driver to resend
	// the last proximity event every time your view becomes the first
	// responder. You can do that here by uncommenting the following line.
	
   // ResendLastTabletEventofType(eEventProximity);
   return YES;
}

// /////////////////////////////////////////////////////////////////////////////

- (int) mEventType
{
    return mEventType;
}

// /////////////////////////////////////////////////////////////////////////////

- (UInt16) mDeviceID
{
    return mDeviceID;
}

// /////////////////////////////////////////////////////////////////////////////

- (float) mMouseX
{
    return mMouseX;
}

// /////////////////////////////////////////////////////////////////////////////

- (float) mMouseY
{
    return mMouseY;
}

// /////////////////////////////////////////////////////////////////////////////

- (float) mSubX
{
    return mSubX;
}

// /////////////////////////////////////////////////////////////////////////////

- (float) mSubY
{
    return mSubY;
}

// /////////////////////////////////////////////////////////////////////////////

- (float) mPressure
{
    return mPressure;
}

// /////////////////////////////////////////////////////////////////////////////

- (float) mTabletRawPressure
{
    return mTabletRawPressure;
}

// /////////////////////////////////////////////////////////////////////////////

- (float) mTabletScaledPressure
{
    return mTabletScaledPressure;
}

// /////////////////////////////////////////////////////////////////////////////

- (SInt32) mAbsX
{
    return mAbsX;
}

// /////////////////////////////////////////////////////////////////////////////

- (SInt32) mAbsY
{
    return mAbsY;
}

// /////////////////////////////////////////////////////////////////////////////

- (float) mTiltX
{
    return mTiltX;
}

// /////////////////////////////////////////////////////////////////////////////

- (float) mTiltY
{
    return mTiltY;
}

// /////////////////////////////////////////////////////////////////////////////

- (float) mRotDeg
{
    return mRotDeg;
}

// /////////////////////////////////////////////////////////////////////////////

- (float) mRotRad
{
    return mRotRad;
}

// /////////////////////////////////////////////////////////////////////////////

- (NSColor *) mForeColor
{
   Transducer *currentDevice = [knownDevices currentDevice];
   
   if (currentDevice != NULL)
   {
      return [currentDevice color];
   }
   
   return [NSColor blackColor];
}

// /////////////////////////////////////////////////////////////////////////////

- (void) setForeColor:(NSColor *)newColor_I
{
   Transducer *currentDevice = [knownDevices currentDevice];
	
   if (currentDevice != NULL)
   {
      [currentDevice setColor:newColor_I];
   }
}

// /////////////////////////////////////////////////////////////////////////////

- (BOOL) mAdjustOpacity
{
   return mAdjustOpacity;
}

// /////////////////////////////////////////////////////////////////////////////

- (void) setAdjustOpacity:(BOOL)adjust_I
{
   mAdjustOpacity = adjust_I;
}

// /////////////////////////////////////////////////////////////////////////////

- (BOOL) mAdjustSize
{
   return mAdjustSize;
}

// /////////////////////////////////////////////////////////////////////////////

- (void) setAdjustSize:(BOOL)adjust_I
{
   mAdjustSize = adjust_I;
}

// /////////////////////////////////////////////////////////////////////////////

- (BOOL) mCaptureMouseMoves
{
   return mCaptureMouseMoves;
}

// /////////////////////////////////////////////////////////////////////////////

- (void) setCaptureMouseMoves:(BOOL)value_I
{
   mCaptureMouseMoves = value_I;
   [[self window] setAcceptsMouseMovedEvents:mCaptureMouseMoves];
}

// /////////////////////////////////////////////////////////////////////////////

- (BOOL) mUpdateStatsDuringDrag
{
   return mUpdateStatsDuringDrag;
}

// /////////////////////////////////////////////////////////////////////////////

- (void) setUpdateStatsDuringDrag:(BOOL)value_I
{
   mUpdateStatsDuringDrag = value_I;
}

@end
