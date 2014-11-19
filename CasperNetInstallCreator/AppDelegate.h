//
//  AppDelegate.h
//  CasperNetInstallCreator
//
//  Created by Justin Feiock on 3/20/14.
//  Copyright (c) 2014 JAMF Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CasperNetinstallOptions.h"
#import "Creator.h"
#import "../OS.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

// outlets for parameters from the interface
@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *imageSourcePath;
@property (weak) IBOutlet NSTextField *casperSourcePath;
@property (strong) IBOutlet NSWindow *advancedPanel;
@property (weak) IBOutlet NSButton *casperPreferenceFile;
@property (weak) IBOutlet NSTextField *jssAddress;
@property (weak) IBOutlet NSTextField *imageName;
@property (weak) IBOutlet NSTextField *imageIndex;
@property (weak) IBOutlet NSButton *imageEnabled;
@property (weak) IBOutlet NSButton *defaultImage;
@property (weak) IBOutlet NSButton *compressImage;
@property (weak) IBOutlet NSButton *imageChooseButton;
@property (weak) IBOutlet NSButton *casperChooseButton;
@property (weak) IBOutlet NSTextFieldCell *pathToImageSource;
@property (weak) IBOutlet NSTextField *imageNameTextBox;
@property (weak) IBOutlet NSTextField *imageIndexTextBox;
@property (weak) IBOutlet NSTextFieldCell *casperImagingApp;
@property (weak) IBOutlet NSTextField *ipNameofJSS;
@property (weak) IBOutlet NSButton *createButton;
@property (weak) IBOutlet NSToolbar *toolbar;
@property (weak) IBOutlet NSMenuItem *openFileItem;
@property (weak) IBOutlet NSMenuItem *saveFileItem;


// outlets for output to interface
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSProgressIndicator *progressBar;
@property (weak) IBOutlet NSTextField *progressBarText;
@property (weak) IBOutlet NSTextField *progressText;


// processing variables
@property CasperNetinstallOptions *options;


// method callbacks for other places in the application
-(void) prepareProgressBar;
-(void) prepareProgressIndicator;
-(void) updateProgressPercent:(double)progress;
-(void) updateProgressText:(NSString *)progress;
-(void) updateProgressBarText:(NSString *)progress;
-(void) displayCommandError;
- (IBAction)onOpen:(id)sender;
-(void)creationComplete;





@end
