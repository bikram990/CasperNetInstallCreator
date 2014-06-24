//
//  AdvancedPanel.h
//  CasperNetInstallCreator
//
//  Created by Justin Feiock on 3/20/14.
//  Copyright (c) 2014 JAMF Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

@interface AdvancedPanel : NSPanel

// The check box outlets

@property (strong) IBOutlet NSImageView *imageView;

@property (strong) IBOutlet NSTextField *desktopImage;

@end
