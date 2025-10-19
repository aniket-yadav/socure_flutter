import 'socure_docv_error.dart';

/// Represents the result of a Socure DocV verification flow.
///
/// This is a sealed result type that can be either a [SocureDocVSuccess]
/// or a [SocureDocVFailure].
///
/// Example usage:
/// ```dart
/// final result = await SocureFlutter().launchDocV(options);
///
/// if (result.isSuccess) {
///   print('Success: ${result.success!.deviceSessionToken}');
/// } else {
///   print('Error: ${result.failure!.errorMessage}');
/// }
///
/// // Or use when method:
/// result.when(
///   success: (data) => print('Token: ${data.deviceSessionToken}'),
///   failure: (error) => print('Error: ${error.errorMessage}'),
/// );
/// ```
sealed class SocureDocVResult {
  const SocureDocVResult();

  /// Returns true if this result is a success.
  bool get isSuccess => this is SocureDocVSuccess;

  /// Returns true if this result is a failure.
  bool get isFailure => this is SocureDocVFailure;

  /// Gets the success result, or null if this is a failure.
  SocureDocVSuccess? get success {
    if (this is SocureDocVSuccess) {
      return this as SocureDocVSuccess;
    }
    return null;
  }

  /// Gets the failure result, or null if this is a success.
  SocureDocVFailure? get failure {
    if (this is SocureDocVFailure) {
      return this as SocureDocVFailure;
    }
    return null;
  }

  /// Executes the appropriate callback based on the result type.
  T when<T>({
    required T Function(SocureDocVSuccess success) success,
    required T Function(SocureDocVFailure failure) failure,
  }) {
    final self = this;
    if (self is SocureDocVSuccess) {
      return success(self);
    } else if (self is SocureDocVFailure) {
      return failure(self);
    } else {
      throw StateError('Unknown SocureDocVResult type');
    }
  }
}

/// Represents a successful document verification result from Socure DocV SDK.
///
/// When document verification completes successfully, this object contains
/// the device session token that can be used to fetch detailed verification
/// results from your backend via Socure's ID+ API.
final class SocureDocVSuccess extends SocureDocVResult {
  /// The device session token returned by Socure SDK.
  /// Use this token to fetch verification results from your backend.
  final String deviceSessionToken;

  const SocureDocVSuccess({
    required this.deviceSessionToken,
  });

  /// Creates a [SocureDocVSuccess] from a map received from the platform channel.
  factory SocureDocVSuccess.fromMap(Map<String, dynamic> map) {
    return SocureDocVSuccess(
      deviceSessionToken: map['deviceSessionToken'] as String,
    );
  }

  /// Converts this success object to a map.
  Map<String, dynamic> toMap() {
    return {
      'deviceSessionToken': deviceSessionToken,
    };
  }

  @override
  String toString() {
    return 'SocureDocVSuccess(deviceSessionToken: ${deviceSessionToken.substring(0, 10)}...)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SocureDocVSuccess &&
        other.deviceSessionToken == deviceSessionToken;
  }

  @override
  int get hashCode => deviceSessionToken.hashCode;
}

/// Represents a failed document verification result from Socure DocV SDK.
///
/// When document verification fails, this object contains the error type,
/// error message, and optionally a device session token if the session was
/// partially created before the failure.
final class SocureDocVFailure extends SocureDocVResult {
  /// The type of error that occurred.
  final SocureDocVErrorType errorType;

  /// Detailed error message from the native SDK.
  final String errorMessage;

  /// Optional device session token if the session was created before failure.
  /// This may be present for certain error types like user cancellation.
  final String? deviceSessionToken;

  const SocureDocVFailure({
    required this.errorType,
    required this.errorMessage,
    this.deviceSessionToken,
  });

  /// Creates a [SocureDocVFailure] from a map received from the platform channel.
  factory SocureDocVFailure.fromMap(Map<String, dynamic> map) {
    final errorCode = map['errorCode'] as String? ?? 'UNKNOWN';
    return SocureDocVFailure(
      errorType: SocureDocVErrorTypeExtension.fromCode(errorCode),
      errorMessage: map['errorMessage'] as String? ?? 'Unknown error occurred',
      deviceSessionToken: map['deviceSessionToken'] as String?,
    );
  }

  /// Converts this failure object to a map.
  Map<String, dynamic> toMap() {
    return {
      'errorCode': errorType.toString().split('.').last,
      'errorMessage': errorMessage,
      if (deviceSessionToken != null) 'deviceSessionToken': deviceSessionToken,
    };
  }

  /// Gets a user-friendly error message.
  String get userFriendlyMessage => errorType.message;

  @override
  String toString() {
    return 'SocureDocVFailure(errorType: $errorType, '
        'errorMessage: $errorMessage, '
        'deviceSessionToken: $deviceSessionToken)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SocureDocVFailure &&
        other.errorType == errorType &&
        other.errorMessage == errorMessage &&
        other.deviceSessionToken == deviceSessionToken;
  }

  @override
  int get hashCode =>
      errorType.hashCode ^ errorMessage.hashCode ^ deviceSessionToken.hashCode;
}
