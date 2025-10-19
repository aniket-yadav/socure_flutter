import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'models/socure_docv_error.dart';
import 'models/socure_docv_options.dart';
import 'models/socure_docv_result.dart';
import 'socure_flutter_platform_interface.dart';

/// An implementation of [SocureFlutterPlatform] that uses method channels.
class MethodChannelSocureFlutter extends SocureFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('socure_flutter');

  @override
  Future<SocureDocVResult> launchDocV(SocureDocVOptions options) async {
    try {
      final result = await methodChannel.invokeMethod<Map<Object?, Object?>>(
        'launchDocV',
        options.toMap(),
      );

      if (result == null) {
        return SocureDocVFailure(
          errorType: SocureDocVErrorType.unknown,
          errorMessage: 'Received null result from native platform',
        );
      }

      // Convert Map<Object?, Object?> to Map<String, dynamic>
      final resultMap = Map<String, dynamic>.from(result);

      // Check if result indicates success or failure
      final isSuccess = resultMap['success'] as bool? ?? false;

      if (isSuccess) {
        return SocureDocVSuccess.fromMap(resultMap);
      } else {
        return SocureDocVFailure.fromMap(resultMap);
      }
    } on PlatformException catch (e) {
      // Handle platform exceptions
      return SocureDocVFailure(
        errorType: _mapPlatformExceptionToErrorType(e.code),
        errorMessage: e.message ?? 'Platform exception: ${e.code}',
      );
    } catch (e) {
      // Handle any other exceptions
      return SocureDocVFailure(
        errorType: SocureDocVErrorType.unknown,
        errorMessage: 'Unexpected error: $e',
      );
    }
  }

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  /// Maps platform exception codes to error types.
  SocureDocVErrorType _mapPlatformExceptionToErrorType(String? code) {
    if (code == null) return SocureDocVErrorType.unknown;

    switch (code.toUpperCase()) {
      case 'INVALID_KEY':
        return SocureDocVErrorType.invalidKey;
      case 'USER_CANCELED':
      case 'USER_CANCELLED':
        return SocureDocVErrorType.userCanceled;
      case 'NETWORK_ERROR':
      case 'NO_INTERNET':
        return SocureDocVErrorType.networkError;
      case 'CAMERA_PERMISSION_DENIED':
      case 'PERMISSION_DENIED':
        return SocureDocVErrorType.cameraPermissionDenied;
      case 'CAMERA_ERROR':
        return SocureDocVErrorType.cameraError;
      case 'INVALID_TOKEN':
      case 'TOKEN_ERROR':
        return SocureDocVErrorType.invalidToken;
      case 'SERVER_ERROR':
      case 'API_ERROR':
        return SocureDocVErrorType.serverError;
      case 'INITIALIZATION_ERROR':
      case 'INIT_ERROR':
        return SocureDocVErrorType.initializationError;
      case 'CAPTURE_ERROR':
      case 'SCAN_ERROR':
        return SocureDocVErrorType.captureError;
      default:
        return SocureDocVErrorType.unknown;
    }
  }
}
