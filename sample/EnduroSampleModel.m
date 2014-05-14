//
//  EnduroSampleModel.m
//  sample
//
//  Copyright (c) 2014 Orando Labs. All rights reserved.
//

#import "EnduroSampleModel.h"

static NSString* kLinkClassName = @"link";
static NSString* kPrefsClassName = @"user";
static NSString* kNamespace = @"http://www.example.com/ns/";

static NSString* kApp = @"YOUR APP NAME";
static NSString* kPassword = @"YOUR PASSWORD";
static NSString* kPassphrase = @"YOUR PASSPHRASE";
static NSString* kDeviceId = @"dummydeviceid";//@"A DEVICE ID, CAN BE ANYTHING FOR NOW";
static NSString* kObjectStoreName = @"YOUR OBJECT STORE NAME";
static NSString* kUsername = @"YOUR EMAIL ADDRESS";
static NSString* kAccount = @"YOUR ACCOUNT NUMBER";

@implementation SyncBase

- (void) createEnduroParms {
    self.parms = [[EnduroSyncParameters alloc] init];
    self.parms.app = kApp;
    self.parms.password = kPassword;
    self.parms.passphrase = kPassphrase;
    self.parms.deviceId = kDeviceId;
    self.parms.objectStoreName = kObjectStoreName;
    self.parms.username = kUsername;
    self.parms.account = kAccount;
    [self createEnduroModel];
}

- (void) createEnduroModel {
    self.model = [[EnduroModel alloc] initWithNamespace:kNamespace];
    self.linksClass = [self.model createClass:kLinkClassName withProperties:@[@"url",@"title"] ofType:[LinkObject class]];
    self.prefsClass = [self.model createClass:kPrefsClassName withProperties:@[@"email",@"language",@"age",@"links"] ofType:[PrefsObject class]];
}

- (NSString*) enduroDirectory {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString* documentsDir = [paths objectAtIndex:0];
    return [documentsDir stringByAppendingPathComponent:@"enduro"];
}

- (void) initializeEnduro:(id) syncBaseDelegate {
    self.syncBaseDelegate = syncBaseDelegate;
    
    [self createEnduroParms];
    [self createEnduroModel];
    [EnduroSync createWithDirectory:[self enduroDirectory] ready:^(EnduroSync *sync) {
        self.enduro = sync;
        EnduroSyncClient* client = [sync createClient:self.parms];
        [client openObjectStore:self.parms.objectStoreName withModel:self.model success:^(EnduroObjectStore *store) {
            self.store = store;
            [self syncObjectStore:^{
                [self storeIsOpenAndSynced];
            }];
        } failure:^(EnduroException *ex) {
            NSLog(@"Exception opening object store, Error: %@", ex);
        }];
    }];
}

- (void) syncObjectStore:(void (^)()) done {
    [self.store sync:^(EnduroObjectStore *store) {
        done();
    } failure:^(EnduroException *ex) {
        NSLog(@"Exception syncing object store, Error: %@", ex);
    }];
}

- (void) storeIsOpenAndSynced {
    [PrefsObject objectWithNameRecursive:self.parms.username andClass:self.prefsClass inStore:self.store withBlock:^(EnduroObject *o, Boolean found) {
        self.prefs = (PrefsObject*) o;
        if (!found) {
            self.prefs.age = 44;
            self.prefs.language = @"en";
            self.prefs.email = self.parms.username;
            
            LinkObject* google = (LinkObject*) [LinkObject objectWithClass:self.linksClass inStore:self.store];
            google.title = @"Google";
            google.url = @"http://www.google.com";
            [self.prefs addLink:google];
            
            LinkObject* apple = (LinkObject*) [LinkObject objectWithClass:self.linksClass inStore:self.store];
            apple.title = @"Apple";
            apple.url = @"http://www.apple.com";
            [self.prefs addLink:apple];
            
            [self syncObjectStore:^{
                [self.syncBaseDelegate prefsAreInitialized];
            }];
        } else {
            [self.syncBaseDelegate prefsAreInitialized];
        }
    }];
}

@end

@implementation PrefsObject
@synthesize links = _links;

- (void) syncModified {
    self.links = nil;
}

- (int) age {
    return [self toInt:@"age"];
}

- (void) setAge:(int) age {
    [self setInt:age property:@"age"];
}

- (NSString*) email {
    return [self toString:@"email"];
}

- (void) setEmail:(NSString*) email {
    [self setString:email property:@"email"];
}

- (NSString*) language {
    return [self toString:@"language"];
}

- (void) setLanguage:(NSString*) language {
    [self setString:language property:@"language"];
}

- (NSArray*) links {
    if (_links==nil) {
        _links = [self toArrayOfObjects:@"links"];
    }
    return _links;
}

- (void) addLink:(LinkObject*) link {
    [self.links addObject:link];
    [self addObject:link toProperty:@"links"];
}

- (void) removeLink:(LinkObject*) link {
    [self.links removeObject:link];
    [self removeObject:link fromProperty:@"links"];
}

@end

@implementation LinkObject

- (NSString*) url {
    return [self toString:@"url"];
}

- (void) setUrl:(NSString*) url {
    [self setString:url property:@"url"];
}

- (NSString*) title {
    return [self toString:@"title"];
}

- (void) setTitle:(NSString*) title {
    [self setString:title property:@"title"];
}

@end

