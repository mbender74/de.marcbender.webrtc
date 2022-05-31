//
//  EndpointResolution.m
//  STUNios
//
//  Created by michael russell on 2017-08-12.
//  Copyright © 2017 ThumbGenius Software. All rights reserved.
//

#import "EndpointResolution.h"
#import <Availability.h>
#import <TargetConditionals.h>
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"

#if TARGET_OS_IPHONE
#else
#endif

@implementation EndpointResolution
@synthesize data=_data;

-(id) init
{
    self = [super init];
    return self;
}

- (void)fetchEndpoints:(void (^)(NSMutableArray* data))complete
{
    self.complete=complete;

//#if TARGET_OS_IPHONE
//    AppDelegate *appdel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//#else
//    AppDelegate *appdel = (AppDelegate *)[NSApp delegate];
//#endif

    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:@"http://thumbgenius.dynalias.com/stun/stun.php?cmd=get"]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                if (!error)
                {
                    NSError *JSONError = nil;
                    
                    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                               options:0
                                                                                 error:&JSONError];
                    if (JSONError)
                    {
                        // NSLog(@"Serialization error: %@", JSONError.localizedDescription);
                    }
                    else
                    {
                      //  // NSLog(@"Response: %@ myuuid=%@", dictionary, appdel.uuid);
                        
                        self->_data = [NSMutableArray arrayWithArray:[dictionary objectForKey:@"endpoints"]];
                        
//                        // remove our own uuid if it's there
//                        for (NSDictionary * dict in self->_data) {
//                            if ([[dict objectForKey:@"uuid"] isEqualToString: appdel.uuid])
//                            {
//                                // NSLog(@"removing our own UUID");
//                                [_data removeObject:dict];
//                                break;
//                            }
//                        }
                        
                        if (self.complete)
                        {
                            self.complete(self->_data);
                        }

                    }
                }
                else
                {
                    // NSLog(@"Error: %@", error.localizedDescription);
                }
            }] resume];
}

-(void) registerApp: (NSString*) uuid _ip:(NSString*) ip _port:(NSString*) port
{
    
    NSString *urlstr=[NSString stringWithFormat:@"http://thumbgenius.dynalias.com/stun/stun.php?cmd=set&uuid=%@&ip=%@&port=%@",
                      [uuid stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]],
                      [ip stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]],
                      [port stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]
                      ];
    
    // NSLog(@"%@", urlstr);
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:urlstr]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                if (!error)
                {
                    NSError *JSONError = nil;
                    
                    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                               options:0
                                                                                 error:&JSONError];
                    if (JSONError)
                    {
                        // NSLog(@"Serialization error: %@", JSONError.localizedDescription);
                    }
                    else
                    {
                        // NSLog(@"Response: %@", dictionary);
                        
                    }
                }
                else
                {
                    // NSLog(@"Error: %@", error.localizedDescription);
                }
                
                
            }] resume];
    
}

@end
