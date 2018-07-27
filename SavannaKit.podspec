Pod::Spec.new do |s|
  s.name = 'SavannaKit'
  s.version = '0.9.0'
  s.license = 'MIT'
  s.summary = 'A protocol oriented framework for creating IDEs for iOS and macOS, written in Swift.'
  s.homepage = 'https://github.com/louisdh/savannakit'
  s.social_media_url = 'http://twitter.com/LouisDhauwe'
  s.authors = { 'Louis D\'hauwe' => 'louisdhauwe@silverfox.be' }
  s.source = { :git => 'https://github.com/louisdh/savannakit.git', :tag => s.version }
  s.module_name  = 'SavannaKit'

  s.ios.deployment_target = '11.0'
  s.osx.deployment_target  = '10.13'

  s.source_files = 'Sources/**/*.swift'

end
