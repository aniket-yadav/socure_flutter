import Flutter
import UIKit
import SocureDocV

public class SocureFlutterPlugin: NSObject, FlutterPlugin {

  private var rootViewController: UIViewController? {
    return UIApplication.shared.keyWindow?.rootViewController
  }

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "socure_flutter", binaryMessenger: registrar.messenger())
    let instance = SocureFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "launchDocV":
      launchDocV(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func launchDocV(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(
        code: "INVALID_ARGUMENTS",
        message: "Invalid arguments provided",
        details: nil
      ))
      return
    }

    guard let sdkKey = args["sdkKey"] as? String, !sdkKey.isEmpty else {
      result(FlutterError(
        code: "INVALID_KEY",
        message: "SDK key is required",
        details: nil
      ))
      return
    }

    guard let transactionToken = args["transactionToken"] as? String, !transactionToken.isEmpty else {
      result(FlutterError(
        code: "INVALID_TOKEN",
        message: "Transaction token is required",
        details: nil
      ))
      return
    }

    guard let viewController = rootViewController else {
      result(FlutterError(
        code: "NO_VIEW_CONTROLLER",
        message: "No view controller available to present DocV",
        details: nil
      ))
      return
    }

    let useSocureGov = args["useSocureGov"] as? Bool ?? false

    // Create Socure DocV options
    let options = SocureDocVOptions(
      publicKey: sdkKey,
      docvTransactionToken: transactionToken,
      presentingViewController: viewController,
      useSocureGov: useSocureGov
    )

    // Launch Socure DocV SDK
    SocureDocVSDK.launch(options) { sdkResult in
      switch sdkResult {
      case .success(let success):
        let resultDict: [String: Any] = [
          "success": true,
          "deviceSessionToken": success.deviceSessionToken ?? ""
        ]
        result(resultDict)

      case .failure(let failure):
        let errorCode = self.mapErrorToCode(failure.error)
        var resultDict: [String: Any] = [
          "success": false,
          "errorCode": errorCode,
          "errorMessage": String(describing: failure.error)
        ]

        // Include deviceSessionToken if available
        if let sessionToken = failure.deviceSessionToken {
          resultDict["deviceSessionToken"] = sessionToken
        }

        result(resultDict)
      }
    }
  }

  private func mapErrorToCode(_ error: SocureDocVError) -> String {
    switch error {
    case .invalidPublicKey:
      return "INVALID_KEY"
    case .invalidDocvTransactionToken:
      return "INVALID_TOKEN"
    case .noInternetConnection:
      return "NETWORK_ERROR"
    case .userCanceled:
      return "USER_CANCELED"
    case .cameraPermissionDeclined:
      return "CAMERA_PERMISSION_DENIED"
    case .sessionExpired:
      return "SESSION_EXPIRED"
    case .sessionInitiationFailure:
      return "INITIALIZATION_ERROR"
    case .documentUploadFailure:
      return "CAPTURE_ERROR"
    case .consentDeclined:
      return "CONSENT_DECLINED"
    case .unknown:
      return "UNKNOWN"
    @unknown default:
      return "UNKNOWN"
    }
  }
}
