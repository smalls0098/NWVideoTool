Pod::Spec.new do |s|
  s.name     = 'NWVideoTool'
  s.version  = '0.1.0'
  s.license  =  { :type => 'MIT', :file => 'LICENSE' }
  s.summary  = 'A NWVideoTool.'
  s.homepage = 'https://github.com/smalls0098/NWVideoTool'
  s.authors   = { 'smalls' => 'smalls0098@gmail.com' }
  s.source   = { :git => 'https://github.com/smalls0098/NWVideoTool.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '9.0'

  s.description   = 'video tool'
  s.swift_version = ['5.0']
  s.frameworks    = 'UIKit', 'AVFoundation'
  s.source_files  = 'NWVideoTool/Classes/**/*'
  
  s.resource_bundles = {
     'NWVideoTool' => ['NWVideoTool/Assets/**/*.png']
  }
  
end
