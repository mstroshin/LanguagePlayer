platform :ios, '14.1'
use_frameworks!
inhibit_all_warnings!

target 'LanguagePlayer' do
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RxSwiftExt'
  #pod 'RxTimelane', '~> 2.0'
  pod 'RxRealm'
  pod 'RealmSwift'
  pod 'GCDWebServer'
#  pod 'mobile-ffmpeg-full', '~> 4.4'
  pod 'ffmpeg-kit-ios-min', '~> 4.4.LTS'
  pod 'DifferenceKit'
#  pod 'MobileVLCKit', '~>3.3.0'
  pod 'Toast-Swift'
#  pod 'Purchases'
  pod 'ReachabilitySwift'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.1'
#        config.build_settings["ONLY_ACTIVE_ARCH"] = "YES"
      end

#        if target.name == "Pods-LanguagePlayer"
#            puts "Updating #{target.name} OTHER_LDFLAGS"
#            target.build_configurations.each do |config|
#                xcconfig_path = config.base_configuration_reference.real_path
#
#                # read from xcconfig to build_settings dictionary
#                build_settings = Hash[*File.read(xcconfig_path).lines.map{|x| x.split(/\s*=\s*/, 2)}.flatten]
#
#                # modify OTHER_LDFLAGS
#                vlc_flag = ' -framework "MobileVLCKit"'
#                build_settings['OTHER_LDFLAGS'].gsub!(vlc_flag, "")
#                build_settings['OTHER_LDFLAGS'].gsub!("\n", "")
#                build_settings['OTHER_LDFLAGS'] += vlc_flag + "\n"
#
#                # write build_settings dictionary to xcconfig
#                File.open(xcconfig_path, "w") do |file|
#                  build_settings.each do |key,value|
#                    file.write(key + " = " + value)
#                  end
#                end
#            end
#        end
    end
end
