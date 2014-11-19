//
//  Shell.h
//  CasperNetInstallCreator
//
//  Created by Justin Feiock on 4/1/14.
//  Copyright (c) 2014 JAMF Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Shell : NSObject

+(NSString *)execute:(NSString *)command;

@property AuthorizationRef authref;

@end
