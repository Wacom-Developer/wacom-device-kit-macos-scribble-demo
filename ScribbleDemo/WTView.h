// /////////////////////////////////////////////////////////////////////////////
//
// DESCRIPTION
//     Header file for WTView class.
//
// COPYRIGHT
//    Copyright (c) 2001 - 2020 Wacom Co., Ltd.
//    All rights reserved
//
// /////////////////////////////////////////////////////////////////////////////

#import <AppKit/AppKit.h>
#import "DeviceTracker.h"

@interface WTView : NSImageView
{
      int       mEventType;
      UInt16    mDeviceID;
      float     mMouseX;
      float     mMouseY;
      float     mSubX;
      float     mSubY;
      float     mPressure;
      float     mTabletRawPressure;
      float     mTabletScaledPressure;
      SInt32    mAbsX;
      SInt32    mAbsY;
      float     mTiltX;
      float     mTiltY;
      float     mRotDeg;
      float     mRotRad;

      DeviceTracker* knownDevices;
      BOOL      mAdjustOpacity;
      BOOL      mAdjustSize;
      BOOL      mCaptureMouseMoves;
      BOOL      mUpdateStatsDuringDrag;
    
    @private
      BOOL       mErasing;
      NSPoint    mLastLoc;
      NSPoint    mSecondLoc;
}

- (int) mEventType;
- (UInt16) mDeviceID;
- (float) mMouseX;
- (float) mMouseY;
- (float) mSubX;
- (float) mSubY;
- (float) mPressure;
- (float) mTabletRawPressure;
- (float) mTabletScaledPressure;
- (SInt32) mAbsX;
- (SInt32) mAbsY;
- (float) mTiltX;
- (float) mTiltY;
- (float) mRotDeg;
- (float) mRotRad;
    
- (NSColor *) mForeColor;
- (void) setForeColor:(NSColor *)newColor_I;

- (BOOL) mAdjustOpacity;
- (void) setAdjustOpacity:(BOOL)adjust_I;
- (BOOL) mAdjustSize;
- (void) setAdjustSize:(BOOL)adjust_I;

- (BOOL) mCaptureMouseMoves;
- (void) setCaptureMouseMoves:(BOOL)value_I;
- (BOOL) mUpdateStatsDuringDrag;
- (void) setUpdateStatsDuringDrag:(BOOL)value_I;

- (void) handleMouseEvent:(NSEvent *)theEvent_I;
- (void) handleProximity:(NSNotification *)proxNotice_I;
- (void) drawDataFromQueue:(NSMutableArray*)eventQueue_IO;

@end

extern NSString *WTViewUpdatedNotification;
