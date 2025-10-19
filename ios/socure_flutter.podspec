#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint socure_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'socure_flutter'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for Socure DocV SDK - Document Verification and KYC.'
  s.description      = <<-DESC
A Flutter plugin that wraps the Socure DocV SDK for iOS and Android, enabling document verification and KYC functionality.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'SocureDocV', '5.2.7'
  s.dependency 'SocureDeviceRisk', '~> 4.5.2'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # Privacy manifest for camera and photo library access
  s.resource_bundles = {'socure_flutter_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
