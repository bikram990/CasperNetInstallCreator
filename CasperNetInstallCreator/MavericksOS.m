//
//  MavericksOS.m
//  CasperNetInstallCreator
//
//  Created by Justin Feiock on 9/22/15.
//  Copyright © 2015 JAMF Software. All rights reserved.
//

#import "MavericksOS.h"

@implementation MavericksOS

-(id) initWithPath:(NSString *)path andOptions:(CasperNetinstallOptions *)options andVersion:(NSString *)osVersion andMinorVersion:(NSString *)minorOSVersion{
    
    self = [super initWithPath:path andOptions:options andVersion:osVersion andMinorVersion:minorOSVersion];
    
    return self;
}

-(void)configureLaunchBehavior{
    [super configureLaunchBehavior];
    [super copyPostPreInstallWS];
}

@end
