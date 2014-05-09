//
//  EnduroSampleAppDelegate.h
//  sample
//
//  Copyright (c) 2014 Orando Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EnduroSampleModel.h"

@interface EnduroSampleAppDelegate : UIResponder <UIApplicationDelegate, SyncBaseDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SyncBase* syncBase;
@end
