//
//  DeprecationFixes.swift
//  Runner
//
//  Created to fix iOS 13+ deprecation issues
//

import UIKit

// Extension to handle various iOS 13+ deprecations
@objc public class DeprecationFixes: NSObject {
    
    @objc public static func setup() {
        // Register for notifications
    }
    
    // Helper to get the key window safely in iOS 13+
    @objc public static var keyWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .first?.windows
                .first(where: { $0.isKeyWindow })
        } else {
            return UIApplication.shared.keyWindow
        }
    }
    
    // Helper to get root view controller safely
    @objc public static var rootViewController: UIViewController? {
        return keyWindow?.rootViewController
    }
    
    // Helper for status bar style (deprecated in iOS 13+)
    @objc public static var statusBarStyle: UIStatusBarStyle {
        get {
            if #available(iOS 13.0, *) {
                return keyWindow?.windowScene?.statusBarManager?.statusBarStyle ?? .default
            }
            return UIApplication.shared.statusBarStyle
        }
        set {
            // No-op, cannot be set in iOS 13+
        }
    }
    
    // Helper for status bar visibility (deprecated in iOS 13+)
    @objc public static var isStatusBarHidden: Bool {
        get {
            if #available(iOS 13.0, *) {
                return keyWindow?.windowScene?.statusBarManager?.isStatusBarHidden ?? false
            }
            return UIApplication.shared.isStatusBarHidden
        }
        set {
            // No-op, cannot be set in iOS 13+
        }
    }
}

// Extension to UIApplication for better iOS 13+ support
extension UIApplication {
    // Helper to open URLs in a way that works on both iOS versions
    @objc public func openURLSafely(_ url: URL, options: [UIApplication.OpenExternalURLOptionsKey: Any] = [:], completionHandler: ((Bool) -> Void)? = nil) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: options, completionHandler: completionHandler)
        } else {
            let success = UIApplication.shared.openURL(url)
            completionHandler?(success)
        }
    }
}

// Extension for activity indicator view compatibility
extension UIActivityIndicatorView.Style {
    @available(iOS, deprecated: 13.0, message: "Use medium or large")
    public static var whiteLarge: UIActivityIndicatorView.Style {
        if #available(iOS 13.0, *) {
            return .large
        }
        return .whiteLarge
    }
    
    @available(iOS, deprecated: 13.0, message: "Use medium with appropriate color")
    public static var white: UIActivityIndicatorView.Style {
        if #available(iOS 13.0, *) {
            return .medium
        }
        return .white
    }
    
    @available(iOS, deprecated: 13.0, message: "Use medium with appropriate color")
    public static var gray: UIActivityIndicatorView.Style {
        if #available(iOS 13.0, *) {
            return .medium
        }
        return .gray
    }
} 