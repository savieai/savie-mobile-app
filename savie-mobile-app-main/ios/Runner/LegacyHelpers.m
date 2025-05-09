//
//  LegacyHelpers.m
//  Runner
//
//  Created to provide C-style accessors for deprecated iOS 13 APIs
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Legacy C-style accessor for keyWindow to avoid direct keyWindow access
UIWindow* getKeyWindow(void) {
    if (@available(iOS 13.0, *)) {
        NSArray *scenes = [UIApplication sharedApplication].connectedScenes.allObjects;
        for (UIScene *scene in scenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        return window;
                    }
                }
            }
        }
        // Fallback if no key window found in active scene
        for (UIScene *scene in scenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *window in windowScene.windows) {
                    return window; // Return first window found
                }
            }
        }
        return [[UIApplication sharedApplication] windows].firstObject;
    } else {
        return [UIApplication sharedApplication].keyWindow;
    }
}

// Legacy C-style accessor for rootViewController
UIViewController* getRootViewController(void) {
    return getKeyWindow().rootViewController;
} 