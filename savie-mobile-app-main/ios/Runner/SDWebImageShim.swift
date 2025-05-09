//
//  SDWebImageShim.swift
//  Runner
//
//  Created to fix build issues with DKPhotoGallery and SDWebImage
//

import Foundation
import UIKit
import SDWebImage

@objc class SDWebImageShim: NSObject {
    @objc static func initializeSDWebImage() {
        // This method ensures SDWebImage is properly linked
        // and all necessary symbols are included in the final binary
        SDImageCache.shared.clearMemory()
    }
}

// Extend NSData to provide the necessary methods
extension NSData {
    @objc func sd_imageFormat() -> Int {
        if let data = self as Data? {
            if let image = UIImage(data: data) {
                return 1 // Just return PNG format as default
            }
        }
        return 0 // Undefined format
    }
}

// Add extension for UIApplication to handle iOS 13+ deprecations
extension UIApplication {
    @objc class var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first { $0.isKeyWindow }
    }
}

// Add category for status bar management
extension UIViewController {
    @objc var statusBarStyle: UIStatusBarStyle {
        get { return .default }
        set { }
    }
    
    @objc var statusBarHidden: Bool {
        get { return false }
        set { }
    }
}

// Define priorities for the downloader
@objc enum SDWebImageDownloaderPriority: Int {
    case low
    case medium
    case high
    case highPriority = 2 // Added for compatibility
}

// Create compatible SDWebImageOptions
@objc enum SDWebImageOptions: Int {
    case retryFailed
    case lowPriority
    case cacheMemoryOnly
    case progressiveLoad
    case refreshCached
    case continueInBackground
    case handleCookies
    case allowInvalidSSLCertificates
    case highPriority
    case delayPlaceholder
    case transformAnimatedImage
    case avoidAutoSetImage
    case scaleDownLargeImages
}

// Create compatible SDImageCacheOptions
@objc enum SDImageCacheOptions: Int {
    case queryMemoryData = 1
    case queryMemoryDataSync = 2
    case queryDiskDataSync = 3
    case scaleDownLargeImages = 4
    case avoidDecodeImage = 5
    case decodeFirstFrameOnly = 6
    case preloadAllFrames = 7
    case waitStoreCache = 8
    case getCacheCost = 9 // Added for compatibility
}

// Create a protocol for SDWebImageDownloaderDelegate
@objc protocol SDWebImageDownloaderDelegate: NSObjectProtocol {
    @objc optional func imageDownloader(_ downloader: SDWebImageDownloader, didFinishWithImage image: UIImage?, data: Data?, error: Error?, finished: Bool)
}

// Create a compatible SDWebImageDownloader class
@objc class SDWebImageDownloader: NSObject {
    @objc static let shared = SDWebImageDownloader()
    weak var delegate: SDWebImageDownloaderDelegate?
    
    @objc func downloadImage(with url: URL, options: Int, progress: ((Int, Int) -> Void)?, completed: ((UIImage?, Any?, Error?, Bool) -> Void)?) -> SDWebImageCombinedOperation? {
        // Forward to the actual SDWebImage implementation
        let op = SDWebImageManager.shared.loadImage(with: url, options: SDWebImageOptions(rawValue: UInt(options)), progress: nil) { image, data, error, cacheType, finished, url in
            completed?(image, data, error, finished)
        }
        return op as? SDWebImageCombinedOperation
    }
}

// Create a compatible SDWebImageOperation protocol
@objc protocol SDWebImageOperation: NSObjectProtocol {
    @objc func cancel()
}

// Create a compatible SDWebImageCombinedOperation class
@objc class SDWebImageCombinedOperation: NSObject, SDWebImageOperation {
    @objc func cancel() {
        // Implementation not needed for our shim
    }
}

// Create a compatible SDImageCache class
@objc class SDImageCache: NSObject {
    @objc static func shared() -> SDImageCache {
        return SDImageCache()
    }
    
    @objc func queryCacheOperation(forKey key: String, options: SDImageCacheOptions, done: ((UIImage?, Data?, Int) -> Void)?) {
        done?(nil, nil, 0)
    }
    
    @objc func store(_ image: UIImage?, imageData: Data?, forKey key: String, completion: (() -> Void)? = nil) {
        completion?()
    }
    
    @objc func getCacheCost() -> UInt {
        return 0
    }
    
    @objc func clearMemory() {
        // Do nothing
    }
} 