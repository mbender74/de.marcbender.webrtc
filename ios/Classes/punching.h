//
//  punching.h
//  DeMarcbenderWebrtc
//
//  Created by Marc Bender on 29.05.19.
//

#import <stdio.h>
#import <stdint.h>
#import <string.h>
#import <pthread.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import "nat_traversal.h"

int doconnection(uint32_t peerid);
//int connectPeer(uint32_t peer_id);
//int myClientID(void);
