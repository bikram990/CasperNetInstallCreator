//
//  Shell.m
//  CasperNetInstallCreator
//
//  Created by Justin Feiock on 4/1/14.
//  Copyright (c) 2014 JAMF Software. All rights reserved.
//

#import "Shell.h"
#import "CasperNetinstallCreator/AppDelegate.h"

static AuthorizationRef authref = NULL;

@implementation Shell

+(NSString *)execute:(NSString *)command {
   
    
    // command is the only argument needed in the argument array
    OSStatus status;
    
    // kAuthorizationRightExecute == "system.privilege.admin"
    if(authref == NULL){
        AuthorizationItem item = { kAuthorizationRightExecute, 0, NULL, 0 };
        AuthorizationRights rights = { 1, &item };
        AuthorizationFlags flags = kAuthorizationFlagDefaults|
        kAuthorizationFlagInteractionAllowed |
        kAuthorizationFlagExtendRights;
        
        status = AuthorizationCreate(&rights, kAuthorizationEmptyEnvironment,
                                     flags, &authref);
    } else {
        status = AuthorizationCopyRights(authref, NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, NULL);
    }
    
    if (status != errAuthorizationSuccess)
        NSLog(@"Copy Rights Unsuccessful: %d", status);
    
    // Convert the NSArray into a const array for running command
    const unsigned arrayCount = 2;
    char *charArgs[arrayCount + 1];
    command = [command stringByAppendingString:@""];
    
    charArgs[0] = "-c";
    charArgs[1] = malloc(([command length] + 1) * sizeof(char));
    snprintf(charArgs[1], [command length] + 1, "%s", [command cString]);
    charArgs[2] = NULL;
    
    
    //Run the command
    FILE *pipe = NULL;
    int err;
    
    AppDelegate *controller = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    err = AuthorizationExecuteWithPrivileges(authref, "/bin/sh",
                                             kAuthorizationFlagDefaults, charArgs, &pipe);
    //NSLog(@"ran command %@", fullCommand);
    if([command rangeOfString:@"-puppetstrings"].location == NSNotFound){
        // wait to see the status of the command
        waitpid(-1, &status, 0);
    }
    
    //256 = Command succeeded, but return value shifted too many bits
    //65280 = Same as above
    if ((err != noErr || status != noErr) && status != 65280 && status != 256 && status != 4096 && status != -60008)
    {
        NSLog(@"Error %d %d for command %@", err, status, command);
        
        // Alert the AppDelegate of the Error
        [controller displayCommandError];
        
        // stop the thread from executing any further
        [NSThread exit];
        
        
    } else {
        //Write out the result to a string
        int c;
        NSString *result = @"";
        while ((c = getc(pipe)) != EOF) {
            result = [NSString stringWithFormat:@"%@%c", result, c];
            
            if ([command rangeOfString:@"-puppetstrings"].location != NSNotFound) {
                if (c == '\n') {
//                    NSLog(@"Found result: %@", result);
                    if ([result rangeOfString:@"PERCENT:"].location != NSNotFound) {
                        [controller updateProgressPercent:[[result substringFromIndex:8] doubleValue]];
                    }
                    result = @"";
                }
            }
        }
        close(fileno(pipe));
        return result;
    }
    
    return nil;
}


@end
