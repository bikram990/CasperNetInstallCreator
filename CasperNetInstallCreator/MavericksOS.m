//
//  MavericksOS.m
//  CasperNetInstallCreator
//
//  Created by Justin Feiock on 9/22/15.
//  Copyright © 2015 JAMF Software. All rights reserved.
//

#import "MavericksOS.h"

@implementation MavericksOS

-(id) initWithPath:(NSString *)path andOptions:(CasperNetinstallOptions *)options andVersion:(NSString *)osVersion {
    
    self = [super initWithPath:path andOptions:options andVersion:osVersion];
    
    return self;
}

-(void)configureLaunchBehavior{
    [super configureLaunchBehavior];
    [super copyPostPreInstallWS];
}

@end
