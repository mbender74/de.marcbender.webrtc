//
//  UDPHolePuncher.h
//  STUNios
//
//  Created by michael russell on 2017-08-12.
//  Copyright © 2017 ThumbGenius Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"

@interface UDPHolePuncher : NSObject <GCDAsyncUdpSocketDelegate> {
    GCDAsyncUdpSocket *txSocket;
    
    NSTimer *pokeTimer;

}
@property (retain, nonatomic) NSString* ip;
@property (retain, nonatomic) NSNumber* port;

-(void) startUDPHolePunch:(NSString*) ip _port:(NSNumber*) port;

@end
