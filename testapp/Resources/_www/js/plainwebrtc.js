
var conf = { 'iceServers': [{ 'urls': 'stun:stun.l.google.com:19302' },{ 'urls': 'stun:stun1.l.google.com:19302' },{ 'urls': 'stun:stun2.l.google.com:19302' },{ 'urls': 'stun:stun3.l.google.com:19302' },{ 'urls': 'stun:stun4.l.google.com:19302' }] };
var pc = null;

var appContainer = document.querySelector('.app');

var localVideo = document.getElementById("local-video");
var localVideoEl = document.getElementById("local-stream");

var remoteVideo = document.querySelector(".remote-video");

var localOfferSetButton = document.getElementById("localOfferSet");
var callButton = document.getElementById("callButton");
var hangupButton = document.getElementById("hangupButton");

var constraints = {
	width: {min: 640, ideal: 1280},
	height: {min: 480, ideal: 720},
	advanced: [
	  {width: 1920, height: 1280},
	  {aspectRatio: 1.333}
	]
  };
var excludeEvents = [
    'ontimeupdate', 'onprogress',
    'onmousemove', 'onmouseover', 'onmouseout', 'onmouseenter', 'onmouseleave',
    'onpointermove', 'onpointerover', 'onpointerenter', 'onpointerrawupdate', 'onpointerout', 'onpointerleave',
    'onpointerdown', 'onmousedown', 'onclick', 'onmouseup', 'onpointerup'
];



var myLocalDescription = '';
var localStream = null;
var inboundStream = null;
// var startButton = document.getElementById('startButton');
// startButton.addEventListener('click', start);

pc = new RTCPeerConnection(conf);
setEvents();

function selectControlByName(name) {
    return appContainer.querySelector('.controls .btn[name=' + name + ']');
}



function  hangup(){
	pc.close();
	pc = null;
	hangupButton.disabled = true;
	callButton.disabled = true;
	localOfferSetButton.disabled = false;
	localOffer.value = '';
	remoteOffer.value = '';
	myLocalDescription = '';
	pc = new RTCPeerConnection(conf);
	setEvents();
	start();
} 


function errHandler(err){
	console.log(err);
	localOfferSetButton.disabled = false;
	callButton.disabled = true;
	hangupButton.disabled = true;
}
function enableChat(){
	enable_chat.checked? (chatEnabled=true) : (chatEnabled=false);
}
//enableChat();

function TestListenEvents(eventTarget) {

    if (eventTarget.TestListenEvents) {
        return;
    }
    eventTarget.TestListenEvents = true;

    function eventTriggered(event) {
       console.debug('event.triggered', event, eventTarget);
    }

    for(var eventName in eventTarget) {
        if (eventName.search('on') === 0 && excludeEvents.indexOf(eventName) == -1) {
           eventTarget.addEventListener(eventName.slice(2), eventTriggered.bind(eventTarget, eventName));
        }
    }
}




function TestControls() {

    navigator.mediaDevices.enumerateDevices().then(function(devices) {
        console.debug('enumerateDevices', devices);
        var canSwitchDevice = devices.filter(function(device) {
            return device.kind === 'videoinput';
        }).length > 1;


        if (!canSwitchDevice && typeof navigator.mediaDevices.getDisplayMedia === 'undefined') {
            selectControlByName('switch_camera').classList.add('hidden');
        }
    });

    if (!isCordova || typeof cordova.plugins.iosrtc.selectAudioOutput === 'undefined') {
        selectControlByName('speaker').classList.add('hidden');
        selectControlByName('earpiece').classList.add('hidden');
    }

    if (!isCordova || typeof cordova.plugins.iosrtc.selectAudioOutput === 'undefined') {
        selectControlByName('speaker').classList.add('hidden');
        selectControlByName('earpiece').classList.add('hidden');
    }

    if (!isCordova || typeof cordova.plugins.iosrtc.turnOnSpeaker === 'undefined') {
        selectControlByName('speaker').classList.add('hidden');
    }
	
}



function handleControlsEvent(event) {
        var targetEl = event.target;

        if (!targetEl.classList.contains('btn')) {
            targetEl = targetEl.closest('.btn');
        }

        if (targetEl && targetEl.classList.contains('btn')) {
            var actionName = targetEl.getAttribute('name');
            switch (actionName) {
                case 'mic_on':
                    selectControlByName('mic_on').classList.add('hidden');
                    selectControlByName('mic_off').classList.remove('hidden');
                    localStream.getAudioTracks().forEach(function(track) {
                        track.enabled = true;
                    });
                    break;
                case 'mic_off':
                    selectControlByName('mic_off').classList.add('hidden');
                    selectControlByName('mic_on').classList.remove('hidden');
                    localStream.getAudioTracks().forEach(function(track) {
                        track.enabled = false;
                    });
                    break;
                case 'hangup_remote':

                    // TestControlsClosingCall();

                    // Object.values(peerConnections).forEach(function(peerConnection) {
                    //     TestRemoveStreamToPeerConnection(peerConnection, localStream);
                    // });

                    // TestHangupRTCPeerConnections(peerConnections);
					
                    break;
                case 'call_remote':
                    // TestControlsIncomingCall();

                    // TestHangupRTCPeerConnections(peerConnections);

                    // TestRTCPeerConnection(localStream);
					
                    break;
                case 'camera_on':
                    selectControlByName('camera_on').classList.add('hidden');
                    selectControlByName('camera_off').classList.remove('hidden');
                    //localVideoEl.classList.remove('hidden');
                    localStream.getVideoTracks().forEach(function(track) {
                        track.enabled = true;
                    });
                    break;
                case 'camera_off':
                    selectControlByName('camera_off').classList.add('hidden');
                    selectControlByName('camera_on').classList.remove('hidden');
                   // localVideoEl.classList.add('hidden');
                    localStream.getVideoTracks().forEach(function(track) {
                        track.enabled = false;
                    });
                    break;
                case 'switch_camera':
                    selectControlByName('switch_camera').classList.toggle('btn-active');


                    // localVideoEl.classList.remove('hidden');
                    // localVideo.srcObject = null;
                    /*
                    localStream.getTracks().forEach(function (track) {
                      localStream.removeTrack(track);
                    });
                    */

                    // var oldLocalStream = localStream;
                    // TestSwitchCamera().then(function() {

                    //     if (typeof pc1 !== 'undefined' && typeof pc2 !== 'undefined') {

                    //         pc1.createOffer({
                    //             iceRestart: true
                    //         }).then(function(desc) {

                    //             TestRemoveStreamToPeerConnection(pc1, oldLocalStream);
                    //             TestAddStreamToPeerConnection(pc1, localStream);

                    //             return pc1.setLocalDescription(desc).then(function() {
                    //                 return pc2.setRemoteDescription(desc).then(function() {
                    //                     return pc2.createAnswer(answerConstraints).then(function(desc) {
                    //                         return pc2.setLocalDescription(desc).then(function() {
                    //                             return pc1.setRemoteDescription(desc);
                    //                         });
                    //                     });
                    //                 });
                    //             });
                    //         }).catch(function(err) {
                    //             console.error('TestCallAwnserPeerError', err);
                    //         });

                    //     } else {
                    //         Object.keys(peerConnections).forEach(function(targetPeerId) {
                    //             var peerConnection = peerConnections[targetPeerId];
                    //             TestRemoveStreamToPeerConnection(peerConnection, oldLocalStream);
                    //             TestAddStreamToPeerConnection(peerConnection, localStream);
                    //             return peerConnection.createOffer({
                    //                 iceRestart: true
                    //             }).then(function(desc) {
                    //                 return peerConnection.setLocalDescription(desc).then(function() {
                    //                     webSocketSendMessage({
                    //                         source: peerId,
                    //                         target: targetPeerId,
                    //                         type: desc.type,
                    //                         sdp: desc.sdp
                    //                     });
                    //                 });
                    //             });
                    //         });
                    //     }


                    // });
                    break;
                case 'speaker':
                    selectControlByName('earpiece').classList.remove('btn-active');
                    selectControlByName('speaker').classList.add('btn-active');
                   // cordova.plugins.iosrtc.turnOnSpeaker(true);
                    break;
                case 'earpiece':
                    selectControlByName('speaker').classList.remove('btn-active');
                    selectControlByName('earpiece').classList.add('btn-active');
                    //cordova.plugins.iosrtc.selectAudioOutput('earpiece');
                    break;
                case 'mute_remote':
                    selectControlByName('mute_remote').classList.add('hidden');
                    selectControlByName('unmute_remote').classList.remove('hidden');
                    // peerStream.getAudioTracks().forEach(function(track) {
                    //     if (track.kind == 'audio') {
                    //         track.enabled = false;
                    //     }
                    // });
                    break;
                case 'unmute_remote':
                    selectControlByName('unmute_remote').classList.add('hidden');
                    selectControlByName('mute_remote').classList.remove('hidden');
                    // peerStream.getAudioTracks().forEach(function(track) {
                    //     if (track.kind == 'audio') {
                    //         track.enabled = true;
                    //     }
                    // });
                    break;
				default:
                    console.error('Unknow button name', targetEl);
            }
        }
}









async function start() {
	console.log('Requesting local stream');
	
	
   
	
		appContainer.addEventListener('click', handleControlsEvent, false);
		
	
	  
	try {
	  const stream = await navigator.mediaDevices.getUserMedia({audio: true, video: true});
	  console.log('Received local stream');
	  localVideo.srcObject = stream;
	  localStream = stream;

	    TestListenEvents(localStream);
    	TestListenEvents(localVideo);
	
	  
	  for (const track of stream.getTracks()) {

		pc.addTrack(track, stream);

	  }
	  localVideo.play();

	  

	} catch (e) {
	  alert(e);
	}
  }


//   localVideo.addEventListener('loadedmetadata', function() {
// 	localVideo.style.display = 'block';
//   });



localVideo.addEventListener('loadedmetadata', function() {

//	alert('Local video videoWidth:'+ this.videoWidth+'  videoHeight:'+ this.videoHeight);

	if (this.videoWidth > this.videoHeight){
		//localVideo.style.removeProperty('width');
		//localVideo.style.height = '9.375rem';
		//localVideo.style.transform = "rotate(-90deg)";
	}



	var track = localStream.getVideoTracks()[0];

	var constraints = {
	  width: {min: 640, ideal: 1280},
	  height: {min: 480, ideal: 720},
	  advanced: [
		{width: 1920, height: 1280},
		{aspectRatio: 1.333}
	  ]
	};
	track.applyConstraints(constraints);
//	localVideo.style.display = 'flex';



	//alert('Remote video videoWidth:'+ this.videoWidth+'  videoHeight:'+ this.videoHeight);


  });
  
  
  
  
  

hangupButton.addEventListener('click', hangup);

remoteVideo.addEventListener('loadedmetadata', function() {
	alert('Remote video videoWidth:'+ this.videoWidth+'  videoHeight:'+ this.videoHeight);

  });
  

// navigator.mediaDevices.getUserMedia({audio:true,video:true}).then(stream=>{
// 	localStream = stream;

// 	for (const track of stream.getTracks()) {
// 		pc.addTrack(track, stream);
// 	  }

//     localVideo.srcObject = stream;
// }).catch(errHandler);

function sendMsg(){
	var text = sendTxt.value;
	chat.innerHTML = chat.innerHTML + "<pre class=sent>" + text + "</pre>";
	_chatChannel.send(text);
	sendTxt.value="";
	return false;
}


function setEvents(){

	pc.ondatachannel = function(e){
		if(e.channel.label == "fileChannel"){
			console.log('fileChannel Received -',e);
			_fileChannel = e.channel;
			fileChannel(e.channel);
		}
		if(e.channel.label == "chatChannel"){
			console.log('chatChannel Received -',e);
			_chatChannel = e.channel;
			chatChannel(e.channel);
		}
	};

	pc.onicecandidate = function(e){
		var cand = e.candidate;
		if(!cand){
			console.log('iceGatheringState complete',pc.localDescription.sdp);
			localOffer.value = JSON.stringify(pc.localDescription);
			myLocalDescription = localOffer.value;
		}else{
			console.log(cand.candidate);
		}
	}
	pc.oniceconnectionstatechange = function(){
		console.log('iceconnectionstatechange: ',pc.iceConnectionState);
	}

	// pc.ontrack = function(e) {
	//     console.log('remote ontrack', e);
	//     remoteVideo.srcObject = e.streams[0];
	// }

	pc.ontrack = (ev) => {
		
		if (ev.streams && ev.streams[0]) {
			remoteVideo.style.display = 'block';
			hangupButton.disabled = false;
			callButton.disabled = true;

	    TestListenEvents(ev.streams[0]);
    	TestListenEvents(remoteVideo);
		
			
		remoteVideo.srcObject = ev.streams[0];
		//remoteVideo.style.display = 'block';
		ev.track.applyConstraints(constraints)
    	remoteVideo.classList.remove('hidden');
	

		}
	};
}  


pc.onconnection = function(e){
	console.log('onconnection ',e);
}

remoteOfferGot.onclick = function(){
	if (remoteOffer.value != ""){
		localOfferSetButton.disabled = true;
		try {
			var _remoteOffer = new RTCSessionDescription(JSON.parse(remoteOffer.value));
			console.log('remoteOffer \n',_remoteOffer);
			pc.setRemoteDescription(_remoteOffer).then(function() {
					console.log('setRemoteDescription ok');
		
					if(_remoteOffer.type == "offer"){
						pc.createAnswer().then(function(description){
							console.log('createAnswer 200 ok \n',description);
							pc.setLocalDescription(description).then(function() {
								callButton.disabled = true;
								hangupButton.disabled = false;
		
							}).catch(errHandler);
						}).catch(errHandler);
					}
					else {
						callButton.disabled = true;
						hangupButton.disabled = false;
					}
			}).catch(errHandler);	
		} catch (e) {
			setTimeout(function(){
				localOfferSetButton.disabled = false;
			},500);
		}		
	}
}
localOfferSet.onclick = function(){
	// if(chatEnabled){
	// 	_chatChannel = pc.createDataChannel('chatChannel');
	// 	_fileChannel = pc.createDataChannel('fileChannel');
	// 	// _fileChannel.binaryType = 'arraybuffer';
	// 	chatChannel(_chatChannel);
	// 	fileChannel(_fileChannel);
	// }
	if (myLocalDescription == '') {
		pc.createOffer().then(des=>{
			console.log('createOffer ok ');
				pc.setLocalDescription(des).then( ()=>{
					setTimeout(function(){
						if(pc.iceGatheringState == "complete"){
		
							return;
						}else{
							console.log('after GetherTimeout');
							localOffer.value = JSON.stringify(pc.localDescription);
							myLocalDescription = localOffer.value;
						}
					},2000);
					console.log('setLocalDescription ok');
				}).catch(errHandler);
			
			// For chat
		}).catch(errHandler);
	}
	else {
		localOffer.value = myLocalDescription;
	}
}


function sendFile(){
	if(!fileTransfer.value)return;
	var fileInfo = JSON.stringify(sendFileDom);
	_fileChannel.send(fileInfo);
	console.log('file info sent');
}


function fileChannel(e){
	_fileChannel.onopen = function(e){
		console.log('file channel is open',e);
	}
	_fileChannel.onmessage = function(e){
		// Figure out data type
		var type = Object.prototype.toString.call(e.data),data;
		if(type == "[object ArrayBuffer]"){
			data = e.data;
			receiveBuffer.push(data);
			receivedSize += data.byteLength;
			recFileProg.value = receivedSize;
			if(receivedSize == recFileDom.size){
				var received = new window.Blob(receiveBuffer);
				file_download.href=URL.createObjectURL(received);
				file_download.innerHTML="download";
				file_download.download = recFileDom.name;
				// rest
				receiveBuffer = [];
				receivedSize = 0;
				// clearInterval(window.timer);
			}
		}else if(type == "[object String]"){
			data = JSON.parse(e.data);
		}else if(type == "[object Blob]"){
			data = e.data;
			file_download.href=URL.createObjectURL(data);
			file_download.innerHTML="download";
			file_download.download = recFileDom.name;
		}

		// Handle initial msg exchange
		if(data.fileInfo){
			if(data.fileInfo == "areYouReady"){
				recFileDom = data;
				recFileProg.max=data.size;
				var sendData = JSON.stringify({fileInfo:"readyToReceive"});
				_fileChannel.send(sendData);
				// window.timer = setInterval(function(){
				// 	Stats();
				// },1000)
			}else if(data.fileInfo == "readyToReceive"){
				sendFileProg.max = sendFileDom.size;
				sendFileinChannel(); // Start sending the file
			}
			console.log('_fileChannel: ',data.fileInfo);
		}
	}
	_fileChannel.onclose = function(){
		console.log('file channel closed');
	}
}

function chatChannel(e){
	_chatChannel.onopen = function(e){
		console.log('chat channel is open',e);
	}
	_chatChannel.onmessage = function(e){
		chat.innerHTML = chat.innerHTML + "<pre>"+ e.data + "</pre>"
	}
	_chatChannel.onclose = function(){
		console.log('chat channel closed');
	}
}

function sendFileinChannel(){
  var chunkSize = 16384;
  var sliceFile = function(offset) {
    var reader = new window.FileReader();
    reader.onload = (function() {
      return function(e) {
        _fileChannel.send(e.target.result);
        if (file.size > offset + e.target.result.byteLength) {
          window.setTimeout(sliceFile, 0, offset + chunkSize);
        }
        sendFileProg.value= offset + e.target.result.byteLength
      };
    })(file);
    var slice = file.slice(offset, offset + chunkSize);
    reader.readAsArrayBuffer(slice);
  };
  sliceFile(0);
}

function Stats(){
	pc.getStats(null,function(stats){
    for (var key in stats) {
      var res = stats[key];
      console.log(res.type,res.googActiveConnection);
      if (res.type === 'googCandidatePair' &&
          res.googActiveConnection === 'true') {
        // calculate current bitrate
        var bytesNow = res.bytesReceived;
        console.log('bit rate', (bytesNow - bytesPrev));
        bytesPrev = bytesNow;
      }
    }
	});
}
