// ------------------------------------------------
// Main Window and init some vars for further
// eventListener setup later....
// ------------------------------------------------
var isIOS = (Titanium.Platform.osname !== 'android');

var win = Ti.UI.createWindow({
  backgroundColor: 'gray'
});

var myUserID;

var offerAnswerContainer;

var buttonContainer, innerButtonContainer, microphoneButtonContainer,callDeniedButtonContainer,microphoneButtonContainer,speakerButtonContainer,callButtonContainer, cameraSwitchButtonContainer,cameraButtonContainer;


// ------------------------------------------------
// callView - Window (only for Android)
// ------------------------------------------------

var callWindow = Ti.UI.createWindow({
  backgroundColor: 'gray',
  extendSafeArea: true,
  includeOpaqueBars:true,
  fullscreen:true,
  isOpen:false
});

// ---------------------------------------------------------
// overlayScrollView - will contain the offer/answer stuff
// because of keyboard will else hide the textAreas without
// ---------------------------------------------------------

var overlay = Ti.UI.createScrollView({
  top:0,
  bottom:0,
  left:0,
  right:0,
  contentHeight:Ti.UI.SIZE,
  scrollingEnabled: true,
  scrollType:'vertical',
  verticalBounce:false,
  showVerticalScrollIndicator:true,
  width:Ti.UI.FILL,
  height:Ti.UI.FILL
});



// ------------------------------------------------
// requires module and libs
// ------------------------------------------------

var webRTC_Module = require('de.marcbender.webrtc');
var fontawesome = require('/lib/IconicFont').IconicFont({font: '/lib/FontAwesome',ligature: false});
var fontawesomeregular = require('/lib/IconicFont').IconicFont({font: '/lib/FontAwesomeRegular',ligature: false});

// ------------------------------------------------
// animations
// ------------------------------------------------

var animViewSize = Ti.UI.createAnimation({
    curve: 7
  });

var touchStartAnim = Titanium.UI.createAnimation({
    duration: 150,
    opacity: 0.7
});

var touchEndAnim = Titanium.UI.createAnimation({
    duration: 150,
    opacity: 1.0
});

var fadeInAnim = Titanium.UI.createAnimation({
    curve:Ti.UI.ANIMATION_CURVE_EASE_IN_OUT,
    opacity:1,
    duration:250
});

var fadeOutAnim = Titanium.UI.createAnimation({
    curve:Ti.UI.ANIMATION_CURVE_EASE_IN_OUT,
    opacity:0.0,
    duration:350
});

// ------------------------------------------------
//  functions
// ------------------------------------------------

var createSimpleButton = function(icon,positionLeft,positionRight,color,events,size,opacity,width,text,_args,regular) {
  if (!_args){ _args = {};}


  var masterContainer = Ti.UI.createView({
      //layout:'horizontal',
      //backgroundColor:'red',
      id: _args.id ? _args.id : 0,
      borderColor:_args.borderColor ? _args.borderColor : undefined,
      borderWidth:_args.borderWidth ? _args.borderWidth : undefined,
      borderRadius:_args.borderRadius ? _args.borderRadius : undefined,
      backgroundColor: (_args.noBackgroundColorDarken != true) ? _args.backgroundColor : undefined,
      width: _args.width ? _args.width : Ti.UI.SIZE,
      height: _args.height ? _args.height : Ti.UI.SIZE,
      top:_args.top ? _args.top : undefined,
      bottom:_args.bottom ? _args.bottom : undefined,
      left:_args.left ? _args.left : undefined,
      right:_args.right ? _args.right : undefined,
      zIndex:_args.zIndex ? _args.zIndex : undefined
  });

  var buttonContainer = Ti.UI.createView({
      touchEnabled:false,
      bubbleParent:true,
      layout:(text) ? 'horizontal' : undefined,
      width: Ti.UI.SIZE,
      height: Ti.UI.SIZE,
      left:(text) ? 10 : undefined,
      right:(text) ? 10 : undefined
  });


  var buttonImage;

  if (icon.indexOf('.png') === -1){
     buttonImage = Ti.UI.createLabel({
        id: _args.id ? _args.id : 0,
        touchEnabled:false,
        bubbleParent:true,

        width: Ti.UI.SIZE,
        height: Ti.UI.SIZE,
        backgroundColor: _args.backgroundColor ? _args.backgroundColor : undefined,
        right: (text) ? 10 : undefined,
        orgColor : color ? color : '#fff',
        color: color ? color : '#fff',
        opacity: opacity ? opacity : undefined,
        textAlign:'center',
        font: {
            fontWeight: _args.fontWeight ? _args.fontWeight : undefined,
            fontSize: _args.iconSize ? _args.iconSize : 26,
            fontFamily: !regular ? fontawesome.fontfamily() : fontawesomeregular.fontfamily() 
        },
        text: !regular ? fontawesome.icon(icon) : fontawesomeregular.icon(icon)
    });
  }
  else {
  
    buttonImage = Ti.UI.createImageView({
        id: _args.id ? _args.id : 0,
        touchEnabled:false,  
        width: Ti.UI.SIZE,
        height: _args.iconSize ? _args.iconSize : 26,
        backgroundColor: _args.backgroundColor ? _args.backgroundColor : undefined,
        orgColor : color ? color : '#fff',
        color: color ? color : '#fff',
        opacity: opacity ? opacity : undefined,
        image: icon,
        bubbleParent:true
    });
  }


  
  buttonContainer.add(buttonImage);

  if (text) {
      var buttonText = Ti.UI.createLabel({
          width:Ti.UI.SIZE,
          height: Ti.UI.SIZE,
          orgColor : color ? color : '#fff',
          color: color ? color : '#fff',
          opacity: opacity ? opacity : undefined,
          textAlign:'left',
          font: {
              fontSize: _args.labelSize ? _args.labelSize : 18,
          },
          text: text,
          touchEnabled:false,
          bubbleParent:true,      
      });
      buttonContainer.add(buttonText);
      masterContainer.textContent = buttonText;
  }
  masterContainer.icon = buttonImage;


  if (events != false) {
      masterContainer.addEventListener('touchstart', function(e){
          this.opacity = 0.7;

          if (_args.tintColor){
            this.icon.color = _args.tintColor;
          }
          else {
           // this.icon.color = ColorLuminance(this.icon.orgColor, 0.4);
          }

          //this.orgColor = this.backgroundColor ? this.backgroundColor : undefined;
          if(_args.noBackgroundColorDarken != true){
           // this.backgroundColor = this.backgroundColor ? ColorLuminance(this.backgroundColor, 0.2) : undefined;
          }

          if (this.textContent){
            //  this.textContent.color = ColorLuminance(this.textContent.orgColor, 0.4);
          }
      });

      masterContainer.addEventListener('touchend', function(e){
          this.opacity = 1.0;

          this.icon.color = this.icon.orgColor;
          if(_args.noBackgroundColorDarken != true){
          //  this.backgroundColor = this.orgColor ? this.orgColor : undefined;
          }

          if (this.textContent){
           //   this.textContent.color = this.textContent.orgColor;
          }
      });

      masterContainer.addEventListener('touchcancel', function(e){
          this.opacity = 1.0;
          this.icon.color = this.icon.orgColor;
          if(_args.noBackgroundColorDarken != true){
          //  this.backgroundColor = this.orgColor ? this.orgColor : undefined;
          }

          if (this.textContent){
           //   this.textContent.color = this.textContent.orgColor;
          }
      });
  }
  masterContainer.add(buttonContainer);

  masterContainer.buttonContainer = buttonContainer;

  return masterContainer;
};


var createCallViewElements = function(webRTC_Module,callWindow){
  
  buttonContainer = Titanium.UI.createView({
    bottom:60,
    height:80,
    borderRadius:12,
    width:Ti.UI.SIZE,
    backgroundColor:'#55000000',
    layout:'vertical',
    touchEnabled:isIOS ? true : false,
    bubbleParent:isIOS ? true : true
  });
  
  
  
  innerButtonContainer = Ti.UI.createView({
    top:10,
    left:10,
    right:10,
    height:Ti.UI.SIZE,
    width:Ti.UI.SIZE,
    layout:'horizontal',
    touchEnabled:isIOS ? true : false,
    bubbleParent:isIOS ? true : true
  });
  buttonContainer.add(innerButtonContainer);
  
  callWindow.add(buttonContainer);
  
     callDeniedButtonContainer = createSimpleButton('icon-remove',0,undefined,'#ffffff',undefined,36,undefined,100,undefined,{
        iconSize: 30,
        borderWidth:0,
        width:60,
        height:60,
        borderRadius:30,
        left:10,
        fontWeight:'bold',
        backgroundColor:'red',
        right:10,
        top:undefined,
        bottom:undefined                  
      },true);
  
      callDeniedButtonContainer.addEventListener("click", function(e){
            callWindow.close({
              animated:isIOS ? false : undefined
            });
      });
    
     callButtonContainer = createSimpleButton('icon-phone',0,undefined,'#ffffff',undefined,36,undefined,100,undefined,{
        iconSize: 26,
        borderWidth:0,
        width:60,
        height:60,
        borderRadius:30,
        left:10,
        right:10,
        top:undefined,
        bottom:undefined                  
      });
      callButtonContainer.applyProperties({
        connected:false,
        backgroundColor:'green',
      });
  
      callButtonContainer.addEventListener("click", function(e){
  
          if (this.connected == false){
            offerAnswerContainer.createOfferLabel.status = true;
            offerAnswerContainer.setAnswerLabel.status = true;
            offerAnswerContainer.offerView.editable = true;
            offerAnswerContainer.answerView.editable = true;
        
            innerButtonContainer.remove(callDeniedButtonContainer);
  
            this.applyProperties({
              connected:true,
              backgroundColor:'red'
            });
            this.icon.applyProperties({
              text:fontawesome.icon('icon-phone-hangup')
            });

            if (isIOS){
              Ti.API.info('start webRTC');
              setTimeout(function () {
                  webRTC_Module.startWebRTC({
                    userID:myUserID,
                    callInitiator:false
                  });        
                  setTimeout(function () {
                        webRTC_Module.createDataChannel({userID:myUserID});
                  },500);
              },150);  
            }
            else {
              Ti.API.info('start webRTC');
              setTimeout(function () {
                  webRTC_Module.startWebRTC({
                    userID:myUserID,
                    callInitiator:false
                  });
              },150);  
            }
            innerButtonContainer.add(speakerButtonContainer);
            innerButtonContainer.add(microphoneButtonContainer);
            innerButtonContainer.add(cameraButtonContainer);
          }
          else {
              this.connected = false;
              
              callWindow.close({
                animated:isIOS ? false : undefined
              });

              setTimeout(function (e) {

                  innerButtonContainer.remove(speakerButtonContainer);
                  innerButtonContainer.remove(microphoneButtonContainer);
                  innerButtonContainer.remove(cameraButtonContainer);
                  innerButtonContainer.remove(callButtonContainer);
    
                  innerButtonContainer.add(callDeniedButtonContainer);
                  innerButtonContainer.add(callButtonContainer);

                  callButtonContainer.applyProperties({
                    backgroundColor:'green'
                  });
                  callButtonContainer.icon.applyProperties({
                    text:fontawesome.icon('icon-phone')
                  });
                  offerAnswerContainer.createOfferLabel.status = false;
                  offerAnswerContainer.setAnswerLabel.status = false;
                  offerAnswerContainer.offerView.editable = false;
                  offerAnswerContainer.answerView.editable = false;
      
              },500);
          }
      });
  
     microphoneButtonContainer = createSimpleButton('icon-microphone',0,undefined,'#ffffff',undefined,36,undefined,100,undefined,{
          iconSize: 26,
          borderWidth:0,
          backgroundColor:'gray',
          width:60,
          height:60,
          borderRadius:30,
          left:10,
          right:10,
          top:undefined,
          bottom:undefined                    
        });
      microphoneButtonContainer.state = true;
  
      microphoneButtonContainer.addEventListener("click", function(e){
          if (this.state == true) {
            this.state = false;
            this.icon.applyProperties({
              text:fontawesome.icon('icon-microphone-off')
            });
            webRTC_Module.switchMicrophone({state:false});
          }
          else {
            this.state = true;
            this.icon.applyProperties({
              text:fontawesome.icon('icon-microphone')
              });
            webRTC_Module.switchMicrophone({state:true});
          }
      });
  
  
     speakerButtonContainer = createSimpleButton('icon-volume',0,undefined,'#ffffff',undefined,36,undefined,100,undefined,{
        iconSize: 26,
        borderWidth:0,
        backgroundColor:'gray',
        width:60,
        height:60,
        borderRadius:30,
        left:10,
        right:10,
        top:undefined,
        bottom:undefined
      });
      speakerButtonContainer.state = true;
  
      speakerButtonContainer.addEventListener("click", function(e){
          if (this.state == true) {
            this.state = false;
            this.icon.applyProperties({
              text:fontawesome.icon('icon-volume-slash')
              });
            webRTC_Module.switchAudio({state:false});
          }
          else {
            this.state = true;
            this.icon.applyProperties({
              text:fontawesome.icon('icon-volume')
              });
            webRTC_Module.switchAudio({state:true});
          }
      });
 
     cameraButtonContainer = createSimpleButton('icon-camera',0,undefined,'#ffffff',undefined,36,undefined,100,undefined,{
        iconSize: 26,
        borderWidth:0,
        left:10,
        right:10,
        backgroundColor:'gray',
        width:60,
        height:60,
        borderRadius:30,
        top:undefined,
        bottom:undefined                  
      });

      cameraButtonContainer.state = true;
      cameraButtonContainer.addEventListener("click", function(e){
  
        if (this.state == true) {
          this.state = false;
          this.icon.applyProperties({
            text:fontawesome.icon('icon-camera-slash')
            });
            setTimeout(function (e) {
              webRTC_Module.switchVideo({state:false});
            },250);
        }
        else {
          this.state = true;
          this.icon.applyProperties({
            text:fontawesome.icon('icon-camera')
            });
            setTimeout(function (e) {
              webRTC_Module.switchVideo({state:true});
            },250);
        }
      });
  
  
     cameraSwitchButtonContainer = createSimpleButton('icon-camera-rotate',0,undefined,'#ffffff',undefined,36,undefined,100,undefined,{
        iconSize: 26,
        borderWidth:0,
        borderRadius:24,
        right:25,
        backgroundColor:'gray',
        width:48,
        height:48,
        top:250
      });
      cameraSwitchButtonContainer.addEventListener("click", function(){
        webRTC_Module.switchCamera();
      });
    
      innerButtonContainer.add(callDeniedButtonContainer);
      innerButtonContainer.add(callButtonContainer);
  
      callWindow.add(cameraSwitchButtonContainer);
}

var removeControlElements = function(){
  callWindow.remove(buttonContainer);
  buttonContainer = null;
  callWindow.remove(cameraSwitchButtonContainer);
  cameraSwitchButtonContainer = null;
}





// ------------------------------------------------
// Offer and Answer for serverless Connection
// ------------------------------------------------

var createOfferAnswerContainer = function(){
   
    var offerAnswerContainer = Ti.UI.createView({
      top:0,
      left:0,
      right:0,
      height:Ti.UI.FILL,
      width:Ti.UI.FILL,
      bottom:80,
      opacity:0.6
    });

    var offerView = Ti.UI.createTextArea({
        backgroundColor: 'green',
        height: 100,
        width: Ti.UI.FILL,
        bottom: 300,
        color:'black',
        value:'',
        editable:false
    });

    var answerView = Ti.UI.createTextArea({
        backgroundColor: 'blue',
        height: 100,
        width: Ti.UI.FILL,
        bottom: 100,
        color:'black',
        value:'',
        editable:false
    });

    var createOfferLabel = Ti.UI.createLabel({
        backgroundColor:'#1777a8',
        animating:false,
        color:'#ffffff',
        font:{fontFamily:'Arial', fontSize:14, fontWeight:'bold'},
        text: 'createLocalOffer',
        textAlign: Ti.UI.TEXT_ALIGNMENT_CENTER,
        borderRadius:18,
        borderColor:'#55ededed',
        borderWidth:2,
        width:Ti.UI.SIZE,
        height:40,
        bottom:250,
        status:false,
        type:'localoffer'
    });

    createOfferLabel.addEventListener('click', function(e) {
      if (this.status != false){
          if (this.type=='localoffer'){
            webRTC_Module.createOffer({
              userID:myUserID
            });
          }
      }
    });

    var copyOfferLabel = Ti.UI.createLabel({
        backgroundColor:'#1777a8',
        animating:false,
        color:'#ffffff',
        font:{fontFamily:'Arial', fontSize:14, fontWeight:'bold'},
        text: 'selectLocalOffer',
        textAlign: Ti.UI.TEXT_ALIGNMENT_CENTER,
        borderRadius:18,
        borderColor:'#55ededed',
        borderWidth:2,
        width:Ti.UI.SIZE,
        height:40,
        left:10,
        bottom:250
    });

    copyOfferLabel.addEventListener('singletap', function(e) {
        offerView.setSelection(0,offerView.value.length);
    });


    var setAnswerLabel = Ti.UI.createLabel({
        backgroundColor:'#1777a8',
        animating:false,
        color:'#ffffff',
        font:{fontFamily:'Arial', fontSize:14, fontWeight:'bold'},
        text: 'setRemoteOffer',
        textAlign: Ti.UI.TEXT_ALIGNMENT_CENTER,
        borderRadius:18,
        borderColor:'#55ededed',
        borderWidth:2,
        width:Ti.UI.SIZE, 
        height:40,
        bottom:50,
        status:false,
        type:'remoteoffer'
    });

    setAnswerLabel.addEventListener('click', function(e) {
        if (this.status != false){
          if (answerView.value != ''){
            console.log("out: "+JSON.parse(answerView.value));
            if (this.type=='remoteoffer'){
              webRTC_Module.setRemoteOffer({
                userID:myUserID,
                data:JSON.parse(answerView.value)
              });
              createOfferLabel.hide();
              copyOfferLabel.text = "selectLocalAnswer";
            }
            else {
              webRTC_Module.setRemoteAnswer({
                userID:myUserID,
                data:JSON.parse(answerView.value)
              });
              setAnswerLabel.hide();
            }    
          }
        }
    });

    var copyAnswerLabel = Ti.UI.createLabel({
        backgroundColor:'#1777a8',
        animating:false,
        color:'#ffffff',
        font:{fontFamily:'Arial', fontSize:14, fontWeight:'bold'},
        text: 'selectAnswer',
        textAlign: Ti.UI.TEXT_ALIGNMENT_CENTER,
        borderRadius:18,
        borderColor:'#55ededed',
        borderWidth:2,
        width:Ti.UI.SIZE,
        height:40,
        left:10,
        bottom:50
    });

    copyAnswerLabel.addEventListener('click', function(e) {
        answerView.setSelection(0,answerView.value.length);
    });

    offerAnswerContainer.add(offerView);
    offerAnswerContainer.add(answerView);        
    offerAnswerContainer.add(setAnswerLabel);
    offerAnswerContainer.add(createOfferLabel);
    offerAnswerContainer.add(copyOfferLabel);        
    offerAnswerContainer.add(copyAnswerLabel);

    offerAnswerContainer.offerView = offerView;
    offerAnswerContainer.answerView = answerView;
    offerAnswerContainer.createOfferLabel = createOfferLabel;
    offerAnswerContainer.setAnswerLabel = setAnswerLabel;
    offerAnswerContainer.copyOfferLabel = copyOfferLabel;
    offerAnswerContainer.copyAnswerLabel = copyAnswerLabel;

  return offerAnswerContainer;
}

offerAnswerContainer = createOfferAnswerContainer();

// ------------------------------------------------
// webRTC-Module Listener
// ------------------------------------------------

webRTC_Module.addEventListener('offer', function(e) {
  console.log("offer: "+JSON.stringify(e.data));
  offerAnswerContainer.offerView.value = JSON.stringify(e.data);

  if (offerAnswerContainer.createOfferLabel.type=='localoffer'){
    offerAnswerContainer.createOfferLabel.hide();
    offerAnswerContainer.setAnswerLabel.type = 'remoteanswer';
    offerAnswerContainer.setAnswerLabel.text = 'setRemoteAnswer';
  }
  else {
    offerAnswerContainer.createOfferLabel.text = "setRemoteAnswer";
    offerAnswerContainer.copyOfferLabel.hide();
  }

});

webRTC_Module.addEventListener('answer', function(e) {
  console.log("answer: "+JSON.stringify(e.data));
  offerAnswerContainer.offerView.value = JSON.stringify(e.data);
  if (offerAnswerContainer.setAnswerLabel.type=='remoteanswer'){

  }
});

webRTC_Module.addEventListener('icecandidate', function(e) {
  console.log("");
  console.log("");
  console.log("---------------------------------------------");

  console.log("icecandidate from: "+e.socketId);
  console.log("");

  console.log("icecandidate: "+JSON.stringify(e.data));
  console.log("");
  console.log("----------------------------------------------");
  console.log("");
  console.log("");
  console.log("");

    // if (myUserID !== e.socketId){

    //     webRTC_Module.setICECandidate({
    //       userID:myUserID,
    //       data:JSON.parse(e.data)
    //     });
    // }
});

webRTC_Module.addEventListener('dialSuccess', function(e) {
  Ti.API.warn('++++++++++++++++++++++++++++ dialSucces');
  // overlay.hide();

  // offerAnswerContainer.hide();
});

webRTC_Module.addEventListener('closed', function () {
  Ti.API.info('stop webRTC');
  offerAnswerContainer.show();
  overlay.show();

  if (callWindow.isOpen == true){
    callWindow.close({
      animated:false
    });  
  }
});

webRTC_Module.addEventListener('open', function () {

});



// ------------------------------------------------
// callView Buttons
// ------------------------------------------------


// ------------------------------------------------
// startCallButton for open the CallView
// ------------------------------------------------

var startCallButton = createSimpleButton('icon-phone',0,undefined,'#ffffff',undefined,36,undefined,100,'open call view',{
    iconSize: 26,
    labelSize: 24,
    borderWidth:0,
    left:undefined,
    right:undefined,
    backgroundColor:'green',
    width:Ti.UI.SIZE,
    height:60,
    borderRadius:30,
    top:undefined,
    bottom:80                  
});







// ------------------------------------------------
// iOS Variants 
// ------------------------------------------------

if (isIOS){
  myUserID = "iOSUser_"+Math.floor(Math.random() * 10);

  var webrtcView = webRTC_Module.createWebRTC({
    height:Ti.UI.FILL,
    width:Ti.UI.FILL,
    backgroundColor:'black'
  });

  callWindow.add(webrtcView);
  overlay.add(offerAnswerContainer);
  callWindow.add(overlay);

  createCallViewElements(webRTC_Module,callWindow);

  callWindow.addEventListener('open', function(e) {
      overlay.contentHeight = Ti.UI.SIZE;
      callWindow.isOpen = true;
      webRTC_Module.open({animated:true,userID:myUserID,asView:true});
  });

  callWindow.addEventListener('close', function(e) {
      callWindow.isOpen = false;
      webRTC_Module.stopWebRTC({
        userID:myUserID
      });
      setTimeout(function (){
        removeControlElements();
        overlay.remove(offerAnswerContainer);
        offerAnswerContainer = null;
        offerAnswerContainer = createOfferAnswerContainer();
        overlay.add(offerAnswerContainer);
        createCallViewElements(webRTC_Module,callWindow);
      },650);
  });



  startCallButton.addEventListener("click", function(e){
      callWindow.open({
          animated:false,
          modal:true,
          modalStyle:Titanium.UI.iOS.MODAL_PRESENTATION_OVER_CURRENT_FULL_SCREEN
      });
  });



  if (Ti.Media.hasAudioRecorderPermissions()) {


  } 
  else {
      Ti.Media.requestAudioRecorderPermissions(function (e) {
          if (e.success) {
          }
          else {
              
              alert('No microphone permission'); // eslint-disable-line no-alert
          }
      });
  }

  if (Ti.Media.hasCameraPermissions()) {
      
  } 
  else {
      Ti.Media.requestCameraPermissions(function (e) {
          if (e.success) {
              
          } 
          else {
              
              alert('No camera permission'); // eslint-disable-line no-alert
          }
      });
  }   
}




// ------------------------------------------------
// Android Variants 
// ------------------------------------------------

else {
    myUserID = "AndroidUser";

    var PlayServices = require('ti.playservices');
    var playServicesAvailable = PlayServices.makeGooglePlayServicesAvailable(function (e){}); 

    var permissions = [ 'android.permission.RECORD_AUDIO','android.permission.MODIFY_AUDIO_SETTINGS','android.permission.CAMERA', 'android.permission.BLUETOOTH','android.permission.READ_EXTERNAL_STORAGE', 'android.permission.WRITE_EXTERNAL_STORAGE' ];

    callWindow.applyProperties({
        exitOnClose:false,
        theme: 'Theme.Titanium.NoTitleBar',
        windowFlags: Ti.UI.Android.FLAG_TRANSLUCENT_NAVIGATION | Ti.UI.Android.FLAG_TRANSLUCENT_STATUS
    });

    startCallButton.addEventListener("click", function(e){
              Ti.Android.requestPermissions(permissions, function (e) {
                  if (e.success) {
                      Ti.API.info('SUCCESS');
                      callWindow.open();
                  } else {
                      Ti.API.info('No permissions');
                  }
              });
      });

    var webrtcView = webRTC_Module.createView({
        height:Ti.UI.FILL,
        width:Ti.UI.FILL,
        backgroundColor:'black',
    });
    overlay.add(offerAnswerContainer);

    callWindow.add(webrtcView);
    callWindow.add(overlay);

    createCallViewElements(webRTC_Module,callWindow);

    callWindow.addEventListener('postlayout', function() {
        overlay.applyProperties(callWindow.safeAreaPadding);
    });

    callWindow.addEventListener('open', function(e) {
        callWindow.isOpen = true;
        overlay.contentHeight = Ti.UI.SIZE;
    });

    callWindow.addEventListener('close', function(e) {
      removeControlElements();

      overlay.remove(offerAnswerContainer);
      offerAnswerContainer = null;
      offerAnswerContainer = createOfferAnswerContainer();
      overlay.add(offerAnswerContainer);
      createCallViewElements(webRTC_Module,callWindow);

      callWindow.isOpen = false;
      Ti.API.info('callWindow close');
      setTimeout(function (){
        webRTC_Module.stopWebRTC({
          userID:myUserID
        }); 
      },650);
  });

}


win.addEventListener('open', function(e) {
  win.add(startCallButton);
});

win.open();