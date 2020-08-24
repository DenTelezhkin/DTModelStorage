Pod::Spec.new do |s|
  s.name     = 'DTModelStorage'
  s.version      = "8.1.0"
  s.license  = 'MIT'
  s.summary  = 'Storage classes for datasource based controls.'
  s.homepage = 'https://github.com/DenTelezhkin/DTModelStorage'
  s.social_media_url = 'https://twitter.com/DenTelezhkin'
  s.authors  = { 'Denys Telezhkin' => 'denys.telezhkin.oss@gmail.com' }
  s.source   = { :git => 'https://github.com/DenTelezhkin/DTModelStorage.git', :tag => s.version.to_s }
  s.swift_versions = ['5.3']
  s.ios.deployment_target = '11.0'
  s.tvos.deployment_target = '11.0'
  s.frameworks = 'UIKit', 'Foundation', 'CoreData'

  s.subspec 'Core' do |core|
      core.source_files = 'Sources/DTModelStorage/*.swift'
  end

#  Realm suspec has been temporarily disabled due to compilation issues in Xcode 12 beta.
# Failed CI pod spec lint: https://github.com/DenTelezhkin/DTModelStorage/runs/1019109916?check_suite_focus=true
# Realm related issue: https://github.com/realm/realm-cocoa/issues/6685

  # s.subspec 'Realm' do |realm|
  #     realm.dependency 'DTModelStorage/Core'
  #     realm.dependency 'RealmSwift', '~> 5.2'
  #     realm.source_files = 'Sources/RealmStorage/*.swift'
  # end

  s.default_subspec = 'Core'
end
