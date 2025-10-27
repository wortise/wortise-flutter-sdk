Pod::Spec.new do |s|
  s.authors =
  {
    'Wortise' => 'hello@wortise.com'
  }

  s.name     = 'wortise'
  s.version  = '1.8.0'
  s.summary  = 'Wortise SDK plugin for Flutter'
  s.homepage = 'https://wortise.com'

  s.license =
  {
    :text => 'Copyright Wortise. All Rights Reserved.',
    :type => 'Copyright'
  }

  s.source       = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.platform     = :ios, '12.0'

  s.dependency 'Flutter'
  s.dependency 'WortiseSDK', '1.8.0-alpha.2'

  # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64' }
  s.swift_version = '5.0'

  s.static_framework = true
end
