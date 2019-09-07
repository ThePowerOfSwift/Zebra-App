# Uncomment the next line to define a global platform for your project

inhibit_all_warnings!
use_frameworks!

platform :ios, '12.0'
workspace 'Suiteboard.xcworkspace'

def shared_with_all_pods
    pod 'Kickstarter-Prelude'
    pod 'ReactiveSwift', '~> 5.0'
    pod 'Result', '~> 4.1'
end

target 'Suiteboard' do

  # Pods for Suiteboard
  shared_with_all_pods
  pod 'Alamofire', '~> 4.8'
  pod 'AlamofireImage', '~> 3.5.2'
  pod 'CHTCollectionViewWaterfallLayout/Swift'
  pod 'PINRemoteImage'
  pod 'RealmSwift'

  target 'ArenaAPIModels' do
    shared_with_all_pods
    pod 'Argo'
    pod 'Curry'
    pod 'Runes'
  end

  target 'SuiteboardTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SuiteboardUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
