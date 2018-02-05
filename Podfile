# Uncomment this line to define a global platform for your project
use_frameworks!
pod 'SwiftyBeaver'
pod 'SBObjectiveCWrapper'

target 'Password Factory'  do
    platform :osx, '10.12'
    pod 'ZXCVBN'
    pod 'MASShortcut'

end

target 'Password Factory iOS'  do
    
    platform :ios, '10.0'
    pod 'ZXCVBN'
    pod 'SwiftHSVColorPicker'

end

target 'Password Factory Widget' do
    platform :osx, '10.12'
    pod 'ZXCVBN'
    pod 'MASShortcut'
end;

target 'Password FactoryTests' do
    platform :osx, '10.12'
    pod 'OCMock'
    pod 'MASShortcut'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.2'
        end
    end
end

