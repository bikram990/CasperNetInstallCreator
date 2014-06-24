//
//  OS.m
//  CasperNetInstallCreator
//
//  Created by Justin Feiock on 4/1/14.
//  Copyright (c) 2014 JAMF Software. All rights reserved.
//

#import "OS.h"
#import "Shell.h"

@implementation OS

AppDelegate *delegate;
@synthesize osIdentifier;
@synthesize mountPath;
@synthesize options;

-(id)initWithPath:(NSString *)path andOptions:(CasperNetinstallOptions *)options andVersion:(NSString *)osVersion{
    // grab access to our delegate
    delegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    self.osIdentifier = osVersion;
    self.options = options;
    self.mountPath = options.mountPath;
    return [super init];
}

-(void)create{
    
    // handles common tasks between the OS's
    [self copyLaunchDaemons];
    [self configureLaunchBehavior];
    [self cleanFiles];
    [self OSSpecific];
    
}

-(void)copyLaunchDaemons{
    
    // fix launch Agents
    [delegate updateProgressText:@"Modifying LaunchAgents..."];
    [Shell execute:[NSString stringWithFormat:@"/bin/rm -rf /private/tmp/Install/System/Library/LaunchAgents/*"]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/ditto -rsrc '%@/LaunchAgents.%@' '%@/System/Library/LaunchAgents'", [[NSBundle mainBundle] resourcePath],self.osIdentifier,self.mountPath]];
    [Shell execute:[NSString stringWithFormat:@"/bin/chmod 644 %@/System/Library/LaunchAgents/*", self.mountPath]];
    [Shell execute:[NSString stringWithFormat:@"/usr/sbin/chown root:wheel %@/System/Library/LaunchAgents/*", self.mountPath]];
    [Shell execute:[NSString stringWithFormat:@"/bin/chmod 644 %@/System/Library/LaunchAgents/*", self.mountPath]];
    
    
    // fix launch Daemons
    [delegate updateProgressText:@"Modifying LaunchDaemons..."];
    [Shell execute:[NSString stringWithFormat:@"/bin/rm -rf /private/tmp/Install/System/Library/LaunchDaemons/*"]];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/ditto -rsrc '%@/LaunchDaemons.%@' '%@/System/Library/LaunchDaemons'", [[NSBundle mainBundle] resourcePath], self.osIdentifier, self.mountPath]];
    [Shell execute:[NSString stringWithFormat:@"/bin/chmod 644 %@/System/Library/LaunchDaemons/*", self.mountPath]];
    [Shell execute:[NSString stringWithFormat:@"/usr/sbin/chown root:wheel %@/System/Library/LaunchDaemons/*", self.mountPath]];
    
    
}

-(void)configureLaunchBehavior{
    [delegate updateProgressText:@"Configuring Launch Behavior..."];
    
    // Configure the image to launch in NetInstall Mode
    [Shell execute:[NSString stringWithFormat:@"/bin/mkdir -p -m 755 '%@/System/Installation'", self.mountPath]];
    
    // Copy rc.install
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/ditto -rsrc '%@/rc.install' '%@/private/etc/rc.install'", [[NSBundle mainBundle] resourcePath], self.mountPath]];
    [Shell execute:[NSString stringWithFormat:@"/bin/chmod 755 '%@/private/etc/rc.install'", self.mountPath]];
    [Shell execute:[NSString stringWithFormat:@"/usr/sbin/chown root:wheel '%@/private/etc/rc.install'", self.mountPath]];
    
    // Copy rc.cdrom
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/ditto -rsrc '%@/rc.cdrom' '%@/private/etc/rc.cdrom'", [[NSBundle mainBundle] resourcePath], self.mountPath]];
    [Shell execute:[NSString stringWithFormat:@"/bin/chmod 755 '%@/private/etc/rc.cdrom'", self.mountPath]];
    [Shell execute:[NSString stringWithFormat:@"/usr/sbin/chown root:wheel '%@/private/etc/rc.cdrom'", self.mountPath]];
    
    // Copy rc.cdrom.preWS
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/ditto -rsrc '%@/rc.cdrom.preWS' '%@/private/etc/rc.cdrom.preWS'", [[NSBundle mainBundle] resourcePath], self.mountPath]];
    [Shell execute:[NSString stringWithFormat:@"/bin/chmod 755 '%@/private/etc/rc.cdrom.preWS'", self.mountPath]];
    [Shell execute:[NSString stringWithFormat:@"/usr/sbin/chown root:wheel '%@/private/etc/rc.cdrom.preWS'", self.mountPath]];

    
    // Configure scripts to launch Casper Imaging
    NSString *script = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/rc.cdrom.postWS.Terminal", [[NSBundle mainBundle] resourcePath]] encoding:NSUTF8StringEncoding error:nil];
    script = [NSString stringWithFormat:script, [self.options.appFolderName stringByReplacingOccurrencesOfString:@" " withString:@"\\ "], [self.options.executableName stringByReplacingOccurrencesOfString:@" " withString:@"\\ "]];
    [script writeToFile:[NSString stringWithFormat:@"%@/rc.cdrom.postWS", [[NSBundle mainBundle] resourcePath]] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [Shell execute:[NSString stringWithFormat:@"/usr/bin/ditto -rsrc '%@/rc.cdrom.postWS' '%@/private/etc/rc.cdrom.postWS'", [[NSBundle mainBundle] resourcePath], self.mountPath]];
    
    
    // set the permissions...
    [Shell execute:[NSString stringWithFormat:@"/bin/chmod 755 '%@/private/etc/rc.cdrom.postWS'", self.mountPath]];
    [Shell execute:[NSString stringWithFormat:@"/usr/sbin/chown root:wheel '%@/private/etc/rc.cdrom.postWS'", self.mountPath]];
}



-(void)cleanFiles {
    // Clean files from Mavericks filesystem
    NSMutableArray *filesToDelete = [self getFilesToDelete];
    // Add the mount point of the DMG to the files to delete
    [delegate updateProgressText:@"Optimizing the Image..."];
    for (int i=1; i < [filesToDelete count]; i++) {
        NSString *filePath = [filesToDelete objectAtIndex:i];
        //Escape spaces in any paths so they are handled appropriately
        filePath = [filePath stringByReplacingOccurrencesOfString:@" "
                                                       withString:@"\\ "];
        [Shell execute:[NSString stringWithFormat:@"rm -rf %@%@", self.mountPath, filePath]];
    }
}


// override this method to change the deleted files in a newer OS if needed
-(NSMutableArray *)getFilesToDelete{
    NSMutableArray *filesToDelete = [NSMutableArray arrayWithObjects:
                                     @"/etc/rc.netboot",
                                     @"/Library/Application Support/JAMF",
                                     @"/private/var/db/auth.db-shm",
                                     @"/private/var/db/auth.db-wal",
                                     @"/private/var/db/auth.db",
                                     @"/private/var/db/BootCache.data",
                                     @"/private/var/db/BootCache.playlist",
                                     @"/private/var/db/BootCaches",
                                     @"/private/var/db/CodeEquivalenceDatabase",
                                     @"/private/var/db/DetachedSignatures",
                                     @"/private/var/db/dslocal-backup.xar",
                                     @"/private/var/db/efw_cahce",
                                     @"/private/var/db/kcm-dump.bin",
                                     @"/private/var/db/kcm-dump.uuid",
                                     @"/private/var/db/launchd.db/com.apple.launchd.peruser.*",
                                     @"/private/var/db/launchd.db/com.apple.launchd/*",
                                     @"/private/var/db/lockdown/*",
                                     @"/private/var/db/logsyswrites",
                                     @"/private/var/db/mds",
                                     @"/private/var/db/ntp.drift",
                                     @"/private/var/db/PanicReporter",
                                     @"/private/var/db/receipts",
                                     @"/private/var/db/Spotlight",
                                     @"/private/var/db/sudo",
                                     @"/private/var/db/SystemEntropyCache",
                                     @"/private/var/db/volinfo.database",
                                     @"/private/var/dhcpclient",
                                     @"/private/var/folders/*",
                                     @"/private/var/lib",
                                     @"/private/var/log/*",
                                     @"/private/var/run/*",
                                     @"/private/var/tmp/*",
                                     @"/private/var/vm/*",
                                     @"/Volumes/*",
                                     nil];
    return filesToDelete;
}


// should be only method overriden in an OS subclass
// ex: MavericksOS
-(void)OSSpecific{
    return;
}

@end
