//
//  RawSocketTransport.m
//  MDWamp
//
//  Created by Niko Usai on 05/07/14.
//  Copyright (c) 2014 mogui.it. All rights reserved.
//

#import "MDWampTransportRawSocket.h"
#import "GCDAsyncSocket.h"
@interface MDWampTransportRawSocket () <GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) NSString *host;
@property (nonatomic, assign) NSInteger port;

@end
@implementation MDWampTransportRawSocket

- (id)initWithHost:(NSString*)host port:(NSInteger)port
{
    self = [super init];
    if (self) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:queue];
        self.host = host;
        self.port = port;
        self.serialization = kMDWampSerializationJSON;
        
    }
    return self;
}

- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
    if (_delegate && [_delegate respondsToSelector:@selector(transportDidOpenWithSerialization:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate transportDidOpenWithSerialization:self.serialization];
        });
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    if (err) {
        if (_delegate && [_delegate respondsToSelector:@selector(transportDidFailWithError:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate transportDidFailWithError:err];
            });
        }
    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(transportDidCloseWithError:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate transportDidCloseWithError:nil];
            });
        }
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSRange lRange = NSMakeRange(0, 4);
    NSData *l = [data subdataWithRange:lRange];
    uint32_t *bigEndianLength = (uint32_t *)[l bytes];
    uint32_t length = CFSwapInt32BigToHost(*bigEndianLength);
    
    NSRange contentRange = NSMakeRange(4, length);
    NSData *content = [data subdataWithRange:contentRange];
    if (_delegate && [_delegate respondsToSelector:@selector(transportDidReceiveMessage:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate transportDidReceiveMessage:content];
        });
    }
}

- (void) open
{
    NSError *err = nil;
    if (![_socket connectToHost:self.host onPort:self.port error:&err])
    {
        NSLog(@"I goofed: %@", err);
        return;
    }
}

- (void) close
{
    [_socket disconnect];
}

- (BOOL) isConnected
{
    return [_socket isConnected];
}

- (void)send:(NSData *)data
{
    unsigned int len = (unsigned int)[data length];
    int32_t swapped = CFSwapInt32HostToBig(len);
    NSMutableData *dd = [NSMutableData dataWithBytes:&swapped length:sizeof(unsigned int)];
    [dd appendData:data];
    [_socket writeData:dd withTimeout:0.5 tag:1];
    [_socket readDataWithTimeout:0.5 tag:2];
}

@end
