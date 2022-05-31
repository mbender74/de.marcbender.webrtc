//
//  UDPHolePuncher.m
//  STUNios
//
//  Created by michael russell on 2017-08-12.
//  Copyright © 2017 ThumbGenius Software. All rights reserved.
//

#import "UDPHolePuncher.h"
#include <stdlib.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <Availability.h>
#import <TargetConditionals.h>
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"

#if TARGET_OS_IPHONE
#else
#endif

@implementation UDPHolePuncher
@synthesize ip=_ip;
@synthesize port=_port;

-(void) startUDPHolePunch:(NSString*) ip _port:(NSNumber*) port
{
//#if TARGET_OS_IPHONE
//    AppDelegate *appdel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//#else
//    AppDelegate *appdel = (AppDelegate *)[NSApp delegate];
//#endif
    _ip=ip;
    _port=port;
    
    
    // NSLog(@"IPADDRESS %@", _ip);
    // NSLog(@"PORT %@", _port);

    
    struct sockaddr_in sockaddr;
    sockaddr.sin_family = AF_INET;
    sockaddr.sin_port = htons([port intValue]);
    inet_pton(AF_INET, [ip UTF8String], &sockaddr.sin_addr);

    [txSocket setDelegate:self];
    
    char ipaddr[32];
    // NSLog(@"%s %s %d", inet_ntop(AF_INET, &sockaddr.sin_addr, ipaddr, 32), [ip UTF8String], [port intValue]);
    
    if (!txSocket.isConnected)
    {
        // bind socket
        NSError *error = nil;
        if (![txSocket bindToPort:0 error:&error]) {
            // NSLog(@"bindToPort error=%@", error);
            //return;
        }
#if 1
        if (![txSocket beginReceiving:&error]){
            // NSLog(@"beginReceiving error=%@", error);
            return;
        }
#endif
    }
    
    // send UDP hole punch hello
    
    NSMutableData *helloData = [NSMutableData data];
    NSString* helloMsg = [NSString stringWithFormat:@"Hello from APP"];
    
    [helloData appendData:[helloMsg dataUsingEncoding:NSUTF8StringEncoding]];
    
    // NSLog(@"Sending hello");
    
    [txSocket sendData:helloData toAddress:[NSData dataWithBytes:&sockaddr length:sizeof(sockaddr)]
                            withTimeout:10 tag:660];


}

-(id) init
{
    self = [super init];

    txSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // we try to receive on our STUN socket
    
    return self;
}

#pragma mark -
#pragma mark GCDAsyncUdpSocketDelegate

/**
 * Called when the socket has received the requested datagram.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
                        fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    
    // NSLog(@"didReceiveData = %@ len=%lu", data, [data length]);
}

/**
 * Called when the datagram with the given tag has been sent.
 **/
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    // NSLog(@"didSendDataWithTag=%ld", tag);
}

@end
