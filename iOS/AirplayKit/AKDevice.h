//
//  AKDevice.h
//  AirplayKit
//
//  Created by Andy Roth on 1/18/11.
//  Copyright 2011 Roozy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncSocket.h"

@class AKDevice;

@protocol AKDeviceDelegate <NSObject>

@optional

- (void) device:(AKDevice *)device didSendBackMessage:(NSString *)message;
- (void) socketDidDisconnectedWithDevice:(AKDevice *)device;
@end


@interface AKDevice : NSObject <AsyncSocketDelegate>
{
@private
	NSString *hostname;
	UInt16 port;
	id <AKDeviceDelegate> delegate;
	BOOL connected;
	AsyncSocket *socket;
	BOOL okToSend;
	NSString *queuedMessage;
}

@property (nonatomic, readonly) NSString *displayName;
@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, retain) NSString *hostname;
@property (nonatomic) UInt16 port;
@property (nonatomic, assign) id <AKDeviceDelegate> delegate;
@property (nonatomic) BOOL connected; // Set to YES when the device is connected.
@property (nonatomic, retain) AsyncSocket *socket; // The socket used to transmit data. Only use for completely custom actions.
@property (nonatomic) CGFloat imageQuality; // JPEG image quality for sending images. Defaults to 0.8;

- (void) sendRawData:(NSData *)data;
- (void) sendRawData:(NSData *)data needDelegate:(BOOL)isNeed;
- (void) sendRawMessage:(NSString *)message; // Sends a raw HTTP string over Airplay.
- (void) sendRawMessage:(NSString *)message needDelegate:(BOOL)isNeed;
- (void) sendContentURL:(NSString *)url;
- (void) sendImage:(UIImage *)image;
- (void) sendImage:(UIImage *)image forceReady:(BOOL)ready;
- (void) sendStop;
- (void) sendReverse;

@end
