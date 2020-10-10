platform :ios, '11.4'
require_relative './node_modules/react-native/scripts/react_native_pods'
require_relative './node_modules/@react-native-community/cli-platform-ios/native_modules'

project './UserAgent.xcodeproj'
workspace 'UserAgent'

inhibit_all_warnings!
use_frameworks!

def xclogger
  pod 'XCGLogger', '~> 7.0.0',  :modular_headers => true
end

def fuzi
  pod 'Fuzi', '~> 3.0', :modular_headers => true
end

def sqlite
  pod 'SQLCipher', '~> 4.4.0'
end

def swiftyjson
  pod 'SwiftyJSON', '~> 5.0'
end

def snapkit
  pod 'SnapKit', '~> 5.0.0', :modular_headers => true
end

def sdwebimage
  pod 'SDWebImage', '~> 5.0', :modular_headers => true
end

def gcdwebserver
  pod 'GCDWebServer', '~> 3.3'
end

def sentry
  pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '4.3.1'
end

def swiftlint
  pod 'SwiftLint'
end

def react_native
  config = use_native_modules!
  config['reactNativePath'] = 'node_modules/react-native'
  use_react_native!(:path => config['reactNativePath'])
end

## Definitions for targets

def main_app
  snapkit
  sdwebimage
  swiftyjson
  fuzi
  xclogger
  react_native
  gcdwebserver
end

def firebase
  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'
end

def facebook
  pod 'FBSDKCoreKit/Swift'
end

def extensions
  snapkit
  swiftyjson
  fuzi
end

target 'Gexsi' do
  main_app
  firebase
  facebook
end

target 'Panda' do
  main_app
  firebase
end

target 'SEALEGACYBlue' do
  main_app
  firebase
end

target 'Storage' do
  snapkit
  sdwebimage
  swiftyjson
  fuzi
  xclogger
  sqlite

  target 'StorageTests' do
    inherit! :search_paths
  end
end

target 'ShareTo' do
  extensions
end

target 'OpenIn' do
  extensions
end

target 'StoragePerfTests' do

end

target 'SharedTests' do

end

target 'ClientTests' do
  snapkit
  sdwebimage
  sentry
  gcdwebserver
end

target 'Shared' do
  sdwebimage
  swiftyjson
  sentry
  swiftlint
  xclogger
end

#target 'Today' do
#  react_native
#end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.4'
      config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
    end
  end
end