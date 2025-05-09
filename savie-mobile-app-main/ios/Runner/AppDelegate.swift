import Flutter
import UIKit
import AVFoundation
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // NOTE: We intentionally do NOT touch AVAudioSession here.
    // The audio session will be configured lazily from Dart via the
    // `setupAudioSession` method-channel call, ensuring the user sees the
    // microphone permission sheet only after they actually tap the mic button.
    
    // Register method channel for audio session reconfiguration if needed
    let controller = window?.rootViewController as? FlutterViewController
    if let messenger = controller?.binaryMessenger {
      let audioChannel = FlutterMethodChannel(name: "com.savie.app/audio_session", binaryMessenger: messenger)
      
      audioChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
        print("[AppDelegate] Got method call: \(call.method)")
        guard let self = self else { return }
        
        if call.method == "setupAudioSession" {
          print("[AppDelegate] setupAudioSession called")
          do {
            let audioSession = AVAudioSession.sharedInstance()
            print("[AppDelegate] AVAudioSession recordPermission: \(audioSession.recordPermission.rawValue)")
            
#if targetEnvironment(simulator)
            print("[AppDelegate] Running on simulator, skipping permission check")
            // Simulators never actually grant mic permission but we still want the
            // Dart side to proceed for UI testing. Pretend everything is fine.
            result(true)
            return
#endif

            // Proactively request permission if status is undetermined so that the
            // alert appears on a simple tap (no gesture in flight).
            if audioSession.recordPermission == .undetermined {
              print("[AppDelegate] Permission undetermined, requesting permission")
              audioSession.requestRecordPermission { granted in
                print("[AppDelegate] Permission dialog result: \(granted)")
                DispatchQueue.main.async {
                  result(granted)
                }
              }
              return // Exit; Dart will call again after user response.
            }

            if audioSession.recordPermission != .granted {
              print("[AppDelegate] Permission not granted, returning false")
              // User previously denied – propagate back so Dart can show guidance.
              result(false)
              return
            }

            print("[AppDelegate] Permission granted, configuring audio session")
            try audioSession.setActive(false)
            try audioSession.setCategory(
              .playAndRecord,
              mode: .default,
              options: [.defaultToSpeaker, .allowBluetooth, .allowAirPlay]
            )
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            // Optional quality tweaks
            try audioSession.setPreferredSampleRate(44100.0)
            try audioSession.setPreferredIOBufferDuration(0.005)
            print("[AppDelegate] Audio session configured successfully")
            result(true)
          } catch {
            print("[AppDelegate] Error configuring audio session: \(error.localizedDescription)")
            print("[AudioChannel] Failed to setup audio session: \(error)")
            result(FlutterError(
              code: "AUDIO_SESSION_ERROR",
              message: "Failed to setup audio session",
              details: error.localizedDescription))
          }
        } else if call.method == "resetPermissions" {
          // Add an explicit permission reset method for Dart code to call
          self.resetPermissionIfNeeded()
          result(true)
        } else if call.method == "checkActualPermission" {
          // Check ACTUAL iOS permission status directly
          let audioSession = AVAudioSession.sharedInstance()
          
          #if targetEnvironment(simulator)
            print("[AppDelegate] Running on simulator, automatically returning true for checkActualPermission")
            result(true)
            return
          #endif

          audioSession.requestRecordPermission { granted in
            DispatchQueue.main.async {
              print("[AppDelegate] Direct iOS permission check result: \(granted)")
              result(granted)
            }
          }
        } else if call.method == "getDeviceModel" {
          // Return device model information to help detect simulator/device
          #if targetEnvironment(simulator)
            result("iOS Simulator")
          #else
            result(UIDevice.current.model)
          #endif
        } else if call.method == "isTestFlightBuild" {
          // Check if we're running in TestFlight
          let isTestFlight = self.isRunningInTestFlight()
          print("[AppDelegate] isTestFlightBuild check: \(isTestFlight)")
          result(isTestFlight)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Check if app is running in TestFlight
  private func isRunningInTestFlight() -> Bool {
    #if DEBUG
      return false // Debug builds are never TestFlight
    #else
      // Check if app is running through TestFlight
      if Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" {
        print("[AppDelegate] TestFlight detected via receipt path")
        return true
      }
      
      // Additional check for TestFlight environment
      if Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") == nil &&
         !isAppStoreValidated() {
        print("[AppDelegate] TestFlight detected via provisioning")
        return true
      }
      
      return false
    #endif
  }
  
  // Check if the app is validated by App Store
  private func isAppStoreValidated() -> Bool {
    if let receiptURL = Bundle.main.appStoreReceiptURL,
       FileManager.default.fileExists(atPath: receiptURL.path) {
      // If we have a receipt and it's not a sandbox receipt, likely from App Store
      return receiptURL.lastPathComponent != "sandboxReceipt"
    }
    return false
  }
  
  // This method ensures iOS will reset and properly request microphone permission
  private func resetPermissionIfNeeded() {
    // Check if this is a fresh install or permission wasn't granted
    let key = "microphone_permission_requested"
    let defaults = UserDefaults.standard
    
    if !defaults.bool(forKey: key) {
      print("[AppDelegate] First launch or fresh install, ensuring permission state is clear")
      
      // Request notification permission to ensure microphone permission isn't cached
      let center = UNUserNotificationCenter.current()
      center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
      
      // Pre-setup for AVCaptureDevice which helps reset permission state
      AVCaptureDevice.requestAccess(for: .audio) { granted in
        print("[AppDelegate] Preemptive audio permission request result: \(granted)")
        defaults.set(true, forKey: key)
      }
      
      // Force AVAudioSession to request permission directly
      let audioSession = AVAudioSession.sharedInstance()
      audioSession.requestRecordPermission { _ in }
    }
  }

  // Comment out scene delegate code as it's not needed for Flutter apps
  /*
  // MARK: - Scene Configuration
  @available(iOS 13.0, *)
  override func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    // Called when a new scene session is being created
    let config = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    config.delegateClass = SceneDelegate.self
    return config
  }
  */
}

// Comment out SceneDelegate as it's not needed for Flutter apps
/*
// Scene Delegate for iOS 13+
@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: windowScene)
    // This will be overridden by Flutter, but it's good to set it
    window?.makeKeyAndVisible()
  }
}
*/
