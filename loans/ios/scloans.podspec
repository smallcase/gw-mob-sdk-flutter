#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint loans.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'scloans'
  s.version          = '0.0.1'
  s.summary          = 'SCLoans Flutter plugin.'
  s.description      = 'SCLoans Flutter plugin.'
  s.homepage         = 'https://github.com/smallcase/gw-mob-sdk-flutter'
  s.license          = { :file => '../LICENSE' }
  s.authors          = { 'smallcase' => '' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '14.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.dependency 'SCLoans-release-scg-v7-2-1-loans-v7-5-0-37c9f15', '7.5.0-53-release'
end
