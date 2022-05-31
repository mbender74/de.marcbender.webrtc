/*
 *  Copyright 2015 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "ARDVideoCallViewController.h"


//ARDAppClientDelegate
@interface ARDVideoCallViewController () <ARDVideoCallViewDelegate,
                                          RTC_OBJC_TYPE (RTCAudioSessionDelegate)>
@property(nonatomic, strong) RTC_OBJC_TYPE(RTCVideoTrack) * remoteVideoTrack;

@property(nonatomic, readwrite) ARDVideoCallView *videoCallView;
@property(nonatomic, assign) AVAudioSessionPortOverride portOverride;
@end

@implementation ARDVideoCallViewController {
  //ARDAppClient *_client;
  RTC_OBJC_TYPE(RTCVideoTrack) * _remoteVideoTrack;
  ARDCaptureController *_captureController;
  ARDFileCaptureController *_fileCaptureController NS_AVAILABLE_IOS(10);
  RTCVideoTrack * _localVideoTrack;
  RTCMediaStream * _localStream;
}

@synthesize videoCallView = _videoCallView;
@synthesize remoteVideoTrack = _remoteVideoTrack;
@synthesize localVideoTrack = _localVideoTrack;
@synthesize localStream = _localStream;

@synthesize delegate = _delegate;
@synthesize portOverride = _portOverride;

- (instancetype)initForRoom:(NSString *)room
                 isLoopback:(BOOL)isLoopback
                   delegate:(id<ARDVideoCallViewControllerDelegate>)delegate {
  if (self = [super init]) {
    ARDSettingsModel *settingsModel = [[ARDSettingsModel alloc] init];
    _delegate = delegate;

    //_client = [[ARDAppClient alloc] initWithDelegate:self];
    //[_client connectToRoomWithId:room settings:settingsModel isLoopback:isLoopback];
  }
  return self;
}

- (ARDVideoCallView *)localVideoView {
    return _videoCallView;
}

- (RTCVideoTrack *)remoteVideoTrack {
    return _remoteVideoTrack;
}






- (void)loadView {
  _videoCallView = [[ARDVideoCallView alloc] initWithFrame:CGRectZero];
  _videoCallView.delegate = self;
  _videoCallView.statusLabel.text =
      [self statusTextForState:RTCIceConnectionStateNew];
  self.view = _videoCallView;
  _videoCallView.remoteVideoView.contentMode = UIViewContentModeScaleAspectFill;

  RTC_OBJC_TYPE(RTCAudioSession) *session = [RTC_OBJC_TYPE(RTCAudioSession) sharedInstance];
  [session addDelegate:self];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskAll;
}


- (void)viewDidLoad {
    [super viewDidLoad];
     NSLog(@"##########################################  viewDidLoad controller");

}



//#pragma mark - ARDAppClientDelegate
//
//- (void)appClient:(ARDAppClient *)client
//    didChangeState:(ARDAppClientState)state {
//  switch (state) {
//    case kARDAppClientStateConnected:
//      RTCLog(@"Client connected.");
//      break;
//    case kARDAppClientStateConnecting:
//      RTCLog(@"Client connecting.");
//      break;
//    case kARDAppClientStateDisconnected:
//      RTCLog(@"Client disconnected.");
//      [self hangup];
//      break;
//  }
//}
//
//- (void)appClient:(ARDAppClient *)client
//    didChangeConnectionState:(RTCIceConnectionState)state {
//  RTCLog(@"ICE state changed: %ld", (long)state);
//  __weak ARDVideoCallViewController *weakSelf = self;
//  dispatch_async(dispatch_get_main_queue(), ^{
//    ARDVideoCallViewController *strongSelf = weakSelf;
//    strongSelf.videoCallView.statusLabel.text =
//        [strongSelf statusTextForState:state];
//  });
//}
//
//- (void)appClient:(ARDAppClient *)client
//    didCreateLocalCapturer:(RTC_OBJC_TYPE(RTCCameraVideoCapturer) *)localCapturer {
//  _videoCallView.localVideoView.captureSession = localCapturer.captureSession;
//  ARDSettingsModel *settingsModel = [[ARDSettingsModel alloc] init];
//  _captureController =
//      [[ARDCaptureController alloc] initWithCapturer:localCapturer settings:settingsModel];
//  [_captureController startCapture];
//}
//
//- (void)appClient:(ARDAppClient *)client
//    didCreateLocalFileCapturer:(RTC_OBJC_TYPE(RTCFileVideoCapturer) *)fileCapturer {
//#if defined(__IPHONE_11_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0)
//  if (@available(iOS 10, *)) {
//    _fileCaptureController = [[ARDFileCaptureController alloc] initWithCapturer:fileCapturer];
//    [_fileCaptureController startCapture];
//  }
//#endif
//}
//
//- (void)appClient:(ARDAppClient *)client
//    didReceiveLocalVideoTrack:(RTC_OBJC_TYPE(RTCVideoTrack) *)localVideoTrack {
//}
//
//- (void)appClient:(ARDAppClient *)client
//    didReceiveRemoteVideoTrack:(RTC_OBJC_TYPE(RTCVideoTrack) *)remoteVideoTrack {
//  self.remoteVideoTrack = remoteVideoTrack;
//  __weak ARDVideoCallViewController *weakSelf = self;
//  dispatch_async(dispatch_get_main_queue(), ^{
//    ARDVideoCallViewController *strongSelf = weakSelf;
//    strongSelf.videoCallView.statusLabel.hidden = YES;
//  });
//}
//
//- (void)appClient:(ARDAppClient *)client
//      didGetStats:(NSArray *)stats {
//  _videoCallView.statsView.stats = stats;
//  [_videoCallView setNeedsLayout];
//}
//
//- (void)appClient:(ARDAppClient *)client
//         didError:(NSError *)error {
//  NSString *message =
//      [NSString stringWithFormat:@"%@", error.localizedDescription];
//  [self hangup];
//  [self showAlertWithMessage:message];
//}

#pragma mark - ARDVideoCallViewDelegate

- (void)videoCallViewDidHangup:(ARDVideoCallView *)view {
  [self hangup];
}

- (void)videoCallViewDidSwitchCamera:(ARDVideoCallView *)view {
  // TODO(tkchin): Rate limit this so you can't tap continously on it.
  // Probably through an animation.
    [self videoCallViewSwitchCamera];
}



- (void)videoCallViewDidChangeRoute:(ARDVideoCallView *)view {
  AVAudioSessionPortOverride override = AVAudioSessionPortOverrideNone;
  if (_portOverride == AVAudioSessionPortOverrideNone) {
    override = AVAudioSessionPortOverrideSpeaker;
  }
  [RTC_OBJC_TYPE(RTCDispatcher) dispatchAsyncOnType:RTCDispatcherTypeAudioSession
                                              block:^{
                                                RTC_OBJC_TYPE(RTCAudioSession) *session =
                                                    [RTC_OBJC_TYPE(RTCAudioSession) sharedInstance];
                                                [session lockForConfiguration];
                                                NSError *error = nil;
                                                if ([session overrideOutputAudioPort:override
                                                                               error:&error]) {
                                                  self.portOverride = override;
                                                } else {
                                                  RTCLogError(@"Error overriding output port: %@",
                                                              error.localizedDescription);
                                                }
                                                [session unlockForConfiguration];
                                              }];
}

- (void)videoCallViewDidEnableStats:(ARDVideoCallView *)view {
 // _client.shouldGetStats = YES;
  _videoCallView.statsView.hidden = YES;
}

#pragma mark - RTC_OBJC_TYPE(RTCAudioSessionDelegate)

- (void)audioSession:(RTC_OBJC_TYPE(RTCAudioSession) *)audioSession
    didDetectPlayoutGlitch:(int64_t)totalNumberOfGlitches {
  RTCLog(@"Audio session detected glitch, total: %lld", totalNumberOfGlitches);
}


//- (void)setRemoteVideoTrack:(RTC_OBJC_TYPE(RTCVideoTrack) *)remoteVideoTrack {
//    
//    // NSLog(@"");
//    // NSLog(@"##################################### ");
//
//    // NSLog(@"setRemoteVideoTrack ");
//
//    
//  if (_remoteVideoTrack == remoteVideoTrack) {
//    return;
//  }
//  [_remoteVideoTrack removeRenderer:_videoCallView.remoteVideoView];
//  _remoteVideoTrack = nil;
//  [_videoCallView.remoteVideoView renderFrame:nil];
//  _remoteVideoTrack = remoteVideoTrack;
//  [_remoteVideoTrack addRenderer:_videoCallView.remoteVideoView];
//    // NSLog(@"##################################### ");
//
//    // NSLog(@"");
//
//}

- (void)hangup {
    
    
    
    
    
    [_delegate viewControllerDidFinish:self];

    [_remoteVideoTrack removeRenderer:_videoCallView.remoteVideoView];
    _remoteVideoTrack = nil;
    [_videoCallView.remoteVideoView renderFrame:nil];

    [_captureController stopCapture];


//    [_localStream removeVideoTrack:_localVideoTrack];
  _videoCallView.localVideoView.captureSession = nil;
  _captureController = nil;
  [_fileCaptureController stopCapture];
  _fileCaptureController = nil;
    
 // [_client disconnect];
}



- (void)videoCallViewSwitchCamera {
  // TODO(tkchin): Rate limit this so you can't tap continously on it.
  // Probably through an animation.
    [_delegate videoCallViewSwitchCamera:self];

  //[_captureController switchCamera];
}



- (NSString *)statusTextForState:(RTCIceConnectionState)state {
  switch (state) {
    case RTCIceConnectionStateNew:
    case RTCIceConnectionStateChecking:
      return @"Connecting...";
    case RTCIceConnectionStateConnected:
    case RTCIceConnectionStateCompleted:
    case RTCIceConnectionStateFailed:
    case RTCIceConnectionStateDisconnected:
    case RTCIceConnectionStateClosed:
    case RTCIceConnectionStateCount:
      return nil;
  }
}

- (void)showAlertWithMessage:(NSString*)message {
  UIAlertController *alert =
      [UIAlertController alertControllerWithTitle:nil
                                          message:message
                                   preferredStyle:UIAlertControllerStyleAlert];

  UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action){
                                                        }];

  [alert addAction:defaultAction];
  [self presentViewController:alert animated:YES completion:nil];
}

@end
