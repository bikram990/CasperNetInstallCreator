//
//  YosemiteOS.m
//  CasperNetInstallCreator
//
//  Created by Justin Feiock on 10/1/14.
//  Copyright (c) 2014 JAMF Software. All rights reserved.
//

#import "YosemiteOS.h"

@implementation YosemiteOS

-(id) initWithPath:(NSString *)path andOptions:(CasperNetinstallOptions *)options andVersion:(NSString *)osVersion {
    
    self = [super initWithPath:path andOptions:options andVersion:osVersion];
    
    // for now, this is the only change we need to make
    self.kernelPath = @"/System/Library/Kernels/kernel";
    
    return self;
}

@end
