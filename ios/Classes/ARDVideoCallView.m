/*
 *  Copyright 2015 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "ARDVideoCallView.h"

#import <AVFoundation/AVFoundation.h>

#import "UIImage+ARDUtilities.h"

static CGFloat const kButtonPadding = 24;
static CGFloat const kButtonSize = 64;
static CGFloat const kLocalVideoViewSize = 120;
static CGFloat const kLocalVideoViewPadding = 8;
static CGFloat const kStatusBarHeight = 20;

@interface ARDVideoCallView () <RTC_OBJC_TYPE (RTCVideoViewDelegate)>
@end

@implementation ARDVideoCallView {
  UIButton *_routeChangeButton;
  UIButton *_cameraSwitchButton;
  UIButton *_hangupButton;
  CGSize _remoteVideoSize;
  UIView *_buttonContainer;
}

@synthesize buttonsViewContainer = _buttonsViewContainer;
@synthesize statusLabel = _statusLabel;
@synthesize localVideoView = _localVideoView;
@synthesize remoteVideoView = _remoteVideoView;
@synthesize statsView = _statsView;
@synthesize delegate = _delegate;

- (instancetype)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {

      
      RTC_OBJC_TYPE(RTCMTLVideoView) *remoteView = [[RTC_OBJC_TYPE(RTCMTLVideoView) alloc] initWithFrame:CGRectZero];
      
      remoteView.delegate = self;
      _remoteVideoView = remoteView;
      

      _buttonContainer = [[UIView alloc] init];
      CGRect buttonContainerFrame = CGRectMake( 0, 0, (kButtonSize*3) + (kButtonPadding*2), kButtonSize+kButtonPadding);

      
     buttonContainerFrame.origin.y = CGRectGetMaxY(self.bounds);
      _buttonContainer.frame = buttonContainerFrame;
      

    [self addSubview:_remoteVideoView];

      
     // _remoteVideoView.backgroundColor = UIColor.greenColor;
      
      CGRect localframe = CGRectZero;
      localframe.origin.x = CGRectGetMaxX(self.bounds);
      localframe.origin.y = CGRectGetMaxY(self.bounds);

      
    _localVideoView = [[RTC_OBJC_TYPE(RTCCameraPreviewView) alloc] initWithFrame:localframe];
      //_localVideoView.backgroundColor = UIColor.redColor;
    [self addSubview:_localVideoView];

    _statsView = [[ARDStatsView alloc] initWithFrame:CGRectZero];
    _statsView.hidden = YES;
    [self addSubview:_statsView];

    _routeChangeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _routeChangeButton.backgroundColor = [UIColor darkGrayColor];
    _routeChangeButton.layer.cornerRadius = kButtonSize / 2;
    _routeChangeButton.layer.masksToBounds = YES;
    UIImage *image = [UIImage imageForName:@"ic_surround_sound_black_24dp.png" color:[UIColor whiteColor]];
    [_routeChangeButton setImage:image forState:UIControlStateNormal];
    [_routeChangeButton addTarget:self
                           action:@selector(onRouteChange:)
                 forControlEvents:UIControlEventTouchUpInside];
    //[self addSubview:_routeChangeButton];

      
      


      
      
    // TODO(tkchin): don't display this if we can't actually do camera switch.
    _cameraSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _cameraSwitchButton.backgroundColor = [UIColor darkGrayColor];
    _cameraSwitchButton.layer.cornerRadius = kButtonSize / 2;
    _cameraSwitchButton.layer.masksToBounds = YES;
    image = [UIImage imageForName:@"ic_switch_video_black_24dp.png" color:[UIColor whiteColor]];
    [_cameraSwitchButton setImage:image forState:UIControlStateNormal];
    [_cameraSwitchButton addTarget:self action:@selector(onCameraSwitch:) forControlEvents:UIControlEventTouchDown];

      
      
      
    _hangupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _hangupButton.backgroundColor = [UIColor redColor];
    _hangupButton.layer.cornerRadius = kButtonSize / 2;
    _hangupButton.layer.masksToBounds = YES;
    image = [UIImage imageForName:@"ic_call_end_black_24dp.png"
                            color:[UIColor whiteColor]];
    [_hangupButton setImage:image forState:UIControlStateNormal];
    [_hangupButton addTarget:self
                      action:@selector(onHangup:)
            forControlEvents:UIControlEventTouchUpInside];
    [_buttonContainer addSubview:_hangupButton];
      [_buttonContainer addSubview:_cameraSwitchButton];
      [_buttonContainer addSubview:_routeChangeButton];

            
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _statusLabel.font = [UIFont fontWithName:@"Roboto" size:16];
    _statusLabel.textColor = [UIColor whiteColor];
//    [self addSubview:_statusLabel];
  //  [self addSubview:_buttonContainer];
  //    [self bringSubviewToFront:_buttonContainer];
//    UITapGestureRecognizer *tapRecognizer =
//        [[UITapGestureRecognizer alloc]
//            initWithTarget:self
//                    action:@selector(didTripleTap:)];
//    tapRecognizer.numberOfTapsRequired = 3;
//    [self addGestureRecognizer:tapRecognizer];
  }
  return self;
}


- (void)viewDidLoad {
    _remoteVideoView.frame = self.bounds;
    _remoteVideoView.contentMode = UIViewContentModeScaleAspectFill;
    // NSLog(@"##########################################  viewDidLoad _remoteVideoView");

}

- (void)setFilleMode:(RCVideoFillMode)filleMode {
    if (RCVideoFillModeAspect == filleMode) {
        _remoteVideoView.contentMode = UIViewContentModeScaleAspectFit;
    } else {
        _remoteVideoView.contentMode = UIViewContentModeScaleAspectFill;
    }
}



- (void)layoutSubviews {
  CGRect bounds = self.bounds;
  
    // NSLog(@"##########################################  _remoteVideoSize width: %f ",_remoteVideoSize.width);
    // NSLog(@"##########################################  _remoteVideoSize height: %f ",_remoteVideoSize.height);


if (_remoteVideoSize.width > 0 && _remoteVideoSize.height > 0) {
    // Aspect fill remote video into bounds.
    CGRect remoteVideoFrame =
        AVMakeRectWithAspectRatioInsideRect (_remoteVideoSize, bounds);
    CGFloat scale = 1;
    if (remoteVideoFrame.size.width > remoteVideoFrame.size.height) {
      // Scale by height.
      scale = bounds.size.height / remoteVideoFrame.size.height;
    } else {
      // Scale by width.
      scale = bounds.size.width / remoteVideoFrame.size.width;
    }
    remoteVideoFrame.size.height *= scale;
    remoteVideoFrame.size.width *= scale;
    _remoteVideoView.frame = remoteVideoFrame;
    _remoteVideoView.center =
        CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
  } else {
    _remoteVideoView.frame = bounds;
  }
    
    _remoteVideoView.frame = bounds;

    _remoteVideoView.contentMode = UIViewContentModeScaleAspectFill;

    
    
    
    
  // Aspect fit local video view into a square box.
  CGRect localVideoFrame =
      CGRectMake(0, 0, kLocalVideoViewSize, kLocalVideoViewSize);
  // Place the view in the bottom right.
  localVideoFrame.origin.x = CGRectGetMaxX(bounds)
      - localVideoFrame.size.width - kLocalVideoViewPadding - (kButtonPadding/2);
  localVideoFrame.origin.y = kButtonSize
      + kLocalVideoViewPadding;
  _localVideoView.frame = localVideoFrame;

  // Place stats at the top.
  CGSize statsSize = [_statsView sizeThatFits:bounds.size];
  _statsView.frame = CGRectMake(CGRectGetMinX(bounds),
                                CGRectGetMinY(bounds) + kStatusBarHeight,
                                statsSize.width, statsSize.height);
    
    
    
//    _buttonContainer.frame =
//    CGRectMake(((bounds.size.width / 2) - (( (kButtonSize*3) + (kButtonPadding*2) ) / 2)), bounds.size.height - kButtonSize - (kButtonPadding*2),
//               ((kButtonSize*3) + (kButtonPadding*2)),
//               kButtonSize);

    
    
    
    _buttonContainer.frame = CGRectMake(0, bounds.size.height - kButtonSize - (kButtonPadding*2), bounds.size.width, 100);
//    _buttonContainer.center = CGPointMake(bounds.size.width  / 2,
//                                          bounds.size.height - kButtonSize - kButtonPadding*2);
    
    
  // Place hangup button in the bottom left.
  _hangupButton.frame =
      CGRectMake(0, 0,
                 kButtonSize,
                 kButtonSize);

  // Place button to the right of hangup button.
    CGRect cameraFrame = _hangupButton.frame;
    cameraFrame.origin.x =
        CGRectGetMaxX(cameraFrame) + kButtonPadding;
    _cameraSwitchButton.frame = cameraFrame;


  // Place route button to the right of camera button.
  CGRect routeChangeFrame = _cameraSwitchButton.frame;
  routeChangeFrame.origin.x =
      CGRectGetMaxX(routeChangeFrame) + kButtonPadding;
  _routeChangeButton.frame = routeChangeFrame;

  [_statusLabel sizeToFit];
  _statusLabel.center =
      CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));

  //  [self bringSubviewToFront:_buttonContainer];
//    [self strechToSuperview:_remoteVideoView];

}

#pragma mark - Helper
- (void)strechToSuperview:(UIView *)view {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *formats = @[ @"H:|[view]|", @"V:|[view]|" ];
    for (NSString *each in formats) {
        NSArray *constraints =
        [NSLayoutConstraint constraintsWithVisualFormat:each options:0 metrics:nil views:@{@"view" : view}];
        [view.superview addConstraints:constraints];
    }
}



#pragma mark - RTC_OBJC_TYPE(RTCVideoViewDelegate)

- (void)videoView:(id<RTC_OBJC_TYPE(RTCVideoRenderer)>)videoView didChangeVideoSize:(CGSize)size {
  if (videoView == _remoteVideoView) {
    _remoteVideoSize = size;
  }
  [self setNeedsLayout];
}

#pragma mark - Private

- (void)onCameraSwitch:(id)sender {
    
//    
//    
//    // set a new camera id
//    cameraId = ([cameraId isEqualToString:frontCameraId]) ? backCameraId : frontCameraId;
//
//    // determine if the stream has a video track
//    BOOL hasActiveVideoTrack = ([self.localMediaStream.videoTracks count] > 0);
//
//    // remove video track from the stream
//    if (hasActiveVideoTrack) {
//        [self.localMediaStream removeVideoTrack:self.localVideoTrack];
//    }
//
//    // remove renderer from the video track
//    [self.localVideoTrack removeRenderer:self.localVideoView];
//
//    // re init the capturer, video source and video track
//    localVideoCapturer = nil;
//    localVideoSource = nil;
//    localVideoCapturer = [RTCVideoCapturer capturerWithDeviceName:cameraId];
//    localVideoSource = [peerConnectionFactory videoSourceWithCapturer:localVideoCapturer constraints:mediaConstraints];
//
//    // create a new video track
//    self.localVideoTrack = [peerConnectionFactory videoTrackWithID:@"ARDAMSv0" source:localVideoSource];
//    [self.localVideoTrack addRenderer:self.localVideoView];
//
//    // add video track back to the stream
//    if (hasActiveVideoTrack) {
//        [self.localMediaStream addVideoTrack:self.localVideoTrack];
//    }
//    
    
  [_delegate videoCallViewDidSwitchCamera:self];
}

- (void)onRouteChange:(id)sender {
  [_delegate videoCallViewDidChangeRoute:self];
}

- (void)onHangup:(id)sender {
  [_delegate videoCallViewDidHangup:self];
}

- (void)didTripleTap:(UITapGestureRecognizer *)recognizer {
  [_delegate videoCallViewDidEnableStats:self];
}

@end

