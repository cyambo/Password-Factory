# Uncomment this line to define a global platform for your project
target 'Password Factory'  do
    platform :osx, '10.11'
    pod 'ZXCVBN'
    pod 'MASShortcut'
    # pod 'Seam3'
end

target 'Password Factory iOS'  do
    use_frameworks!
    platform :ios, '10.0'
    pod 'ZXCVBN'
    pod 'SwiftHSVColorPicker'
    #pod 'Seam3'
end

target 'Password Factory Widget' do
    platform :osx, '10.11'
    pod 'ZXCVBN'
    #pod 'Seam3'
end;

target 'Password FactoryTests' do
    platform :osx, '10.11'
    pod 'MASShortcut'
	pod 'OCMock'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
#        target.new_shell_script_build_phase.shell_script = "mkdir -p $PODS_CONFIGURATION_BUILD_DIR/#{target.name}"
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.2'
#            config.build_settings['CONFIGURATION_BUILD_DIR'] = '$PODS_CONFIGURATION_BUILD_DIR'
        end
    end
end

