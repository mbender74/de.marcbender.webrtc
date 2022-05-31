//
//  punching.c
//  DeMarcbenderWebrtc
//
//  Created by Marc Bender on 29.05.19.
//

#import "punching.h"
#import <string.h>
#import <pthread.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#define DEFAULT_SERVER_PORT 9988
#define MSG_BUF_SIZE 512

// use public stun servers to detect port allocation rule
static char *stun_servers[] = {
    "stun.ideasip.com",
    "stun.ekiga.net",
    "203.183.172.196"
};



//int myClientID(void)
//{
//    if (c.sfd){
//        return c.sfd;
//    }
//    else {
//        return 0;
//    }
//}


//int connectPeer(uint32_t peer_id)
//{
//    
//    int clientID = myClientID();
//    
////    if (connect_to_peer(&clientID, peer_id) < 0) {
////
////        return -1;
////    }
//    
//}
//
//                


int doconnection(uint32_t peerid)
{
    char* stun_server = stun_servers[0];
    char local_ip[16] = "0.0.0.0";
    uint16_t stun_port = DEFAULT_STUN_SERVER_PORT;
    uint16_t local_port = DEFAULT_LOCAL_PORT;
    char* punch_server = "5.44.99.22";
    uint32_t peer_id = 0;
    int ttl = 10;
    
    char ext_ip[16] = {0};
    uint16_t ext_port = 0;
    
    // TODO we should try another STUN server if failed
    nat_type type = detect_nat_type(stun_server, stun_port, local_ip, local_port, ext_ip, &ext_port);
    
    // printf("NAT type: %s\n", get_nat_desc(type));
    if (ext_port) {
        //   printf("external address: %s:%d\n", ext_ip, ext_port);
    } else {
        //   return -1;
    }
    
    if (!punch_server) {
        //  printf("please specify punch server\n");
        //  return -1;
    }
    struct peer_info selfpuncher;
    strncpy(selfpuncher.ip, ext_ip, 16);
    selfpuncher.port = ext_port;
    selfpuncher.type = type;
    
    struct sockaddr_in server_addr;
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = inet_addr(punch_server);
    server_addr.sin_port = htons(DEFAULT_SERVER_PORT);
    
    client c;
    c.type = type;
    c.ttl = ttl;
    
    if (enroll(selfpuncher, server_addr, &c) < 0) {
        //  printf("failed to enroll\n");
        
        return -1;
    }
    
    //  printf("enroll successfully, ID: %d\n", c.id);

    
    
        if (peerid) {

          //  printf("connecting to peer %d\n", peer_id);
            if (connect_to_peer(&c, peerid) < 0) {
              //  printf("failed to connect to peer %d\n", peer_id);
    
                return -2;
            }
        }
    
      pthread_t tid = wait_for_command(&c.sfd);
    //
      pthread_join(tid, NULL);
    return 0;
}
