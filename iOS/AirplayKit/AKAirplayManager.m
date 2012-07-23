//
//  AKServiceManager.m
//  AirplayKit
//
//  Created by Andy Roth on 1/18/11.
//  Copyright 2011 Roozy. All rights reserved.
//

#import "AKAirplayManager.h"


@implementation AKAirplayManager

@synthesize delegate, connectedDevice;
@synthesize foundServices = foundServices_;
#pragma mark -
#pragma mark Initialization

- (id) init
{
	if((self = [super init]))
	{
		self.foundServices = [NSMutableArray array];
	}
	
	return self;
}

#pragma mark -
#pragma mark Public Methods

- (void) findDevices
{
	NSLog(@"Finding Airport devices.");
	[self.foundServices removeAllObjects];
	serviceBrowser = [[NSNetServiceBrowser alloc] init];
	[serviceBrowser setDelegate:self];
	[serviceBrowser searchForServicesOfType:@"_airplay._tcp" inDomain:@""];
}

- (void) connectToDevice:(AKDevice *)device
{
	NSLog(@"Connecting to device : %@:%d", device.hostname, device.port);
	
	if(!tempDevice)
	{
		tempDevice = [device retain];
		
		AsyncSocket *socket = [[AsyncSocket alloc] initWithDelegate:self];
		[socket connectToHost:device.hostname onPort:device.port error:NULL];
	}
}

#pragma mark -
#pragma mark Net Service Browser Delegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
	NSLog(@"Found service");
	
	[self.foundServices addObject:aNetService];
	
	if(!moreComing)
	{
		[serviceBrowser stop];
		[serviceBrowser release];
		serviceBrowser = nil;
	}
}

#pragma mark -
#pragma mark Net Service Delegate

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
	NSLog(@"Resolved service: %@:%d", sender.hostName, sender.port);
	
	AKDevice *device = [[AKDevice alloc] init];
	device.hostname = sender.hostName;
	device.port = sender.port;
	
	if(delegate && [delegate respondsToSelector:@selector(manager:didFindDevice:)])
	{
		[delegate manager:self didFindDevice:[device autorelease]];
	}
	
	
    [self connectToDevice:device];
	
}

#pragma mark -
#pragma mark AsyncSocket Delegate

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	NSLog(@"Connected to device.");
	
	AKDevice *device = tempDevice;
	device.socket = sock;
    [sock release];
	device.connected = YES;
	
	self.connectedDevice = device;
	[device release];
	tempDevice = nil;
	
	if(delegate && [delegate respondsToSelector:@selector(manager:didConnectToDevice:)])
	{
		[self.connectedDevice sendReverse];
		[delegate manager:self didConnectToDevice:self.connectedDevice];
	}
}

#pragma mark -
#pragma mark Cleanup

- (void) dealloc
{
	[connectedDevice release];
	[self.foundServices removeAllObjects];
    self.foundServices = nil;
	[super dealloc];
}



- (void)resolveService:(NSNetService*)service withTimeOut:(CGFloat)timeOut {
    [service stop];
    [service setDelegate:self];
	[service resolveWithTimeout:timeOut];

}

@end
