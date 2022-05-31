#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <time.h>
#include <sys/time.h>  
#include <arpa/inet.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <pthread.h>

#include "nat_traversal.h"

#define MAX_PORT 65535
#define MIN_PORT 1025
#define NUM_OF_PORTS 700

#define MSG_BUF_SIZE 512

// file scope variables
static int ports[MAX_PORT - MIN_PORT];

static int send_to_punch_server(client* c) {
    int n = send(c->sfd, c->buf, c->msg_buf - c->buf, 0);
    c->msg_buf= c->buf;

    return n;
}

static int get_peer_info(client* cli, uint32_t peer_id, struct peer_info *peer) {
    cli->msg_buf = encode16(cli->msg_buf, GetPeerInfo);
    cli->msg_buf = encode32(cli->msg_buf, peer_id);
    if (-1 == send_to_punch_server(cli)) {
        return -1;
    }

    int n_bytes = recv(cli->sfd, (void*)peer, sizeof(struct peer_info), 0);
    if (n_bytes <= 0) {
        return -1;
    } else if (n_bytes == 1) {
        // offline
        return 1;
    } else {
        peer->port = ntohs(peer->port);
        peer->type = ntohs(peer->type);

        return 0;
    }
}

static int send_dummy_udp_packet(int fd, struct sockaddr_in addr) {
    char dummy = 'c';

    struct timeval tv = {5, 0};
    setsockopt(fd, SOL_SOCKET, SO_SNDTIMEO, (const char*)&tv, sizeof(tv));
    
    return sendto(fd, &dummy, 1, 0, (struct sockaddr *)&addr, sizeof(addr));
}


static int punch_hole(struct sockaddr_in peer_addr, int ttl) {
    int hole = socket(AF_INET, SOCK_DGRAM, 0);
    if (hole != -1) {
          //struct sockaddr_in local_addr;
          //local_addr.sin_family = AF_INET;
          //local_addr.sin_addr.s_addr = htonl(INADDR_ANY);
          //local_addr.sin_port = htons(DEFAULT_LOCAL_PORT + 1); 
          //int reuse_addr = 1;
          //setsockopt(hole, SOL_SOCKET, SO_REUSEADDR, (const char*)&reuse_addr, sizeof(reuse_addr));
          //if (bind(hole, (struct sockaddr *)&local_addr, sizeof(local_addr))) {
          //    if (errno == EADDRINUSE) {
          //        // NSLog(@"addr already in use, try another port\n");
          //        return -1; 
          //    }   
          //}

        /* TODO we can use traceroute to get the number of hops to the peer
         * to make sure this packet woudn't reach the peer but get through the NAT in front of itself
         */
        setsockopt(hole, IPPROTO_IP, IP_TTL, &ttl, sizeof(ttl));

        // send short ttl packets to avoid triggering flooding protection of NAT in front of peer
        if (send_dummy_udp_packet(hole, peer_addr) < 0) {
            return -1;
        }
    }

    return hole;
}

static int wait_for_peer(int* socks, int sock_num, struct timeval *timeout) {
    fd_set fds;  
    int max_fd = 0;
    FD_ZERO(&fds);

    int i;
    for (i = 0; i < sock_num; ++i) {
        FD_SET(socks[i], &fds);
        if (socks[i] > max_fd) {
            max_fd = socks[i];
        }
    }
    int ret = select(max_fd + 1, &fds, NULL, NULL, timeout);

    int index = -1;
    if (ret > 0) {
        for (i = 0; i < sock_num; ++i) {
            if (FD_ISSET(socks[i], &fds)) {
                index = i;
                break;
            }
        }
    } else {
        // timeout or error
    }

    // one of the fds is ready, close others
    if (index != -1) {
        for (i = 0; i < sock_num; ++i) {
            if (index != i) {
                close(socks[i]);
            }
        }

        return socks[index];
    }

    return -1;
}

static void shuffle(int *num, int len) {
    srand(time(NULL));

    // Fisher-Yates shuffle algorithm
    int i, r, temp;
    for (i = len - 1; i > 0; i--) {
        r = rand() % i;

        temp = num[i];
        num[i] = num[r];
        num[r] = temp;
    }
}

static int connect_to_symmetric_nat(client* c, uint32_t peer_id, struct peer_info remote_peer) {
    // TODO choose port prediction strategy

    /* 
    * according to birthday paradox, probability that port randomly chosen from [1024, 65535] 
    * will collide with another one chosen by the same way is 
    * p(n) = 1-(64511!/(64511^n*64511!))
    * where '!' is the factorial operator, n is the number of ports chosen.
    * P(100)=0.073898
    * P(200)=0.265667
    * P(300)=0.501578
    * P(400)=0.710488
    * P(500)=0.856122
    * P(600)=0.938839
    * but symmetric NAT has port sensitive filter for incoming packet
    * which makes the probalility decline dramatically. 
    * Moreover, symmetric NATs don't really allocate ports randomly.
    */  
    struct sockaddr_in peer_addr;

    peer_addr.sin_family = AF_INET;
    peer_addr.sin_addr.s_addr = inet_addr(remote_peer.ip);

    int *holes = (int*)malloc(NUM_OF_PORTS * sizeof(int));
    shuffle(ports, MAX_PORT - MIN_PORT + 1);

    int i = 0;
    for (; i < NUM_OF_PORTS;) {
        uint16_t port = ports[i];
        if (port != remote_peer.port) { // exclude the used one
            peer_addr.sin_port = htons(port);

            if ((holes[i] = punch_hole(peer_addr, c->ttl)) < 0) {
                // NAT in front of us wound't tolerate too many ports used by one application
               // verbose_log("failed to punch hole, error: %s\n", strerror(errno));
                break;
            }
            // sleep for a while to avoid flooding protection
            usleep(1000 * 100);
            ++i;
        } else {
            ports[i] = ports[1000];
            continue;
        }
    }

    // hole punched, notify remote peer via punch server
    c->msg_buf = encode16(c->msg_buf, NotifyPeer);
    c->msg_buf = encode32(c->msg_buf, peer_id);
    send_to_punch_server(c);

    struct timeval timeout={100, 0};
    int fd = wait_for_peer(holes, i, &timeout);
    if (fd > 0) {
        on_connected(fd);
    } else {
        int j = 0;
        for (; j < i; ++j) {
            close(holes[j]);
        }
     //   // NSLog(@"timout, not connected\n");
    }

    return 0;
}

// run in another thread
static void* server_notify_handler(void* data) {
    int server_sock = *(int*)data;
    struct peer_info peer;

    // wait for notification 
 //   // NSLog(@"waiting for notification...\n");
    for (; ;) {
        if (recv(server_sock, &peer, sizeof peer, 0) > 0) {
            break;
        }
    }

    peer.port = ntohs(peer.port);
    peer.type = ntohs(peer.type);

  //  // NSLog(@"recved command, ready to connect to %s:%d\n", peer.ip, peer.port);

    struct sockaddr_in peer_addr;

    peer_addr.sin_family = AF_INET;
    peer_addr.sin_addr.s_addr = inet_addr(peer.ip);

    int sock_array[NUM_OF_PORTS];
    int i = 0;

    shuffle(ports, MAX_PORT - MIN_PORT + 1);
    // send probe packets, check if connected with peer, if yes, stop probing
    for (; i < NUM_OF_PORTS;) {
        if (ports[i] == peer.port) {
            ports[i] = ports[1000]; // TODO
            continue;
        }
        if ((sock_array[i] = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
         //   // NSLog(@"failed to create socket, send %d probe packets\n", i);
            break;
        }

        peer_addr.sin_port = htons(ports[i]);

        // let OS choose available ports
        if (send_dummy_udp_packet(sock_array[i], peer_addr) < 0) {
        //    // NSLog(@"may trigger flooding protection\n");
            break;
        }

        // wait for a while
        struct timeval tv = {0, 1000 * 100};
        int fd = wait_for_peer(sock_array, ++i, &tv);
        if (fd > 0) {
            // connected
            on_connected(fd);

            // TODO
            return NULL;
        }
    }

  //  // NSLog(@"holes punched, waiting for peer\n");
    struct timeval tv = {100, 0};
    int fd = wait_for_peer(sock_array, i, &tv);
    if (fd > 0) {
        on_connected(fd);
    } else {
        int j = 0;
        for (j = 0; j < i; ++j) {
            close(sock_array[j]);
        }
    }

    // TODO wait for next notification

    return NULL;
}

int enroll(struct peer_info self, struct sockaddr_in punch_server, client* c) {
    int i, temp;
    for (i = 0, temp = MIN_PORT; temp <= MAX_PORT; i++, temp++) {
        ports[i] = temp;
    }
    
    int server_sock = socket(AF_INET, SOCK_STREAM, 0);
    
    if (connect(server_sock, (struct sockaddr *)&punch_server, sizeof(punch_server)) < 0) {
      //  printf("failed to connect to punch server\n");
        
        return -1;
    }
    
    c->sfd = server_sock;
    c->msg_buf = c->buf;
    c->msg_buf = encode16(c->msg_buf, Enroll);
    c->msg_buf = encode(c->msg_buf, self.ip, 16);
    c->msg_buf = encode16(c->msg_buf, self.port);
    c->msg_buf = encode16(c->msg_buf, self.type);
    
    if (-1 == send_to_punch_server(c)) {
        return -1;
    }
    
    // wait for server reply to get own ID
    uint32_t peer_id = 0;
    struct timeval tv;
    tv.tv_sec = 5;
    tv.tv_usec = 0;
    setsockopt(server_sock, SOL_SOCKET, SO_RCVTIMEO, (const char*)&tv, sizeof(tv));
    int n = recv(server_sock, &peer_id, sizeof(uint32_t), 0);
    if (n != sizeof(uint32_t)) {
        return -1;
    }
    
    c->id = ntohl(peer_id);
    
    return 0;
}

pthread_t wait_for_command(int* server_sock)
{
    // wait for command from punch server in another thread
    pthread_t thread_id;
    pthread_create(&thread_id, NULL, server_notify_handler, (void*)server_sock);

    return thread_id;
}

void on_connected(int sock) {
    char buf[MSG_BUF_SIZE] = {0};
    struct sockaddr_in remote_addr;
    socklen_t fromlen = sizeof remote_addr;
    recvfrom(sock, buf, MSG_BUF_SIZE, 0, (struct sockaddr *)&remote_addr, &fromlen);
 //   // NSLog(@"recv %s\n", buf);

//    // NSLog(@"connected with peer from %s:%d\n", inet_ntoa(remote_addr.sin_addr), ntohs(remote_addr.sin_port));

    // restore the ttl
    int ttl = 64;
    setsockopt(sock, IPPROTO_IP, IP_TTL, &ttl, sizeof(ttl));
    sendto(sock, "hello, peer", strlen("hello, peer"), 0, (struct sockaddr *)&remote_addr, sizeof(remote_addr));
}

int connect_to_peer(client* cli, uint32_t peer_id) {
    struct peer_info peer;
    int n = get_peer_info(cli, peer_id, &peer);
    if (n) {
    //    // NSLog(@"failed to get info of remote peer\n");

        return -1;
    }

   // // NSLog("peer %d: %s:%d, nat type: %s\n", peer_id, peer.ip, peer.port, get_nat_desc(peer.type));

    // choose less restricted peer as initiator
    switch(peer.type) {
        case OpenInternet:
            // todo
            break;
        case FullCone:
            break;
        case RestricNAT:
            // todo
            break;
        case RestricPortNAT:
            // todo 
            break;
        case SymmetricNAT:
            if (cli->type == SymmetricNAT) {
                connect_to_symmetric_nat(cli, peer_id, peer);
            }
            else {
                // todo
            }
            break;
        default:
        //    // NSLog(@"unknown nat type\n");
            return -1;
            // log
    }

    return 0;
}

