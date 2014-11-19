//
//  OS.h
//  CasperNetInstallCreator
//
//  Created by Justin Feiock on 3/21/14.
//  Copyright (c) 2014 JAMF Software. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OS;
@interface Creator : NSObject

// properties used during generation
@property NSString *mountPath;
@property NSString *nbiFolderRoot;
@property OS *os;




// abstract method to be overriden by each subclass
// this may include more abstract methods as we move to
// actual implementation rather than planning
-(void)modifyImageWithOptions:(CasperNetinstallOptions *)options;

@end
