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

import org.appcelerator.titanium.TiActivity;
import androidx.appcompat.app.AppCompatActivity;
import android.app.Activity;
import org.appcelerator.titanium.TiApplication;

import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentManager;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.SeekBar;
import android.widget.TextView;
import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.TiC;
import org.appcelerator.kroll.common.TiConfig;
import org.appcelerator.titanium.util.TiConvert;
import android.util.Log;
import de.marcbender.webrtc.CaptureQualityController;
import org.webrtc.RendererCommon.ScalingType;

/**
 * Fragment for call control.
 */
public class CallFragment extends Fragment {
  private TextView contactView;
  private ImageButton cameraSwitchButton;
  private ImageButton videoScalingButton;
  private ImageButton toggleMuteButton;
  private TextView captureFormatText;
  private SeekBar captureFormatSlider;
  private OnCallEvents callEvents;
  private ScalingType scalingType;
  private boolean videoCallEnabled = true;
  private KrollDict callProperties;
  private static final String TAG = "CallFragment";



  public static final String EXTRA_ROOMID = "ROOMID";
  public static final String EXTRA_VIDEO_CALL = "VIDEO_CALL";
  public static final String EXTRA_VIDEO_CAPTUREQUALITYSLIDER_ENABLED = "VIDEO_CAPTUREQUALITYSLIDER";


  /**
   * Call control interface for container activity.
   */
  public interface OnCallEvents {
    void onCallHangUp();
    void onCameraSwitch();
    void onVideoScalingSwitch(ScalingType scalingType);
    void onCaptureFormatChange(int width, int height, int framerate);
    boolean onToggleMic();
  }


  public void putProperties(KrollDict properties) {
      callProperties = properties;
  }


  // @Override
  // public View onCreateView(
  //   // LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
  //   // View controlView = inflater.inflate(R.layout.fragment_call, container, false);

  //   // ((FragmentActivity) getContext())
  //   Log.d(TAG, "++++++++++++++++++++   onCreateView: " + container);


  //   // // Create UI controls.
  //   // contactView = controlView.findViewById(R.id.contact_name_call);
  //   // ImageButton disconnectButton = controlView.findViewById(R.id.button_call_disconnect);
  //   // cameraSwitchButton = controlView.findViewById(R.id.button_call_switch_camera);
  //   // videoScalingButton = controlView.findViewById(R.id.button_call_scaling_mode);
  //   // toggleMuteButton = controlView.findViewById(R.id.button_call_toggle_mic);
  //   // captureFormatText = controlView.findViewById(R.id.capture_format_text_call);
  //   // captureFormatSlider = controlView.findViewById(R.id.capture_format_slider_call);

  //   // Add buttons click events.
  //   // disconnectButton.setOnClickListener(new View.OnClickListener() {
  //   //   @Override
  //   //   public void onClick(View view) {
  //   //     callEvents.onCallHangUp();
  //   //   }
  //   // });

  //   // cameraSwitchButton.setOnClickListener(new View.OnClickListener() {
  //   //   @Override
  //   //   public void onClick(View view) {
  //   //     callEvents.onCameraSwitch();
  //   //   }
  //   // });

  //   // videoScalingButton.setOnClickListener(new View.OnClickListener() {
  //   //   @Override
  //   //   public void onClick(View view) {
  //   //     if (scalingType == ScalingType.SCALE_ASPECT_FILL) {
  //   //       videoScalingButton.setBackgroundResource(R.drawable.ic_action_full_screen);
  //   //       scalingType = ScalingType.SCALE_ASPECT_FIT;
  //   //     } else {
  //   //       videoScalingButton.setBackgroundResource(R.drawable.ic_action_return_from_full_screen);
  //   //       scalingType = ScalingType.SCALE_ASPECT_FILL;
  //   //     }
  //   //     callEvents.onVideoScalingSwitch(scalingType);
  //   //   }
  //   // });
  //   // scalingType = ScalingType.SCALE_ASPECT_FILL;

  //   // toggleMuteButton.setOnClickListener(new View.OnClickListener() {
  //   //   @Override
  //   //   public void onClick(View view) {
  //   //     boolean enabled = callEvents.onToggleMic();
  //   //     toggleMuteButton.setAlpha(enabled ? 1.0f : 0.3f);
  //   //   }
  //   // });

  //   // return controlView;
  // }

  @Override
  public void onStart() {
    super.onStart();

    Log.d(TAG, "++++++++++++++++++++   onStart: " + callProperties);


    boolean captureSliderEnabled = false;
    Bundle args = getArguments();
    if (args != null) {
      String contactName = args.getString(EXTRA_ROOMID);
      contactView.setText(contactName);
      videoCallEnabled = TiConvert.toBoolean(args.getString(EXTRA_VIDEO_CALL), true);
      captureSliderEnabled = videoCallEnabled
          && TiConvert.toBoolean(args.getString(EXTRA_VIDEO_CAPTUREQUALITYSLIDER_ENABLED), false);
    }

    if (!videoCallEnabled) {
      cameraSwitchButton.setVisibility(View.INVISIBLE);
    }
    if (captureSliderEnabled) {
      captureFormatSlider.setOnSeekBarChangeListener(
          new CaptureQualityController(captureFormatText, callEvents));
    } else {
      captureFormatText.setVisibility(View.GONE);
      captureFormatSlider.setVisibility(View.GONE);
    }
  }

  // TODO(sakal): Replace with onAttach(Context) once we only support API level 23+.
  @SuppressWarnings("deprecation")
  public void onAttach(AppCompatActivity activity) {

    Log.w(TAG, "\n\n\n\n ++++++++++++++++++++   onAttach: " + activity);
    Log.w(TAG, "\n\n\n\n ++++++++++++++++++++   onAttach: " + TiApplication.getInstance().getCurrentActivity());



//    super.onAttach(activity);
    callEvents = (OnCallEvents) activity;
  }
}
