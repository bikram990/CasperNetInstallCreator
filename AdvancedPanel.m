//
//  AdvancedPanel.m
//  CasperNetInstallCreator
//
//  Created by Justin Feiock on 3/20/14.
//  Copyright (c) 2014 JAMF Software. All rights reserved.
//

#import "AdvancedPanel.h"


@implementation AdvancedPanel

@synthesize imageView;
@synthesize desktopImage;


- (IBAction)cancelPanel:(id)sender {
    desktopImage.stringValue = @"";
    imageView.image = [NSImage imageNamed:@"CasperSuiteDesktop.jpg"];
    [NSApp stopModal];
}


- (IBAction)savePanel:(id)sender {
    // grab access to our delegate
    AppDelegate *delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    // set other advanced parameters
    delegate.options.desktopBackgroundImage = desktopImage.stringValue;
    
    [NSApp stopModal];
}


- (IBAction)chooseBackgroundImage:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        desktopImage.stringValue = [[panel URL] path];
    }
    
    imageView.image = [[NSImage alloc] initWithContentsOfFile:desktopImage.stringValue];
    
    
}


@end
