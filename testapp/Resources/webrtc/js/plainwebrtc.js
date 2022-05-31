
var conf = { 'iceServers': [{ 'urls': 'stun:stun.l.google.com:19302' },{ 'urls': 'stun:stun1.l.google.com:19302' },{ 'urls': 'stun:stun2.l.google.com:19302' },{ 'urls': 'stun:stun3.l.google.com:19302' },{ 'urls': 'stun:stun4.l.google.com:19302' }] };
var pc = null;


var localVideo = document.getElementById("local");
var remoteVideo = document.getElementById("remote");

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


var myLocalDescription = '';
var localStream = null;
var inboundStream = null;
// var startButton = document.getElementById('startButton');
// startButton.addEventListener('click', start);

pc = new RTCPeerConnection(conf);
setEvents();


// function localFileVideoPlayer() {

	
//    var playSelectedFile = function(event) {
//    var file = this.files[0]
//    var URL = window.URL || window.webkitURL 
//    var fileURL = URL.createObjectURL(file)
//    var videoNode = document.querySelector('video')
//    videoNode.src = fileURL
//    }
//   var inputNode = document.querySelector('input')
//   inputNode.addEventListener('change', playSelectedFile, false)
// }


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



function TestGetUserMedia(deviceId) {

    if (!deviceId) {
        return navigator.mediaDevices.enumerateDevices().then(function(devices) {
            var newDevice = devices.filter(function(device) {
                return device.kind === 'videoinput';
            }).find(function(device, idx) {
                return device.deviceId !== 'default';
            });

            localDeviceId = newDevice ? newDevice.deviceId : null;
            return TestGetUserMedia(localDeviceId || 'default');
        });
    }

    console.debug('TestGetUserMedia', deviceId);
    return navigator.mediaDevices.getUserMedia({
        /*
        video: true,
        */
        video: {
            deviceId: deviceId,

            /*
            width: {
                max: 1280,
                min: 640
            },
            height: {
                max: 720,
                min: 480
            },
            */
                                               /*
            height: {
                ideal: 240,
                min: 180,
                max: 480
            },
                                                */
            //facingMode: 'environment'
            //height: 480,
            //width: 1280,
            //height: 720,
            //width: 1280,
            //height: 960,
            //aspectRatio: 16/9,
            //aspectRatio: 11/9,
            //aspectRatio: 4/3,
            //frameRate:{ min: 30.0, max: 30.0 }
        },
        audio: true
        /*
        video: {
          // Test Back Camera
          //deviceId: 'com.apple.avfoundation.avcapturedevice.built-in_video:0'
          //sourceId: 'com.apple.avfoundation.avcapturedevice.built-in_video:0'
          deviceId: {
            exact: 'com.apple.avfoundation.avcapturedevice.built-in_video:0'
          }
        },
        audio: {
          deviceId: {
            exact: 'Built-In Microphone'
          }
        }*/
    })
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

async function start() {
	console.log('Requesting local stream');
	
	  
	try {
	  const stream = await TestGetUserMedia();
	  console.log('Received local stream');
	  localVideo.srcObject = stream;
	  localStream = stream;

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



localVideo.addEventListener('loadedmetadata', function(e) {

	alert(JSON.stringify(this));
	
	//alert('Local video videoWidth:'+ this.videoWidth+'  videoHeight:'+ this.videoHeight);

	// if (this.videoWidth > this.videoHeight){
	// 	localVideo.style.removeProperty('width');
	// 	localVideo.style.height = '9.375rem';
	// 	localVideo.style.transform = "rotate(-90deg)";
	// }



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
	localVideo.style.display = 'flex';



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
			remoteVideo.style.display = 'flex';
			hangupButton.disabled = false;
			callButton.disabled = true;

		remoteVideo.srcObject = ev.streams[0];
		//remoteVideo.style.display = 'block';
		ev.track.applyConstraints(constraints)


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
