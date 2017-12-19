# Uncomment this line to define a global platform for your project



target 'Password Factory'  do
    platform :osx, '10.11'
    pod 'ZXCVBN'
    pod 'MASShortcut'
    pod 'SyncKit'
end

target 'Password Factory iOS'  do
    use_frameworks!
    platform :ios, '10.0'
    pod 'ZXCVBN'
    pod 'SyncKit'
    pod 'SwiftHSVColorPicker'
end

target 'Password Factory Widget' do
    platform :osx, '10.11'
    pod 'ZXCVBN'
    pod 'SyncKit'
end;

target 'Password FactoryTests' do
    platform :osx, '10.11'
	pod 'OCMock'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.2'
        end
    end
end
