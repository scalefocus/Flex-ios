Pod::Spec.new do |s|
    
s.name             = 'Flexx'
s.version          = '3.0.0'
s.summary          = 'Take care for managing the localization in realtime.'
s.description  = <<-DESC
Add and change your localizations in CMS web page and see the changes almost immediately in your app.
DESC
s.homepage         = 'https://github.com/scalefocus/Flex-ios/'
s.swift_versions    = '5.0'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'Scalefocus' => 'ios@scalefocus.com' }
s.source           = { :git => 'https://github.com/scalefocus/Flex-ios.git', :tag => s.version.to_s }
s.ios.deployment_target = '9.3'
s.source_files = 'Flexx/Classes/**/*'

end