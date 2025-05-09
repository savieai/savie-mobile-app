//
//  Runner-Bridging-Header.h
//  Runner
//
//  Created manually to fix build issues.
//

#ifndef Runner_Bridging_Header_h
#define Runner_Bridging_Header_h

// Import Flutter-generated plugin header
#import "GeneratedPluginRegistrant.h"

// Include our custom bridge headers
#import "MixpanelBridge.h"
#import "GoogleSignInBridge.h"

// C functions to work around deprecation issues
#ifdef __cplusplus
extern "C" {
#endif

// Legacy C-style accessor for keyWindow to avoid direct keyWindow access
UIWindow* getKeyWindow(void);

// Legacy C-style accessor for rootViewController
UIViewController* getRootViewController(void);

#ifdef __cplusplus
}
#endif

#endif /* Runner_Bridging_Header_h */
