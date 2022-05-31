/*
 *  Copyright 2015 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

package de.marcbender.webrtc;

import android.annotation.TargetApi;
import android.app.Activity;
import android.app.AlertDialog;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;
import org.appcelerator.titanium.TiApplication;
import androidx.appcompat.app.AppCompatActivity;
import androidx.activity.result.*;
import androidx.activity.result.contract.*;
import android.util.AttributeSet;
import org.appcelerator.titanium.TiRootActivity;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.TiC;
import org.appcelerator.kroll.common.TiConfig;
import org.appcelerator.titanium.util.TiConvert;
import org.appcelerator.titanium.util.TiPropertyResolver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.media.projection.MediaProjection;
import android.media.projection.MediaProjectionManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.view.WindowManager.LayoutParams;
import android.widget.Toast;
import java.io.IOException;
import java.lang.RuntimeException;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import android.os.Parcelable;
import android.content.res.Resources;
import org.webrtc.RTCStatsReport;

import de.marcbender.webrtc.AppRTCAudioManager;
import de.marcbender.webrtc.AppRTCAudioManager.AudioDevice;
import de.marcbender.webrtc.AppRTCAudioManager.AudioManagerEvents;
import de.marcbender.webrtc.AppRTCClient;
import de.marcbender.webrtc.AppRTCClient.RoomConnectionParameters;
import de.marcbender.webrtc.AppRTCClient.SignalingParameters;
import de.marcbender.webrtc.DirectRTCClient;
import de.marcbender.webrtc.PeerConnectionClient;
import de.marcbender.webrtc.PeerConnectionClient.DataChannelParameters;
import de.marcbender.webrtc.PeerConnectionClient.PeerConnectionParameters;
import de.marcbender.webrtc.UnhandledExceptionHandler;
import org.webrtc.PeerConnection;
import org.webrtc.PeerConnection.IceConnectionState;

import org.webrtc.Camera1Enumerator;
import org.webrtc.Camera2Enumerator;
import org.webrtc.CameraEnumerator;
import org.webrtc.EglBase;
import org.webrtc.FileVideoCapturer;
import org.webrtc.IceCandidate;
import org.webrtc.Logging;
import org.webrtc.PeerConnectionFactory;
import org.webrtc.RendererCommon.ScalingType;
import org.webrtc.ScreenCapturerAndroid;
import org.webrtc.SessionDescription;
import org.webrtc.SurfaceViewRenderer;
import org.webrtc.VideoCapturer;
import org.webrtc.VideoFileRenderer;
import org.webrtc.VideoFrame;
import org.webrtc.VideoSink;
import org.appcelerator.titanium.proxy.TiViewProxy;
import de.marcbender.webrtc.ViewProxy;
import android.view.LayoutInflater;
import android.widget.FrameLayout;
import android.view.SurfaceView;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView;
import android.opengl.GLSurfaceView.Renderer;
import javax.microedition.khronos.opengles.GL10;

/**
 * Activity for peer connection call setup, call waiting
 * and call view.
 */

public class CallActivity extends FrameLayout implements AppRTCClient.SignalingEvents,
                                                      PeerConnectionClient.PeerConnectionEvents {



// public class CallActivity extends AppCompatActivity implements AppRTCClient.SignalingEvents,
//                                                       PeerConnectionClient.PeerConnectionEvents,
//                                                       CallFragment.OnCallEvents {
  private static final String TAG = "CallRTCClient";
  public ViewProxy VIEW_PROXY = null;

  public static final String EXTRA_ROOMID = "ROOMID";
  public static final String EXTRA_URLPARAMETERS = "URLPARAMETERS";
  public static final String EXTRA_LOOPBACK = "LOOPBACK";
  public static final String EXTRA_VIDEO_CALL = "VIDEO_CALL";
  public static final String EXTRA_SCREENCAPTURE = "SCREENCAPTURE";
  public static final String EXTRA_CAMERA2 = "CAMERA2";
  public static final String EXTRA_VIDEO_WIDTH = "VIDEO_WIDTH";
  public static final String EXTRA_VIDEO_HEIGHT = "VIDEO_HEIGHT";
  public static final String EXTRA_VIDEO_FPS = "VIDEO_FPS";
  public static final String EXTRA_VIDEO_CAPTUREQUALITYSLIDER_ENABLED =
      "VIDEO_CAPTUREQUALITYSLIDER";
  public static final String EXTRA_VIDEO_BITRATE = "VIDEO_BITRATE";
  public static final String EXTRA_VIDEOCODEC = "VIDEOCODEC";
  public static final String EXTRA_HWCODEC_ENABLED = "HWCODEC";
  public static final String EXTRA_CAPTURETOTEXTURE_ENABLED = "CAPTURETOTEXTURE";
  public static final String EXTRA_FLEXFEC_ENABLED = "FLEXFEC";
  public static final String EXTRA_AUDIO_BITRATE = "AUDIO_BITRATE";
  public static final String EXTRA_AUDIOCODEC = "AUDIOCODEC";
  public static final String EXTRA_NOAUDIOPROCESSING_ENABLED =
      "NOAUDIOPROCESSING";
  public static final String EXTRA_AECDUMP_ENABLED = "AECDUMP";
  public static final String EXTRA_SAVE_INPUT_AUDIO_TO_FILE_ENABLED =
      "SAVE_INPUT_AUDIO_TO_FILE";
  public static final String EXTRA_OPENSLES_ENABLED = "OPENSLES";
  public static final String EXTRA_DISABLE_BUILT_IN_AEC = "DISABLE_BUILT_IN_AEC";
  public static final String EXTRA_DISABLE_BUILT_IN_AGC = "DISABLE_BUILT_IN_AGC";
  public static final String EXTRA_DISABLE_BUILT_IN_NS = "DISABLE_BUILT_IN_NS";
  public static final String EXTRA_DISABLE_WEBRTC_AGC_AND_HPF =
      "DISABLE_WEBRTC_GAIN_CONTROL";
  public static final String EXTRA_DISPLAY_HUD = "DISPLAY_HUD";
  public static final String EXTRA_TRACING = "TRACING";
  public static final String EXTRA_CMDLINE = "CMDLINE";
  public static final String EXTRA_RUNTIME = "RUNTIME";
  public static final String EXTRA_VIDEO_FILE_AS_CAMERA = "VIDEO_FILE_AS_CAMERA";
  public static final String EXTRA_SAVE_REMOTE_VIDEO_TO_FILE =
      "SAVE_REMOTE_VIDEO_TO_FILE";
  public static final String EXTRA_SAVE_REMOTE_VIDEO_TO_FILE_WIDTH =
      "SAVE_REMOTE_VIDEO_TO_FILE_WIDTH";
  public static final String EXTRA_SAVE_REMOTE_VIDEO_TO_FILE_HEIGHT =
      "SAVE_REMOTE_VIDEO_TO_FILE_HEIGHT";
  public static final String EXTRA_USE_VALUES_FROM_INTENT =
      "USE_VALUES_FROM_INTENT";
  public static final String EXTRA_DATA_CHANNEL_ENABLED = "DATA_CHANNEL_ENABLED";
  public static final String EXTRA_ORDERED = "ORDERED";
  public static final String EXTRA_MAX_RETRANSMITS_MS = "MAX_RETRANSMITS_MS";
  public static final String EXTRA_MAX_RETRANSMITS = "MAX_RETRANSMITS";
  public static final String EXTRA_PROTOCOL = "PROTOCOL";
  public static final String EXTRA_NEGOTIATED = "NEGOTIATED";
  public static final String EXTRA_ID = "ID";
  public static final String EXTRA_ENABLE_RTCEVENTLOG = "ENABLE_RTCEVENTLOG";
  public static final String EXTRA_USE_LEGACY_AUDIO_DEVICE =
      "USE_LEGACY_AUDIO_DEVICE";

  private static final int CAPTURE_PERMISSION_REQUEST_CODE = 1;

  // List of mandatory application permissions.
  private static final String[] MANDATORY_PERMISSIONS = {"android.permission.MODIFY_AUDIO_SETTINGS",
      "android.permission.RECORD_AUDIO", "android.permission.INTERNET"};

  // Peer connection statistics callback period in ms.
  private static final int STAT_CALLBACK_PERIOD = 1000;

  private static class ProxyVideoSink implements VideoSink {
    private VideoSink target;

    @Override
    synchronized public void onFrame(VideoFrame frame) {
      if (target == null) {
        ////Logging.d(TAG, "Dropping frame in proxy because target is null.");
        return;
      }

      target.onFrame(frame);
    }

    synchronized public void setTarget(VideoSink target) {
      this.target = target;
    }
  }

  private final ProxyVideoSink remoteProxyRenderer = new ProxyVideoSink();
  private final ProxyVideoSink localProxyVideoSink = new ProxyVideoSink();
  
  private PeerConnectionClient peerConnectionClient = null;
  
  private AppRTCClient appRtcClient;
  
  private SignalingParameters signalingParameters;
  
  private AppRTCAudioManager audioManager = null;
  
  private SurfaceViewRenderer pipRenderer;
  
  private SurfaceViewRenderer fullscreenRenderer;
  
  private VideoFileRenderer videoFileRenderer;
  private final List<VideoSink> remoteSinks = new ArrayList<>();
  private Toast logToast;
  private boolean commandLineRun;
  private boolean activityRunning;
  public RoomConnectionParameters roomConnectionParameters;
  
  public PeerConnectionParameters peerConnectionParameters;
  private boolean iceConnected;
  private boolean isError;
  private boolean callControlFragmentVisible = true;
  private long callStartedTimeMs = 0;
  private boolean micEnabled = true;
  private boolean screencaptureEnabled = false;
  private static Intent mediaProjectionPermissionResultData;
  private static int mediaProjectionPermissionResultCode;
  // True if local view is in the fullscreen renderer.
  private boolean isSwappedFeeds;

  // Controls
  // private CallFragment callFragment;
  // private CpuMonitor cpuMonitor;
  private KrollDict callProperties;
  public TiPropertyResolver propertyresolv;
  private static Context callActivityContext;
  private   View viewWrapper;
  // private   View callFragmentView;
 private    int resId_viewHolder;
//  private    int id_callFragment;
  private   int id_pipRenderer;
  private   int id_fullscreenRenderer;



  public static Context getCallViewContext() {
      return callActivityContext;
  }






	public CallActivity(Context context) {
		this(context, null);
	}

	public CallActivity(Context context, AttributeSet attrs) {
		this(context, attrs, 0);
	}

	public CallActivity(Context context, AttributeSet attrs, int defStyle) {
		super(context, attrs, defStyle);
    this.callActivityContext = context;
    //Thread.setDefaultUncaughtExceptionHandler(new UnhandledExceptionHandler(this));
    VIEW_PROXY = ViewProxy.getInstance();
    //ViewProxy.getInstance().putCallActivity(this);




    // Set window styles for fullscreen-window size. Needs to be done before
    // adding content.
    // requestWindowFeature(Window.FEATURE_NO_TITLE);
    // getWindow().addFlags(LayoutParams.FLAG_FULLSCREEN | LayoutParams.FLAG_KEEP_SCREEN_ON
    //     | LayoutParams.FLAG_SHOW_WHEN_LOCKED | LayoutParams.FLAG_TURN_SCREEN_ON);
    // getWindow().getDecorView().setSystemUiVisibility(getSystemUiVisibility());

    String packageName = ViewProxy.getInstance().getActivity().getPackageName();
    Resources resources = ViewProxy.getInstance().getActivity().getResources();

    // resId_viewHolder = resources.getIdentifier("activity_call", "layout", packageName);

    // LayoutInflater inflater = LayoutInflater.from(ViewProxy.getInstance().getActivity());
    // viewWrapper = inflater.inflate(resId_viewHolder, null);

    // id_callFragment = resources.getIdentifier("call_fragment_container", "id", packageName);
    id_pipRenderer = resources.getIdentifier("pip_video_view", "id", packageName);
    id_fullscreenRenderer = resources.getIdentifier("fullscreen_video_view", "id", packageName);

    // callFragmentView = viewWrapper.findViewById(id_callFragment);
    // hudFragmentView = viewWrapper.findViewById(id_hudFragment);
    //  callFragmentView.setId(100001);
    //  hudFragmentView.setId(100002);

    // String colorstring = "#000000";
		// viewWrapper.setBackgroundColor(TiConvert.toColor(colorstring));



    //ViewProxy.getInstance().getContentView().addNativeView(viewWrapper);

    //setContentView(viewWrapper);
    

    // setupCallView(context);

  }


  public void setProperties(KrollDict properties) {
      this.callProperties = properties;
              //Log.d(TAG, "\n\n\n +++++++++++++++++++++++++    setProperties: ");

  }



  // @TargetApi(17)
  // private DisplayMetrics getDisplayMetrics() {
  //   DisplayMetrics displayMetrics = new DisplayMetrics();
  //   WindowManager windowManager =
  //       (WindowManager) getApplication().getSystemService(Context.WINDOW_SERVICE);
  //   windowManager.getDefaultDisplay().getRealMetrics(displayMetrics);
  //   return displayMetrics;
  // }

  // @TargetApi(19)
  // private static int getSystemUiVisibility() {
  //   int flags = View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_FULLSCREEN;
  //   if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
  //     flags |= View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY;
  //   }
  //   return flags;
  // }

  // @TargetApi(21)
  // private void startScreenCapture() {
  //   MediaProjectionManager mediaProjectionManager =
  //       (MediaProjectionManager) TiApplication.getInstance().getCurrentActivity().getApplication().getSystemService(
  //           Context.MEDIA_PROJECTION_SERVICE);

  //     getResult.launch(mediaProjectionManager.createScreenCaptureIntent());

  //   // startActivityForResult(
  //   //     mediaProjectionManager.createScreenCaptureIntent(), CAPTURE_PERMISSION_REQUEST_CODE);
  // }


  // ActivityResultLauncher<Intent> getResult =  TiApplication.getInstance().getRootActivity().registerForActivityResult(
  //       new ActivityResultContracts.StartActivityForResult(),
  //       new ActivityResultCallback<ActivityResult>() {
  //           @Override
  //           public void onActivityResult(ActivityResult result) {
  //               if (result.getResultCode() != CAPTURE_PERMISSION_REQUEST_CODE) {
  //                   // There are no request codes
  //                   // Intent data = result.getData();
  //                   // doSomeOperations();
  //                         return;
  //               }
  //               else {
  //                     Intent data = result.getData();
  //                     mediaProjectionPermissionResultCode = result.getResultCode();
  //                     mediaProjectionPermissionResultData = data;
  //                     startCall();
  //               }
  //           }
  // });


  public void setupCallView() {
              //Log.d(TAG, "\n\n\n +++++++++++++++++++++++++    setupCallView: ");

    // callFragmentView.addView(callFragment);
    // hudFragmentView.add(hudFragment);

    iceConnected = false;
    signalingParameters = null;

    // Create UI controls.
    pipRenderer = findViewById(id_pipRenderer);
    fullscreenRenderer = findViewById(id_fullscreenRenderer);
    // callFragment = new CallFragment();

 // Show/hide call control fragment on view click.
    View.OnClickListener listener = new View.OnClickListener() {
      @Override
      public void onClick(View view) {
//        toggleCallControlFragmentVisibility();
      }
    };

    // Swap feeds on pip view click.
    pipRenderer.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View view) {
        setSwappedFeeds(!isSwappedFeeds);
      }
    });

    fullscreenRenderer.setOnClickListener(listener);
    remoteSinks.add(remoteProxyRenderer);

    boolean callInitiator = TiConvert.toBoolean(this.callProperties.get("CALL_INITIATOR"), false);

    final EglBase eglBase = EglBase.create();

    // Create video renderers.
    pipRenderer.init(eglBase.getEglBaseContext(), null);
    pipRenderer.setScalingType(ScalingType.SCALE_ASPECT_FIT);

					// COLUMN_WIDTH = TiConvert.toInt(this.callProperties.get(EXTRA_SAVE_REMOTE_VIDEO_TO_FILE));

    String saveRemoteVideoToFile =  TiConvert.toString(this.callProperties.get(EXTRA_SAVE_REMOTE_VIDEO_TO_FILE));

    // When saveRemoteVideoToFile is set we save the video from the remote to a file.
    if (saveRemoteVideoToFile != null) {
      int videoOutWidth = TiConvert.toInt(this.callProperties.get(EXTRA_SAVE_REMOTE_VIDEO_TO_FILE_WIDTH), 0);
      int videoOutHeight = TiConvert.toInt(this.callProperties.get(EXTRA_SAVE_REMOTE_VIDEO_TO_FILE_HEIGHT), 0);
      try {
        videoFileRenderer = new VideoFileRenderer(
            saveRemoteVideoToFile, videoOutWidth, videoOutHeight, eglBase.getEglBaseContext());
        remoteSinks.add(videoFileRenderer);
      } catch (IOException e) {
        throw new RuntimeException(
            "Failed to open video file for output: " + saveRemoteVideoToFile, e);
      }
    }
    fullscreenRenderer.init(eglBase.getEglBaseContext(), null);
    fullscreenRenderer.setScalingType(ScalingType.SCALE_ASPECT_FILL);

    pipRenderer.setZOrderMediaOverlay(true);
    pipRenderer.setEnableHardwareScaler(true /* enabled */);
    fullscreenRenderer.setEnableHardwareScaler(false /* enabled */);
    // Start with local feed in fullscreen and swap it to the pip when the call is connected.
    setSwappedFeeds(true /* isSwappedFeeds */);

    // Check for mandatory permissions.
    for (String permission : MANDATORY_PERMISSIONS) {
      if (this.callActivityContext.checkCallingOrSelfPermission(permission) != PackageManager.PERMISSION_GRANTED) {
        logAndToast("Permission " + permission + " is not granted");
        //setResult(RESULT_CANCELED);
        //finish();
        return;
      }
    }

    // Uri roomUri = intent.getData();
    // if (roomUri == null) {
    //   logAndToast(getString(de.marcbender.webrtc.R.string.missing_url));
    //   //Log.e(TAG, "Didn't get any URL in intent!");
    //   //setResult(RESULT_CANCELED);
    //   //finish();
    //   return;
    // }




        //Log.d(TAG, "\n\n\n +++++++++++++++++++++++++    this.callProperties VideoCall: " + this.callProperties.get(EXTRA_VIDEO_CALL));


    // Get Intent parameters.
    String roomId = TiConvert.toString(this.callProperties.get(EXTRA_ROOMID));
    //Log.d(TAG, "Room ID: " + roomId);
    if (roomId == null || roomId.length() == 0) {
      logAndToast(TiApplication.getInstance().getString(de.marcbender.webrtc.R.string.missing_url));
      //Log.e(TAG, "Incorrect room ID in intent!");
      //setResult(RESULT_CANCELED);
      //finish();
      return;
    }

    boolean captureQualitySlider = TiConvert.toBoolean(this.callProperties.get(EXTRA_VIDEO_CAPTUREQUALITYSLIDER_ENABLED), false);

    boolean loopback = false;

//    boolean loopback = TiConvert.toBoolean(this.callProperties.get(EXTRA_LOOPBACK), false);
    boolean tracing = TiConvert.toBoolean(this.callProperties.get(EXTRA_TRACING), false);

    int videoWidth = TiConvert.toInt(this.callProperties.get(EXTRA_VIDEO_WIDTH), 0);
    int videoHeight = TiConvert.toInt(this.callProperties.get(EXTRA_VIDEO_HEIGHT), 0);

    screencaptureEnabled = TiConvert.toBoolean(this.callProperties.get(EXTRA_SCREENCAPTURE), false);
    // If capturing format is not specified for screencapture, use screen resolution.
    if (screencaptureEnabled && videoWidth == 0 && videoHeight == 0) {
      DisplayMetrics displayMetrics = this.callActivityContext.getResources().getDisplayMetrics();
      videoWidth = displayMetrics.widthPixels;
      videoHeight = displayMetrics.heightPixels;
    }
    DataChannelParameters dataChannelParameters = null;
    if (TiConvert.toBoolean(this.callProperties.get(EXTRA_DATA_CHANNEL_ENABLED), false)) {
      dataChannelParameters = new DataChannelParameters(TiConvert.toBoolean(this.callProperties.get(EXTRA_ORDERED), true),
          TiConvert.toInt(this.callProperties.get(EXTRA_MAX_RETRANSMITS_MS), -1),
          TiConvert.toInt(this.callProperties.get(EXTRA_MAX_RETRANSMITS), -1), TiConvert.toString(this.callProperties.get(EXTRA_PROTOCOL)),
          TiConvert.toBoolean(this.callProperties.get(EXTRA_NEGOTIATED), false), TiConvert.toInt(this.callProperties.get(EXTRA_ID), -1));
    }

    //Log.d(TAG, "\n\n\n ####################### peerConnectionParameters videoCall: " + TiConvert.toBoolean(this.callProperties.get(EXTRA_VIDEO_CALL), true) );


// PeerConnectionParameters(boolean videoCallEnabled, boolean loopback, boolean tracing,
//         int videoWidth, int videoHeight, int videoFps, int videoMaxBitrate, String videoCodec,
//         boolean videoCodecHwAcceleration, boolean videoFlexfecEnabled, int audioStartBitrate,
//         String audioCodec, boolean noAudioProcessing, boolean aecDump, boolean saveInputAudioToFile,
//         boolean useOpenSLES, boolean disableBuiltInAEC, boolean disableBuiltInAGC,
//         boolean disableBuiltInNS, boolean disableWebRtcAGCAndHPF, boolean enableRtcEventLog,
//         DataChannelParameters dataChannelParameters)

    peerConnectionParameters = new PeerConnectionParameters(TiConvert.toBoolean(this.callProperties.get(EXTRA_VIDEO_CALL), true), loopback,
            tracing, videoWidth, videoHeight, TiConvert.toInt(this.callProperties.get(EXTRA_VIDEO_FPS), 0),
            TiConvert.toInt(this.callProperties.get(EXTRA_VIDEO_BITRATE), 0), TiConvert.toString(this.callProperties.get(EXTRA_VIDEOCODEC)),
            TiConvert.toBoolean(this.callProperties.get(EXTRA_HWCODEC_ENABLED), true),
            TiConvert.toBoolean(this.callProperties.get(EXTRA_FLEXFEC_ENABLED), false),
            TiConvert.toInt(this.callProperties.get(EXTRA_AUDIO_BITRATE), 0), TiConvert.toString(this.callProperties.get(EXTRA_AUDIOCODEC)),
            TiConvert.toBoolean(this.callProperties.get(EXTRA_NOAUDIOPROCESSING_ENABLED), false),
            TiConvert.toBoolean(this.callProperties.get(EXTRA_AECDUMP_ENABLED), false),
            TiConvert.toBoolean(this.callProperties.get(EXTRA_SAVE_INPUT_AUDIO_TO_FILE_ENABLED), false),
            TiConvert.toBoolean(this.callProperties.get(EXTRA_OPENSLES_ENABLED), true),
            TiConvert.toBoolean(this.callProperties.get(EXTRA_DISABLE_BUILT_IN_AEC), false),
            TiConvert.toBoolean(this.callProperties.get(EXTRA_DISABLE_BUILT_IN_AGC), false),
            TiConvert.toBoolean(this.callProperties.get(EXTRA_DISABLE_BUILT_IN_NS), false),
            TiConvert.toBoolean(this.callProperties.get(EXTRA_DISABLE_WEBRTC_AGC_AND_HPF), false),
            TiConvert.toBoolean(this.callProperties.get(EXTRA_ENABLE_RTCEVENTLOG), false),
 dataChannelParameters);
    commandLineRun = TiConvert.toBoolean(this.callProperties.get(EXTRA_CMDLINE), false);
    int runTimeMs = TiConvert.toInt(this.callProperties.get(EXTRA_RUNTIME), 0);

    //Log.d(TAG, "VIDEO_FILE: '" + TiConvert.toString(this.callProperties.get(EXTRA_VIDEO_FILE_AS_CAMERA) + "'"));

    // Create connection client. Use DirectRTCClient if room name is an IP otherwise use the
    // standard WebSocketRTCClient.
    // if (loopback || !DirectRTCClient.IP_PATTERN.matcher(roomId).matches()) {
    //   appRtcClient = new WebSocketRTCClient(this);
    // } else {
      //Log.i(TAG, "Using DirectRTCClient because room name looks like an IP.");
      appRtcClient = new DirectRTCClient(this,VIEW_PROXY);
    //}
    // Create connection parameters.


    String urlParameters = "";
    roomConnectionParameters =
        new RoomConnectionParameters("no URL", roomId, loopback, callInitiator, urlParameters);


      //Log.i(TAG, "\n\n+++++++++++++++++++++++++++  roomConnectionParameters "+roomConnectionParameters.toString());


    // Create CPU monitor
    // if (CpuMonitor.isSupported()) {
    //   cpuMonitor = new CpuMonitor(this.callActivityContext);
    //   hudFragment.setCpuMonitor(cpuMonitor);
    // }

    // Send intent arguments to fragments.
    // Activate call and HUD fragments and start the call.
		// Bundle args = new Bundle();
		// args.putString(EXTRA_ROOMID, roomId);
		// args.putString(EXTRA_VIDEO_CALL, TiConvert.toString(this.callProperties.get(EXTRA_VIDEO_CALL)));
		// args.putString(EXTRA_VIDEO_CAPTUREQUALITYSLIDER_ENABLED, TiConvert.toString(captureQualitySlider));
		// callFragment.setArguments(args);



      // //Log.w(TAG, "callFragmentView.getId()  "+callFragmentView.getId());
      // //Log.w(TAG, "callFragmentView  "+callFragmentView);


    // Activity currentActivity = ViewProxy.getInstance().getActivity();
    // if (!(currentActivity instanceof AppCompatActivity)) {

    //   //Log.w(TAG, "currentActivity not AppCompatActivity  "+currentActivity);

		// 	return;
		// }
	//	AppCompatActivity appCompatActivity = ((AppCompatActivity) currentActivity);



    //FragmentManager fragmentManager = context.getSupportFragmentManager();
   // FragmentManager fragmentManager = appCompatActivity.getSupportFragmentManager();
    // FragmentManager fragmentManager = ((FragmentActivity)ViewProxy.getInstance().getActivity()).getSupportFragmentManager();

    // // FragmentTransaction ft = fragmentManager.beginTransaction();
    //fragmentManager.beginTransaction().add(id_hudFragment, hudFragment).commit();

    // fragmentManager.beginTransaction().add(id_callFragment, callFragment).commit();
    
    // ft.commit();

    // viewWrapper.addView(ll);


    // For command line execution run connection for <runTimeMs> and exit.
    if (commandLineRun && runTimeMs > 0) {
      (new Handler()).postDelayed(new Runnable() {
        @Override
        public void run() {
          disconnect();
        }
      }, runTimeMs);
    }

    // Create peer connection client.
    peerConnectionClient = new PeerConnectionClient(
       TiApplication.getInstance().getApplicationContext(), eglBase, peerConnectionParameters, this);
    PeerConnectionFactory.Options options = new PeerConnectionFactory.Options();
    if (loopback) {
      options.networkIgnoreMask = 0;
    }
    peerConnectionClient.createPeerConnectionFactory(options);

    // if (screencaptureEnabled) {
    //   startScreenCapture();
    // } else {
      startCall();
   // }




   

  }


  public PeerConnectionClient getPeerConnectionClient() {
      return peerConnectionClient;
  }

 public boolean switchSpeakerOn() {
    audioManager.setSpeakerphoneOn(true);
    return true;
  }
 public boolean switchSpeakerOff() {
    audioManager.setSpeakerphoneOn(false);
    return true;
  }
  

  public boolean unMuteRemoteAudio() {
    audioManager.setMicrophoneMute(false);
    return true;
  }

  public boolean muteRemoteAudio() {
    audioManager.setMicrophoneMute(true);
    return true;
  }

  private boolean useCamera2() {
    return Camera2Enumerator.isSupported(ViewProxy.getInstance().getActivity()) && TiConvert.toBoolean(this.callProperties.get(EXTRA_CAMERA2),true);
  }

  private boolean captureToTexture() {
    return TiConvert.toBoolean(this.callProperties.get(EXTRA_CAPTURETOTEXTURE_ENABLED),false);
  }

  private  VideoCapturer createCameraCapturer(CameraEnumerator enumerator) {
    final String[] deviceNames = enumerator.getDeviceNames();
    Logging.enableLogToDebugOutput(Logging.Severity.LS_NONE);

    // First, try to find front facing camera
    ////Logging.d(TAG, "Looking for front facing cameras.");
    for (String deviceName : deviceNames) {
      if (enumerator.isFrontFacing(deviceName)) {
        ////Logging.d(TAG, "Creating front facing camera capturer.");
        VideoCapturer videoCapturer = enumerator.createCapturer(deviceName, null);

        if (videoCapturer != null) {
          return videoCapturer;
        }
      }
    }

    // Front facing camera not found, try something else
    ////Logging.d(TAG, "Looking for other cameras.");
    for (String deviceName : deviceNames) {
      if (!enumerator.isFrontFacing(deviceName)) {
        //Logging.d(TAG, "Creating other camera capturer.");
        VideoCapturer videoCapturer = enumerator.createCapturer(deviceName, null);

        if (videoCapturer != null) {
          return videoCapturer;
        }
      }
    }

    return null;
  }

  @TargetApi(21)
  private  VideoCapturer createScreenCapturer() {
    if (mediaProjectionPermissionResultCode != Activity.RESULT_OK) {
      reportError("User didn't give permission to capture the screen.");
      return null;
    }
    return new ScreenCapturerAndroid(
        mediaProjectionPermissionResultData, new MediaProjection.Callback() {
      @Override
      public void onStop() {
        reportError("User revoked permission to capture the screen.");
      }
    });
  }

  // Activity interfaces
  public void onStop() {
//    super.onStop();

Log.e(TAG, "###################################  onStop()");


    activityRunning = false;
    // Don't stop the video when using screencapture to allow user to show other apps to the remote
    // end.
    if (peerConnectionClient != null && !screencaptureEnabled) {
      peerConnectionClient.stopVideoSource();
    }
    // if (cpuMonitor != null) {
    //   cpuMonitor.pause();
    // }
        ViewProxy.getWebRTCModule().fireEvent("closed",null);

  }

  public void onStart() {
    //super.onStart();


    Log.e(TAG, "###################################  onStart()");


    activityRunning = true;
    // Video is not paused for screencapture. See onPause.
    if (peerConnectionClient != null && !screencaptureEnabled) {
      peerConnectionClient.startVideoSource();
    }
    // if (cpuMonitor != null) {
    //   cpuMonitor.resume();
    // }
  }

  protected void onDestroy() {
    //Thread.setDefaultUncaughtExceptionHandler(null);
    disconnect();
    if (logToast != null) {
      logToast.cancel();
    }
    activityRunning = false;
    //super.onDestroy();
  }

  // CallFragment.OnCallEvents interface implementation.
//  @Override
  public void onCallHangUp() {
    disconnect();
  }

 // @Override
  public void onCameraSwitch() {
    if (peerConnectionClient != null) {
      peerConnectionClient.switchCamera();
    }
  }

 // @Override
  public void onVideoScalingSwitch(ScalingType scalingType) {
    fullscreenRenderer.setScalingType(scalingType);
  }

 // @Override
  public void onCaptureFormatChange(int width, int height, int framerate) {
    if (peerConnectionClient != null) {
      peerConnectionClient.changeCaptureFormat(width, height, framerate);
    }
  }

 // @Override
  public boolean onToggleMic() {
    if (peerConnectionClient != null) {
      micEnabled = !micEnabled;
      peerConnectionClient.setAudioEnabled(micEnabled);
    }
    return micEnabled;
  }

  // Helper functions.
  // private void toggleCallControlFragmentVisibility() {
  //   if (!iceConnected || !callFragment.isAdded()) {
  //     return;
  //   }
  //   // // Show/hide call control fragment
  //   // callControlFragmentVisible = !callControlFragmentVisible;

  //   // FragmentManager fragmentManager = ((FragmentActivity) getContext()).getSupportFragmentManager();


    
  //   // if (callControlFragmentVisible) {
  //   //   fragmentManager.beginTransaction().show(callFragment).commit();
  //   // } else {
  //   //   fragmentManager.beginTransaction().hide(callFragment).commit();
  //   // }
  // }

  private void startCall() {
    if (appRtcClient == null) {
      //Log.e(TAG, "AppRTC client is not allocated for a call.");
      return;
    }

    ViewProxy.getInstance().appRTCClient(appRtcClient);

    callStartedTimeMs = System.currentTimeMillis();

    // Start room connection.
    logAndToast(TiApplication.getInstance().getString(de.marcbender.webrtc.R.string.connecting_to, roomConnectionParameters.roomUrl));
    appRtcClient.connectToRoom(roomConnectionParameters);

    // Create and audio manager that will take care of audio routing,
    // audio modes, audio device enumeration etc.
    audioManager = AppRTCAudioManager.create(TiApplication.getInstance().getApplicationContext());
    // Store existing audio settings and change audio mode to
    // MODE_IN_COMMUNICATION for best possible VoIP performance.
    //Log.d(TAG, "Starting the audio manager...");
    audioManager.start(new AudioManagerEvents() {
      // This method will be called each time the number of available audio
      // devices has changed.
      @Override
      public void onAudioDeviceChanged(
          AudioDevice audioDevice, Set<AudioDevice> availableAudioDevices) {
        onAudioManagerDevicesChanged(audioDevice, availableAudioDevices);
      }
    });
  }

  // Should be called from UI thread
  private void callConnected() {
    final long delta = System.currentTimeMillis() - callStartedTimeMs;
    //Log.i(TAG, "Call connected: delay=" + delta + "ms");
    if (peerConnectionClient == null || isError) {
      //Log.w(TAG, "Call is connected in closed or error state");
      return;
    }
    // Enable statistics callback.
    peerConnectionClient.enableStatsEvents(true, STAT_CALLBACK_PERIOD);
    setSwappedFeeds(false /* isSwappedFeeds */);

  }

  // This method is called when the audio manager reports audio device change,
  // e.g. from wired headset to speakerphone.
  private void onAudioManagerDevicesChanged(
      final AudioDevice device, final Set<AudioDevice> availableDevices) {
    //Log.d(TAG, "onAudioManagerDevicesChanged: " + availableDevices + ", "
  //            + "selected: " + device);
    // TODO(henrika): add callback handler.
  }

  // Disconnect from remote resources, dispose of local resources, and exit.
  private void disconnect() {
    ViewProxy.getWebRTCModule().fireEvent("closed",null);

    activityRunning = false;
    remoteProxyRenderer.setTarget(null);
    localProxyVideoSink.setTarget(null);
    if (appRtcClient != null) {
      appRtcClient.disconnectFromRoom();
      appRtcClient = null;
    }
    if (pipRenderer != null) {
      pipRenderer.release();
      pipRenderer = null;
    }
    if (videoFileRenderer != null) {
      videoFileRenderer.release();
      videoFileRenderer = null;
    }
    if (fullscreenRenderer != null) {
      fullscreenRenderer.release();
      fullscreenRenderer = null;
    }
    if (peerConnectionClient != null) {
      peerConnectionClient.close();
      peerConnectionClient = null;
    }
    if (audioManager != null) {
      audioManager.stop();
      audioManager = null;
    }
    if (iceConnected && !isError) {
      //setResult(RESULT_OK);
    } else {
      //setResult(RESULT_CANCELED);
    }
    //finish();
  }

  private void disconnectWithErrorMessage(final String errorMessage) {
    if (commandLineRun || !activityRunning) {
      //Log.e(TAG, "Critical error: " + errorMessage);
      disconnect();
    } else {
      // new AlertDialog.Builder(ViewProxy.getInstance().getActivity())
      //     .setTitle(TiApplication.getInstance().getString(de.marcbender.webrtc.R.string.channel_error_title))
      //     .setMessage(errorMessage)
      //     .setCancelable(false)
      //     .setNeutralButton(de.marcbender.webrtc.R.string.ok,
      //         new DialogInterface.OnClickListener() {
      //           @Override
      //           public void onClick(DialogInterface dialog, int id) {
      //             dialog.cancel();
      //             disconnect();
      //           }
      //         })
      //     .create()
      //     .show();
    }
  }

  // Log |msg| and Toast about it.
  public void logAndToast(String msg) {
    //Log.d(TAG, msg);
    // if (logToast != null) {
    //   logToast.cancel();
    // }
    // logToast = Toast.makeText(ViewProxy.getInstance().getActivity(), msg, Toast.LENGTH_SHORT);
    // logToast.show();
  }

  private void reportError(final String description) {
    ViewProxy.getInstance().getActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        if (!isError) {
          isError = true;
          disconnectWithErrorMessage(description);
        }
      }
    });
  }

  private  VideoCapturer createVideoCapturer() {
    final VideoCapturer videoCapturer;
    String videoFileAsCamera = TiConvert.toString(this.callProperties.get(EXTRA_VIDEO_FILE_AS_CAMERA));
    if (videoFileAsCamera != null) {
      try {
        videoCapturer = new FileVideoCapturer(videoFileAsCamera);
      } catch (IOException e) {
        reportError("Failed to open video file for emulated camera");
        return null;
      }
    } else if (screencaptureEnabled) {
      return createScreenCapturer();
    } else if (useCamera2()) {
      if (!captureToTexture()) {
        reportError(TiApplication.getInstance().getString(de.marcbender.webrtc.R.string.camera2_texture_only_error));
        return null;
      }

      ////Logging.d(TAG, "Creating capturer using camera2 API.");
      videoCapturer = createCameraCapturer(new Camera2Enumerator(ViewProxy.getInstance().getActivity()));
    } else {
      ////Logging.d(TAG, "Creating capturer using camera1 API.");
      videoCapturer = createCameraCapturer(new Camera1Enumerator(captureToTexture()));
    }
    if (videoCapturer == null) {
      reportError("Failed to open camera");
      return null;
    }
    return videoCapturer;
  }

  private void setSwappedFeeds(boolean isSwappedFeeds) {
    ////Logging.d(TAG, "setSwappedFeeds: " + isSwappedFeeds);
    this.isSwappedFeeds = isSwappedFeeds;
    localProxyVideoSink.setTarget(isSwappedFeeds ? fullscreenRenderer : pipRenderer);
    remoteProxyRenderer.setTarget(isSwappedFeeds ? pipRenderer : fullscreenRenderer);
    fullscreenRenderer.setMirror(isSwappedFeeds);
    pipRenderer.setMirror(!isSwappedFeeds);

    if (isSwappedFeeds == false){
      //ViewProxy.getWebRTCModule().fireEvent("dialSuccess",null);
    }

  }

  // -----Implementation of AppRTCClient.AppRTCSignalingEvents ---------------
  // All callbacks are invoked from websocket signaling looper thread and
  // are routed to UI thread.
  private void onConnectedToRoomInternal(final SignalingParameters params) {
    final long delta = System.currentTimeMillis() - callStartedTimeMs;

    signalingParameters = params;
    logAndToast("Creating peer connection, delay=" + delta + "ms");
    VideoCapturer videoCapturer = null;

    if (peerConnectionParameters.videoCallEnabled) {
      videoCapturer = createVideoCapturer();
    }


      //Log.d(TAG, "####################   localProxyVideoSink "+localProxyVideoSink);
      //Log.d(TAG, "####################   remoteSinks "+remoteSinks);
      //Log.d(TAG, "####################   videoCapturer "+videoCapturer);
      //Log.d(TAG, "####################   signalingParameters "+signalingParameters);


    peerConnectionClient.createPeerConnection(localProxyVideoSink, remoteSinks, videoCapturer, signalingParameters);

    if (signalingParameters.initiator) {
      logAndToast("Creating OFFER...");
      // Create offer. Offer SDP will be sent to answering client in
      // PeerConnectionEvents.onLocalDescription event.
      peerConnectionClient.createOffer();
    } else {
      if (params.offerSdp != null) {
        peerConnectionClient.setRemoteDescription(params.offerSdp);
        logAndToast("Creating ANSWER...");
        // Create answer. Answer SDP will be sent to offering client in
        // PeerConnectionEvents.onLocalDescription event.
        peerConnectionClient.createAnswer();
      }
      if (params.iceCandidates != null) {
        // Add remote ICE candidates from room.
        for (IceCandidate iceCandidate : params.iceCandidates) {
          peerConnectionClient.addRemoteIceCandidate(iceCandidate);
        }
      }
    }
  }


  @Override
  public void onDisconnected() {
    ViewProxy.getInstance().getActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        ViewProxy.getWebRTCModule().fireEvent("closed",null);
      }
    });
  }

  @Override
  public void onConnected() {
    ViewProxy.getInstance().getActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
            ViewProxy.getWebRTCModule().fireEvent("dialSuccess",null);
      }
    });
  }

  @Override
  public void onConnectedToRoom(final SignalingParameters params) {
    ViewProxy.getInstance().getActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        onConnectedToRoomInternal(params);
      }
    });
  }

  @Override
  public void onRemoteDescription(final SessionDescription sdp) {
    final long delta = System.currentTimeMillis() - callStartedTimeMs;
    ViewProxy.getInstance().getActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        if (peerConnectionClient == null) {
          //Log.e(TAG, "Received remote SDP for non-initilized peer connection.");
          return;
        }
        logAndToast("Received remote " + sdp.type + ", delay=" + delta + "ms");
        peerConnectionClient.setRemoteDescription(sdp);
        if (!signalingParameters.initiator) {
          logAndToast("Creating ANSWER...");
          // Create answer. Answer SDP will be sent to offering client in
          // PeerConnectionEvents.onLocalDescription event.
          peerConnectionClient.createAnswer();
        }
      }
    });
  }

  @Override
  public void onRemoteIceCandidate(final IceCandidate candidate) {
    ViewProxy.getInstance().getActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        if (peerConnectionClient == null) {
          //Log.e(TAG, "Received ICE candidate for a non-initialized peer connection.");
          return;
        }
        peerConnectionClient.addRemoteIceCandidate(candidate);
      }
    });
  }

  @Override
  public void onRemoteIceCandidatesRemoved(final IceCandidate[] candidates) {
    ViewProxy.getInstance().getActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        if (peerConnectionClient == null) {
          //Log.e(TAG, "Received ICE candidate removals for a non-initialized peer connection.");
          return;
        }
        peerConnectionClient.removeRemoteIceCandidates(candidates);
      }
    });
  }

  @Override
  public void onChannelClose() {
    ViewProxy.getInstance().getActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        ViewProxy.getWebRTCModule().fireEvent("closed",null);

        logAndToast("Remote end hung up; dropping PeerConnection");
        disconnect();
      }
    });
  }



  @Override
  public void onChannelError(final String description) {
    reportError(description);
  }

  // -----Implementation of PeerConnectionClient.PeerConnectionEvents.---------
  // Send local peer connection SDP and ICE candidates to remote party.
  // All callbacks are invoked from peer connection client looper thread and
  // are routed to UI thread.
  @Override
  public void onLocalDescription(final SessionDescription sdp) {
    final long delta = System.currentTimeMillis() - callStartedTimeMs;
    ViewProxy.getInstance().getActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        if (appRtcClient != null) {
          logAndToast("Sending " + sdp.type + ", delay=" + delta + "ms");
          if (signalingParameters.initiator) {
              Log.d(TAG, "\n\n\n ++++++++++++++++++ onLocalDescription: ");
              if (peerConnectionClient.getPeerConnection().getLocalDescription() != null) {
                //appRtcClient.sendAnswerSdp(sdp);
                appRtcClient.sendOfferSdp(sdp);
              }
              else {
                  //appRtcClient.sendOfferSdp(sdp);
                  appRtcClient.sendAnswerSdp(sdp);
              }
          } 
          else {
              if (peerConnectionClient.getPeerConnection().getRemoteDescription() == null) {
                appRtcClient.sendOfferSdp(sdp);
              }
              else {
                appRtcClient.sendAnswerSdp(sdp);
              }
          }
        }
        if (peerConnectionParameters.videoMaxBitrate > 0) {
          //Log.d(TAG, "Set video maximum bitrate: " + peerConnectionParameters.videoMaxBitrate);
          peerConnectionClient.setVideoMaxBitrate(peerConnectionParameters.videoMaxBitrate);
        }
      }
    });
  }

  @Override
  public void onIceGatheringChange(final PeerConnection.IceGatheringState newState) {
                    Log.d(TAG, "\n\n\n ++++++++++++++++++ IceGatheringState: " + newState);


      // ViewProxy.getInstance().getActivity().runOnUiThread(new Runnable() {
      //       @Override
      //       public void run() {
      //         if (appRtcClient != null) {

      //             if (newState == PeerConnection.IceGatheringState.COMPLETE ) {
      //                   if (signalingParameters.initiator) {
      //                       appRtcClient.sendOfferSdp(peerConnectionClient.getPeerConnection().getLocalDescription());
      //                   }
      //             }
      //         }
      //       }
      // });

  }



  @Override
  public void onIceCandidate(final IceCandidate candidate) {
                        Log.d(TAG, "\n\n\n ++++++++++++++++++ onIceCandidate: ");

    // ViewProxy.getInstance().getActivity().runOnUiThread(new Runnable() {
    //   @Override
    //   public void run() {
    //     if (appRtcClient != null) {
    //       peerConnectionClient.getPeerConnection().addIceCandidate(candidate);
    //       appRtcClient.sendLocalIceCandidate(candidate);
    //     }
    //   }
    // });
  }

  @Override
  public void onIceCandidatesRemoved(final IceCandidate[] candidates) {
    ViewProxy.getInstance().getActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        if (appRtcClient != null) {
          appRtcClient.sendLocalIceCandidateRemovals(candidates);
        }
      }
    });
  }

  @Override
  public void onIceConnected() {
    final long delta = System.currentTimeMillis() - callStartedTimeMs;
    ViewProxy.getInstance().getActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        logAndToast("ICE connected, delay=" + delta + "ms");
        iceConnected = true;
        callConnected();
      }
    });
  }

  @Override
  public void onIceDisconnected() {
    ViewProxy.getInstance().getActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        logAndToast("ICE disconnected");
        iceConnected = false;
        disconnect();
      }
    });
  }



  @Override
  public void onPeerConnectionClosed() {
    // ViewProxy.getInstance().getActivity().runOnUiThread(new Runnable() {
    //   @Override
    //   public void run() {
    //     ViewProxy.getWebRTCModule().fireEvent("closed",null);

    //   }
    // });
  }

  @Override
  public void onPeerConnectionStatsReady(final RTCStatsReport reports) {
    ViewProxy.getInstance().getActivity().runOnUiThread(new Runnable() {
      @Override
      public void run() {
        if (!isError && iceConnected) {
        }
      }
    });
  }

  @Override
  public void onPeerConnectionError(final String description) {
    reportError(description);
  }
}
