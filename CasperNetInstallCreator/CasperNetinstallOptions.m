//
// CasperNetinstallOptions.m
// CasperNetInstallCreator
//
// Created by Justin Feiock on 3/21/14.
// Copyright (c) 2014 JAMF Software. All rights reserved.
//

#import "CasperNetinstallOptions.h"

@implementation CasperNetinstallOptions

@synthesize allowCasperImaging;
@synthesize allowTheJSS;
@synthesize allowFinder;
@synthesize allowShutDown;
@synthesize allowRestart;
@synthesize allowTerminal;
@synthesize allowDiskUtility;
@synthesize allowConsole;
@synthesize allowActivityMonitor;
@synthesize allowSystemPreferences;

// other advanced parameters
@synthesize desktopBackgroundImage;
@synthesize quitBehavior;

// basic data parameters
@synthesize imagePath;
@synthesize imageName;
@synthesize index;
@synthesize enableImage;
@synthesize defaultImage;
@synthesize compressImage;
@synthesize casperImagingPath;
@synthesize createPreferenceFile;
@synthesize jssAddress;
@synthesize nbiFolderRoot;
@synthesize mountPath;

// values for executable name
@synthesize appFolderName;
@synthesize executableName;

-(id) init {
    self = [super init];
    
    // initialize the properties with their default values
    allowCasperImaging = YES;
    allowTheJSS = YES;
    allowFinder = YES;
    allowShutDown = YES;
    allowRestart = YES;
    allowTerminal = YES;
    allowDiskUtility = YES;
    allowConsole = YES;
    allowActivityMonitor = YES;
    allowSystemPreferences = YES;
    
    // other advanced
    quitBehavior = 2;
    desktopBackgroundImage = [NSString stringWithFormat:@"%@/CasperSuiteDesktop.jpg", [[NSBundle mainBundle] resourcePath]];
    
    // basic parameters don't need to be given default values as they are
    // required to be entered prior to execution
    mountPath = @"/private/tmp/Install";
    
    return self;
}

-(BOOL)readyToCreate{
    // for now, simply verify that both paths are filled in with a value
    return imagePath != nil && casperImagingPath != nil && ![imagePath isEqualToString:@""] && ![casperImagingPath isEqualToString:@""];
}


@end
