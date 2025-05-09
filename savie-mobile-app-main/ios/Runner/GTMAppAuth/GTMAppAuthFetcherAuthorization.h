//
//  GTMAppAuthFetcherAuthorization.h
//  Runner
//
//  Created manually to fix build issues.
//

#ifndef GTMAppAuthFetcherAuthorization_h
#define GTMAppAuthFetcherAuthorization_h

// Forward declaration for GTMAppAuthFetcherAuthorization
@interface GTMAppAuthFetcherAuthorization : NSObject

// Minimal implementation for building
+ (instancetype)authorizationWithKeychainItemName:(NSString *)keychainItemName;

@end

#endif /* GTMAppAuthFetcherAuthorization_h */ 