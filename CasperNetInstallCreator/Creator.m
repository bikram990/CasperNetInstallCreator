//
//  OS.m
//  CasperNetInstallCreator
//
//  Created by Justin Feiock on 3/21/14.
//  Copyright (c) 2014 JAMF Software. All rights reserved.
//

#import "../Shell.h"
#import "../OS.h"

@implementation Creator

@synthesize mountPath;
@synthesize nbiFolderRoot;
@synthesize os;

-(id)init {
    self = [super init];
    return self;
}

-(void)modifyImageWithOptions:(CasperNetinstallOptions *)options {
    
    // this will do the common work which is independant of the OS,
    // then spawn off to the overriden methods of each implementation
    // for the OS specific work
    self.nbiFolderRoot = options.nbiFolderRoot;
    self.mountPath = options.mountPath;
    
    // make sure the nbiFolderRoot does not already exist. If it does, delete it.
    if([[NSFileManager defaultManager] fileExistsAtPath:[self.nbiFolderRoot stringByReplacingOccurrencesOfString:@"\\ " withString:@" "]]){
        [Shell execute:[NSString stringWithFormat:@"/bin/rm -rf %@", self.nbiFolderRoot]];
    }
    
    
    // create the NBI structure
    [self updateProgressText:@"Creating .nbi folder..."];
    [Shell execute:[NSString stringWithFormat:@"/bin/mkdir -p -m 755 %@", self.nbiFolderRoot]];
    [Shell execute:[NSString stringWithFormat:@"/usr/sbin/chown root:admin %@", self.nbiFolderRoot]];
    
    
    // convert the image to read/write format
    [self updateProgressBarText:@"Converting image to read/write..."];
    AppDelegate *controller = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [controller prepareProgressBar];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/hdiutil convert -pmap -format UDSP -o %@/Install.dmg.sparseimage %@ -puppetstrings", self.nbiFolderRoot, options.imagePath]];
    [controller prepareProgressIndicator];
    
    [self updateProgressText:@"Finishing Conversion..."];
    //[Shell execute:@"/bin/sleep 10"];
    [Shell execute:[NSString stringWithFormat:@"/bin/chmod 664 %@/Install.dmg.sparseimage", self.nbiFolderRoot]];
    [Shell execute:[NSString stringWithFormat:@"/usr/sbin/chown root:admin %@/Install.dmg.sparseimage", self.nbiFolderRoot]];
    
    
    // mount the DMG we just created
    [self updateProgressText:@"Mounting..."];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/hdiutil attach -readwrite -owners on %@/Install.dmg.sparseimage -mountpoint %@ -nobrowse -noverify -noautofsck", self.nbiFolderRoot, self.mountPath]];
    
    //Determine OS version
    [self updateProgressText:@"Determining Image OS Version..."];
    NSString *osVersion = [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults read %@/System/Library/CoreServices/SystemVersion ProductVersion", self.mountPath]];
    osVersion = [osVersion stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSArray *osVersionArray = [osVersion componentsSeparatedByString:@"."];
    osVersion = [NSString stringWithFormat:@"%@.%@", osVersionArray[0], osVersionArray[1]];
    
    [self createOS:osVersion andOptions:options];

    
    
    // rename the DMG we just mounted
    [self updateProgressText:@"Renaming the DMG..."];
    [Shell execute:[NSString stringWithFormat:@"/usr/sbin/diskutil rename %@ Install", self.mountPath]];
    
    // read the name of the executable from the .app which was sent
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Info.plist", options.casperImagingPath]];
    NSString *executableName = [dict valueForKey:@"CFBundleExecutable"];
    NSURL *file = [NSURL fileURLWithPath:options.casperImagingPath isDirectory:YES];
    NSString *appFolderName = [file lastPathComponent];
    options.appFolderName = appFolderName;
    options.executableName = executableName;
    
    
    // Copy imaging to the disk image
    [self updateProgressText:[NSString stringWithFormat:@"Adding %@...", appFolderName]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/ditto -rsrc '%@' '%@/Applications/%@'", options.casperImagingPath, self.mountPath, appFolderName]];
    [Shell execute:[NSString stringWithFormat:@"/usr/sbin/chown -R root:wheel '%@/Applications/%@'", self.mountPath, appFolderName]];
    [Shell execute:[NSString stringWithFormat:@"/bin/chmod -R 755 '%@/Applications/%@'", self.mountPath, appFolderName]];
    
    
    
    // Create casper preferences file
    if(options.createPreferenceFile) {
        
        options.jssAddress = [Creator urlHelper:options.jssAddress];
        
        [self updateProgressText:@"Creating Casper Preferences File..."];
        
        //Create the Library and Preferences folder for root if it does not exist
        [Shell execute:[NSString stringWithFormat:@"/bin/mkdir -p -m 700 %@/private/var/root/Library/Preferences", self.mountPath]];
        
        //Write the plist
        [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@/private/var/root/Library/Preferences/com.jamfsoftware.jss allowInvalidCertificate -bool NO", self.mountPath]];
        [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@/private/var/root/Library/Preferences/com.jamfsoftware.jss url -string %@", self.mountPath, options.jssAddress]];
        
        NSURL *url = [NSURL URLWithString:options.jssAddress];
        [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@/private/var/root/Library/Preferences/com.jamfsoftware.jss secure -bool %@", self.mountPath, [[url scheme] isEqualTo:@"https"] ? @"YES" : @"NO"]];
        [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@/private/var/root/Library/Preferences/com.jamfsoftware.jss address -string %@", self.mountPath, [url host]]];
        
        // determine the port number
        NSNumber *port = [NSNumber numberWithInt:80];
        if(url.port == nil && [[url scheme] isEqualTo:@"https"]){
            port = [NSNumber numberWithInt:443];
        } else if(url.port != nil){
            port = url.port;
        }
        
        if(options.createPreferenceFile) {
            [self updateProgressText:@"Adding Trust for the JSS CA Cert..."];
            
            [Shell execute:[NSString stringWithFormat:@"/usr/bin/curl -k -o /private/tmp/jamf_ca.cer %@/CA/SCEP?operation=getcacert", options.jssAddress]];
            [Shell execute:[NSString stringWithFormat:@"/usr/bin/security add-trusted-cert -r trustRoot -k '%@/Library/Keychains/System.keychain' -i '%@/Library/Security/Trust Settings/Admin.plist' -o '%@/Library/Security/Trust Settings/Admin.plist' /private/tmp/jamf_ca.cer", self.mountPath, self.mountPath, self.mountPath]];
            
        }
        
        
        [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@/private/var/root/Library/Preferences/com.jamfsoftware.jss port -string %@", self.mountPath, port.stringValue]];
        [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@/private/var/root/Library/Preferences/com.jamfsoftware.jss path -string %@", self.mountPath, url.path]];
        
    }

    
    
    // Modify the OS
    [self.os create];

    
    
    // Create the Casper Netinstall LaunchPad plist and add the LaunchPad application
    if(options.quitBehavior == 0){
        [self updateProgressText:@"Adding LaunchPad Application..."];
        NSLog(@"Running command %@", [NSString stringWithFormat:@"/usr/bin/ditto -rsrc '%@/NetInstall LaunchPad.app' '%@/Applications/NetInstall LaunchPad.app'", [[NSBundle mainBundle] resourcePath], self.mountPath]);
        [Shell execute:[NSString stringWithFormat:@"/usr/bin/ditto -rsrc '%@/NetInstall LaunchPad.app' '%@/Applications/NetInstall LaunchPad.app'", [[NSBundle mainBundle] resourcePath], self.mountPath]];
        [Shell execute:[NSString stringWithFormat:@"/usr/sbin/chown -R root:wheel '%@/Applications/NetInstall LaunchPad.app'", self.mountPath]];
        [Shell execute:[NSString stringWithFormat:@"/bin/chmod -R 755 '%@/Applications/NetInstall LaunchPad.app'", self.mountPath]];
        
        
        [self updateProgressText:@"Creating LaunchPad Preferences File..."];
        NSString *preferenceFilePath = [self.mountPath stringByAppendingString:@"/private/var/root/Library/Preferences/com.jamfsoftware.LaunchPad"];
        [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ allowActivityMonitor -bool %@", preferenceFilePath, options.allowActivityMonitor ? @"YES" : @"NO"]];
        [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ allowCasperImaging -bool %@", preferenceFilePath, options.allowCasperImaging ? @"YES" : @"NO"]];
        [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ allowConsole -bool %@", preferenceFilePath, options.allowConsole ? @"YES" : @"NO"]];
        [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ allowDiskUtility -bool %@", preferenceFilePath, options.allowDiskUtility ? @"YES" : @"NO"]];
        [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ allowFullFinder -bool %@", preferenceFilePath, options.allowFinder ? @"YES" : @"NO"]];
        [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ allowJSS -bool %@", preferenceFilePath, options.allowTheJSS ? @"YES" : @"NO"]];
        [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ allowRestart -bool %@", preferenceFilePath, options.allowRestart ? @"YES" : @"NO"]];
        [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ allowShutDown-bool %@", preferenceFilePath, options.allowShutDown ? @"YES" : @"NO"]];
        [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ allowSystemPreferences -bool %@", preferenceFilePath, options.allowSystemPreferences ? @"YES" : @"NO"]];
        [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ allowTerminal -bool %@", preferenceFilePath, options.allowTerminal ? @"YES" : @"NO"]];
        
    }
    

    
    // Add desktop background
    [self updateProgressText:@"Adding Desktop Background..."];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/ditto -rsrc '%@/Wallpaper.app' '%@/Applications/Wallpaper.app'", [[NSBundle mainBundle] resourcePath], self.mountPath]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/ditto -rsrc '%@' '%@/Applications/Wallpaper.app/Contents/Resources/CasperSuiteDesktop.jpg'", options.desktopBackgroundImage, self.mountPath]];
    [Shell execute:[NSString stringWithFormat:@"/usr/sbin/chown -R root:wheel '%@/Applications/Wallpaper.app'", self.mountPath]];
    [Shell execute:[NSString stringWithFormat:@"/bin/chmod -R 755 '%@/Applications/Wallpaper.app'", self.mountPath]];

    
    
    // Create the booter and kernel files
    [self updateProgressText:@"Creating Booter and Kernel Files..."];
    //Booter
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/ditto -rsrc '%@/usr/standalone/i386/boot.efi' %@/i386/booter", self.mountPath, self.nbiFolderRoot]];
    [Shell execute:[NSString stringWithFormat:@"/bin/chmod 644 '%@/i386/booter'", self.nbiFolderRoot]];
    [Shell execute:[NSString stringWithFormat:@"/usr/sbin/chown root:admin %@/i386/booter", self.nbiFolderRoot]];
    
    //Kernel Cache
    [Shell execute:[NSString stringWithFormat:@"/bin/mkdir -p -m 755 %@/i386/x86_64", self.nbiFolderRoot]];
    [Shell execute:[NSString stringWithFormat:@"/usr/sbin/kextcache -a x86_64 -N -z -K %@/mach_kernel -c %@/i386/x86_64/kernelcache '%@/System/Library/Extensions'", self.mountPath, self.nbiFolderRoot, self.mountPath]];
    [Shell execute:[NSString stringWithFormat:@"/bin/chmod 644 %@/i386/x86_64/kernelcache", self.nbiFolderRoot]];
    [Shell execute:[NSString stringWithFormat:@"/usr/sbin/chown root:wheel %@/i386/x86_64/kernelcache", self.nbiFolderRoot]];
    
    
    [self updateProgressText:@"Unmounting..."];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/hdiutil detach -force '%@'", self.mountPath]];
    
    // Create the NBImageInfo Plist
    [self updateProgressText:@"Creating NBImageInfo.plist..."];
    NSString *NBImageInfoPath = [self.nbiFolderRoot stringByAppendingString:@"/NBImageInfo"];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ Architectures -array i386", NBImageInfoPath]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ BackwardCompatible -bool NO", NBImageInfoPath]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ BootFile -string booter", NBImageInfoPath]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ Index -int '%@'", NBImageInfoPath, options.index]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ IsDefault -bool %@", NBImageInfoPath, options.defaultImage ? @"YES" : @"NO"]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ IsEnabled -bool %@", NBImageInfoPath, options.enableImage ? @"YES" : @"NO"]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ IsInstall -bool YES", NBImageInfoPath]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ Description -string 'Casper NetInstall Image of OS X %@'", NBImageInfoPath, osVersion]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ Kind -int 1", NBImageInfoPath]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ Name -string '%@'", NBImageInfoPath, options.imageName]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ RootPath -string Install.dmg.sparseimage", NBImageInfoPath]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ SupportsDiskless -bool NO", NBImageInfoPath]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ Type -string NFS", NBImageInfoPath]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/plutil -convert xml1 %@.plist", NBImageInfoPath]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ EnabledMACAddresses -array", NBImageInfoPath]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ EnabledSystemIdentifiers -array", NBImageInfoPath]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ DisabledMACAdresses -array", NBImageInfoPath]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ DisabledSystemIdentifiers -array", NBImageInfoPath]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ Language -string Default", NBImageInfoPath]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ imageType -string netinstall", NBImageInfoPath]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/defaults write %@ osVersion -string %@", NBImageInfoPath, osVersion]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/plutil -convert xml1 %@.plist", NBImageInfoPath]];
    [Shell execute:[NSString stringWithFormat:@"/bin/chmod 644 %@.plist", NBImageInfoPath]];
    [Shell execute:[NSString stringWithFormat:@"/usr/sbin/chown root:admin %@.plist", NBImageInfoPath]];
    
    
    // Compress the image
    if (options.compressImage) {
        [self updateProgressBarText:@"Compressing image..."];
        [controller prepareProgressBar];
        [Shell execute:[NSString stringWithFormat:@"/usr/bin/hdiutil compact %@/Install.dmg.sparseimage -puppetstrings", self.nbiFolderRoot]];
        [controller prepareProgressIndicator];
    }

    
    // We're done
    [controller creationComplete];
}

// identify and declare the OS Implementation
-(void)createOS:(NSString*)osVersion andOptions:(CasperNetinstallOptions *)options {
        self.os = [[OS alloc] initWithPath:self.mountPath andOptions:options andVersion:osVersion];
}

-(void)updateProgressText:(NSString *)progress{
    AppDelegate *controller = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [controller updateProgressText:progress];
}

-(void)updateProgressBarText:(NSString *)progress{
    AppDelegate *controller = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    [controller updateProgressBarText:progress];
}

+ (NSString *)urlHelper:(NSString *)baseUrl {
    NSURL *baseUrlAsUrl = [NSURL URLWithString:baseUrl];
    NSString *result = [NSString stringWithString:baseUrl];
    
    // check URL schema
    if (![baseUrl hasPrefix:@"https://"] && ![baseUrl hasPrefix:@"http://"]) {
        result = [NSString stringWithFormat:@"https://%@", result];
        if ([baseUrl rangeOfString:@":8443"].length == 0) {
            if ([baseUrlAsUrl.path rangeOfString:@"/"].location == NSNotFound) {
                result = [NSString stringWithFormat:@"%@:8443", result];
            }
        }
    }
    if (![baseUrl hasSuffix:@"/"]) {
        result = [NSString stringWithFormat:@"%@/", result];
    }
    return result;
}

@end
