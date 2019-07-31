Pod::Spec.new do |spec|

  spec.name         = "Flex"
  spec.version      = "2.2.1"
  spec.summary      = "Take care for managing the localization in realtime."

  spec.description  = <<-DESC
    Add and change your localizations in CMS web page and see the changes almost immediately in your app. 
                   DESC

  spec.homepage     = "https://github.com/upnetix/Flex-ios"

  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.author             = { "Upnetix" => "office@upnetix.com" }

  spec.ios.deployment_target = "9.3"

  spec.source       = { :http => 'https://github.com/upnetix/Flex-ios/raw/master/Flex.zip' }

  spec.preserve_paths = "localizer_download.sh", "Flex.framework/*", "Flex.framework"

  spec.ios.vendored_frameworks = "Flex.framework", "CryptoSwift.framework"

end
