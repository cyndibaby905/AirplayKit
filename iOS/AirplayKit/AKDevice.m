//
//  AKDevice.m
//  AirplayKit
//
//  Created by Andy Roth on 1/18/11.
//  Copyright 2011 Roozy. All rights reserved.
//

#import "AKDevice.h"

NSString *animationArray[] = {@"Dissolve",@"SwipeRight",@"SwipeLeft",@"PageCurl",@"CopyMachine",@"BarsSwipe",@"Ripple",@"Disintegrate",@"Mod",@"Flash"};

@implementation AKDevice

@synthesize hostname, port, delegate, connected, socket,deviceName;
@synthesize imageQuality = _imageQuality;

#pragma mark -
#pragma mark Initialization

- (id) init
{
	if((self = [super init]))
	{
		connected = NO;
		_imageQuality = 0.8;
	}
	
	return self;
}

- (NSString *) displayName
{
	NSString *name = hostname;
	if([hostname rangeOfString:@"-"].length != 0)
	{
		name = [hostname stringByReplacingCharactersInRange:[hostname rangeOfString:@"-"] withString:@" "];
	}
	
	if([name rangeOfString:@".local."].length != 0)
	{
		name = [name stringByReplacingCharactersInRange:[name rangeOfString:@".local."] withString:@""];
	}
	
	return name;
}

#pragma mark -
#pragma mark Public Methods

- (void) sendRawData:(NSData *)data
{
	self.socket.delegate = self;
	[self.socket writeData:data withTimeout:20 tag:1];
	[self.socket readDataWithTimeout:20.0 tag:1];
}

- (void) sendRawData:(NSData *)data needDelegate:(BOOL)isNeed {
    if (isNeed) {
        self.socket.delegate = self;
    }
    else {
        self.socket.delegate = nil;
    }
    [self.socket writeData:data withTimeout:20 tag:1];
	[self.socket readDataWithTimeout:20.0 tag:1];
}


- (void) sendRawMessage:(NSString *)message
{
	if(!okToSend)
	{
		queuedMessage = [message retain];
	}
	
	[self sendRawData:[message dataUsingEncoding:NSUTF8StringEncoding]];
}

- (void) sendRawMessage:(NSString *)message needDelegate:(BOOL)isNeed {
    if(!okToSend)
	{
		queuedMessage = [message retain];
	}
	if (isNeed) {
        [self sendRawData:[message dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else {
     	[self sendRawData:[message dataUsingEncoding:NSUTF8StringEncoding] needDelegate:NO];   
    }
}

- (void) sendContentURL:(NSString *)url
{	
	NSString *body = [[NSString alloc] initWithFormat:@"Content-Location: %@\r\n"
                      "Start-Position: 0\r\n\r\n", url];
	int length = [body length];
	
	NSString *message = [[NSString alloc] initWithFormat:@"POST /play HTTP/1.1\r\n"
                         "Content-Length: %d\r\n"
                         "User-Agent: MediaControl/1.0\r\n\r\n%@", length, body];
	
	
	[self sendRawMessage:message];
	
	[body release];
	[message release];
}

- (void) sendImage:(UIImage *)image forceReady:(BOOL)ready
{
	if(ready) okToSend = YES;
	[self sendImage:image];
}

- (void) sendImage:(UIImage *)image
{
	if(okToSend)
	{
		okToSend = NO;
		
		NSData *imageData = UIImageJPEGRepresentation(image, _imageQuality);
		int length = [imageData length];
        static int i = 0;
        NSString *animationStr = animationArray[i];
        i = (i+1)%(sizeof(animationArray)/sizeof(NSString*));
		NSString *message = [[NSString alloc] initWithFormat:@"PUT /photo HTTP/1.1\r\n"
							 "Content-Length: %d\r\n"
                             "X-Apple-Transition: %@\r\n"
							 "User-Agent: MediaControl/1.0\r\n\r\n", length,animationStr];
        
		NSMutableData *messageData = [[NSMutableData alloc] initWithData:[message dataUsingEncoding:NSUTF8StringEncoding]];
		[messageData appendData:imageData];
		
		// Send the raw data
		[self sendRawData:messageData];
		
		[messageData release];
		[message release];
	}
}

- (void) sendStop
{
	NSString *message = @"POST /stop HTTP/1.1\r\n"
	"User-Agent: MediaControl/1.0\r\n\r\n";
	[self sendRawMessage:message needDelegate:NO];
}

- (void) sendReverse
{
	NSString *message = @"POST /reverse HTTP/1.1\r\n"
	"Upgrade: PTTH/1.0\r\n"
	"Connection: Upgrade\r\n"
	"X-Apple-Purpose: event\r\n"
	"Content-Length: 0\r\n"
	"User-Agent: MediaControl/1.0\r\n\r\n";
	
	[self sendRawData:[message dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark -
#pragma mark Socket Delegate

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *message = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
	if([delegate respondsToSelector:@selector(device:didSendBackMessage:)])
	{
		
		[delegate device:self didSendBackMessage:[message autorelease]];
	}
	
	okToSend = YES;
	
	if(queuedMessage)
	{
		[self sendRawData:[queuedMessage dataUsingEncoding:NSUTF8StringEncoding]];
		[queuedMessage release];
		queuedMessage = nil;
	}
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock {
    if([delegate respondsToSelector:@selector(socketDidDisconnectedWithDevice:)]) {
        [delegate socketDidDisconnectedWithDevice:self];
    }
}


#pragma mark -
#pragma mark Cleanup

- (void) dealloc
{
	[self sendStop];
	self.socket = nil;
    self.hostname = nil;
    self.deviceName = nil;
	[super dealloc];
}

@end