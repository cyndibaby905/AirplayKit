//
//  AppDelegate_iPhone.h
//  AirplayKit
//
//  Created by Andy Roth on 1/22/11.
//  Copyright 2011 Roozy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AKAirplayManager.h"

@interface AppDelegate_iPhone : NSObject <UIApplicationDelegate, AKAirplayManagerDelegate,UIActionSheetDelegate>
{
    UIWindow *window;
	
	AKAirplayManager *manager;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

- (void) sendRemoteVideo;
- (IBAction)showAvailableSource:(id)sender;
@end

