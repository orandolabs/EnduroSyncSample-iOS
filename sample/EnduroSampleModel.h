//
//  EnduroSampleModel.h
//  sample
//
//  Copyright (c) 2014 Orando Labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EnduroSync.h"

@interface LinkObject : EnduroObject
@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSString* title;
@end

@interface PrefsObject : EnduroObject
@property (nonatomic, assign) int age;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* language;
@property (nonatomic, strong) NSMutableArray* links;

- (void) addLink:(LinkObject*) link;
@end

@class SyncBase;
@protocol SyncBaseDelegate
- (void) prefsAreInitialized;
@end

@interface SyncBase : NSObject
@property (strong, nonatomic) EnduroSync* enduro;
@property (strong, nonatomic) EnduroModel* model;
@property (strong, nonatomic) PrefsObject* prefs;
@property (strong, nonatomic) EnduroClass* prefsClass;
@property (strong, nonatomic) EnduroClass* linksClass;
@property (strong, nonatomic) EnduroObjectStore* store;
@property (strong, nonatomic) EnduroSyncParameters* parms;
@property (nonatomic, assign) id syncBaseDelegate;

- (void) initializeEnduro:(id) syncBaseDelegate;
@end


