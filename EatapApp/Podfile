# Uncomment the next line to define a global platform for your project
platform :ios, '14.1'

target 'EatapApp' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'Alamofire'
  pod 'XLPagerTabStrip'
  pod 'Cosmos'
  pod 'SwiftyJSON'
  pod 'FloatingPanel'
  pod 'SwiftKeychainWrapper'
  pod 'AlamofireImage'
  pod 'Firebase/Analytics'
  # Pods for EatapApp

  target 'EatapAppTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'EatapAppUITests' do
    # Pods for testing
  end

end
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.1'
    end
  end
end