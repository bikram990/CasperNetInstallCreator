//
//  YosemiteOS.m
//  CasperNetInstallCreator
//
//  Created by Justin Feiock on 10/1/14.
//  Copyright (c) 2014 JAMF Software. All rights reserved.
//

#import "YosemiteOS.h"
#import "Shell.h"

@implementation YosemiteOS


-(id) initWithPath:(NSString *)path andOptions:(CasperNetinstallOptions *)options andVersion:(NSString *)osVersion andMinorVersion:(NSString *)minorOSVersion {
    
    self = [super initWithPath:path andOptions:options andVersion:osVersion andMinorVersion:minorOSVersion];
    
    // for now, this is the only change we need to make
    self.kernelPath = @"/System/Library/Kernels/kernel";
    
    self.minorOSVersion = minorOSVersion;

    return self;
}

-(void)configureLaunchBehavior{
    [super configureLaunchBehavior];
    [super copyPostPreInstallWS];
    //Fix DNS issues where discoveryd was dumped on 10.10.2 and higher
    if (![self.minorOSVersion isEqualToString:@"0"] && ![self.minorOSVersion isEqualToString:@"1"]) {
        NSLog(@"Fixing DNS issues...");
        [Shell execute:[NSString stringWithFormat:@"/bin/rm -rf /private/tmp/Install/System/Library/LaunchDaemons/com.apple.discoveryd.plist"]];
        [Shell execute:[NSString stringWithFormat:@"/bin/rm -rf /private/tmp/Install/System/Library/LaunchDaemons/com.apple.discoveryd_helper.plist"]];
        [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write /private/tmp/Install/System/Library/LaunchDaemons/com.apple.mDNSResponder Disabled -bool NO"]];
        [Shell execute:[NSString stringWithFormat:@"/bin/chmod 644 /private/tmp/Install/System/Library/LaunchDaemons/*"]];
        [Shell execute:[NSString stringWithFormat:@"/usr/sbin/chown root:wheel /private/tmp/Install/System/Library/LaunchDaemons/*"]];
    }
}

@end
