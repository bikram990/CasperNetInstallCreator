//
//  AppDelegate.m
//  CasperNetInstallCreator
//
//  Created by Justin Feiock on 3/20/14.
//  Copyright (c) 2014 JAMF Software. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize imageSourcePath;
@synthesize casperSourcePath;
@synthesize advancedPanel;
@synthesize casperPreferenceFile;
@synthesize jssAddress;
@synthesize options;
@synthesize imageName;
@synthesize imageIndex;
@synthesize imageEnabled;
@synthesize defaultImage;
@synthesize compressImage;
@synthesize casperChooseButton;
@synthesize imageChooseButton;
@synthesize pathToImageSource;
@synthesize imageIndexTextBox;
@synthesize imageNameTextBox;
@synthesize ipNameofJSS;
@synthesize casperImagingApp;
@synthesize toolbar;
@synthesize createButton;
@synthesize openFileItem;
@synthesize saveFileItem;

@synthesize progressIndicator;
@synthesize progressBar;
@synthesize progressBarText;
@synthesize progressText;


- (IBAction)advancedOptionsAction:(id)sender {
    
    
    [NSApp beginSheet:advancedPanel modalForWindow:[NSApp mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
    [NSApp runModalForWindow:advancedPanel];
    [NSApp endSheet:advancedPanel];
    [advancedPanel orderOut:self];
}
- (IBAction)chooseImageFile:(id)sender {
        imageSourcePath.stringValue = [self retrieveFilePath];
        [self fieldChanged:sender];
    
}
- (IBAction)chooseCasperFile:(id)sender {
        casperSourcePath.stringValue = [self retrieveFilePath];
        [self fieldChanged:sender];
    
}
- (IBAction)casperPreferenceChanged:(id)sender {
        if(casperPreferenceFile.state == NSOnState){
            [jssAddress setEnabled:YES];
        } else {
            [jssAddress setEnabled:NO];
        }
    
}

- (NSString *)retrieveFilePath {
    
    NSString *filePath = @"";
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        filePath = [[panel URL] path];
    }
    
    return filePath;
}
- (IBAction)quitApplication:(id)sender {
    if(![imageChooseButton isEnabled]){
        // our application is busy...make sure the user really wants to quit
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:@"Casper NetIntstall Creator is busy."];
        [alert setInformativeText:@"Would you like to quit anyway?"];
        [alert setAlertStyle:NSWarningAlertStyle];
        
        [alert beginSheetModalForWindow:[NSApp mainWindow] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
        
    } else {
        // we can quit safely without prompting the user
        [[NSApplication sharedApplication] terminate:self];
    }
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) {
        [[NSApplication sharedApplication] terminate:self];
    }
}

- (IBAction)fieldChanged:(id)sender {
    
    [self updateOptions];
    dispatch_async(dispatch_get_main_queue(), ^{
        [createButton setEnabled:[options readyToCreate]];
    });
   
}

- (IBAction)create:(id)sender {
    
    
    // now need to prompt the user for a save window
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setDirectoryURL:[NSURL URLWithString:@"/Library/NetBoot/NetBootSP0"]];
    [panel setNameFieldStringValue:![imageName.stringValue isEqualToString:@""] ? [imageName.stringValue stringByAppendingString:@".nbi"] : @"Casper.nbi"];
    NSInteger clicked = [panel runModal];
    if (clicked == NSFileHandlingPanelOKButton) {
        options.nbiFolderRoot = [[[panel URL] path] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
    
    
    
        // hook up the remaining inputs to our options
        [self updateOptions];
    
        // connect to the model and begin the process
        // Use a thread to ensure that the GUI is reachable
        // and renderable
        
        //[NSThread detachNewThreadSelector:@selector(modifyImageWithOptions:) toTarget:creator withObject:options];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            Creator *creator = [[Creator alloc] init];
            [creator modifyImageWithOptions:options];
        });
    
        // Disable all the fields and boxes
        [self toggleFieldEnabledState:NO];
    }
    
}

-(void)updateOptions{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        options.imagePath = [imageSourcePath.stringValue stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
        options.imageName = imageName.stringValue;
        options.index = imageIndex.stringValue;
        options.enableImage = imageEnabled.state == NSOnState;
        options.defaultImage = defaultImage.state == NSOnState;
        options.compressImage = compressImage.state == NSOnState;
        options.casperImagingPath = casperSourcePath.stringValue;
        options.jssAddress = jssAddress.stringValue;
        options.createPreferenceFile = casperPreferenceFile.state == NSOnState;
    });

   
}

-(void) toggleFieldEnabledState:(BOOL)state{
    dispatch_async(dispatch_get_main_queue(), ^{
        [imageSourcePath setEnabled:state];
        [casperImagingApp setTextColor:state == YES ? [NSColor blackColor] : [NSColor disabledControlTextColor]];
        [casperSourcePath setEnabled:state];
        [casperPreferenceFile setEnabled:state];
        [openFileItem setEnabled:state];
        [saveFileItem setEnabled:state];
        [imageName setEnabled:state];
        [imageIndex setEnabled:state];
        [imageEnabled setEnabled:state];
        [defaultImage setEnabled:state];
        [compressImage setEnabled:state];
        [jssAddress setEnabled:casperPreferenceFile.state == NSOnState ? state: NO];
        [imageChooseButton setEnabled:state];
        [casperChooseButton setEnabled:state];
        [pathToImageSource setTextColor:state == YES ? [NSColor blackColor] : [NSColor disabledControlTextColor]];
        [imageNameTextBox setTextColor:state == YES ? [NSColor blackColor] : [NSColor disabledControlTextColor]];
        [imageIndexTextBox setTextColor:state == YES ? [NSColor blackColor] : [NSColor disabledControlTextColor]];
        [createButton setEnabled:state == YES ? [options readyToCreate] : state];
        for (NSToolbarItem *item in [toolbar items]){
            [item setEnabled:state];
        }
        [ipNameofJSS setTextColor:state == YES ? [NSColor blackColor] : [NSColor disabledControlTextColor]];
    });
    
    
}

- (IBAction)onOpen:(id)sender {
    [self chooseImageFile:sender];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.options = [[CasperNetinstallOptions alloc] init];
    [self toggleFieldEnabledState:YES];
    [[progressIndicator animator] setHidden:YES];
}

-(void)prepareProgressBar{
    NSLog(@"About to prepare");
    dispatch_async(dispatch_get_main_queue(), ^{
        [progressIndicator stopAnimation:self];
        [[progressIndicator animator] setHidden:YES];
        [progressIndicator setHidden:YES];
        [[progressText animator] setHidden:YES];
        [progressText setHidden:YES];
        [[progressBarText animator] setHidden:NO];
        [progressBar setDoubleValue:0.0];
        [progressBar setHidden:NO];
        [progressBarText setHidden:NO];
        [progressBar setUsesThreadedAnimation:YES];
        [progressBar setIndeterminate:NO];
    });
   
}

-(void) updateProgressPercent:(double)progress{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(progress > 0.0  && progress <= 100.0){
            progressBar.doubleValue = progress;
        }
        [progressBar displayIfNeeded];
        
    });
    
}

-(void) prepareProgressIndicator{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[progressBar animator] setHidden:YES];
        [progressBar setHidden:YES];
        [[progressIndicator animator] setHidden:NO];
        [progressIndicator setHidden:NO];
        [[progressBarText animator] setHidden:YES];
        [progressBarText setHidden:YES];
        [[progressText animator] setHidden:NO];
        [progressText setHidden:NO];
    });
    
}

-(void) updateProgressText:(NSString *)progress {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [progressText setTextColor:[NSColor blackColor]];
        [[progressIndicator animator] setHidden:NO];
        [progressIndicator setHidden:NO];
        [progressIndicator startAnimation:self];
        [[progressText animator] setHidden:NO];
        [progressText setHidden:NO];
        progressText.stringValue = progress;
    });
    
    
}

-(void) updateProgressBarText:(NSString *)progress {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [progressBarText setTextColor:[NSColor blackColor]];
        [progressBarText setHidden:NO];
        progressBarText.stringValue = progress;
    });

}

-(void) displayCommandError{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [progressIndicator stopAnimation:self];
        [[progressIndicator animator] setHidden:YES];
        [progressIndicator setHidden:YES];
        [[progressBarText animator] setHidden:YES];
        [progressBarText setHidden:YES];
        [[progressBar animator] setHidden:YES];
        [progressBar setHidden:YES];
        
        
        [progressText setTextColor:[NSColor redColor]];
        [[progressText animator] setHidden:NO];
        [progressText setHidden:NO];
        NSString *step = progressText.stringValue;
        step = [step stringByReplacingOccurrencesOfString:@"..." withString:@""];
        progressText.stringValue = [@"An error occurred while " stringByAppendingString:[step lowercaseString]];
        
        [self toggleFieldEnabledState:YES];
    });
    
    
}


-(void)creationComplete{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        progressText.stringValue = @"The image was successfully created.";
        [progressIndicator setHidden:YES];
        [self toggleFieldEnabledState:YES];
    });
    
    
    
}

@end
