//
//  AppDelegate_iPhone.m
//  AirplayKit
//
//  Created by Andy Roth on 1/22/11.
//  Copyright 2011 Roozy. All rights reserved.
//

#import "AppDelegate_iPhone.h"
#import "UIDevice-Hardware.h"

@interface AppDelegate_iPhone () {
    NSTimer *timer_;
    UIImageView *imgView_;
    NSInteger currentAirPlaySourceIndex_;
}
- (void)playSlide;
- (void)stopSlide;
- (void) sendRemoteImage;
@end

@implementation AppDelegate_iPhone

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    // Just Testing
	manager = [[AKAirplayManager alloc] init];
	manager.delegate = self;
	[manager findDevices];
    
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    playBtn.frame = CGRectMake(100, 59, 50, 50);
    [playBtn setTitle:@"play" forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playSlide) forControlEvents:UIControlEventTouchUpInside];
    playBtn.center = CGPointMake(100, 59);
    [self.window addSubview:playBtn];
    
    
    UIButton *stopBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    stopBtn.frame = CGRectMake(100, 59, 50, 50);
    [stopBtn setTitle:@"stop" forState:UIControlStateNormal];
    [stopBtn addTarget:self action:@selector(stopSlide) forControlEvents:UIControlEventTouchUpInside];
    stopBtn.center = CGPointMake(150, 59);
    [self.window addSubview:stopBtn];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void) manager:(AKAirplayManager *)manager didFindDevice:(AKDevice *)device
{
	NSLog(@"Found device. Connecting...");
}

- (void) manager:(AKAirplayManager *)manager didConnectToDevice:(AKDevice *)device
{
	NSLog(@"Connected to device : %@", device.hostname);
	//[self sendRemoteVideo];
}

- (void)playSlide {
    [timer_ invalidate];
    timer_ = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(sendRemoteImage) userInfo:nil repeats:YES];
    [timer_ fire];
}

- (void)stopSlide {
    [timer_ invalidate];
    timer_ = nil;
}

- (void) sendRemoteImage {
    static int i = 0;
    i = (i+1)%10;
    
    if (manager.connectedDevice) {
        if (!imgView_) {
            imgView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 320, 380)];
            imgView_.contentMode = UIViewContentModeScaleAspectFill;
            imgView_.clipsToBounds = YES;
            [self.window addSubview:imgView_];
        }
        imgView_.image = [UIImage imageNamed:[NSString stringWithFormat:@"000%d.jpg",i]];
        [manager.connectedDevice sendImage:[UIImage imageNamed:[NSString stringWithFormat:@"000%d.jpg",i]] forceReady:YES];
    }

}


- (void) sendRemoteVideo
{
	if(manager.connectedDevice) [manager.connectedDevice sendContentURL:@"http://roozy.net/deadman.mp4"];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [manager.connectedDevice sendStop];
    [timer_ invalidate];
    timer_ = nil;
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [manager.connectedDevice sendStop];
    [timer_ invalidate];
    timer_ = nil;
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [timer_ invalidate];
    timer_ = nil;
    [imgView_ release];
    [window release];
    [super dealloc];
}

- (IBAction)showAvailableSource:(id)sender {

   
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:[[UIDevice currentDevice] platformString], nil];
    
    for (NSNetService *service in [manager foundServices]) {
        [actionSheet addButtonWithTitle:service.name];
    }
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel")];
    
    [actionSheet setCancelButtonIndex:actionSheet.numberOfButtons - 1];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.window];  
    [actionSheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.numberOfButtons - 1) {
        currentAirPlaySourceIndex_ = buttonIndex;
        [self stopSlide];
        imgView_.image = nil;
        manager.connectedDevice = nil;
        if (!currentAirPlaySourceIndex_) {
           
        }
        else {
            NSNetService *service = [manager.foundServices objectAtIndex:currentAirPlaySourceIndex_ - 1];
            [manager resolveService:service withTimeOut:20];
        }
    }
    
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
  ;
    
    NSString *serviceName = nil;
    NSString *platformName = [[UIDevice currentDevice] platformString];
    if (currentAirPlaySourceIndex_ && currentAirPlaySourceIndex_ <= [manager foundServices].count) {
        
        
        NSNetService *service = [[manager foundServices] objectAtIndex:currentAirPlaySourceIndex_-1];
        serviceName = service.name;
    }
    
    for (UIView *subView in actionSheet.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            
            UIButton *btn = (UIButton*)subView;
            if ([btn.titleLabel.text isEqualToString:NSLocalizedString(@"Cancel", @"Cancel")]) {
                continue;
            }
            
            UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"airplay_screen"]];
            
            imgView.frame = CGRectMake(10, (btn.frame.size.height - 37)/2, 43, 37);
            [btn addSubview:imgView];
            [imgView release];
            
            
            
            if (!currentAirPlaySourceIndex_) {
                if ([btn.titleLabel.text isEqualToString:platformName]) {
                    UIImageView *tickView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icn-check-black"]];
                    
                    tickView.frame = CGRectMake(btn.frame.size.width - 30, (btn.frame.size.height - 15)/2, 15, 15);
                    [btn addSubview:tickView];
                    [tickView release];
                }
            }
            else {
                if (serviceName) {
                    if ([btn.titleLabel.text isEqualToString:serviceName]) {
                        UIImageView *tickView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icn-check-black"]];
                        
                        tickView.frame = CGRectMake(btn.frame.size.width - 30, (btn.frame.size.height - 15)/2, 15, 15);
                        [btn addSubview:tickView];
                        [tickView release];
                    }
                }
            }
            
            
            
            
        }
    }
    
}


@end
