/* global RTCPeerConnection */
// jshint unused:false

//
// Test RTCPeerConnection
//

var peerConnectionConfig = {
    offerToReceiveVideo: true,
    offerToReceiveAudio: true,
    //iceTransportPolicy: 'relay',
    //sdpSemantics: 'unified-plan',
    //sdpSemantics: 'plan-b',
    //bundlePolicy: 'max-compat',
    //rtcpMuxPolicy: 'negotiate',

    iceServers: [
       { 'urls': 'stun:stun.l.google.com:19302' },{ 'urls': 'stun:stun1.l.google.com:19302' },{ 'urls': 'stun:stun2.l.google.com:19302' },{ 'urls': 'stun:stun3.l.google.com:19302' },{ 'urls': 'stun:stun4.l.google.com:19302' }
    ]
};

var peerId = uuid4(),
    peerConnections = {},
    peerConnectionsCandicates = {};

var offerConstraints = {
    offerToReceiveAudio: true,
    offerToReceiveVideo: true
};

var answerConstraints = {
    //iceRestart: true
};

var pc1, pc2;


var useTrackEvent = false; //Object.getOwnPropertyDescriptors(RTCPeerConnection.prototype).ontrack;

function TestRTCPeerConnection(localStream) {

    // Current you cannot reuse previous RTCPeerConnection
    pc1 = new RTCPeerConnection(peerConnectionConfig);
    pc2 = new RTCPeerConnection(peerConnectionConfig);

    peerConnections.pc1 = pc1;
    peerConnections.pc2 = pc2;

    if (useTrackEvent) {

        localStream.getTracks().forEach(function (track) {
          console.log('addTrack', track);
          pc1.addTrack(track);
        });
        
    // Note: Deprecated but supported    
    } else {

        pc1.addStream(localStream);

        // Note: Deprecated Test removeStream
        // pc1.removeStream(pc1.getLocalStreams()[0]);<
    }
    
    function onAddIceCandidate(pc, can) {
        console.log('addIceCandidate', pc, can);
        return can && pc.addIceCandidate(can).catch(function(err) {
            console.log('addIceCandidateError', err);
        });
    }

    pc1.addEventListener('icecandidate', function(e) {
        onAddIceCandidate(pc2, e.candidate);
    });

    pc2.addEventListener('icecandidate', function(e) {
        onAddIceCandidate(pc1, e.candidate);
    });

    if (useTrackEvent) {

        var peerStream;

        pc2.addEventListener('track', function(e) {
            console.log('pc2.track', e);
            var peerStream = e.streams[0] || new MediaStream();
            TestSetPeerStream(peerStream);   
            peerStream.addTrack(e.track);
        });
    } else {

        pc2.addEventListener('addstream', function(e) {
            console.log('pc2.addStream', e);
            TestSetPeerStream(e.stream);
        });
    }

    pc2.addEventListener('removestream', function(e) {
        console.log('pc2.removeStream', e);
    });

    pc1.addEventListener('iceconnectionstatechange', function(e) {
        console.log('pc1.iceConnectionState', e, pc1.iceConnectionState);

        if (pc1.iceConnectionState === 'completed') {
            console.log('pc1.getSenders', pc1.getSenders());
            console.log('pc2.getReceivers', pc2.getReceivers());
        }
    });

    pc1.addEventListener('icegatheringstatechange', function(e) {
        console.log('pc1.iceGatheringStateChange', e);
    });

    // https://stackoverflow.com/questions/48963787/failed-to-set-local-answer-sdp-called-in-wrong-state-kstable
    // https://bugs.chromium.org/p/chromium/issues/detail?id=740501
    var isNegotiating = false;
    pc1.addEventListener('signalingstatechange', function(e) {
        console.log('pc1.signalingstatechange', e);
        isNegotiating = (pc1.signalingState !== "stable");
    });

    pc1.addEventListener('negotiationneeded', function(e) {

        if (isNegotiating) {
            // Should not trigger on iosrtc cause of PluginRTCPeerConnection.swift fix
            console.log("pc1.negotiatioNeeded", "SKIP nested negotiations");
            return;
        }
        isNegotiating = true;

        console.log('pc1.negotiatioNeeded', e);

        return pc1.createOffer().then(function(d) {
            var desc = {
                type: d.type,
                sdp: d.sdp
            };
            console.log('pc1.setLocalDescription', desc);
            return pc1.setLocalDescription(desc);
        }).then(function() {
            var desc = {
                type: pc1.localDescription.type,
                sdp: pc1.localDescription.sdp
            };
            console.log('pc2.setLocalDescription', desc);
            return pc2.setRemoteDescription(desc);
        }).then(function() {
            console.log('pc2.createAnswer');
            return pc2.createAnswer();
        }).then(function(d) {
            var desc = {
                type: d.type,
                sdp: d.sdp
            };
            console.log('pc2.setLocalDescription', desc);
            return pc2.setLocalDescription(d);
        }).then(function() {
            var desc = {
                type: pc2.localDescription.type,
                sdp: pc2.localDescription.sdp
            };
            console.log('pc1.setRemoteDescription', desc);
            return pc1.setRemoteDescription(desc);
        }).then(function() {
            TestControlsOutgoingCall();
        }).catch(function(err) {
            console.log('pc1.createOfferError', err);
        });
    });
}