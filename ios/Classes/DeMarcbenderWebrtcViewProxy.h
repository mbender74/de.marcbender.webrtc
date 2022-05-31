#import <TitaniumKit/TiViewProxy.h>
#import <TitaniumKit/TiProxy.h>
#import <TitaniumKit/TiUIView.h>
#import <TitaniumKit/TitaniumKit.h>
#import <TitaniumKit/TiUtils.h>

@interface DeMarcbenderWebrtcView: TiUIView {

}
@end


@interface DeMarcbenderWebrtcViewProxy: TiViewProxy {
    DeMarcbenderWebrtcView *webRTCView;
}
- (DeMarcbenderWebrtcView *)getWebRTCView;
- (void)putWebRTCView:(DeMarcbenderWebrtcView *)view;

@end


