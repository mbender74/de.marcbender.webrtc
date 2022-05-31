/**
 * webrtc
 *
 * Created by Your Name
 * Copyright (c) 2019 Your Company. All rights reserved.
 */

#import "TiModule.h"

#import <TitaniumKit/TiViewController.h>
#import <TitaniumKit/TiViewProxy.h>
#import <TitaniumKit/TiProxy.h>
#import <TitaniumKit/TiUIView.h>

#import <TitaniumKit/TitaniumKit.h>
#import "TiUINavigationWindowProxy.h"
#import "TiUINavigationWindowInternal.h"
#import "TiWindowProxy+Addons.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreMedia/CoreMedia.h>

#import <WebRTC/RTCPeerConnection.h>
#import <WebRTC/RTCVideoTrack.h>
#import "ARDSettingsModel.h"

#import "RTCSessionDescription+JSON.h"
#import <AudioToolbox/AudioToolbox.h>


#import <WebRTC/RTCAudioTrack.h>
#import <WebRTC/RTCCameraVideoCapturer.h>
#import <WebRTC/RTCConfiguration.h>
#import <WebRTC/RTCDefaultVideoDecoderFactory.h>
#import <WebRTC/RTCDefaultVideoEncoderFactory.h>
#import <WebRTC/RTCFileLogger.h>
#import <WebRTC/RTCFileVideoCapturer.h>
#import <WebRTC/RTCAudioSession.h>

#import <WebRTC/RTCIceServer.h>
#import <WebRTC/RTCLogging.h>
#import <WebRTC/RTCMediaConstraints.h>
#import <WebRTC/RTCMediaStream.h>
#import <WebRTC/RTCPeerConnectionFactory.h>
#import <WebRTC/RTCRtpSender.h>
#import <WebRTC/RTCRtpTransceiver.h>
#import <WebRTC/RTCTracing.h>
#import <WebRTC/RTCVideoSource.h>
#import <WebRTC/RTCVideoTrack.h>
#import <WebRTC/RTCDataChannel.h>
#import <WebRTC/RTCVideoCapturer.h>

#import <WebRTC/RTCFieldTrials.h>
#import <WebRTC/RTCLogging.h>
#import <WebRTC/RTCSSLAdapter.h>
#import <WebRTC/RTCTracing.h>
#import <WebRTC/RTCDataChannelConfiguration.h>
#import <WebRTC/RTCIceCandidate.h>
#import <WebRTC/RTCCameraVideoCapturer.h>
#import <WebRTC/RTCCameraPreviewView.h>
#import <WebRTC/RTCVideoRenderer.h>
#import <WebRTC/RTCMTLVideoView.h>

#import "ARDVideoCallView.h"
#import "ARDVideoCallViewController.h"
#import "ARDCaptureController.h"
#import "ARDFileCaptureController.h"

#import "STUNClient.h"
#import "GCDAsyncUdpSocket.h"
#import "EndpointResolution.h"
#import "UDPHolePuncher.h"

#import "nat_type.h"
#import "nat_traversal.h"
#import "DeMarcbenderWebrtcViewProxy.h"

@interface DeMarcbenderWebrtcModule : TiModule {
    STUNClient *stunClient;
    GCDAsyncUdpSocket *udpSocket;
    EndpointResolution* epr;
    UDPHolePuncher*  puncher;
    RTCMediaStream *_localStream;
    RTCMediaStream *_remoteStream;
    RTCPeerConnectionFactory *_factory;
    RTCDataChannel *_localDataChannel;
    RTCCameraVideoCapturer *capture;
    RTCFileVideoCapturer *fileCapturer;
    ARDVideoCallViewController *videoCallController;
    BOOL animated;
    BOOL asView;
    NSString *myID;
    RTCDefaultVideoDecoderFactory *decoderFactory;
    RTCDefaultVideoEncoderFactory *encoderFactory;
    ARDCaptureController *_captureController;
    ARDFileCaptureController *_fileCaptureController NS_AVAILABLE_IOS(10);
    BOOL _usingFrontCamera;
    UIView *buttonContainer;
    TiViewProxy *buttonContainerProxy;
    NSMutableArray *participantsDetails;
    NSMutableArray *participantsTempDetails;
    DeMarcbenderWebrtcViewProxy * viewProxy;
}
@property(nonatomic,strong)RTCCameraPreviewView *localVideoView;
@property (nonatomic, strong)   RTCVideoTrack  *remoteVideoTrack;
@property (nonatomic, strong)   RTCAudioTrack  *localAudioTrak;
@property(nonatomic, strong) RTCMediaStream *remoteAudioStream;

@property(nonatomic, readonly) __kindof UIView<RTC_OBJC_TYPE(RTCVideoRenderer)> *videoView;
- (void)setContainerView:(UIView *)view;
- (void)setRemoteAudioEnabled:(BOOL)enabled;

//- (NSInteger)doPuncher;
@end
