/**
 * webrtc
 *
 * Created by Your Name
 * Copyright (c) 2019 Your Company. All rights reserved.
 */

#import "DeMarcbenderWebrtcModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"
#import "TiProxy.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreMedia/CoreMedia.h>
#import "NetworkInformation.h"
#include <netinet/in.h>
#include <sys/fcntl.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <netdb.h>
#include <sys/types.h>

#import "punching.h"
#import <objc/runtime.h>



static NSString *const RTCSTUNServerURLA = @"stun:stun.l.google.com:19302";
static NSString *const RTCSTURNServerURL = @"stun:stun1.l.google.com:19302";
static NSString *const RTCSTURNServerURL2 = @"stun:stun.2.google.com:19302";

static NSString * const kARDAppClientErrorDomain = @"ARDAppClient";
static NSInteger const kARDAppClientErrorUnknown = -1;
static NSInteger const kARDAppClientErrorRoomFull = -2;
static NSInteger const kARDAppClientErrorCreateSDP = -3;
static NSInteger const kARDAppClientErrorSetSDP = -4;
static NSInteger const kARDAppClientErrorInvalidClient = -5;
static NSInteger const kARDAppClientErrorInvalidRoom = -6;
static NSString * const kARDMediaStreamId = @"ARDAMS";
static NSString * const kARDAudioTrackId = @"ARDAMSa0";
static NSString * const kARDVideoTrackId = @"ARDAMSv0";
static NSString * const kARDVideoTrackKind = @"video";

@interface DeMarcbenderWebrtcModule()<RTCPeerConnectionDelegate,RTCDataChannelDelegate,ARDVideoCallViewControllerDelegate,RTCAudioSessionDelegate>{

}

@property(nonatomic, strong) RTCMediaConstraints * defaultPeerConnectionConstraints;

@end




@implementation DeMarcbenderWebrtcModule
{
    NSString *_server;
    NSString *_room;

    NSMutableDictionary *_datachannelDic;
    NSMutableDictionary *_roomsConnections;

    NSMutableDictionary *_connectionDic;
    NSMutableArray *_connectionIdArray;
    
    //    Role _role;
    NSMutableArray *ICEServers;
    BOOL _usingCamera;
    BOOL callInitiator;

    BOOL isConference;
    NSString *roomID;
    
    RTCPeerConnection *_peerConnection;
    RTCSessionDescription *sdpString;
    
    RTCDataChannel *_remoteDataChannel;
    RTCVideoTrack * _localVideoTrack;

    NSString *_myId;
    
    NSString *_connectId;
}


int puncherresult = 0;
int connectresult = 0;

int clientID;

#pragma mark Internal

// This is generated for your module, please do not change it
- (id)moduleGUID
{
  return @"dc48cac4-7cf5-42fe-b919-89301e014132";
}

// This is generated for your module, please do not change it
- (NSString *)moduleId
{
  return @"DeMarcbenderWebrtc";
}

#pragma mark Lifecycle

- (void)startup
{
  // This method is called when the module is first loaded
  // You *must* call the superclass
  [super startup];
  // NSLog(@"[INFO] %@ loaded", self);
    
  buttonContainerProxy = nil;
  _connectionDic = [NSMutableDictionary dictionary];
  _datachannelDic = [NSMutableDictionary dictionary];
    _roomsConnections = [NSMutableDictionary dictionary];
    
   epr=[[EndpointResolution alloc] init];
    _usingFrontCamera = YES;
  //[self _setupForIceServers];
    participantsDetails=[[NSMutableArray alloc]init];
    participantsTempDetails=[[NSMutableArray alloc]init];

}






#pragma Public APIs

- (id)createView:(id)args{
//    return [[TiBottomsheetcontrollerProxy alloc] _initWithPageContext:[self executionContext] args:args];
    viewProxy = [[DeMarcbenderWebrtcViewProxy alloc] _initWithPageContext:[self executionContext] args:args];
    return viewProxy;
}


- (void)setContainerView:(UIView *)view {
    
}


- (void)setButtonContainer:(id)value
{
  ENSURE_SINGLE_ARG(value, TiViewProxy);
  // NSLog(@"setButtonContainer ");

    if (buttonContainerProxy != nil) {
      // NSLog(@"release closeButtonproxy ");
        buttonContainerProxy = nil;
      //RELEASE_TO_NIL(buttonContainer);
  }
    buttonContainerProxy = (TiViewProxy*)value;
   // // NSLog(@"closeButton ");

    //
   
}







- (NSString *)getKeyFromConnectionDic:(RTCPeerConnection *)peerConnection
{
    //find socketid by pc
    static NSString *socketId;
    [_connectionDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, RTCPeerConnection *obj, BOOL * _Nonnull stop) {
        if ([obj isEqual:peerConnection])
        {
            // NSLog(@"%@",key);
            socketId = key;
        }
    }];
    return socketId;
}


//- (void)createDataChannel:(id)value

- (NSInteger) doPuncher:(id)args
{

//  //  dispatch_async(dispatch_get_main_queue(), ^(int){
//    ENSURE_SINGLE_ARG(args,NSString);
//    
//    NSString *peerID = args;
//    NSUInteger peerIDValue = [peerID intValue];
//    // NSLog(@"[INFO] PUNCHERINT FROM ARGS  %@: ",peerIDValue);

    
    
        // NSLog(@"[INFO] PUNCHERINT  %i: ",2);

        puncherresult = doconnection(NULL);

        NSInteger nsi = (NSInteger) puncherresult;

    
    // NSLog(@"[INFO] PUNCHERRESULT: %i",puncherresult);

//        // NSLog(@"[INFO] PUNCHER 2");
//
//        NSNumber *someNumber = [NSNumber numberWithInt:puncherresult];
//
//        NSMutableDictionary * event = [NSMutableDictionary dictionary];

    // NSLog(@"[INFO] PUNCHERRESULT: %d",nsi);

        return nsi;
        
//        [event setValue:someNumber
//             forKey:@"result"];
//
//        [self fireEvent:@"puchcher" withObject:event];
  //  });

}


//- (id) myClient:(id)args
//{
//    // NSLog(@"BEFORE CLIENT ID NATIVE:");
//
//    clientID = myClientID();
//
//    // NSLog(@"CLIENT ID NATIVE: %@",clientID);
//
//
//   // return clientID;
//};


//
//
//- (NSInteger) connectP2P:(id)args
//{
//
//    //  dispatch_async(dispatch_get_main_queue(), ^(int){
//
//
//
//    NSInteger peerID = (NSInteger) args;
//
//    int peerIDInt = (int) peerID;
//
//
//    // NSLog(@"[INFO] connect::: %i",peerID);
//
//    // NSLog(@"[INFO] connect::: %i",peerIDInt);
//
//
//    connectresult = connectPeer(peerIDInt);
//
//    NSInteger nsi = (NSInteger) connectresult;
//
//
//    // NSLog(@"[INFO] connect: %i",connectresult);
//
//    //        // NSLog(@"[INFO] PUNCHER 2");
//    //
//    //        NSNumber *someNumber = [NSNumber numberWithInt:puncherresult];
//    //
//    //        NSMutableDictionary * event = [NSMutableDictionary dictionary];
//
//    // NSLog(@"[INFO] connect: %d",nsi);
//
//    return nsi;
//
//    //        [event setValue:someNumber
//    //             forKey:@"result"];
//    //
//    //        [self fireEvent:@"puchcher" withObject:event];
//    //  });
//
//}
//
//
//


- (void)getPublicIP
{
    udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];

    stunClient = [[STUNClient alloc] init];

    [stunClient requestPublicIPandPortWithUDPSocket:udpSocket delegate:(id)self];
};


- (void)getAllInterfaces
{
    NetworkInformation *networkInfo = [NetworkInformation sharedInformation];
    NSString *interface = [networkInfo primaryIPv4Address];
    
    NSMutableDictionary * event = [NSMutableDictionary dictionary];
    NSError* error = nil;

//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[networkInfo allInterfaceNames] options:NSJSONWritingPrettyPrinted error:&error];
//
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    
    [event setValue:interface
             forKey:@"interface"];
    
    [self fireEvent:@"networkadapter" withObject:event];
    
};






- (void)punchHoleTo:(id)args{

        // NSLog(@"HOLE PUNCHING CALL %@",args);
    
        puncher = [[UDPHolePuncher alloc] init];

        // NSLog(@"PUNCHER INIT");

        NSString *ip = [args objectAtIndex:0];
    
        // NSLog(@"IP ");

        // let's make sure port is a real number because we've got it from json
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];

        // NSLog(@"NUMBER FORMATER ");

        f.numberStyle = NSNumberFormatterDecimalStyle;
    
        // NSLog(@"NUMBER STYLE ");

        NSNumber *port = [f numberFromString:[args objectAtIndex:1]];
    
        // NSLog(@"PORT ");

        if (port == nil) // NSLog(@"ERROR - port is not a number %@", [args objectAtIndex:1]);

    
    
        // NSLog(@"HOLE PUNCHING %@",args);

        [puncher startUDPHolePunch:ip _port:port];
};
    
    
    


- (NSString *)getKeyFromDataChannelDic:(RTCDataChannel *)datachannel
{
    //find socketid by pc
    static NSString *socketId;
    [_datachannelDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, RTCDataChannel *obj, BOOL * _Nonnull stop) {
        if ([obj isEqual:datachannel])
        {
            // NSLog(@"%@",key);
            socketId = key;
        }
    }];
    return socketId;
};



- (RTCMediaConstraints *)localVideoConstraints
{
    

    NSDictionary *dic = @{
        kRTCMediaConstraintsOfferToReceiveVideo: @"true",
        kRTCMediaConstraintsOfferToReceiveAudio: @"true",
    };
    
    RTCMediaConstraints *constraints =
         [[RTCMediaConstraints alloc]
          initWithMandatoryConstraints:dic
                      optionalConstraints:nil];
     return constraints;
}






- (void)createLocalStream
{
    _localStream = [_factory mediaStreamWithStreamId:@"ARDAMS"];


    AVCaptureDeviceDiscoverySession *captureDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera]
                                          mediaType:AVMediaTypeVideo
                                           position:AVCaptureDevicePositionBack];
    NSArray *deviceArray = [captureDeviceDiscoverySession devices];
    AVCaptureDevice *device = [deviceArray lastObject];

    
    //检测摄像头权限
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    
    

    
//    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
//    {
//        // NSLog(@"相机访问受限");
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"相机访问受限" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alertView show];
//    }
//    else
//    {
        RTCVideoSource *videoSource = [_factory videoSource];

        #if !TARGET_IPHONE_SIMULATOR
        capture = [[RTCCameraVideoCapturer alloc] initWithDelegate:videoSource];
    
        AVCaptureDeviceFormat * format = [[RTCCameraVideoCapturer supportedFormatsForDevice:device] lastObject];
        CGFloat fps = [[format videoSupportedFrameRateRanges] firstObject].maxFrameRate;

        #else
        // NSLog(@"_fileCaptureController 1");
             fileCapturer =
                [[RTCFileVideoCapturer alloc] initWithDelegate:videoSource];
        #endif

        
        ARDVideoCallView *videoview = [videoCallController localVideoView];


         _localVideoTrack = [_factory videoTrackWithSource:videoSource trackId:@"ARDAMSv0"];

        if (_localVideoTrack){
            _localVideoTrack.isEnabled = YES;
            videoCallController.localVideoTrack = _localVideoTrack;
            videoCallController.localStream = _localStream;

            [_localStream addVideoTrack:_localVideoTrack];

            
         //   [_peerConnection addTrack:_localVideoTrack streamIds:@[ kARDMediaStreamId ]];
                
                
                
                
#if !TARGET_IPHONE_SIMULATOR
            videoview.localVideoView.captureSession = capture.captureSession;
            
                ARDSettingsModel *settingsModel = [[ARDSettingsModel alloc] init];
                _captureController =
                    [[ARDCaptureController alloc] initWithCapturer:capture settings:settingsModel];

            
            
            
            AVCaptureDevicePosition position =
                _usingFrontCamera ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
            AVCaptureDevice *device = [_captureController findDeviceForPosition:position];
            AVCaptureDeviceFormat *format = [_captureController selectFormatForDevice:device];

            NSInteger fps = [_captureController selectFpsForFormat:format];

            [capture startCaptureWithDevice:device format:format fps:fps];

             //   [_captureController startCapture];
#else
            // NSLog(@"_fileCaptureController 2");

            _fileCaptureController = [[ARDFileCaptureController alloc] initWithCapturer:fileCapturer];

            
            [fileCapturer startCapturingFromFileNamed:@"foreman.mp4"
                                                   onError:^(NSError *_Nonnull error) {
                                                     // NSLog(@"Error %@", error.userInfo);
                                                   }];
            
            videoview.localVideoView.backgroundColor = UIColor.blueColor;


#endif

                
                
        //        ARDSettingsModel *settingsModel = [[ARDSettingsModel alloc] init];
        //        self->_captureController =
        //        [[ARDCaptureController alloc] initWithCapturer:self->capture settings:settingsModel];
        //        [self->_captureController startCapture];
                
                
                
                
                
                
         //   }];
            

        }

            [_peerConnection addStream:_localStream];

    
            if (self->isConference){

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->videoCallController localVideoView].statusLabel.hidden = YES;
                    //[[AVAudioSession sharedInstance] setMode:AVAudioSessionModeVoiceChat error:nil];
                    [self enableSpeaker];
                    
                    
                    NSMutableDictionary * event = [NSMutableDictionary dictionary];
                    NSString *thisPeerID = [self getKeyFromConnectionDic:self->_peerConnection];
                    NSArray *userRoomArray = [thisPeerID componentsSeparatedByString:@":@:"];
                    [event setValue:userRoomArray[1] forKey:@"inConferenceRoom"];
                    [event setValue:userRoomArray[0] forKey:@"userID"];

                    [self fireEvent:@"joinedToRoom" withObject:event];
                });
            }
       

    //}
    
}

- (void)swichCamera{
    _captureController.isFrontCamera = !_captureController.isFrontCamera;
    [self createLocalStreamNew];
}



-(void)createLocalStreamNew{
    _localStream = [_factory mediaStreamWithStreamId:@"ARDAMS"];
    //音频
    RTCAudioTrack * audioTrack = [_factory audioTrackWithTrackId:@"ARDAMSa0"];
    [_localStream addAudioTrack:audioTrack];
    NSArray<AVCaptureDevice *> *captureDevices = [RTCCameraVideoCapturer captureDevices];
    AVCaptureDevicePosition position = _usingFrontCamera ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    AVCaptureDevice * device = captureDevices[0];
    for (AVCaptureDevice *obj in captureDevices) {
        if (obj.position == position) {
            device = obj;
            break;
        }
    }
    
    //检测摄像头权限
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
    {
//        // NSLog(@"相机访问受限");
//        if ([_delegate respondsToSelector:@selector(webRTCHelper:setLocalStream:userId:)])
//        {
//
//            [_delegate webRTCHelper:self setLocalStream:nil userId:_myId];
//        }
    }
    else
    {
        if (device)
        {
            RTCVideoSource *videoSource = [_factory videoSource];
            RTCCameraVideoCapturer * capture = [[RTCCameraVideoCapturer alloc] initWithDelegate:videoSource];
            AVCaptureDeviceFormat * format = [[RTCCameraVideoCapturer supportedFormatsForDevice:device] lastObject];
            CGFloat fps = [[format videoSupportedFrameRateRanges] firstObject].maxFrameRate;
            RTCVideoTrack *videoTrack = [_factory videoTrackWithSource:videoSource trackId:@"ARDAMSv0"];
            __weak RTCCameraVideoCapturer *weakCapture = capture;
            __weak RTCMediaStream * weakStream = _localStream;
            __weak NSString * weakMyId = _myId;
            [weakCapture startCaptureWithDevice:device format:format fps:fps completionHandler:^(NSError * error) {
                // NSLog(@"11111111");
                [weakStream addVideoTrack:videoTrack];
//                if ([self->_delegate respondsToSelector:@selector(webRTCHelper:setLocalStream:userId:)])
//                {
//                    [self->_delegate webRTCHelper:self setLocalStream:weakStream userId:weakMyId];
//                    [self->_delegate webRTCHelper:self capturerSession:weakCapture.captureSession];
//                }
            }];
//            [videoSource adaptOutputFormatToWidth:640 height:480 fps:30];
            
        }
        else
        {
//            // NSLog(@"该设备不能打开摄像头");
//            if ([_delegate respondsToSelector:@selector(webRTCHelper:setLocalStream:userId:)])
//            {
//                [_delegate webRTCHelper:self setLocalStream:nil userId:_myId];
//            }
        }
    }
}




- (void)setSessionDescriptionWithPeerConnection:(RTCPeerConnection *)peerConnection
{
    // NSLog(@"%s",__func__);
    NSString *currentId = [self getKeyFromConnectionDic:peerConnection];
    
    if (peerConnection.signalingState == RTCSignalingStateHaveRemoteOffer)
    {
        //创建一个answer,会把自己的SDP信息返回出去
        [peerConnection answerForConstraints:[self creatAnswerOrOfferConstraint] completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
            __weak RTCPeerConnection *obj = peerConnection;
            [peerConnection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
                [self setSessionDescriptionWithPeerConnection:obj];
            }];
        }];
    }
    //判断连接状态为本地发送offer
//    else if (peerConnection.signalingState == RTCSignalingStateHaveLocalOffer)
//    {
//        if (peerConnection.localDescription.type == RTCSdpTypeAnswer)
//        {
//       //     dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 2.0);
//     //       dispatch_after(delay, dispatch_get_main_queue(), ^(void){
//
//
//
//            NSDictionary *dic = @{@"data":[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@{@"type":@"answer",@"sdp":peerConnection.localDescription.sdp} options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding], @"socketId":currentId,@"fromUserId":self->myID};
//
////                NSDictionary *dic = @{@"data": @{@"type": @"answer", @"sdp": peerConnection.localDescription.sdp}, @"socketId": currentId};
////                NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
//
//
////                NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
////
////                NSMutableDictionary * event = [NSMutableDictionary dictionary];
////
////                [event setValue:jsonString
////                         forKey:@"sdp"];
////
////                NSString *currentId = [self getKeyFromConnectionDic: peerConnection];
////
////
////                [event setValue:[TiUtils stringValue:currentId]
////                         forKey:@"session"];
//
//
//                [self fireEvent:@"answer" withObject:dic];
//          //  });
//        }
//        //发送者,发送自己的offer
//        else if(peerConnection.localDescription.type == RTCSdpTypeOffer)
//        {
//          // dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 2.0);
//          //  dispatch_after(delay, dispatch_get_main_queue(), ^(void){
//                   // NSDictionary *dic = @{@"eventName": @"__offer", @"data": @{@"sdp": @{@"type": @"offer", @"sdp": peerConnection.localDescription.sdp}, @"socketId": currentId}};
//
//
////            NSDictionary *dic = @{@"data":[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@{@"type":@"offer",@"sdp":peerConnection.localDescription.sdp} options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding], @"socketId":currentId};
////            [self fireEvent:@"offer" withObject:dic];
//
//
////                    NSDictionary *dic = @{@"data": @{@"type": @"offer", @"sdp": peerConnection.localDescription.sdp}, @"socketId": currentId};
//
////                    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
////
////
////                    NSMutableDictionary * event = [NSMutableDictionary dictionary];
////
////                    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
////
////
////                    [event setValue:jsonString
////                             forKey:@"sdp"];
////                    NSString *currentId = [self getKeyFromConnectionDic: peerConnection];
////
////                    [event setValue:[TiUtils stringValue:currentId]
////                             forKey:@"session"];
//
//                    //    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 1.0);
//                    //    dispatch_after(delay, dispatch_get_main_queue(), ^(void){
////                    [self fireEvent:@"offer" withObject:dic];
//          //   });
//
//        }
//    }
//    else if (peerConnection.signalingState == RTCSignalingStateStable)
//    {
//        if (peerConnection.localDescription.type == RTCSdpTypeAnswer)
//        {
//         //  dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 2.0);
//         //   dispatch_after(delay, dispatch_get_main_queue(), ^(void){
//
//                    NSDictionary *dic = @{@"data":[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@{@"type":@"answer",@"sdp":peerConnection.localDescription.sdp} options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding], @"socketId":currentId,@"fromUserId":self->myID};
//
////                    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
////
////                    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
////
////                    NSMutableDictionary * event = [NSMutableDictionary dictionary];
////
////                    [event setValue:jsonString
////                             forKey:@"data"];
//
//                    NSString *currentId = [self getKeyFromConnectionDic: peerConnection];
//
////
////                    [event setValue:[TiUtils stringValue:currentId]
////                             forKey:@"session"];
//
//
//                    [self fireEvent:@"answer" withObject:dic];
//          //  });
//        }
//    }
    
}




- (RTCMediaConstraints *)creatAnswerOrOfferConstraint
{
    NSDictionary *optionalConstraints = @{
                                          @"internalSctpDataChannels" : @"true",
                                          @"DtlsSrtpKeyAgreement" : @"true"};
    NSDictionary *mandatoryConstraints = @{
                                           @"OfferToReceiveAudio" : @"true",
                                           @"OfferToReceiveVideo" : @"true",
                                           @"maxWidth" : @"640",
                                           @"minWidth" : @"192",
                                           @"maxHeight" : @"480",
                                           @"minHeight" : @"144",
                                           @"maxFrameRate" : @"30",
                                           @"minFrameRate" : @"5",
                                           @"googLeakyBucket" : @"true"
                                           };

    
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints optionalConstraints:optionalConstraints];
    return constraints;
}



- (void)createOffer:(id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
    NSString *peerConnectionID = [TiUtils stringValue:@"userID" properties:args];

     _peerConnection = [_connectionDic objectForKey:peerConnectionID];
    if (_peerConnection)
    {
        [_peerConnection offerForConstraints:[self creatAnswerOrOfferConstraint] completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
            if (error == nil) {
                __weak RTCPeerConnection * weakPeerConnction = self->_peerConnection;
                [weakPeerConnction setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
                    if (error == nil) {
                        [self setSessionDescriptionWithPeerConnection:weakPeerConnction];
                    }
                }];
            }
        }];
    }
}



- (RTCSessionDescription *)sdpFromJSONDictionary:(NSDictionary *)dictionary{
    NSString *sdp = [dictionary objectForKey:@"sdp"];
    
    
  //  // NSLog(@"[INFO] +++++++  JSON SDP: %@",sdp);

    
    NSString *type = [dictionary objectForKey:@"type"];
    
    
//    // NSLog(@"[INFO] +++++++  JSON TYPE: %@",type);

    
    RTCSdpType sdpType;
    if ([type isEqualToString:@"offer"]) {
        sdpType = RTCSdpTypeOffer;
    }else if ([type isEqualToString:@"answer"]){
        sdpType = RTCSdpTypeAnswer;
//    }else if ([type isEqualToString:@"pranswer"]){

    }else {
        sdpType = RTCSdpTypePrAnswer;
    }
    
    return [[RTCSessionDescription alloc] initWithType:sdpType sdp:sdp];
}

- (void)setRemoteOffer:(id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
    // NSLog(@"[INFO] +++++++ setRemoteOffer");
    
        //offer

//    // NSLog(@"[INFO] +++++++  JSON VALUE: %@",value);

    //ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);


    
//    RTCSessionDescription *outcome = [self sdpFromJSONDictionary:args];
//

    NSString *sdp = [args objectForKey:@"data"];
    NSString *userID = [args objectForKey:@"userID"];
    
    
    NSData *jsonData = [sdp dataUsingEncoding:NSUTF8StringEncoding];

    NSError *error;

    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];

    

//
//
//    NSLog(@"[INFO] +++++++  JSON STRING VALUE: %@",sdp);
//
//
//    NSData *data = [sdp dataUsingEncoding:NSUTF8StringEncoding];

   // NSError *error;
   
    RTCSessionDescription *remoteSdp = [self sdpFromJSONDictionary:jsonDic];


    //RTCSessionDescription *remoteSdp = [[RTCSessionDescription alloc] initWithType:RTCSdpTypeOffer sdp:sdp];

    // NSLog(@"[INFO] +++++++ RTCSessionDescription: %@",remoteSdp);

  //  // NSLog(@"[INFO] +++++++ RTCSessionDescription END");
    
    
    

    RTCPeerConnection *peerConnection = [_connectionDic objectForKey:userID];
    if (peerConnection)
    {
        __weak RTCPeerConnection *weakPeerConnection = peerConnection;
        [weakPeerConnection setRemoteDescription:remoteSdp completionHandler:^(NSError * _Nullable error) {
            if (error){
                 NSLog(@"[INFO] +++++++ RTCSessionDescription ERROR: %@",error);
            }
            else {
                [self setSessionDescriptionWithPeerConnection:weakPeerConnection];

            }
        }];
    }
    else {
        NSLog(@"[INFO] +++++++ NO PEERCONNECTION ERROR: %@",userID);

    }
}


- (void)setRemoteAnswer:(id)args
{
    // NSLog(@"[INFO] +++++++ setRemoteAnwser");
    
    //offer
    
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);

    NSString *sdp = [args objectForKey:@"data"];
    NSString *userID = [args objectForKey:@"userID"];
    
    
    NSData *jsonData = [sdp dataUsingEncoding:NSUTF8StringEncoding];

    NSError *error;

    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];

   
    RTCSessionDescription *remoteSdp = [self sdpFromJSONDictionary:jsonDic];

    
    RTCPeerConnection *peerConnection = [_connectionDic objectForKey:userID];
    if (peerConnection)
    {
        __weak RTCPeerConnection *weakPeerConnection = peerConnection;
        [weakPeerConnection setRemoteDescription:remoteSdp completionHandler:^(NSError * _Nullable error) {
            if (error){
                // NSLog(@"[INFO] +++++++ RTCSessionDescription ERROR: %@",error);
            }
            else {
                [self setSessionDescriptionWithPeerConnection:weakPeerConnection];
            }
        }];
    }

}





- (void)switchMicrophone:(id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
    BOOL state = [TiUtils boolValue:@"state" properties:args def:NO];

    dispatch_async(dispatch_get_main_queue(), ^{
        if (state == NO){
            if (self->_localStream.audioTracks.count){
                if(self->_localStream.audioTracks[0]){
                    [self->_localStream removeAudioTrack:self->_localStream.audioTracks[0]];
                    [self->_peerConnection removeStream:self->_localStream];
                    [self->_peerConnection addStream:self->_localStream];
                }
            }
        }
        else {
            if(!self->_localStream.audioTracks.count){

                self->_localAudioTrak = [self->_factory audioTrackWithTrackId:@"ARDAMSa0"];

                [self->_localStream addAudioTrack:self->_localAudioTrak];
                [self->_peerConnection removeStream:self->_localStream];
                [self->_peerConnection addStream:self->_localStream];
                [self enableSpeaker];

            }
        }
    });
}

//- (void)switchMicrophone:(id)args
//{
//    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
//
//    BOOL state = [TiUtils boolValue:@"state" properties:args def:NO];
//
//    if (state == NO){
//        [self setRemoteAudioEnabled:NO];
//    }
//    else {
//        [self setRemoteAudioEnabled:YES];
//    }
//}


- (void)switchAudio:(id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
      
    BOOL state = [TiUtils boolValue:@"state" properties:args def:NO];

    if (state == NO){
        [self setRemoteAudioEnabled:NO];
    }
    else {
        [self setRemoteAudioEnabled:YES];
    }
}

- (void)switchVideo:(id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
      
    BOOL state = [TiUtils boolValue:@"state" properties:args def:NO];

    if (state == NO){
        _localVideoTrack.isEnabled = NO;
        [_captureController stopCapture];

    }
    else {
        [_captureController startCapture];
        _localVideoTrack.isEnabled = YES;
    }
}



- (void)enableSpeaker {
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    //_isSpeakerEnabled = YES;
}

- (void)disableSpeaker {
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
   // _isSpeakerEnabled = NO;
}


- (void)createDataChannel:(id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
    
    NSString *peerConnectionID = [TiUtils stringValue:@"userID" properties:args];

    RTCPeerConnection *peerConnection = [_connectionDic objectForKey:peerConnectionID];
    if (peerConnection)
    {
        
        //dataChannel
        // NSLog(@" ");

        // NSLog(@"[INFO] +++++++ dataChannel %@: ",userID);

        RTCDataChannelConfiguration *dataChannelConfiguration = [[RTCDataChannelConfiguration alloc] init];
        dataChannelConfiguration.isOrdered = NO;
        dataChannelConfiguration.isNegotiated = YES;
       // dataChannelConfiguration.maxRetransmits = 30;
      //  dataChannelConfiguration.maxPacketLifeTime = 30000;
        dataChannelConfiguration.channelId = 50;
        
        
         _localDataChannel = [peerConnection dataChannelForLabel:@"datatransfer" configuration:dataChannelConfiguration];

            
    
        // NSLog(@" ");

        // NSLog(@"[JUPP] +++++++ DATACHANNEL %@", _localDataChannel);

        if(_localDataChannel){
            _localDataChannel.delegate = self;
            // NSLog(@" ");

            // NSLog(@"[INFO] %@ +++++++ DATACHANNEL READYSTATE", _localDataChannel);
            [_datachannelDic setObject:_localDataChannel forKey:peerConnectionID];
            // NSLog(@"[INFO] %@ +++++++ _datachannelDic ", _datachannelDic);

        }
        else {
            // NSLog(@" ");

            // NSLog(@"[INFO] +++++++ ERROR DATACHANNEL ");
        }
        
    }
    
}

- (RTCMediaConstraints *)creatPeerConnectionConstraint
{
    
    NSDictionary *optionalConstraints = @{
                                          @"internalSctpDataChannels" : @"true",
                                          @"DtlsSrtpKeyAgreement" : @"true"};
    
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:@{
        @"OfferToReceiveAudio" : @"true",
        @"OfferToReceiveVideo" : @"true",
        } optionalConstraints:optionalConstraints];
    return constraints;
}


- (void)setICECandidate:(id)args
{
 
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);

    NSString *icecandidate = [args objectForKey:@"data"];
    NSString *peerConnectionID = [args objectForKey:@"userID"];
    
    
    
    NSData *jsonData = [icecandidate dataUsingEncoding:NSUTF8StringEncoding];

    NSError *error;

//    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];

    
    
    

//    NSData *jsonData = [[icecandidate dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
//    //
    
//    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:[icecandidate dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];

    
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];

//    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];

    
    
//    NSString *data = [args objectAtIndex:1];
//
//    NSString *peerConnectionID = [args objectAtIndex:0];

//    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];


//    NSDictionary *dataDic = dic[@"data"];
    NSString *socketId = jsonDic[@"socketId"];
    NSString *sdpMid = jsonDic[@"id"];
    int sdpMLineIndex = [jsonDic[@"label"] intValue];
    NSString *sdp = jsonDic[@"candidate"];
    //生成远端网络地址对象
    RTCIceCandidate *candidate = [[RTCIceCandidate alloc] initWithSdp:sdp sdpMLineIndex:sdpMLineIndex sdpMid:sdpMid];;
    
    
    // NSLog(@"[JUPP] +++++++ CANDIDATE %@", candidate);

    
    //拿到当前对应的点对点连接
    //添加到点对点连接中
    RTCPeerConnection *peerConnection = [_connectionDic objectForKey:peerConnectionID];
    if (peerConnection)
    {
        [peerConnection addIceCandidate:candidate completionHandler:^(NSError * _Nullable error) {

        }];
    }
    else {
        // NSLog(@"[INFO] +++++++ ERROR peerConnection ");

    }
}



//
//- (BOOL)sendMessage:(NSString *)msg
//{
//    if (!_localDataChannel.open) {
//        return NO;
//    }
//
//    RTCDataBuffer *buffer = [[RTCDataBuffer alloc]initWithData:[msg dataUsingEncoding:NSUTF8StringEncoding] isBinary:NO];
//    return [_dataChannel sendData:buffer];
//}
//
- (RTCIceServer *)_setupForIceServer:(NSString *)stunURL
{
    return [[RTCIceServer alloc] initWithURLStrings:@[stunURL] username:@"" credential:@""];
}


- (RTCIceServer *)_setupForIceServerTurn:(NSString *)stunURL
{
    return [[RTCIceServer alloc] initWithURLStrings:@[stunURL] username:@"lookpoint" credential:@"testtest"];
}


- (void)_setupForIceServers
{
//    [ICEServers addObject:[self _setupForIceServer:RTCSTUNServerURLA]];
//    [ICEServers addObject:[self _setupForIceServer:RTCSTUNServerURL2]];
//    [ICEServers addObject:[self _setupForIceServerTurn:RTCSTURNServerURL]];
  //  [ICEServers addObject:[self _setupForIceServerTurn:RTCSTURNServerURL2]];
}


- (NSString*)checkConnection:(id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
    
    NSString *peerConnectionID = [TiUtils stringValue:@"userID" properties:args];

    RTCPeerConnection *peerConnection = [_connectionDic objectForKey:peerConnectionID];
    if (peerConnection)
    {
        return @"true";
    }
    else {
        return @"false";
    }
}


- (NSString*)stopWebRTC:(id)args
{
    [self removeConnection:args];
}


- (NSString*)removeConnection:(id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
    NSString *peerConnectionID = [TiUtils stringValue:@"userID" properties:args];
    RTCPeerConnection *peerConnection;
    
    if ([args objectForKey:@"roomID"] != nil){
        peerConnectionID = [@[peerConnectionID, [TiUtils stringValue:@"roomID" properties:args]] componentsJoinedByString:@":@:"];
    }
      peerConnection = [_connectionDic objectForKey:peerConnectionID];
//    NSString * userId = [self getKeyFromConnectionDic:peerConnection];
//    RTCPeerConnection *peerConnection = [_connectionDic objectForKey:peerConnectionID];

    
    
    if (peerConnection){
        
        _localVideoTrack.isEnabled = NO;

        [capture stopCapture];

        [_localStream removeVideoTrack:_localVideoTrack];
        
        [self->videoCallController hangup];

        [self->buttonContainerProxy.view removeFromSuperview];
        self->buttonContainerProxy = nil;
        [peerConnection close];
        
        [self->_connectionDic removeObjectForKey:peerConnectionID];
        [self->_datachannelDic removeObjectForKey:peerConnectionID];

        
        self->_peerConnection = nil;

        
        [self fireEvent:@"closed" withObject:nil];
        self->videoCallController = nil;
        self->_factory = nil;
        
//        [self->videoCallController dismissViewControllerAnimated:YES
//          completion:^{
//            [self->buttonContainerProxy.view removeFromSuperview];
//            self->buttonContainerProxy = nil;
//            [peerConnection close];
//
//            [self->_connectionDic removeObjectForKey:peerConnectionID];
//            [self->_datachannelDic removeObjectForKey:peerConnectionID];
//
//
//            self->_peerConnection = nil;
//
//
//            [self fireEvent:@"closed" withObject:nil];
//            self->videoCallController = nil;
//            self->_factory = nil;
//          }];

        return @"removed";
    }
    else {

        [self->buttonContainerProxy.view removeFromSuperview];
        self->buttonContainerProxy = nil;

        [self fireEvent:@"closed" withObject:nil];
        self->videoCallController = nil;

//        [self->videoCallController dismissViewControllerAnimated:YES
//          completion:^{
//            [self->buttonContainerProxy.view removeFromSuperview];
//            self->buttonContainerProxy = nil;
//
//            [self fireEvent:@"closed" withObject:nil];
//            self->videoCallController = nil;
//
//        }];

        return @"no_connection";
    }
}


- (void)switchCamera:(id)args {
    
    // NSLog(@"[WARN] ###################################   switchCamera");

    [capture stopCapture];
    [_captureController switchCamera];
}




- (id)startWebRTC:(id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
    NSString *peerConnectionID = nil;
    NSString *userID = [TiUtils stringValue:@"userID" properties:args];
    myID = [TiUtils stringValue:@"fromUserID" properties:args];
    
    callInitiator = NO;
    isConference = NO;
    roomID = nil;

    if ([args objectForKey:@"callInitiator"] != nil){
        callInitiator = [TiUtils boolValue:@"callInitiator" properties:args def:NO];
    }

    
    if ([args objectForKey:@"conference"] != nil){
        isConference = [TiUtils boolValue:@"conference" properties:args def:NO];
    }
    
    if ([args objectForKey:@"roomID"] != nil){
        roomID = [TiUtils stringValue:@"roomID" properties:args];
        if (isConference){
            peerConnectionID = [@[userID, roomID] componentsJoinedByString:@":@:"];
            _peerConnection = [_connectionDic objectForKey:peerConnectionID];

        }
        else{
            peerConnectionID = userID;
            _peerConnection = [_connectionDic objectForKey:peerConnectionID];
        }
    }
    else {
        peerConnectionID = userID;
        _peerConnection = [_connectionDic objectForKey:peerConnectionID];
    }

    
    
    if (!_peerConnection) {

        
        dispatch_async(dispatch_get_main_queue(), ^{
//            [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
//            [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeDefault error:nil];
            if (!self->isConference){
                [self fireEvent:@"dialing" withObject:nil];
            }
            
        });

        RTCInitializeSSL();
        
        
        
        NSArray<RTCIceServer *> *iceServers = [NSArray arrayWithObjects:[[RTCIceServer alloc] initWithURLStrings:@[RTCSTURNServerURL] username:@"" credential:@""],[[RTCIceServer alloc] initWithURLStrings:@[RTCSTUNServerURLA] username:@"" credential:@""],nil];

        // NSLog(@"[INFO] +++++++ ICESERVER2 %@", iceServers);

        
        
        if (encoderFactory == nil) {
          encoderFactory = [[RTCDefaultVideoEncoderFactory alloc] init];
        }
        if (decoderFactory == nil) {
          decoderFactory = [[RTCDefaultVideoDecoderFactory alloc] init];
        }

        

        _factory = [[RTCPeerConnectionFactory alloc] initWithEncoderFactory:encoderFactory decoderFactory:decoderFactory];

        RTCConfiguration *config = [[RTCConfiguration alloc] init];
        
        [config setIceServers:iceServers];
        [config setDisableLinkLocalNetworks:YES];
        //[config setContinualGatheringPolicy:RTCContinualGatheringPolicyGatherContinually];
      //  [config setActiveResetSrtpParams:YES];
        [config setSdpSemantics:RTCSdpSemanticsPlanB];

      //  config.iceServers = ICEServers;
        config.bundlePolicy = RTCBundlePolicyBalanced;
      //  config.iceTransportPolicy = RTCIceTransportPolicyNoHost;
        config.candidateNetworkPolicy = RTCCandidateNetworkPolicyAll;
       // config.maxIPv6Networks = INT_MAX;
    //    config.rtcpMuxPolicy = RTCRtcpMuxPolicyNegotiate;
        config.tcpCandidatePolicy = RTCTcpCandidatePolicyEnabled;

        // RTCIceTransportPolicyRelay
        // RTCIceTransportPolicyAll
        
        NSDictionary *mandatoryConstraints = @{
                                               @"OfferToReceiveAudio" : @"true",
                                               @"OfferToReceiveVideo" : @"true",
                                               @"maxWidth" : @"640",
                                               @"minWidth" : @"192",
                                               @"maxHeight" : @"480",
                                               @"minHeight" : @"144",
                                               @"maxFrameRate" : @"30",
                                               @"minFrameRate" : @"5",
                                               @"googLeakyBucket" : @"true"
                                               };
        
        NSDictionary *optionalConstraints = @{
                                              @"internalSctpDataChannels" : @"true",
                                              @"DtlsSrtpKeyAgreement" : @"true"};
        
        RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints optionalConstraints:optionalConstraints];
        
        _peerConnection = [_factory peerConnectionWithConfiguration:config constraints:constraints delegate:self];
        [self->_connectionDic setObject:_peerConnection forKey:peerConnectionID];

        // [self->_roomsConnections setObject:_peerConnection forKey:peerConnectionID];

        [self createLocalStream];

        if (callInitiator == YES){
            [self createOffer:peerConnectionID];
        }
    }
    
    return self;
}


- (RTCRtpTransceiver *)videoTransceiver {
    for (RTCRtpTransceiver *transceiver in _peerConnection.transceivers) {
        if (transceiver.mediaType == RTCRtpMediaTypeVideo) {
            return transceiver;
        }
    }
    return nil;
}


- (BOOL)sendMessage:(id)args
{

    NSString *userID = [args objectAtIndex:0];
    NSString *message = [args objectAtIndex:1];

    RTCDataChannel *datachannel = [_datachannelDic objectForKey:userID];
    BOOL *result = NULL;
    
    if (datachannel){
        __weak RTCDataChannel *weakDataChannel = datachannel;

        // NSLog(@"[DATACHANNEL] +++++++ DATACHANNEL %@", datachannel);

        // NSLog(@"WEBRTC sending message:");
        
        NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
        
        
        
        RTCDataBuffer *dataBuffer = [[RTCDataBuffer alloc] initWithData:data isBinary:NO];

        // NSLog(@"WEBRTC before sending message");
        
        BOOL result = [weakDataChannel sendData:dataBuffer];

        // NSLog(@"WEBRTC sending message DONE:");
        
        
        
        // NSLog(@"WEBRTC count tracks ");
        // NSLog(@"Received %lu video tracks and %lu audio tracks",
         //     (unsigned long)self->_remoteStream.videoTracks.count,
         //     (unsigned long)self->_remoteStream.audioTracks.count)
        
        // NSLog(@"AFTER WEBRTC count tracks ");

        //RTCVideoTrack *track = (RTCVideoTrack *)([self videoTransceiver].receiver.track);

        // NSLog(@"AFTER 2 WEBRTC count tracks ");

        // NSLog(@"AFTER 3 WEBRTC count tracks ");

        // NSLog(@"AFTER 4 WEBRTC count tracks ");


        // NSLog(@"AFTER 5 WEBRTC count tracks ");

    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self fireEvent:@"dialTimeout" withObject:nil];
        });

        result = FALSE;
    }
    
    return *result;
    
  // Example property getter. 
  // Call with "MyModule.exampleProp" or "MyModule.getExampleProp()"
}

- (void)setExampleProp:(id)value
{
  // Example property setter. 
  // Call with "MyModule.exampleProp = 'newValue'" or "MyModule.setExampleProp('newValue')"
}



- (void)closePeerConnection:(NSString *)connectionId
{
    
    RTCPeerConnection *peerConnection = [_connectionDic objectForKey:connectionId];
    if (peerConnection){
        [_connectionDic removeObjectForKey:connectionId];
        [peerConnection close];
        peerConnection = nil;
        _peerConnection = nil;
    }
    RTCDataChannel *datachannel = [_datachannelDic objectForKey:connectionId];
    if (datachannel != nil){
        [_datachannelDic removeObjectForKey:connectionId];
        [datachannel close];
        _localDataChannel = nil;
        datachannel = nil;
    }
    _localVideoTrack.isEnabled = NO;

    [capture stopCapture];

    [_localStream removeVideoTrack:_localVideoTrack];


        dispatch_async(dispatch_get_main_queue(), ^{
            [self->videoCallController hangup];
            [self->videoCallController dismissViewControllerAnimated:YES
              completion:^{
                [self->buttonContainerProxy.view removeFromSuperview];

                [self fireEvent:@"closed" withObject:nil];
                self->videoCallController = nil;
                self->_factory = nil;
                [self->_datachannelDic removeObjectForKey:connectionId];
                [self->_connectionDic removeObjectForKey:connectionId];
                self->_peerConnection = nil;
            }];
        });
}


- (void)open:(id)args
{
  ENSURE_SINGLE_ARG_OR_NIL(args, NSDictionary);
    
    animated = [TiUtils boolValue:@"animated" properties:args def:YES];
        
    NSString *userID = [TiUtils stringValue:@"userID" properties:args];

    asView = [TiUtils boolValue:@"asView" properties:args def:NO];

    
    
    
    
    
    
    // NSLog(@"THIS IS THE USERID: %@", userID);

    videoCallController =
        [[ARDVideoCallViewController alloc] initForRoom:@"test"
                                             isLoopback:NO
                                               delegate:self];
    
    
    videoCallController.delegate = self;
    
    
    
    if (asView == YES){
        
        videoCallController.view.backgroundColor = UIColor.blackColor;

        UIView *containterView = [viewProxy getWebRTCView];
        
        NSLog(@" containerView %@: ",containterView);

        
        [videoCallController loadView];
        
        [containterView addSubview:videoCallController.view];
        videoCallController.view.frame = containterView.bounds;
        [containterView bringSubviewToFront:videoCallController.view];
        
//        [[[[TiApp app] controller] topPresentedController].view addSubview:videoCallController.view];

        
        [self fireEvent:@"open" withObject:nil];

    }
    else {
        
        
        videoCallController.modalTransitionStyle =
            UIModalTransitionStyleCrossDissolve;
        videoCallController.view.backgroundColor = UIColor.blackColor;
        
        
        [videoCallController setModalPresentationStyle:UIModalPresentationFullScreen];

        if (buttonContainerProxy != nil){
            // NSLog(@"has ButtonContainer ");
            
            
            
                [videoCallController.view addSubview:buttonContainerProxy.view];
                
                
    //                [buttonContainerProxy layoutChildrenIfNeeded];
    //                [buttonContainerProxy windowDidOpen];

            [buttonContainerProxy windowWillOpen];
            buttonContainerProxy.parentVisible = YES;
            [buttonContainerProxy refreshSize];
            [buttonContainerProxy willChangeSize];
            [buttonContainerProxy layoutChildren:NO];

                
              //
            
            LayoutConstraint* layoutProperties = [(TiViewProxy *)buttonContainerProxy layoutProperties];
            layoutProperties->left = layoutProperties->left;
            layoutProperties->top = layoutProperties->top;
            layoutProperties->height = layoutProperties->height;
            layoutProperties->width = layoutProperties->width;
            [(TiViewProxy *)buttonContainerProxy refreshView:nil];

            
        //        NSArray *children = [_buttonsViewContainer children];
        //        for (TiViewProxy *proxy in children) {
        //            [proxy reposition];
        //            [proxy layoutChildrenIfNeeded];
        //        }


            
            
            [videoCallController localVideoView].buttonsViewContainer = buttonContainerProxy;

    //            [buttonContainerProxy windowWillOpen];
    //            [buttonContainerProxy reposition];
    //            [buttonContainerProxy layoutChildrenIfNeeded];
            
        }
        
        
        [[[[TiApp app] controller] topPresentedController] presentViewController:videoCallController animated:animated completion:^{
            [self fireEvent:@"open" withObject:nil];
            
            [self->videoCallController.view bringSubviewToFront:self->buttonContainerProxy.view];

        }];
    }
    


}


#pragma mark - RTCPeerConnectionDelegate



- (void)peerConnection:(RTC_OBJC_TYPE(RTCPeerConnection) *)peerConnection
       gotICECandidate:(RTC_OBJC_TYPE(RTCIceCandidate) *)candidate {
  dispatch_async(dispatch_get_main_queue(), ^{

      // NSLog(@" ");
      // NSLog(@"  ");
      // NSLog(@"  ");

      // NSLog(@"  gotICECandidate  ");


  });
}



- (void)peerConnection:(RTC_OBJC_TYPE(RTCPeerConnection) *)peerConnection
    didStartReceivingOnTransceiver:(RTC_OBJC_TYPE(RTCRtpTransceiver) *)transceiver {
    
    
    // NSLog(@"-------------------- ");
    // NSLog(@"-------------------- didStartReceivingOnTransceiver ");

    
//  RTC_OBJC_TYPE(RTCMediaStreamTrack) *track = transceiver.receiver.track;
//    // NSLog(@"Now receiving %@ on track %@.", track.kind, track.trackId);
//    // NSLog(@" videoTrack: %@",track);

    
    // NSLog(@"-------------------- ");

}


- (void)peerConnection:(RTC_OBJC_TYPE(RTCPeerConnection) *)peerConnection
    didChangeConnectionState:(RTCPeerConnectionState)newState {
    // NSLog(@"ICE+DTLS state changed: %ld", (long)newState);
}


- (void)peerConnection:(RTC_OBJC_TYPE(RTCPeerConnection) *)peerConnection
     didChangeLocalCandidate:(RTC_OBJC_TYPE(RTCIceCandidate) *)local
    didChangeRemoteCandidate:(RTC_OBJC_TYPE(RTCIceCandidate) *)remote
              lastReceivedMs:(int)lastDataReceivedMs
               didHaveReason:(NSString *)reason {
    // NSLog(@"ICE candidate pair changed because: %@", reason);
}


/** Called when a receiver and its track are created. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
        didAddReceiver:(RTCRtpReceiver *)rtpReceiver
               streams:(NSArray<RTCMediaStream *> *)mediaStreams {
     NSLog(@"-------------------- ");
     NSLog(@"-------------------- didAddReceiver ");

    // NSLog(@"💦💦💦💦💦mediaStream %@ streamid: %@",mediaStreams.firstObject,mediaStreams.firstObject.streamId);
//    static BOOL addAlready = NO;
//    if (addAlready) {
//        return ;
//    }

    self->_remoteStream = mediaStreams.firstObject;

    

//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        if (mediaStreams.firstObject.videoTracks.firstObject){
//
//          //  ARDVideoCallView *videoview = [self->videoCallController localVideoView];
//
//
////            for (RTCVideoTrack *obj in self->_remoteStream.videoTracks) {
////                [obj addRenderer:videoview.remoteVideoView];
////            }
////
////            ARDVideoCallView *videoview = [self->videoCallController localVideoView];
////
////            RTCVideoTrack *videoTrack = self->_remoteStream.videoTracks[0];
////            [videoTrack addRenderer:videoview.remoteVideoView];
//
//
//        }
//        else {
////            if (mediaStreams.firstObject.audioTracks.firstObject){
////
////                for (RTCAudioTrack *obj in self->_remoteStream.audioTracks) {
////                    obj.isEnabled = YES;
////                }
////            }
//        }
//    });

    
    
    // NSLog(@"💦💦💦💦💦 videoTrack: %@",mediaStreams.firstObject.videoTracks.firstObject);
//    dispatch_async(dispatch_get_main_queue(), ^{
//        addAlready = YES;
//        [self.videoTrack1 removeRenderer:self.removeVideoView];
//        [self.videoTrack1 addRenderer:self.removeVideoView];
//    });
    

}

- (void)setLocalAudioEnabled:(BOOL)enabled {
  if (self->_localStream.audioTracks.count == 0) {
    return;
  }
    
    [self->_localStream.audioTracks[0] setIsEnabled:enabled];
}


- (void)setRemoteAudioEnabled:(BOOL)enabled {
  if (self->_remoteStream.audioTracks.count == 0) {
    return;
  }
    
    [self->_remoteStream.audioTracks[0] setIsEnabled:enabled];
}


/**获取远程视频流*/
- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didAddStream:(nonnull RTCMediaStream *)stream {
    NSString * userId = [self getKeyFromConnectionDic:peerConnection];

    // NSLog(@"********************************");

     NSLog(@"*********************************");

     NSLog(@"WEBRTC didAddStream ");

    _localAudioTrak = [_factory audioTrackWithTrackId:@"ARDAMSa0"];
   // [_localAudioTrak setIsEnabled:NO];

    [_localStream addAudioTrack:_localAudioTrak];

    
    _remoteAudioStream = stream;

    
    
    ARDVideoCallView *videoview = [self->videoCallController localVideoView];

    RTCVideoTrack *videoTrack = self->_remoteStream.videoTracks[0];
    [videoTrack addRenderer:videoview.remoteVideoView];

    
    dispatch_async(dispatch_get_main_queue(), ^{

        //if (self->_localAudioTrak){
          //  [self->_localAudioTrak setIsEnabled:YES];
        //}

//            NSLog(@"\n\n  Received %lu video tracks and %lu audio tracks",
//                    (unsigned long)stream.videoTracks.count,
//                    (unsigned long)stream.audioTracks.count);
//
        
        if (!self->isConference){
           // [self->videoCallController localVideoView].statusLabel.hidden = YES;
    //        [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeVoiceChat error:nil];
            [self enableSpeaker];
        }
        [self fireEvent:@"dialSuccess" withObject:nil];

    });
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//      // NSLog(@"Received %lu video tracks and %lu audio tracks",
//            (unsigned long)stream.videoTracks.count,
//            (unsigned long)stream.audioTracks.count);
//        if (stream.videoTracks.count) {
//
//            self->_remoteStream = stream;
//
//      }
//    });
    
    
    
    
    //
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if ([self->_delegate respondsToSelector:@selector(webRTCHelper:addRemoteStream:userId:)]) {
//            [self->_delegate webRTCHelper:self addRemoteStream:stream userId:userId];
//        }
//    });
    
    
    
}
/**RTCIceConnectionState 状态变化*/
- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didChangeIceConnectionState:(RTCIceConnectionState)newState {
    // NSLog(@"%s",__func__);
    NSString * connectId = [self getKeyFromConnectionDic:peerConnection];
    
    // NSLog(@"-------------------- ICE CONNECTION STATE: %ld", (long)newState);

    


    
    if (newState == RTCIceConnectionStateDisconnected || newState == RTCIceConnectionStateClosed || newState == RTCIceConnectionStateFailed) {
        // NSLog(@"-------------------- CONNECTION CLOSED:");

                
        //断开connection的连接
        dispatch_async(dispatch_get_main_queue(), ^{
            [self closePeerConnection:connectId];
        });
    }
}

/**获取到新的candidate*/
- (void)peerConnection:(RTCPeerConnection *)peerConnection didGenerateIceCandidate:(RTCIceCandidate *)candidate{
    
//    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.1);
//    dispatch_after(delay, dispatch_get_main_queue(), ^(void){
////
   // [_peerConnection addIceCandidate:candidateMessage.candidate];

    [peerConnection addIceCandidate:candidate completionHandler:^(NSError * _Nullable error) {
        
    }];

        
        dispatch_async(dispatch_get_main_queue(), ^{

        
            // NSLog(@" ");
            // NSLog(@"  ");
            // NSLog(@"  ");

            // NSLog(@"  didGenerateIceCandidate  ");

            
            
           // // NSLog(@"%s",__func__);
        
            NSString *currentId = [self getKeyFromConnectionDic: peerConnection];
        //
            
            NSDictionary *dic = @{@"data":[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@{@"id":candidate.sdpMid,@"label": [NSNumber numberWithInteger:candidate.sdpMLineIndex], @"candidate": candidate.sdp} options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding], @"socketId":currentId,@"fromUserId":self->myID};


    //        // NSLog(@"-------------------- ICE CANDIDATE: %@", dic);

//            NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
//        //    [_socket send:data];
//
//
//            NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//
//            NSMutableDictionary * event = [NSMutableDictionary dictionary];
//
//            [event setValue:jsonString
//                     forKey:@"candidate"];
//
//
//            [event setValue:[TiUtils stringValue:currentId]
//                     forKey:@"session"];
//

            [self fireEvent:@"icecandidate" withObject:dic];
        });

//    });
    
}


- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didRemoveStream:(nonnull RTCMediaStream *)stream {
    // NSLog(@"%s",__func__);
    
    
    
//    [self->videoCallController hangup];
//    [self->videoCallController dismissViewControllerAnimated:YES
//      completion:^{
//        [self fireEvent:@"closed" withObject:nil];
//        self->videoCallController = nil;
//        self->_factory = nil;
//      }];
}

- (void)peerConnectionShouldNegotiate:(RTCPeerConnection *)peerConnection{
    // NSLog(@"%s,line = %d object = %@",__FUNCTION__,__LINE__,peerConnection);
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didRemoveIceCandidates:(nonnull NSArray<RTCIceCandidate *> *)candidates {
    // NSLog(@"%s,line = %d object = %@",__FUNCTION__,__LINE__,candidates);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeSignalingState:(RTCSignalingState)stateChanged{
    // NSLog(@"stateChanged = %ld",(long)stateChanged);
}
- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeIceGatheringState:(RTCIceGatheringState)newState{
    // NSLog(@"newState = %ld",newState);
    NSString *currentId = [self getKeyFromConnectionDic: peerConnection];
    
    if (newState == RTCIceGatheringStateComplete || newState == RTCIceGatheringStateNew) {
        // NSLog(@"-------------------- ICE CONNECTION STATE COMPLETED");

        if (peerConnection.signalingState == RTCSignalingStateHaveLocalOffer)
        {
            if (peerConnection.localDescription.type == RTCSdpTypeAnswer)
            {

                NSDictionary *dic = @{@"data":[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@{@"type":@"answer",@"sdp":peerConnection.localDescription.sdp} options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding], @"socketId":currentId,@"fromUserId":self->myID};
                [self fireEvent:@"answer" withObject:dic];

            }
            //发送者,发送自己的offer
            else if(peerConnection.localDescription.type == RTCSdpTypeOffer)
            {

                NSDictionary *dic = @{@"data":[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@{@"type":@"offer",@"sdp":peerConnection.localDescription.sdp} options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding], @"socketId":currentId,@"fromUserId":self->myID};
                [self fireEvent:@"offer" withObject:dic];


            }
        }
        else if (peerConnection.signalingState == RTCSignalingStateStable)
        {
            if (peerConnection.localDescription.type == RTCSdpTypeAnswer)
            {

                NSDictionary *dic = @{@"data":[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@{@"type":@"answer",@"sdp":peerConnection.localDescription.sdp} options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding], @"socketId":currentId,@"fromUserId":self->myID};
                [self fireEvent:@"answer" withObject:dic];

            }
        }

       // });
    }
    
}



-(void)peerConnection:(RTCPeerConnection *)peerConnection
   didOpenDataChannel:(RTCDataChannel *)dataChannel {
    // NSLog(@"-------           Received remote data channel %ld ", (long)dataChannel.readyState);
//    _remoteDataChannel = dataChannel;
//    _remoteDataChannel.delegate = self;
}
















#pragma mark - RTCSessionDescriptionDelegate
// Callbacks for this delegate occur on non-main thread and need to be
// dispatched back to main queue as needed.
//
//-(void)sessionHasMedia:(RTCMediaStream *)media :(NSArray *)allmedias
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        participantsDetails= [allmedias mutableCopy];
//        self.myCollectionView.hidden=NO;
//        for (int i=0; i<participantsDetails.count; i++)
//        {
//            RTCMediaStream *media = [[participantsDetails objectAtIndex:i] objectForKey:@"streamInfo"];
//
//            if ((participantsTempDetails.count-1)>i)
//            {
//                [participantsTempDetails replaceObjectAtIndex:i+1 withObject:[media.videoTracks objectAtIndex:0]];
//            }
//            else
//            {
//                [participantsTempDetails addObject:[media.videoTracks objectAtIndex:0]];
//            }
//
//        }
//        [self resetViews];
//        [[media.videoTracks objectAtIndex:0] addRenderer:self.remoteView];
//
//        [self.myCollectionView reloadData];
//        [self.myCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(participantsTempDetails.count-1) inSection:0]
//                                  atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
//                                          animated:YES];
//
//
////        [self.view bringSubviewToFront:self.buttonContainerView];
//        [self.view bringSubviewToFront:self.myCollectionView];
//        if (allmedias.count==0)
//        {
//            self.myCollectionView.hidden=YES;
//            self.footerView.hidden=NO;
//        }
//        else
//        {
//            self.myCollectionView.hidden=NO;
//            self.footerView.hidden=YES;
//        }
//    });
//}
//-(void)sessionRemoveMedia:(RTCMediaStream *)media :(NSArray *)allmedias
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//        participantsDetails= [allmedias mutableCopy];
//        for (int i=1; i<participantsTempDetails.count; i++)
//        {
//
//            if (participantsDetails.count>=i)
//            {
//                RTCMediaStream *media = [[participantsDetails objectAtIndex:(i-1)] objectForKey:@"streamInfo"];
//                [participantsTempDetails replaceObjectAtIndex:i withObject:[media.videoTracks objectAtIndex:0]];
//            }
//            else
//            {
//                [participantsTempDetails removeObjectAtIndex:i];
//            }
//
//        }
//        [self resetViews];
//        [[participantsTempDetails objectAtIndex:(participantsTempDetails.count-1)] addRenderer:self.remoteView];
//        [self.myCollectionView reloadData];
//       //[self.view bringSubviewToFront:self.buttonContainerView];
//
//        if (allmedias.count==0)
//        {
//            self.myCollectionView.hidden=YES;
//            self.footerView.hidden=NO;
//        }
//        else
//        {
//            [self.view bringSubviewToFront:self.myCollectionView];
//            [self.myCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(participantsTempDetails.count-1) inSection:0]
//                                          atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
//                                                  animated:YES];
//            self.myCollectionView.hidden=NO;
//            self.footerView.hidden=YES;
//        }
//    });
//}



- (void)peerConnection:(RTC_OBJC_TYPE(RTCPeerConnection) *)peerConnection
    didCreateSessionDescription:(RTC_OBJC_TYPE(RTCSessionDescription) *)sdp
                          error:(NSError *)error {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (error) {
     
      return;
    }
//
//    [self.peerConnection setLocalDescription:sdp
//                           completionHandler:^(NSError *error) {
//                             ARDAppClient *strongSelf = weakSelf;
//                             [strongSelf peerConnection:strongSelf.peerConnection
//                                 didSetSessionDescriptionWithError:error];
//                           }];
//    ARDSessionDescriptionMessage *message =
//        [[ARDSessionDescriptionMessage alloc] initWithDescription:sdp];
//    [self sendSignalingMessage:message];
//    [self setMaxBitrateForPeerConnectionVideoSender];
  });
}

- (void)peerConnection:(RTC_OBJC_TYPE(RTCPeerConnection) *)peerConnection
    didSetSessionDescriptionWithError:(NSError *)error {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (error) {
//      RTCLogError(@"Failed to set session description. Error: %@", error);
//      [self disconnect];
//      NSDictionary *userInfo = @{
//        NSLocalizedDescriptionKey: @"Failed to set session description.",
//      };
//      NSError *sdpError =
//          [[NSError alloc] initWithDomain:kARDAppClientErrorDomain
//                                     code:kARDAppClientErrorSetSDP
//                                 userInfo:userInfo];
//      [self.delegate appClient:self didError:sdpError];
      return;
    }
    // If we're answering and we've just set the remote offer we need to create
    // an answer and set the local description.
//    if (!self.isInitiator && !self.peerConnection.localDescription) {
//      RTC_OBJC_TYPE(RTCMediaConstraints) *constraints = [self defaultAnswerConstraints];
//      __weak ARDAppClient *weakSelf = self;
//      [self.peerConnection
//          answerForConstraints:constraints
//             completionHandler:^(RTC_OBJC_TYPE(RTCSessionDescription) * sdp, NSError * error) {
//               ARDAppClient *strongSelf = weakSelf;
//               [strongSelf peerConnection:strongSelf.peerConnection
//                   didCreateSessionDescription:sdp
//                                         error:error];
//             }];
//    }
  });
}




#pragma mark--RTCDataChannelDelegate

/** The data channel state changed. */
- (void)dataChannelDidChangeState:(RTCDataChannel *)dataChannel
{
    // NSLog(@" ");

    // NSLog(@"**********  -------           dataChannelDidChangeState ");

    
    // NSLog(@"%s",__func__);
    // NSLog(@" ");

    // NSLog(@"channel.state %ld",(long)dataChannel.readyState);
    // NSLog(@" ");
    
    NSString *currentId = [self getKeyFromDataChannelDic: dataChannel];


    if (dataChannel.readyState == 1){
        NSMutableDictionary * event = [NSMutableDictionary dictionary];
        
        [event setValue:@"online" forKey:@"state"];
        [event setValue:currentId forKey:@"userID"];

        [self fireEvent:@"datachannel" withObject:event];

    }
    
}

/** The data channel successfully received a data buffer. */
- (void)dataChannel:(RTCDataChannel *)dataChannel didReceiveMessageWithBuffer:(RTCDataBuffer *)buffer
{
    // NSLog(@" ");

    
    // NSLog(@"-------           Received remote data message ");

    // NSLog(@" ");

    // NSLog(@"%s",__func__);
    NSString *message = [[NSString alloc] initWithData:buffer.data encoding:NSUTF8StringEncoding];
    //// NSLog(@"message:%@",message);
    dispatch_async(dispatch_get_main_queue(), ^{
//        if ([_chatdelegate respondsToSelector:@selector(webRTCHelper:receiveMessage:)])
//        {
//            [_chatdelegate webRTCHelper:self receiveMessage:message];
//        }
        
        NSString *currentId = [self getKeyFromDataChannelDic: dataChannel];

        NSMutableDictionary * event = [NSMutableDictionary dictionary];
        
        [event setValue:message
                 forKey:@"message"];
    
        [event setValue:[TiUtils stringValue:currentId]
                 forKey:@"session"];
        
        [self fireEvent:@"remotemessage" withObject:event];
        
    });
    
}



#pragma mark - STUNClientDelegate

-(void)didReceivePublicIPandPort:(NSDictionary *) data{
    // NSLog(@"Public IP=%@, public Port=%@, NAT is Symmetric: %@", [data objectForKey:publicIPKey],
    //      [data objectForKey:publicPortKey], [data objectForKey:isPortRandomization]);
    
//    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:@"result"
//                                                                               message:[data description]
//                                                                        preferredStyle:UIAlertControllerStyleAlert ];
//    UIAlertAction* ok = [UIAlertAction
//                         actionWithTitle:@"OK"
//                         style:UIAlertActionStyleDefault
//                         handler:^(UIAlertAction * action)
//                         {
//                             //Do some thing here, eg dismiss the alertwindow
//                             [myAlertController dismissViewControllerAnimated:YES completion:nil];
//
//                         }];
//    [myAlertController addAction: ok];
//    [[self topMostController] presentViewController:myAlertController animated:YES completion:nil];
    
    
 //   [epr registerApp:_uuid _ip:[data objectForKey:publicIPKey] _port:[data objectForKey:publicPortKey]];
    
    NSMutableDictionary * event = [NSMutableDictionary dictionary];


    
    [event setValue:[data objectForKey:publicIPKey]
             forKey:@"ip"];
    
    
    [event setValue:[data objectForKey:publicPortKey]
             forKey:@"port"];
    
    
    [self fireEvent:@"publicAddress" withObject:event];
    
    
    [stunClient startSendIndicationMessage];
}

//- (id)createController:(id)args{
////    return [[TiBottomsheetcontrollerProxy alloc] _initWithPageContext:[self executionContext] args:args];
//    return [[DeMarcbenderWebrtcViewProxy alloc] _initWithPageContext:[self executionContext] args:args];
//}




#pragma mark - ARDVideoCallViewDelegate


- (void)viewControllerDidFinish:(ARDVideoCallViewController *)viewController {
    
    [self->_peerConnection close];

}



- (void)videoCallViewSwitchCamera:(ARDVideoCallViewController *)viewController {
  // TODO(tkchin): Rate limit this so you can't tap continously on it.
  // Probably through an animation.
  //[_captureController switchCamera];
    
    // NSLog(@"[WARN] ###################################   videoCallViewSwitchCamera");
    _captureController.isFrontCamera = !_usingFrontCamera;
    [_captureController switchCamera];
}





//
//
//#pragma mark - swap camera
//- (RTCVideoTrack *)createLocalVideoTrackBackCamera {
//    RTCVideoTrack *localVideoTrack = nil;
//#if !TARGET_IPHONE_SIMULATOR && TARGET_OS_IPHONE
//    //AVCaptureDevicePositionFront
//    NSString *cameraID = nil;
//    for (AVCaptureDevice *captureDevice in
//         [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
//        if (captureDevice.position == AVCaptureDevicePositionBack) {
//            cameraID = [captureDevice localizedName];
//            break;
//        }
//    }
//
//    RTCVideoCapturer *capturer = [RTCVideoCapturer capturerWithDeviceName:cameraID];
//    RTCMediaConstraints *mediaConstraints = [self defaultMediaStreamConstraints];
//    RTCVideoSource *videoSource = [_factory videoSourceWithCapturer:capturer constraints:mediaConstraints];
//    localVideoTrack = [_factory videoTrackWithID:@"ARDAMSv0" source:videoSource];
//#endif
//    return localVideoTrack;
//}
//- (void)swapCameraToFront{
//    RTCMediaStream *localStream = _peerConnection.localStreams[0];
//    [localStream removeVideoTrack:localStream.videoTracks[0]];
//
//    RTCVideoTrack *localVideoTrack = [self createLocalVideoTrack];
//
//    if (localVideoTrack) {
//        [localStream addVideoTrack:localVideoTrack];
//        [_delegate appClient:self didReceiveLocalVideoTrack:localVideoTrack];
//    }
//    [_peerConnection removeStream:localStream];
//    [_peerConnection addStream:localStream];
//}
//- (void)swapCameraToBack{
//    RTCMediaStream *localStream = _peerConnection.localStreams[0];
//    [localStream removeVideoTrack:localStream.videoTracks[0]];
//
//    RTCVideoTrack *localVideoTrack = [self createLocalVideoTrackBackCamera];
//
//    if (localVideoTrack) {
//        [localStream addVideoTrack:localVideoTrack];
//        [_delegate appClient:self didReceiveLocalVideoTrack:localVideoTrack];
//    }
//    [_peerConnection removeStream:localStream];
//    [_peerConnection addStream:localStream];
//}
//


@end


