/*
 *  Copyright 2015 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <UIKit/UIKit.h>
#import <TitaniumKit/TiViewProxy.h>
#import <TitaniumKit/TiProxy.h>
#import <TitaniumKit/TiUIView.h>
#import <MetalKit/MetalKit.h>

#import <WebRTC/RTCCameraPreviewView.h>
#import <WebRTC/RTCVideoRenderer.h>
#import <WebRTC/RTCMTLVideoView.h>

#import "ARDStatsView.h"

@class ARDVideoCallView;
@protocol ARDVideoCallViewDelegate <NSObject>

// Called when the camera switch button is pressed.
- (void)videoCallViewDidSwitchCamera:(ARDVideoCallView *)view;

// Called when the route change button is pressed.
- (void)videoCallViewDidChangeRoute:(ARDVideoCallView *)view;

// Called when the hangup button is pressed.
- (void)videoCallViewDidHangup:(ARDVideoCallView *)view;

// Called when stats are enabled by triple tapping.
- (void)videoCallViewDidEnableStats:(ARDVideoCallView *)view;

@end


typedef NS_ENUM(NSInteger, RCVideoFillMode) {
    RCVideoFillModeAspect ,
    RCVideoFillModeAspectFill
};

// Video call view that shows local and remote video, provides a label to
// display status, and also a hangup button.
@interface ARDVideoCallView : UIView

@property(nonatomic, readwrite) TiViewProxy *buttonsViewContainer;
@property(nonatomic,assign) RCVideoFillMode filleMode;

@property(nonatomic, readonly) UILabel *statusLabel;
@property(nonatomic, readonly) RTC_OBJC_TYPE(RTCCameraPreviewView) * localVideoView;
@property(nonatomic, readonly) __kindof UIView<RTC_OBJC_TYPE(RTCVideoRenderer)> *remoteVideoView;
@property(nonatomic, readonly) ARDStatsView *statsView;
@property(nonatomic, weak) id<ARDVideoCallViewDelegate> delegate;

@end
