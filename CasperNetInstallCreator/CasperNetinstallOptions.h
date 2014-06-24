//
//  CasperNetinstallOptions.h
//  CasperNetInstallCreator
//
//  Created by Justin Feiock on 3/21/14.
//  Copyright (c) 2014 JAMF Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CasperNetinstallOptions : NSObject

// advacced privileges data parameters
@property BOOL allowCasperImaging;
@property BOOL allowTheJSS;
@property BOOL allowFinder;
@property BOOL allowShutDown;
@property BOOL allowRestart;
@property BOOL allowTerminal;
@property BOOL allowDiskUtility;
@property BOOL allowConsole;
@property BOOL allowActivityMonitor;
@property BOOL allowSystemPreferences;

// other advanced data parameters
@property NSString *desktopBackgroundImage;
@property NSInteger quitBehavior;

// basic data parameters
@property NSString *imagePath;
@property NSString *imageName;
@property NSString *index;
@property BOOL enableImage;
@property BOOL defaultImage;
@property BOOL compressImage;
@property NSString *casperImagingPath;
@property BOOL createPreferenceFile;
@property NSString *jssAddress;
@property NSString *nbiFolderRoot;
@property NSString *mountPath;

-(BOOL)readyToCreate; // validates the paramters and returns true if enough accurate information was given to begin the creation process

// values for the custom executable passed in
@property NSString *executableName;
@property NSString *appFolderName;

@end
