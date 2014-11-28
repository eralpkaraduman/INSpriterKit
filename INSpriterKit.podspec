Pod::Spec.new do |s|
  s.name             = "INSpriterKit"
  s.version          = "1.0.1"
  s.summary          = "SpriterKit is a Spriter binding for iOS Sprite Kit."
  s.homepage         = "https://github.com/indieSoftware/INSpriterKit"
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = "Sven Korset"

  s.platform         = :ios
  s.ios.deployment_target = '7.0'
  s.requires_arc     = true
  
  s.frameworks       = 'SpriteKit'

  s.dependency 'INLib', '~> 2.1'
  s.dependency 'INSpriteKit', '~> 1.1'
  s.dependency 'RaptureXML', '~> 1.0'
  # Header search path for RaptureXML
  s.xcconfig      = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }
  
  s.source           = { :git => "https://github.com/indieSoftware/INSpriterKit.git", :tag => "1.0.1" }
  s.source_files     = 'INSpriterKit/**/*.{h,m}'

end
