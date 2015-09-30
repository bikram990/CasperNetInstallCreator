//
//  CapitanOS.m
//  CasperNetInstallCreator
//
//  Created by Justin Feiock on 9/22/15.
//  Copyright © 2015 JAMF Software. All rights reserved.
//

#import "CapitanOS.h"
#import "Shell.h"

@implementation CapitanOS

-(id) initWithPath:(NSString *)path andOptions:(CasperNetinstallOptions *)options andVersion:(NSString *)osVersion {
    
    self = [super initWithPath:path andOptions:options andVersion:osVersion];
    
    // for now, this is the only change we need to make
    self.kernelPath = @"/System/Library/Kernels/kernel";
    
    return self;
}

@end
