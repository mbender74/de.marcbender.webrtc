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
#import <WebRTC/RTCVideoTrack.h>
#import <WebRTC/RTCMediaStream.h>
#import <WebRTC/RTCPeerConnection.h>
#import <MetalKit/MetalKit.h>

#import <WebRTC/RTCAudioSession.h>
#import <WebRTC/RTCCameraVideoCapturer.h>
#import <WebRTC/RTCDispatcher.h>
#import <WebRTC/RTCLogging.h>
#import <WebRTC/RTCMediaConstraints.h>
#import <WebRTC/RTCMediaStream.h>

//#import "ARDAppClient.h"
#import "ARDCaptureController.h"
#import "ARDFileCaptureController.h"
#import "ARDSettingsModel.h"
#import "ARDVideoCallView.h"


@class ARDVideoCallViewController;
@protocol ARDVideoCallViewControllerDelegate <NSObject>

- (void)viewControllerDidFinish:(ARDVideoCallViewController *)viewController;
- (void)videoCallViewSwitchCamera:(ARDVideoCallViewController *)viewController;

@end

@interface ARDVideoCallViewController : UIViewController

@property(nonatomic, weak) id<ARDVideoCallViewControllerDelegate> delegate;
@property(nonatomic, strong) RTC_OBJC_TYPE(RTCVideoTrack) * localVideoTrack;
@property(nonatomic, strong) RTC_OBJC_TYPE(RTCMediaStream) * localStream;
@property(nonatomic, strong) RTCMediaStream *remoteAudioStream;







- (instancetype)initForRoom:(NSString *)room
                 isLoopback:(BOOL)isLoopback
                   delegate:(id<ARDVideoCallViewControllerDelegate>)delegate;
- (ARDVideoCallView *)localVideoView;
- (RTCVideoTrack *)remoteVideoTrack;
- (void)setRemoteAudioEnabled:(BOOL)enabled;
- (void)hangup;
- (void)setRemoteVideoTrack:(RTC_OBJC_TYPE(RTCVideoTrack) *)remoteVideoTrack;
@end
