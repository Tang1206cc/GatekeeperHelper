//
//  AuthorizationHelper.m
//  GatekeeperHelper
//
//  Created by 唐梓耀 on 2025/7/25.
//

// AuthorizationTool.m

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import "AuthorizationTool.h"

@implementation AuthorizationTool

+ (BOOL)runCommand:(NSString *)command {
    OSStatus status;
    AuthorizationRef authorizationRef;

    status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &authorizationRef);
    if (status != errAuthorizationSuccess) {
        NSLog(@"Authorization failed to create: %d", status);
        return NO;
    }

    AuthorizationItem right = {kAuthorizationRightExecute, 0, NULL, 0};
    AuthorizationRights rights = {1, &right};
    AuthorizationFlags flags = kAuthorizationFlagDefaults |
                                kAuthorizationFlagInteractionAllowed |
                                kAuthorizationFlagPreAuthorize |
                                kAuthorizationFlagExtendRights;

    status = AuthorizationCopyRights(authorizationRef, &rights, kAuthorizationEmptyEnvironment, flags, NULL);
    if (status != errAuthorizationSuccess) {
        NSLog(@"Authorization failed to obtain rights: %d", status);
        return NO;
    }

    const char *tool = "/bin/sh";
    const char *args[] = {"-c", [command UTF8String], NULL};
    FILE *pipe = NULL;

    status = AuthorizationExecuteWithPrivileges(authorizationRef, tool, kAuthorizationFlagDefaults, (char * const *)args, &pipe);

    if (status != errAuthorizationSuccess) {
        NSLog(@"Command execution failed: %d", status);
        return NO;
    }

    return YES;
}

@end
