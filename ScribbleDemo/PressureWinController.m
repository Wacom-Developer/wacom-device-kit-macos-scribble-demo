///////////////////////////////////////////////////////////////////////////////
//
// DESCRIPTION
// 	Implementation file for PressureWinController class.
//
// COPYRIGHT
//    Copyright (c) 2001 - 2020 Wacom Co., Ltd.
//    All rights reserved
//
///////////////////////////////////////////////////////////////////////////////

#import "PressureWinController.h"
#import "WTView.h"

@implementation PressureWinController

- (id) init
{
    self = [super init];
    if (self)
    {
        // Initialization code here.
        
        // Must want to know when WTCView's data has been updated
        [[NSNotificationCenter defaultCenter] addObserver:self
               selector:@selector(wtvUpdatedStats:)
               name:WTViewUpdatedNotification
               object:wtvTabletDraw];
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////

- (void) awakeFromNib
{
   [wtvTabletDraw setForeColor:[clrForeColor color]];
   
   // Set check marks of Pressure Menu Items
   if ([wtvTabletDraw mAdjustOpacity])
   {
      [mnuOpacity setState:NSOnState];
   }
   else
   {
      [mnuOpacity setState:NSOffState];
   }
   
   if ([wtvTabletDraw mAdjustSize])
   {
      [mnuOpacity setState:NSOnState];
   }
   else
   {
      [mnuLineSize setState:NSOffState];
   }
   
   // Set check marks for Events menu
   if ([wtvTabletDraw mCaptureMouseMoves])
   {
      [mnuCaptureMouseMoves setState:NSOnState];
   }
   else
   {
      [mnuCaptureMouseMoves setState:NSOffState];
   }
   
   if ([wtvTabletDraw mUpdateStatsDuringDrag])
   {
      [mnuUpdateStatsDuringDrag setState:NSOnState];
   }
   else
   {
      [mnuUpdateStatsDuringDrag setState:NSOffState];
   }
}

///////////////////////////////////////////////////////////////////////////////

- (IBAction) opacityMenuAction:(id)sender_I
{
   if([sender_I state] == NSOnState)
   {
      [sender_I setState:NSOffState];
      [wtvTabletDraw setAdjustOpacity:NO];
   }
   else
   {
      [sender_I setState:NSOnState];
      [wtvTabletDraw setAdjustOpacity:YES];
   }
}

///////////////////////////////////////////////////////////////////////////////

- (IBAction) lineSizeMenuAction:(id)sender_I
{
   if([sender_I state] == NSOnState)
   {
      [sender_I setState:NSOffState];
      [wtvTabletDraw setAdjustSize:NO];
   }
   else
   {
      [sender_I setState:NSOnState];
      [wtvTabletDraw setAdjustSize:YES];
   }
}

///////////////////////////////////////////////////////////////////////////////

- (IBAction) captureMouseMovesAction:(id)sender_I
{
   if([sender_I state] == NSOnState)
   {
      [sender_I setState:NSOffState];
      [wtvTabletDraw setCaptureMouseMoves:NO];
   }
   else
   {
      [sender_I setState:NSOnState];
      [wtvTabletDraw setCaptureMouseMoves:YES];
   }
}

///////////////////////////////////////////////////////////////////////////////

- (IBAction) updateStatsDuringDragAction:(id)sender_I
{
   if([sender_I state] == NSOnState)
   {
      [sender_I setState:NSOffState];
      [wtvTabletDraw setUpdateStatsDuringDrag:NO];
   }
   else
   {
      [sender_I setState:NSOnState];
      [wtvTabletDraw setUpdateStatsDuringDrag:YES];
   }
}

///////////////////////////////////////////////////////////////////////////////

- (IBAction) openColorPanel:(id)sender_I
{
   [sender_I activate:NO];
}

///////////////////////////////////////////////////////////////////////////////

- (IBAction) changeColor:(id)sender
{
   [wtvTabletDraw setForeColor: [sender color]];
}

///////////////////////////////////////////////////////////////////////////////

-(void) wtvUpdatedStats:(NSNotification *)theNotification_I
{
#pragma unused(theNotification_I)

   switch([wtvTabletDraw mEventType])
   {
		case NSEventTypeLeftMouseDown:
		case NSEventTypeRightMouseDown:
         [txtEventType setStringValue:@"Mouse Down"];
      break;
      
		case NSEventTypeLeftMouseUp:
		case NSEventTypeRightMouseUp:
         [txtEventType setStringValue:@"Mouse Up"];
      break;
      
		case NSEventTypeLeftMouseDragged:
		case NSEventTypeRightMouseDragged:
         [txtEventType setStringValue:@"Mouse Drag"];
      break;
      
		case NSEventTypeMouseMoved:
         [txtEventType setStringValue:@"Mouse Move"];
      break;
   }
   
   [txtDeviceID setIntValue:[wtvTabletDraw mDeviceID]];
   [txtMouseX setFloatValue:[wtvTabletDraw mMouseX]];
   [txtMouseY setFloatValue:[wtvTabletDraw mMouseY]];
   [txtPressure setFloatValue:[wtvTabletDraw mPressure]];
   [txtRawTabletPressure setFloatValue:[wtvTabletDraw mTabletRawPressure]];
   [txtScaledTabletPressure setFloatValue:[wtvTabletDraw mTabletScaledPressure]];
   [txtAbsoulteX setIntValue:[wtvTabletDraw mAbsX]];
   [txtAbsoulteY setIntValue:[wtvTabletDraw mAbsY]];
   [txtTiltX setFloatValue:[wtvTabletDraw mTiltX]];
   [txtTiltY setFloatValue:[wtvTabletDraw mTiltY]];
   [txtRotationDegrees setFloatValue:[wtvTabletDraw mRotDeg]];
   [txtRotationRadians setFloatValue:[wtvTabletDraw mRotRad]];
   
   [clrForeColor setColor:[wtvTabletDraw mForeColor]];
}
@end
