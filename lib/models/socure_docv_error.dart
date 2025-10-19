/// Represents an error type from Socure DocV SDK.
///
/// These error types correspond to the native SDK error codes
/// and provide type-safe error handling in Dart.
enum SocureDocVErrorType {
  /// Invalid SDK key or configuration error.
  invalidKey,

  /// User canceled the verification flow.
  userCanceled,

  /// Network error or no internet connection.
  networkError,

  /// Camera permission was denied by the user.
  cameraPermissionDenied,

  /// Camera initialization or access error.
  cameraError,

  /// Invalid or expired transaction token.
  invalidToken,

  /// Server returned an error response.
  serverError,

  /// SDK initialization failed.
  initializationError,

  /// Document capture failed or timed out.
  captureError,

  /// Unknown or unhandled error.
  unknown,
}

/// Extension to convert error codes to error types.
extension SocureDocVErrorTypeExtension on SocureDocVErrorType {
  /// Gets the error type from a platform error code string.
  static SocureDocVErrorType fromCode(String code) {
    switch (code) {
      case 'INVALID_KEY':
      case 'invalidKey':
        return SocureDocVErrorType.invalidKey;
      case 'USER_CANCELED':
      case 'userCanceled':
        return SocureDocVErrorType.userCanceled;
      case 'NETWORK_ERROR':
      case 'networkError':
        return SocureDocVErrorType.networkError;
      case 'CAMERA_PERMISSION_DENIED':
      case 'cameraPermissionDenied':
        return SocureDocVErrorType.cameraPermissionDenied;
      case 'CAMERA_ERROR':
      case 'cameraError':
        return SocureDocVErrorType.cameraError;
      case 'INVALID_TOKEN':
      case 'invalidToken':
        return SocureDocVErrorType.invalidToken;
      case 'SERVER_ERROR':
      case 'serverError':
        return SocureDocVErrorType.serverError;
      case 'INITIALIZATION_ERROR':
      case 'initializationError':
        return SocureDocVErrorType.initializationError;
      case 'CAPTURE_ERROR':
      case 'captureError':
        return SocureDocVErrorType.captureError;
      default:
        return SocureDocVErrorType.unknown;
    }
  }

  /// Gets a user-friendly error message for this error type.
  String get message {
    switch (this) {
      case SocureDocVErrorType.invalidKey:
        return 'Invalid SDK key. Please check your configuration.';
      case SocureDocVErrorType.userCanceled:
        return 'Verification was canceled by user.';
      case SocureDocVErrorType.networkError:
        return 'Network error. Please check your internet connection.';
      case SocureDocVErrorType.cameraPermissionDenied:
        return 'Camera permission is required for document verification.';
      case SocureDocVErrorType.cameraError:
        return 'Camera error. Please try again.';
      case SocureDocVErrorType.invalidToken:
        return 'Invalid or expired transaction token.';
      case SocureDocVErrorType.serverError:
        return 'Server error. Please try again later.';
      case SocureDocVErrorType.initializationError:
        return 'Failed to initialize SDK. Please try again.';
      case SocureDocVErrorType.captureError:
        return 'Document capture failed. Please try again.';
      case SocureDocVErrorType.unknown:
        return 'An unknown error occurred.';
    }
  }
}
