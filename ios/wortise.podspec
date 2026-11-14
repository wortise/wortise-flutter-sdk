Pod::Spec.new do |s|
  s.authors =
  {
    'Wortise' => 'hello@wortise.com'
  }

  s.name     = 'wortise'
  s.version  = '1.8.3'
  s.summary  = 'Wortise SDK plugin for Flutter'
  s.homepage = 'https://wortise.com'

  s.license =
  {
    :text => 'Copyright Wortise. All Rights Reserved.',
    :type => 'Copyright'
  }

  s.source       = { :path => '.' }
  s.source_files = 'wortise/Sources/wortise/**/*'
  s.platform     = :ios, '15.0'

  s.dependency 'Flutter'
  s.dependency 'WortiseSDK', '1.8.1'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  s.static_framework = true
end
