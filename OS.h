//
//  OS.h
//  CasperNetInstallCreator
//
//  Created by Justin Feiock on 4/1/14.
//  Copyright (c) 2014 JAMF Software. All rights reserved.

#import <Foundation/Foundation.h>
#import "AppDelegate.h"


@interface OS : NSObject

@property NSString *osIdentifier; // a string which holds a unique identifier for the OS folder
@property NSString *mountPath;
@property NSString *kernelPath;
@property CasperNetinstallOptions *options;

-(void)create; // calls copyLaunchDaemons and createNetinstallLaunchpad methods at this level, the lower level will call super then do whatever it needs to do
-(id)initWithPath:(NSString *)path andOptions:(CasperNetinstallOptions *)options andVersion:(NSString *)osVersion andMinorVersion:(NSString*)minorOSVersion;
-(void)configureLaunchBehavior;
-(void) copyPostPreInstallWS;


@end
