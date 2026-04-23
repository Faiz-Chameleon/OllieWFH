import Flutter
import UIKit
import GoogleMaps
import UserNotifications
import FirebaseCore
import Flutter
import os


@main
@objc class AppDelegate: FlutterAppDelegate {
  private let timeZoneChannelName = "com.shahwaiz.meditrace/time_zone"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyCsgi7wgsqtBYQCBErgKJpn6AtCmtGdFxE") 
    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: timeZoneChannelName, binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { call, result in
        if call.method == "getIanaTimeZone" {
          let timeZone = TimeZone.current.identifier
          os_log("iOS timezone: %{public}@", log: .default, type: .debug, timeZone)
          result(timeZone)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
