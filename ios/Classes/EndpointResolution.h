//
//  EndpointResolution.h
//  STUNios
//
//  Created by michael russell on 2017-08-12.
//  Copyright © 2017 ThumbGenius Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"

@interface EndpointResolution : NSObject
typedef void (^completeFuncType)(NSMutableArray* data);

@property (retain, nonatomic) NSMutableArray* data;
@property (copy, nonatomic) completeFuncType complete;

- (void)fetchEndpoints:(void (^)(NSMutableArray* data))complete;
-(void) registerApp: (NSString*) uuid _ip:(NSString*) ip _port:(NSString*) port;

@end
