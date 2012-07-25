//
//  AKServiceManager.h
//  AirplayKit
//
//  Created by Andy Roth on 1/18/11.
//  Copyright 2011 Roozy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AKDevice.h"
#import "AsyncSocket.h"

@class AKAirplayManager;

@protocol AKAirplayManagerDelegate <NSObject>

@optional
- (void) manager:(AKAirplayManager *)manager didFindDevice:(AKDevice *)device; // Use - (void) connectToDevice:(AKDevice *)device; to connect to a specific device.
- (void) manager:(AKAirplayManager *)manager didConnectToDevice:(AKDevice *)device; // Once connected, use AKDevice methods to communicate over Airplay.

@end


@interface AKAirplayManager : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate,AKDeviceDelegate>
{
@private
	id <AKAirplayManagerDelegate> delegate;
	NSNetServiceBrowser *serviceBrowser;
	AKDevice *connectedDevice;
	AKDevice *tempDevice;
	NSMutableArray *foundServices_;
}

@property (nonatomic, retain) NSMutableArray *foundServices;
@property (nonatomic, assign) id <AKAirplayManagerDelegate> delegate;

@property (nonatomic, retain) AKDevice *connectedDevice;

- (void) findDevices; // Searches for Airplay devices on the same wifi network.
- (void) connectToDevice:(AKDevice *)device; // Connects to a found device.
- (void)resolveService:(NSNetService*)service withTimeOut:(CGFloat)timeOut;

@end
