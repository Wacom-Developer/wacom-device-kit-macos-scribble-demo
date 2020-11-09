///////////////////////////////////////////////////////////////////////////////
//
// DESCRIPTION
// 	Header file for PressureWinController class.
//
// COPYRIGHT
//    Copyright (c) 2001 - 2020 Wacom Co., Ltd.
//    All rights reserved
//
///////////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>

@interface PressureWinController : NSObject
{
    IBOutlet id txtEventType;
    IBOutlet id txtDeviceID;
    
    IBOutlet id txtMouseX;
    IBOutlet id txtMouseY;
    
    IBOutlet id txtAbsoulteX;
    IBOutlet id txtAbsoulteY;
    
    IBOutlet id txtTiltX;
    IBOutlet id txtTiltY;
    
    IBOutlet id txtPressure;
    IBOutlet id txtRawTabletPressure;
    IBOutlet id txtScaledTabletPressure;
    
    IBOutlet id txtRotationDegrees;
    IBOutlet id txtRotationRadians;
    
    IBOutlet id clrForeColor;
    
    IBOutlet id wtvTabletDraw;
    
    IBOutlet id mnuLineSize;
    IBOutlet id mnuOpacity;
    
    IBOutlet id mnuCaptureMouseMoves;
    IBOutlet id mnuUpdateStatsDuringDrag;
}

- (IBAction) opacityMenuAction:(id)sender_I;
- (IBAction) lineSizeMenuAction:(id)sender_I;
- (IBAction) captureMouseMovesAction:(id)sender_I;
- (IBAction) updateStatsDuringDragAction:(id)sender_I;
- (IBAction) openColorPanel:(id)sender_I;
- (IBAction) changeColor:(id)sender_I;
- (void) wtvUpdatedStats:(NSNotification *)theNotification_I;

@end
