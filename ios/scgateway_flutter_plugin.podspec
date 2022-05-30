#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint scgateway_flutter_plugin.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'scgateway_flutter_plugin'
  s.version          = '0.0.1'
  s.summary          = 'Scgateway Flutter plugin.'
  s.description      = <<-DESC
Scgateway Flutter plugin.
                       DESC
  s.homepage         = 'https://github.com/smallcase/gw-mob-sdk-flutter'
  s.license          = { :file => '../LICENSE' }
  s.authors          = { "smallcase" => "mobile@smallcase.com" }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'SCGateway', '3.1.19'
  s.xcconfig = {'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES'}
  s.vendored_frameworks = 'SCGateway.framework'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.swift_version = '5.0'
end
